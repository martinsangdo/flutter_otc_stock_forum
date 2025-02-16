import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:otc_stock_forum/entry_point.dart';
import '../../constants.dart';
import 'package:http/http.dart' as http;

import '../../model/database_helper.dart';
import '../../model/metadata_model.dart';
import 'components/onboard_content.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;

  //1. load metadata of project
    void fetchMetadata(http.Client client) async {
      final response = await client.get(Uri.parse(METADATA_URL));
      if (response.statusCode != 200){
        debugPrint('Cannot get metadata from cloud');
        //display something or check if we had metadata in sqlite
        refreshMetaDataWithCloudData(MetaDataModel.empty(uuid: ""));
      } else {
        final metadataObjFromCloud = MetaDataModel.fromJson(jsonDecode(response.body));
        //Query db & compare with latest data from cloud
        refreshMetaDataWithCloudData(metadataObjFromCloud);
      }
    }
    //
  void refreshMetaDataWithCloudData(MetaDataModel metadataObjFromCloud) async{
    //check if table metadata existed
      final metadataInDB = await DatabaseHelper.instance.rawQuery('SELECT * FROM metadata', []);
        if (metadataInDB.isEmpty){
          //there is no metadata in db
          if (metadataObjFromCloud.uuid != ""){
            //insert new
            DatabaseHelper.instance.insertMetadata(metadataObjFromCloud).then((id){
              debugPrint('Inserted metadata into db');
              move2HomePage(metadataObjFromCloud);
            });
          } else {
            //todo: no data from db neither cloud -> should tell them to close app & try again
          }
        } else if (metadataObjFromCloud.uuid != ""){
          debugPrint('Metadata existed in db time: ${metadataInDB[0]['update_time']}');
          //compare update_time
          var updateTimeInDB =  metadataInDB[0]['update_time'];
          var updateTimeInCloud =  metadataObjFromCloud.update_time;
          if (updateTimeInDB != updateTimeInCloud){
            //update metadata in db
            DatabaseHelper.instance.updateMetadata(metadataObjFromCloud).then((id){
              debugPrint('Updated new metadata into db');
              move2HomePage(metadataObjFromCloud);
            });
          } else {
            //do nothing because there is no new info from cloud
            move2HomePage(metadataObjFromCloud);
          }
        } else {
          //do nothing because metadata existed in db & has nothing new from cloud
          move2HomePage(metadataInDB[0]);
        }
  }
  Future<void> move2HomePage(metadataObj) async {
    //save variables to global space
    glb_otc_market_uri = metadataObj.otc_market_uri;
    glb_fin_key = metadataObj.fin_key;
    glb_fin_uri = metadataObj.fin_uri;
    glb_gem_key = metadataObj.gem_key;
    glb_gem_uri = metadataObj.gem_uri;
    glb_avatar_uri = metadataObj.avatar_uri;
    //
    if (!glb_isDebug){
      glb_backend_uri = metadataObj.backend_uri;
    }
    //
    _getAllUsers();
    // WidgetsBinding.instance.addPostFrameCallback((_){
      if (context.mounted) {
        Future.delayed(const Duration(milliseconds: 3000*1000));  //delay screen 3 secs
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const EntryPoint()));
      }
    // });
  }

  //get all users from db
  _getAllUsers() async{
    final response = await http.Client().get(Uri.parse(glb_backend_uri + getAllUsers));
      if (response.statusCode != 200){
        debugPrint('Cannot get users from cloud');
        //todo display something or check if we had metadata in sqlite
      } else {
        Map<String, dynamic> objFromCloud = jsonDecode(response.body);
        for (Map<String, dynamic> item in objFromCloud['data']){
          glb_allUsers[item['usr']!] = item['name']!;
        }
      }
  }

  @override
  void initState() {
      super.initState();
      fetchMetadata(http.Client());
  } 

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Expanded(
              flex: 14,
              child: PageView.builder(
                itemCount: demoData.length,
                onPageChanged: (value) {
                  setState(() {
                    currentPage = value;
                  });
                },
                itemBuilder: (context, index) => OnboardContent(
                  illustration: demoData[index]["illustration"],
                  title: demoData[index]["title"],
                  text: demoData[index]["text"],
                ),
              ),
            ),
            const Spacer(),
            const Spacer()
          ],
        ),
      ),
    );
  }
}

// Demo data for our Onboarding screen
List<Map<String, dynamic>> demoData = [
  {
    "illustration": "assets/Illustrations/splash.jpg",
    "title": "OTC Stock forum",
    "text":
        "Loading ...",
  }
];

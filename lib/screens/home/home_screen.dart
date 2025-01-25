import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodly_ui/screens/details/details_screen.dart';

import '../../components/section_title.dart';
import '../../constants.dart';
import '../../model/metadata_model.dart';
import '../details/components/market_block.dart';
import '../profile/components/body.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

@override
  State<HomeScreen> createState() =>
      _HomeState();
}

class _HomeState extends State<HomeScreen> {
  // List<Map<String, dynamic>> _snapshots;
  //
  void _fetchSnapshots() async{
      final response = await http.Client().get(Uri.parse(glb_otc_market_uri + getSnapshots), headers: OTC_HEADER);
      if (response.statusCode != 200){
        debugPrint('Cannot get metadata from cloud');
        //todo display something or check if we had metadata in sqlite
      } else {
        List<dynamic> objFromCloud = jsonDecode(response.body);
        debugPrint(objFromCloud[0].toString());
      }
    }

  @override
  void initState() {
    super.initState();
    _fetchSnapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        title: const Column(
          children: [
            Text(
              "",
              style: TextStyle(color: Colors.black),
            )
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: defaultPadding),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...List.generate(
                      6, // for demo we use 3
                      (index) => const Padding(
                        padding: EdgeInsets.only(left: defaultPadding),
                        child: StockCard(
                          ticker: 'OTC Int.',
                          price: '6.38',
                          changePercentage: '23.58%',
                          isPositive: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: defaultPadding),
                  ],
                ),
              ),
              const SizedBox(height: defaultPadding),
              SectionTitle(
                title: "My watchlist",
                press: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DetailsScreen(),
                  ),
                ),
              ),
              const Divider(thickness: 0.3,),
              ProfileMenuCard(
                svgSrc: "assets/icons/profile.svg",
                title: "TCRRF",
                subTitle: "click here",
                press: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DetailsScreen(),
                  ),
                ),
                commentCount: "6"
              ),
              const Divider(thickness: 0.3,),
              ProfileMenuCard(
                svgSrc: "assets/icons/profile.svg",
                title: "TCRRF",
                subTitle: "Terrace Energy Corp",
                press: () {},
                commentCount: "6"
              ),
              //random stocks
              const SizedBox(height: defaultPadding * 3),
              SectionTitle(
                title: "Market",
                press: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DetailsScreen(),
                  ),
                ),
              ),
              const Divider(thickness: 0.3,),
              ProfileMenuCard(
                svgSrc: "assets/icons/profile.svg",
                title: "TCRRF",
                subTitle: "Terrace Energy Corp",
                press: () {},
                commentCount: "6"
              ),
              const Divider(thickness: 0.3,),
              ProfileMenuCard(
                svgSrc: "assets/icons/profile.svg",
                title: "TCRRF",
                subTitle: "Terrace Energy Corp",
                press: () {},
                commentCount: "6"
              )
            ],
          ),
        ),
      ),
    );
  }
}

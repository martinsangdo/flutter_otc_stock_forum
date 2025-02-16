import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:otc_stock_forum/screens/details/details_screen.dart';
import 'package:otc_stock_forum/screens/featured/components/search_screen.dart';

import '../../components/section_title.dart';
import '../../constants.dart';
import '../details/components/market_block.dart';
import '../profile/components/body.dart';
import 'package:http/http.dart' as http;
import 'package:otc_stock_forum/model/user_setting_model.dart';
import 'package:otc_stock_forum/model/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

@override
  State<HomeScreen> createState() =>
      _HomeState();
}

class _HomeState extends State<HomeScreen> {
  List<Map<String, dynamic>> _snapshots = []; //market status
  List<Map<String, dynamic>> _activeStocks = [];  //most active stocks
  List<Map<String, dynamic>> _myFavoritedStocks = [];  //my watch list

  bool _isLoading = true;
  //
  void _fetchSnapshots() async{
      final response = await http.Client().get(Uri.parse(glb_otc_market_uri + otc_getSnapshots), headers: OTC_HEADER);
      if (response.statusCode != 200){
        debugPrint('Cannot get snapshots from cloud');
        //todo display something or check if we had metadata in sqlite
      } else {
        List<dynamic> objFromCloud = jsonDecode(response.body);
        // debugPrint(objFromCloud[0].toString());
        List<Map<String, dynamic>> snapshots = [];
        if (objFromCloud.isNotEmpty){
          for (Map<String, dynamic> obj in objFromCloud){
            snapshots.add({
              'description': obj['description']!.replaceAll('OTCQX', '').replaceAll('OTCQB', ''),
              'change': obj['change']!,
              'percentChange': obj['percentChange']!
            });
          }
          // debugPrint(snapshots.toString());
          setState(() {
            _snapshots = snapshots;
          });
        }
      }
    }
  //get top stocks from OTC, then fetch more data from our db
  void _fetchActiveStocks() async{
      final response = await http.Client().get(Uri.parse(glb_otc_market_uri + otc_getActiveStocks), headers: OTC_HEADER);
      if (response.statusCode != 200){
        debugPrint('Cannot get active stocks from OTC site');
      } else {
        Map<String, dynamic> objFromCloud = jsonDecode(response.body);
        //debugPrint(objFromCloud.toString());
        List<dynamic> rawStocks = objFromCloud['records'];
        if (objFromCloud['records'] != null){
          List<String> stockIds = [];
          Map<String, dynamic> simpleDetails = {};  //key: symbol, value: simple detail
          for (Map<String, dynamic> item in rawStocks){
            stockIds.add(item['symbol']);
            simpleDetails[item['symbol']] = {
              'price': item['price'], 'pctChange': item['pctChange']
            };
          }
          //debugPrint(stockIds.toString());
          //call our db to get more detail
          final stockResponse = await http.Client().get(
            Uri.parse(glb_backend_uri + getStockDetails + stockIds.join(',')));
          if (stockResponse.statusCode != 200){
            debugPrint('Cannot get stock details from cloud');
            //todo display something or check if we had metadata in sqlite
          } else {
            Map<String, dynamic> responseObj = jsonDecode(stockResponse.body);
            List<dynamic> ourStockDetails = responseObj['data'];
            //get stocks that has data in OTC site and sort by comment count
            List<Map<String, dynamic>> activeStocks = [];  //most active stocks
            for (Map<String, dynamic> ourStockDetail in ourStockDetails){
              if (ourStockDetail['is_otc'] && ourStockDetail['comment_count'] > 0){
                String cSymbol = ourStockDetail['symbol'];
                activeStocks.add({
                  'symbol': cSymbol,
                  'name': ourStockDetail['name'],
                  'comment_count': ourStockDetail['comment_count'],
                  'price': simpleDetails[cSymbol]['price'], 
                  'pctChange': simpleDetails[cSymbol]['pctChange']
                });
              }
            }
            //debugPrint(activeStocks.toString());
            setState(() {
              _activeStocks = activeStocks;
              _isLoading = false;
            });
          }
        } else {
          //todo cannot get data from OTC site
        }
      }
  }
  
  //get my favorited stocks in local app
  _fetchWatchlist() async{
    final userSettingsInLocal = await DatabaseHelper.instance.rawQuery('SELECT * FROM user_settings', []);
    //debugPrint(userSettingsInLocal.toString());
    if (userSettingsInLocal.isNotEmpty){
      //load list of stocks, if any
      List<dynamic> favoritedStocks = jsonDecode(userSettingsInLocal[0]['stocks']);
      //debugPrint(favoritedStocks.toString());
      if (favoritedStocks.isNotEmpty){
        //get more details from db
        final stockResponse = await http.Client().get(
            Uri.parse(glb_backend_uri + getStockDetails + favoritedStocks.join(',')));
          if (stockResponse.statusCode != 200){
            debugPrint('Cannot get stock details from cloud');
          } else {
            Map<String, dynamic> responseObj = jsonDecode(stockResponse.body);
            List<dynamic> ourStockDetails = responseObj['data'];
            //get stocks that has data in OTC site and sort by comment count
            List<Map<String, dynamic>> myFavoritedStocks = [];  //most active stocks
            for (Map<String, dynamic> ourStockDetail in ourStockDetails){
              if (ourStockDetail['is_otc'] && ourStockDetail['comment_count'] > 0){
                String cSymbol = ourStockDetail['symbol'];
                myFavoritedStocks.add({
                  'symbol': cSymbol,
                  'name': ourStockDetail['name'],
                  'comment_count': ourStockDetail['comment_count'],
                });
              }
            }
            setState(() {
              _myFavoritedStocks = myFavoritedStocks;
            });
          }
      }
    } else {
      //init empty user settings
      UserSettingModel userSettingModel = UserSettingModel(
        uuid: generateUuid(), usr: '', name: '', stocks: jsonEncode([]));
      DatabaseHelper.instance.insertUserSettings(userSettingModel).then((id){
              debugPrint('Inserted new user settings into db');
      });
    }
  }
  //
  @override
  void initState() {
    super.initState();
    _fetchSnapshots();
    _fetchWatchlist();
    _fetchActiveStocks();
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
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0), // Or EdgeInsets.symmetric, etc.
                  child: Center(
                    child: CircularProgressIndicator(), // Or any other widget
                  ),
                ),
              const SizedBox(height: defaultPadding),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                    _snapshots.map((item) =>
                      Padding(
                        padding: const EdgeInsets.only(left: defaultPadding),
                        child: StockCard(
                          ticker: item['description']!,
                          price: item['change']!.toString(),
                          changePercentage: item['percentChange']!.toString(),
                          isPositive: double.parse(item['percentChange']!.toString()) > 0
                        ),
                      ),
                    ).toList(),
                ),
              ),
              const SizedBox(height: defaultPadding),
              SectionTitle(
                title: "My watchlist",
                press: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchScreen(refreshWatchlist: _fetchWatchlist),
                  ),
                ),
                isAddMore: true,
              ),
              for (int i=0; i<_myFavoritedStocks.length; i++)
                StockListItem(
                        iconData: Icons.arrow_forward_ios_outlined,
                        title: _myFavoritedStocks[i]['symbol'],
                        subTitle: _myFavoritedStocks[i]['name'],
                        press: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsScreen(symbol: _myFavoritedStocks[i]['symbol']),
                          ),
                        ),
                        commentCount: _myFavoritedStocks[i]['comment_count'].toString()
                      )
                ,
              //random active stocks
              const SizedBox(height: defaultPadding * 3),
              SectionTitle(
                title: "Market",
                press: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchScreen(refreshWatchlist: _fetchWatchlist,),
                  ),
                ),
                isAddMore: false,
              ),
              for (int i=0; i<_activeStocks.length; i++)
                StockListItem(
                        iconData: Icons.arrow_forward_ios_outlined,
                        title: _activeStocks[i]['symbol'],
                        subTitle: _activeStocks[i]['name'],
                        press: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsScreen(symbol: _activeStocks[i]['symbol']),
                          ),
                        ),
                        commentCount: _activeStocks[i]['comment_count'].toString(),
                        price: _activeStocks[i]['price'].toString(),
                        pctChange: _activeStocks[i]['pctChange']
                      )
                ,
            ],
          ),
        ),
      ),
    );
  }
}

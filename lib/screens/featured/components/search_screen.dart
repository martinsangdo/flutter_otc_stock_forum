import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:otc_stock_forum/model/database_helper.dart';
import 'package:otc_stock_forum/model/user_setting_model.dart';
import '../../../constants.dart';
import 'dart:convert';
import '../../profile/components/body.dart';

//Search stock symbol
class SearchScreen extends StatefulWidget{
  const SearchScreen({super.key});

@override
  State<SearchScreen> createState() =>
      _State();
}

class _State extends State<SearchScreen> {
  String _errMessage = '';
  List<dynamic> _searchedList = [];  //searched stock list
  UserSettingModel _userSettingModel = UserSettingModel(
        uuid: '', usr: '', name: '', stocks: jsonEncode([]));

  _beginSearching(String query) async{
    if (query.length <= 2){
      //require input more than 2 characters
      setState(() {
        _errMessage = 'Please input more than 2 characters';
      });
      return;
    }
    //begin searching
    setState(() {
        _errMessage = 'Searching ...';
      });
    //debugPrint(query);
    final response = await http.Client().get(Uri.parse(glb_backend_uri + searchStocks + query));
      if (response.statusCode != 200){
        debugPrint('Cannot get stocks from cloud');
      } else {
        Map<String, dynamic> objFromCloud = jsonDecode(response.body);
        List<dynamic> results = [];
        if (objFromCloud['data'].isEmpty){
          //not found any from our db
          setState(() {
            _errMessage = 'Not found';
          });
        } else {
          //found some stocks in our cloud
          List<dynamic> favoritedStocks = jsonDecode(_userSettingModel.stocks.toString());
          for (Map<String, dynamic> obj in objFromCloud['data']){
            results.add({
                  "symbol": obj['symbol'],
                  "name": obj['name'],
                  "comment_count": obj['comment_count'],
                  "isFavorited": favoritedStocks.contains(obj['symbol']) ? true : false
                });
              }
          //
          setState(() {
            _errMessage = '';
            _searchedList = results;
          });
        }
      }
  }
  //
  _addStock2Watchlist(symbol){
    List<dynamic> favoritedStocks = jsonDecode(_userSettingModel.stocks.toString());
    if (favoritedStocks.contains(symbol)){
      return; //already in the list, do nothing
    }
    favoritedStocks.add(symbol);
    //save into local db
    _userSettingModel.stocks = jsonEncode(favoritedStocks);
    debugPrint(_userSettingModel.uuid);
    debugPrint(_userSettingModel.stocks);
    DatabaseHelper.instance.updateUserSettings(_userSettingModel).then((id){
      debugPrint('Updated new user settings into db');
    });
    //
    List<dynamic> _newSearchedList = [];  //searched stock list

    for (Map<String, dynamic> obj in _searchedList){
      _newSearchedList.add({
          "symbol": obj['symbol'],
          "name": obj['name'],
          "comment_count": obj['comment_count'],
          "isFavorited": (obj['symbol'] == symbol)? true : obj['isFavorited']
        });
    }
    //
    setState(() {
      _searchedList = _newSearchedList;
    });
  }
  //
  getFavoritedStocks() async{
    //query stocks that already added into the watch list
    final userSettingsInLocal = await DatabaseHelper.instance.rawQuery('SELECT * FROM user_settings', []);
    //debugPrint(userSettingsInLocal.toString());
    if (userSettingsInLocal.isNotEmpty){
      //get the favorited stocks, if any
      setState(() {
        //save to state
        _userSettingModel = UserSettingModel(
          uuid: userSettingsInLocal[0]['uuid'], 
          usr: userSettingsInLocal[0]['usr'], 
          name: userSettingsInLocal[0]['name'], 
          stocks: userSettingsInLocal[0]['stocks']);
      });
    } else {
      //do nothing
    }
  }
  //
  _removeStockFromWatchlist(symbol){
    List<dynamic> favoritedStocks = jsonDecode(_userSettingModel.stocks.toString());
    if (favoritedStocks.contains(symbol)){
      favoritedStocks.remove(symbol);
    }
    List<dynamic> _newSearchedList = [];  //searched stock list
    for (Map<String, dynamic> obj in _searchedList){
      _newSearchedList.add({
          "symbol": obj['symbol'],
          "name": obj['name'],
          "comment_count": obj['comment_count'],
          "isFavorited": (obj['symbol'] == symbol)? false : obj['isFavorited']
        });
    }
    //
    setState(() {
      _searchedList = _newSearchedList;
    });
  }
  //
  _removeUserSettings(){
    DatabaseHelper.instance.removeUserSettings();
  }

  @override
  void initState() {
    super.initState();
    //_removeUserSettings();
    getFavoritedStocks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            Text(
              "Search",
              style: TextStyle(color: Colors.black),
            )
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container( // Wrap TextField in a Container for margin
                      margin: const EdgeInsets.all(8.0), // Add margin here
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Type the symbol or stock name',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onSubmitted: (query) { // Call search on Enter
                          _beginSearching(query); // or _performSearch();
                        },
                      ),
                    ),
                    if (_errMessage.isNotEmpty)
                      Container( // Wrap TextField in a Container for margin
                        margin: const EdgeInsets.symmetric(horizontal: 8.0), // Add margin here
                        child: 
                          Text(_errMessage, 
                          style: const TextStyle(color: Colors.red))
                      ),
                    
                    for (int i=0; i<_searchedList.length; i++)
                      StockListItem(
                            iconData: _searchedList[i]['isFavorited'] ? Icons.remove : Icons.add,
                            title: _searchedList[i]['symbol'],
                            subTitle: _searchedList[i]['name'],
                            press: (() {
                              if (_searchedList[i]['isFavorited']){
                                _removeStockFromWatchlist(_searchedList[i]['symbol']);
                              } else {
                                _addStock2Watchlist(_searchedList[i]['symbol']);
                              }
                            }),
                            commentCount: _searchedList[i]['comment_count'].toString()
                          )
                    ,//end for
                    const SizedBox(height: defaultPadding),
                    ],
              )
            )
      ),
    );
  }

}
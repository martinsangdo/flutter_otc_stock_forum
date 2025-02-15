import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../constants.dart';
import 'dart:convert';

//Search stock symbol
class SearchScreen extends StatefulWidget{
  SearchScreen({super.key});

@override
  State<SearchScreen> createState() =>
      _State();
}

class _State extends State<SearchScreen> {
  String _searchText = ''; // Store the current search text
  String _errMessage = '';
  List<dynamic> _searchedList = [];  //searched stock list

  _onTyping(String query) {
    setState(() {
      _searchText = query;
    });
  }
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
        //todo display something or check if we had metadata in sqlite
      } else {
        Map<String, dynamic> objFromCloud = jsonDecode(response.body);
        List<dynamic> results = objFromCloud['data'];
        if (results.isEmpty){
          //not found any
          setState(() {
            _errMessage = 'Not found';
          });
        } else {
          setState(() {
            _errMessage = '';
            _searchedList = results;
          });
        }
      }
  }

  @override
  void initState() {
    super.initState();

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
        child: Column(
          children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container( // Wrap TextField in a Container for margin
                      margin: const EdgeInsets.all(8.0), // Add margin here
                      child: TextField(
                        onChanged: _onTyping,
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
                ],
              )
            )
          ]
        )
      ),
    );
  }

}
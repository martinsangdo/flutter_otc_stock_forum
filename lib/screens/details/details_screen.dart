import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:otc_stock_forum/model/database_helper.dart';
import 'package:otc_stock_forum/model/user_setting_model.dart';

import '../../constants.dart';
import '../forum/components/post_item.dart';
import '../news/news_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class DetailsScreen extends StatefulWidget {
  String symbol;
  DetailsScreen({super.key, required this.symbol});

@override
  State<DetailsScreen> createState() =>
      _State();
}

class _State extends State<DetailsScreen> {
  late WebViewController _controller;
  late bool _isLoading = true;
  List<dynamic> _comments = [];
  UserSettingModel _userSettingModel = UserSettingModel(
        uuid: '', usr: '', name: '', stocks: jsonEncode([]));

  String _fullName = '';  //input user full name
  String _usr = ''; //input username
  String _newCommentContent = '';
  String _errComment = '';

  //load the trading chart
  _loadWebview(){
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            //debugPrint('progress');
          },
          onPageStarted: (String url) {
            //debugPrint('started');
          },
          onPageFinished: (String url) {
            //debugPrint('finished');
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(glb_backend_uri + getStockChart + widget.symbol));
  }
  //load comments of this stock
  _loadComments() async{
    final response = await http.Client().get(Uri.parse(glb_backend_uri + getCommentsByStock + widget.symbol.toUpperCase()));
    if (response.statusCode != 200){
        debugPrint('Cannot get comments from cloud');
      } else {
        Map<String, dynamic> objFromCloud = jsonDecode(response.body);
        //debugPrint(objFromCloud['data'].toString());
        setState(() {
          _comments = objFromCloud['data'];
        });
      }
  }
  //
  String formatDateFromTimestamp(int timestamp) {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}";
  }
  //
  void _showMyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter new comment'),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Important for text fields in dialogs
            children: <Widget>[
              TextFormField(
                initialValue: _fullName,
                onChanged: (value) {
                  setState(() {
                    _fullName = value.trim();
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Your name',
                  contentPadding: EdgeInsets.all(4.0), // Padding on all sides
                ),
              ),
              const SizedBox(height: 8),
              TextFormField( // Replaced with TextField for multi-line input
                initialValue: _newCommentContent,
                onChanged: (value) {
                  setState(() {
                    _newCommentContent = value.trim();
                  });
                },
                keyboardType: TextInputType.multiline, // Key for multi-line
                maxLines: 6, // Number of lines
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(4.0), // Padding on all sides
                  hintText: 'Type your new comment',
                  border: OutlineInputBorder(), // Add a border for better UX
                ),
              ),
              if (_errComment.isNotEmpty)
                Container( // Wrap TextField in a Container for margin
                        margin: const EdgeInsets.symmetric(horizontal: 8.0), // Add margin here
                        child: 
                          Text(_errComment, 
                          style: const TextStyle(color: Colors.red))
                      ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Do something with _text1 and _text2
                _createNewComment();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  //load data from local app
  _loadUserSettings() async{
    final userSettingsInLocal = await DatabaseHelper.instance.rawQuery('SELECT * FROM user_settings', []);
    if (userSettingsInLocal.isNotEmpty){
      setState(() {
        _userSettingModel = UserSettingModel(
          uuid: userSettingsInLocal[0]['uuid'], 
          usr: userSettingsInLocal[0]['usr'], 
          name: userSettingsInLocal[0]['name'], 
          stocks: userSettingsInLocal[0]['stocks']);
        //
        _fullName = userSettingsInLocal[0]['name'];
        _usr = userSettingsInLocal[0]['usr'];
      });
    }
  }
  //
  _createNewComment() async{
    if (_fullName.isEmpty || _fullName.length < 5){
      setState(() {
        _errComment = 'Your name must be more than 5 characters';
      });
      return;
    }
    if (_newCommentContent.isEmpty || _newCommentContent.length < 10){
      setState(() {
        _errComment = 'Please input the comment more than 5 words';
      });
      return;
    }
    //begin saving new comment
    setState(() {
        _errComment = 'Saving ...';
      });
    //send request to server to save it
    final headers = {'Content-Type': 'application/json'}; // Important for JSON requests
    String newCommentUuid = generateUuid();
    String usr = _fullName.toLowerCase().replaceAll(' ', '');
    final body = jsonEncode({
      'symbol': widget.symbol,
      'uuid': newCommentUuid, //new comment ID
      'usr': usr,  //username
      'name': _fullName,
      'text': _newCommentContent.trim(), //comment content
      'time': getCurrentTimestampInSeconds()
    });
    final response = await http.Client().post(Uri.parse(
      glb_backend_uri + createNewComment), headers: headers, body: body);
      //debugPrint(response.body.toString());
    if (response.statusCode != 200){
        debugPrint('Cannot create new comment in cloud');
    } else {
      Map<String, dynamic> responseObj = jsonDecode(response.body);
      if (responseObj["result"] == "OK"){
        //created new comment succesfully, need to update user name
        //save new usr into global var
        glb_allUsers[usr] = _fullName;
        //save new user into local db
        _userSettingModel.usr = usr;
        _userSettingModel.name = _fullName;
        DatabaseHelper.instance.updateUserSettings(_userSettingModel).then((id){
          debugPrint('Updated new user settings into db');
        });
        setState(() {
          _usr = usr;
          _errComment = '';
        });
        //append new comment into the list
        _comments.insert(0, {   //latest comment into the first position
          'uuid': newCommentUuid,
          'usr': usr,
          'time': getCurrentTimestampInSeconds(),
          'text': _newCommentContent,
          'replies': [],
          'like': 0
        });
        //
        Navigator.of(context).pop(); // Close the dialog
      } else {
        //something wrong when creating new comment
        setState(() {
          _errComment = 'Please try again later';
        });
      }
    }
  }
  //
  callbackDeleteComment(deleted_cmt_uuid){
    //debugPrint(deleted_cmt_uuid);
    _loadComments();
  }
  //
  @override
  void initState() {
    super.initState();
    _loadWebview();
    _loadComments();
    _loadUserSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              widget.symbol,
              style: const TextStyle(color: Colors.black),
            )
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0), // Or EdgeInsets.symmetric, etc.
                  child: Center(
                    child: CircularProgressIndicator(), // Or any other widget
                  ),
                ),
              //WebViewWidget should be displayed first
              Container(
                padding: const EdgeInsets.symmetric(),
                height: 200,
                child: WebViewWidget(controller: _controller),
              ),
              // SingleChildScrollView should be below the WebView
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: defaultPadding),
                      for (int i=0; i<_comments.length; i++) ...[
                        PostItem(
                            uuid: _comments[i]['uuid'],
                            postType: 'comment',
                            username: glb_allUsers[_comments[i]['usr']]!,
                            timestamp: formatDateFromTimestamp(_comments[i]['time']!),
                            message: _comments[i]['text']!,
                            image: glb_avatar_uri + _comments[i]['usr'],
                            likes: _comments[i]['like'],
                            replyNum: _comments[i]['replies'] != null?_comments[i]['replies'].length: 0,
                            canDelete: _comments[i]['usr'] == _usr,
                            callbackDeleteComment: callbackDeleteComment
                          ),
                        const Divider(thickness: 0.3,)
                      ]
                  ],
                )
              )
            ]
          )
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showMyDialog,
        child: const Icon(Icons.add), // Icon displayed on the button
      ),
    );
  }
}

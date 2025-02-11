import 'dart:convert';

import 'package:flutter/material.dart';

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
  late bool _isLoading = false;
  List<dynamic> _comments = [];
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
            debugPrint('finished');
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
        //debugPrint(objFromCloud.toString());
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
  @override
  void initState() {
    super.initState();
    _loadWebview();
    _loadComments();
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
              //if (_isLoading)
                //const CircularProgressIndicator(),
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
                            username: glb_allUsers[_comments[i]['usr']]!,
                            timestamp: formatDateFromTimestamp(_comments[i]['time']!),
                            message: _comments[i]['text']!,
                            image: glb_avatar_uri + _comments[i]['usr'],
                            likes: _comments[i]['like'],
                            comments: 0,
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
        onPressed: () {
          // Function to be executed when the button is pressed
          // For example, navigate to another screen:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewsScreen()),
          );
        },
        child: const Icon(Icons.add), // Icon displayed on the button
      ),
    );
  }
}

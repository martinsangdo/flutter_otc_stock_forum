import 'package:flutter/material.dart';
import 'package:otc_stock_forum/constants.dart';
import 'package:otc_stock_forum/screens/forum/components/post_item.dart';
import 'package:otc_stock_forum/screens/news/news_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});
@override
  State<ForumScreen> createState() =>
      _State();
}

class _State extends State<ForumScreen> {
    List<dynamic> _comments = [];

  //
  _loadComments() async{
    final response = await http.Client().get(Uri.parse(
      glb_backend_uri + getLatestComments + '0'));
    if (response.statusCode != 200){
        debugPrint('Cannot get comments from cloud');
      } else {
        Map<String, dynamic> objFromCloud = jsonDecode(response.body);
        //debugPrint(objFromCloud.toString());
        List<Map<String, dynamic>> list = [];
        for (Map<String, dynamic> item in objFromCloud['data']){
          list.add({
              'symbol': item['symbol']!,
              'usr': glb_allUsers[item['usr']!],  //map to user name
              'like': item['like']!,
              'text': item['text']!,
              'replies': item['replies']!=null?item['replies'].length:0,
              'time': formatDateFromTimestamp(item['time']!)
            });
        }
        setState(() {
          _comments = list;
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
    _loadComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            Text(
              "Forum",
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
              for (int i=0; i<_comments.length; i++) ...[
                PostItem(
                          username: _comments[i]['usr'],
                          timestamp: _comments[i]['time'],
                          message: _comments[i]['text'],
                          image: glb_avatar_uri + _comments[i]['usr'],
                          likes: _comments[i]['like'],
                          replyNum: _comments[i]['replies'],
                        ),
                const Divider(thickness: 0.3,),
              ]
            ]
          )
        )
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

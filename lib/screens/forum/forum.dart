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
    List<Map<String, dynamic>> _comments = [];
    int _currentPageIndex = 0;
    bool _isLoading = true;

    final ScrollController _scrollController = ScrollController();
    double _scrollableHeight = 0;

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_scrollController.position.atEdge && _scrollController.position.pixels > 0) {
      // Scrolled to the end!
      //debugPrint("Scrolled to the end!");
      //
      setState((){
        _currentPageIndex += 1;
        //load next page
        _loadComments(_currentPageIndex);
      });
    }
  }
  //
  _loadComments(newPageIndex) async{
    final response = await http.Client().get(Uri.parse(
      glb_backend_uri + getLatestComments + (newPageIndex * glb_page_length).toString()));
    if (response.statusCode != 200){
        debugPrint('Cannot get comments from cloud');
      } else {
        Map<String, dynamic> objFromCloud = jsonDecode(response.body);
        //debugPrint(objFromCloud.toString());
        List<Map<String, dynamic>> list = _comments;
        for (Map<String, dynamic> item in objFromCloud['data']){
          list.add({
              'uuid': item['uuid'],
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
          _isLoading = false;
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
    _scrollController.addListener(_handleScroll);
    _loadComments(0);
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
          controller: _scrollController,
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
              for (int i=0; i<_comments.length; i++) ...[
                PostItem(
                  uuid: _comments[i]['uuid'],
                  postType: 'comment',
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

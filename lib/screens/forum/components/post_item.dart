import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../constants.dart';
import 'dart:convert';

//this is a comment structure
class PostItem extends StatefulWidget {
  final String uuid;  //can be comment of reply
  final String postType;  //'comment' or 'reply'
  final String username;
  final String timestamp;
  final String message;
  final String image;
  final int likes;
  final int replyNum;
  bool? isLiked;
  bool? canDelete;  //can delete this comment or not
  Function(String)? callbackDeleteComment; // Define the function type


  PostItem({
    super.key,
    required this.uuid,
    required this.postType,
    required this.username,
    required this.timestamp,
    required this.message,
    required this.image,
    required this.likes,
    required this.replyNum,
    this.canDelete,
    this.callbackDeleteComment
  });

@override
  State<PostItem> createState() =>
      _State();
}

class _State extends State<PostItem> {
  bool isLiked = false;
  int noOfLiked = 0;

  //We do NOT support unlike
  _likeThisItem() async{
    if (isLiked){
      //We do NOT support unlike
      return;
    }
    //send request to update the number
    final headers = {'Content-Type': 'application/json'}; // Important for JSON requests
    final body = jsonEncode({
      'uuid': widget.uuid
    });
    final response = await http.Client().put(Uri.parse(
      glb_backend_uri + putLikeComment), headers: headers, body: body);
    if (response.statusCode != 200){
        debugPrint('Cannot update likes from cloud');
      } else {
        Map<String, dynamic> objFromCloud = jsonDecode(response.body);
        //debugPrint(objFromCloud.toString());
        //todo: what if the request failed
      }
    setState((){
      isLiked = true;
      noOfLiked += 1;
    });
  }
  //
  _deleteThisItem() async{
    final response = await http.Client().delete(Uri.parse(
      '$glb_backend_uri$deleteComment?uuid=${widget.uuid}'));
    if (response.statusCode != 200){
        debugPrint('Cannot delete comment from cloud');
      } else {
        Map<String, dynamic> objFromCloud = jsonDecode(response.body);
        //debugPrint(objFromCloud['result'].toString());
        if (objFromCloud['result'] == 'OK'){
          //delete successfully
          widget.callbackDeleteComment!(widget.uuid);
        }
        //todo: what if the request failed
      }
    
  }
  //

  @override
  void initState() {
    super.initState();
    setState(() {
      noOfLiked = widget.likes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.image),
                radius: 20,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black
                    ),
                  ),
                  Text(
                    widget.timestamp,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.message,
            style: const TextStyle(
              fontSize: 14, color: Colors.black
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  const Icon(Icons.chat_bubble_outline),
                  const SizedBox(width: 4),
                  Text(widget.replyNum.toString()),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () {
                      _likeThisItem();
                    },
                    icon: 
                    (isLiked)?
                      const Icon(Icons.favorite)  //liked
                    :
                      const Icon(Icons.favorite_border),
                  ),
                  Text(noOfLiked.toString()), //todo why it is not refreshed after adding new comment
                ],
              ),
              const Row(
                children: [
                  Icon(Icons.reply),
                ],
              ),
              if (widget.canDelete!)
                Row(
                  children: [
                    IconButton(
                      onPressed: _deleteThisItem,
                      icon: const Icon(Icons.delete),
                    )
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
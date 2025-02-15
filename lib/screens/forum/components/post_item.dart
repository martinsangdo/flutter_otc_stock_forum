import 'package:flutter/material.dart';

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

  PostItem({
    super.key,
    required this.uuid,
    required this.postType,
    required this.username,
    required this.timestamp,
    required this.message,
    required this.image,
    required this.likes,
    required this.replyNum
  });

@override
  State<PostItem> createState() =>
      _State();
}

class _State extends State<PostItem> {
  bool isLiked = false;

  //We do NOT support unlike
  _likeThisItem(){
    setState((){
      isLiked = !isLiked;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.isLiked != null){
      isLiked = widget.isLiked!;
    }
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
                  Text(widget.likes.toString()),
                ],
              ),
              const Row(
                children: [
                  const Icon(Icons.reply),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
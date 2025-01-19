import 'package:flutter/material.dart';

class PostItem extends StatelessWidget {
  final String username;
  final String timestamp;
  final String message;
  final String ticker;
  final String image;
  final int likes;
  final int comments;

  const PostItem({
    super.key,
    required this.username,
    required this.timestamp,
    required this.message,
    required this.ticker,
    required this.image,
    required this.likes,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
                radius: 20,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    timestamp,
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
            message,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.chat_bubble_outline),
                  const SizedBox(width: 4),
                  Text('$comments'),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.favorite_border),
                  const SizedBox(width: 4),
                  Text('$likes'),
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
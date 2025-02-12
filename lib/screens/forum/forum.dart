import 'package:flutter/material.dart';
import 'package:otc_stock_forum/constants.dart';
import 'package:otc_stock_forum/screens/forum/components/post_item.dart';
import 'package:otc_stock_forum/screens/news/news_screen.dart';

class ForumScreen extends StatelessWidget {
  const ForumScreen({super.key});

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
      body: const SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: defaultPadding),
              PostItem(
                        username: 'jeffceee',
                        timestamp: '01/15/25, 04:50 PM',
                        message: 'X like this if youre in from under 1.00.',
                        image: 'https://i.pravatar.cc/150',
                        likes: 1541,
                        replyNum: 124,
                      ),
              Divider(thickness: 0.3,),
              PostItem(
                        username: 'jeffceee',
                        timestamp: '01/15/25, 04:50 PM',
                        message: 'X like this if youre in from under 1.00.',
                        image: 'https://i.pravatar.cc/150',
                        likes: 1541,
                        replyNum: 124,
                      ),
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

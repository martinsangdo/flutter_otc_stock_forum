import 'package:flutter/material.dart';
import 'package:otc_stock_forum/constants.dart';
import 'package:otc_stock_forum/screens/news/components/news_item.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            Text(
              "Latest news",
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
              NewsItem(
                title: "Russian Sentenced to Seven Years in Prison for Sending Crypto Assets t...",
                imageUrl: 'https://i.pravatar.cc/150', // Replace with actual image URL
                webUrl: 'dailyhodl',
                description: 'Shares of Square soared on Tuesday evening after posting better-than-expected quarterly results and strong growth in its consumer payments app.', 
                timestamp: '1596589501',
              ),
              Divider(thickness: 0.3,),
            ]
          )
        )
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../constants.dart';
import '../forum/components/post_item.dart';
import '../news/news_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';


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

  @override
  void initState() {
    super.initState();
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
      ..loadRequest(Uri.parse(glb_backend_uri + 'stock/chart?symbol=' + widget.symbol));
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
        child: Column(
          children: [
            //if (_isLoading)
              //const CircularProgressIndicator(),
            // WebViewWidget should be displayed first
            Container(
              padding: const EdgeInsets.symmetric(),
              height: 200,
              child: WebViewWidget(controller: _controller),
            ),
            // SingleChildScrollView should be below the WebView
              const SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: defaultPadding),
                    PostItem(
                        username: 'jeffceee',
                        timestamp: '01/15/25, 04:50 PM',
                        message: 'X like this if youre in from under 1.00.',
                        ticker: 'XRP.X',
                        image: 'https://i.pravatar.cc/150',
                        likes: 1541,
                        comments: 124,
                      ),
                      Divider(thickness: 0.3,),
                      PostItem(
                        username: 'jeffceee',
                        timestamp: '01/15/25, 04:50 PM',
                        message: 'X like this if youre in from under 1.00.',
                        ticker: 'XRP.X',
                        image: 'https://i.pravatar.cc/150',
                        likes: 1541,
                        comments: 124,
                      ),
                ],
              )
            )
          ]
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

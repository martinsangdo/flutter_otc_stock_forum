

import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget{
  SearchScreen({super.key});

@override
  State<SearchScreen> createState() =>
      _State();
}

class _State extends State<SearchScreen> {

  @override
  void initState() {
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            Text(
              "TBBFE",
              style: TextStyle(color: Colors.black),
            )
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
              const SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                ],
              )
            )
          ]
        )
      ),
    );
  }

}
import 'package:flutter/material.dart';

import 'components/body.dart';

class IPOScreen extends StatelessWidget {
  const IPOScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            Text(
              "IPO Calendar",
              style: TextStyle(color: Colors.black),
            )
          ],
        ),
      ),
      body: const IPOBody(),
    );
  }
}

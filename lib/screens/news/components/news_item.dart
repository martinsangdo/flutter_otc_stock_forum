import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NewsItem extends StatelessWidget {
  final String timestamp;
  final String title;
  final String description;
  final String imageUrl;
  final String webUrl;

  const NewsItem({
    super.key,
    required this.title,
    required this.timestamp,
    required this.description,
    required this.webUrl,
    required this.imageUrl
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
              CachedNetworkImage(
                fit: BoxFit.fill,
                imageUrl: imageUrl,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                // placeholder: (context, url) => const CircularProgressIndicator(),
                // errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 200, // Set a maximum width for the text container
                    child: Text(
                      'This is a long text that will wrap to the next line within the container.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  // Text(
                  //   title,
                  //   style: const TextStyle(
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
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
                  Text(timestamp),
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
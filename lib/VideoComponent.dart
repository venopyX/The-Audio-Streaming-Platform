import 'package:flutter/material.dart';

class VideoComponent extends StatelessWidget {
  final String url;
  final String title;
  final String channel;
  final String id;
  VideoComponent({
    required this.url,
    required this.title,
    required this.channel,
    required this.id
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.black87, // Dark background
        borderRadius: BorderRadius.circular(15), // Rounded corners
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15),bottom: Radius.circular(15)), // Rounded top corners for image
            child: Image.network(
              url,
              height: 100, // Adjust as needed
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                 overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  channel,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
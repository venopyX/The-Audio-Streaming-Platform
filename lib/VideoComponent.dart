import 'package:flutter/material.dart';
import 'package:youtube_scrape_api/models/video.dart';
import 'package:provider/provider.dart';
import 'main.dart'; // Replace with the actual path

class VideoComponent extends StatelessWidget {
  final Video video;

  VideoComponent({required this.video});

  @override
  Widget build(BuildContext context) {
    final playing = Provider.of<Playing>(context, listen: false);
    return GestureDetector(
      onTap: () {
        playing.assign(video);
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row( // Use a Row to arrange elements horizontally
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(15),
                bottom: Radius.circular(15),
              ),
              child: Image.network(
                video.thumbnails![0].url!,
                height: 100,
                width: 120, // Adjust width as needed
                fit: BoxFit.cover,
              ),
            ),
            Expanded( // Use Expanded to take remaining space
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title!,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      video.channelName!,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (String result) {
                // Handle menu item selection here
                if (result == 'Add to Queue') {
                  playing.addToQueue(video);
                } else if (result == 'Share') {
                  // Implement Share logic
                  print('Share: ${video.title}');
                } else if (result == "Download"){
                  print('Download: ${video.title}');
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'Add to Queue',
                  child: Text('Add to Queue'),
                ),
                const PopupMenuItem<String>(
                  value: 'Share',
                  child: Text('Share'),
                ),
                const PopupMenuItem<String>(
                  value: 'Download',
                  child: Text('Download'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
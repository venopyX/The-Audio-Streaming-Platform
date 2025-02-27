import 'package:flutter/material.dart';
import 'package:youtube_scrape_api/models/video.dart';
import 'package:provider/provider.dart';
import 'main.dart'; // Replace with the actual path

class VideoComponent extends StatelessWidget {
  final Video video;

  VideoComponent({
    required this.video,
  });

  @override
  Widget build(BuildContext context) {
    final playing = Provider.of<Playing>(context, listen: false);
    return GestureDetector(
      onTap: () {

        playing.assign(video,true);
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.black87, // Dark background
          borderRadius: BorderRadius.circular(15), // Rounded corners
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with Overlapping Menu Button
            Stack(
              children: [
                // Thumbnail Image
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(15),
                      bottom: Radius.circular(15)), // Rounded corners for image
                  child: Image.network(
                    video.thumbnails![0].url!,
                    height: 100, // Adjust as needed
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Three-dot dropdown menu (positioned in the top-right corner)
                Positioned(
                  top: -4,
                  right: -4,
                  child: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      size: 20, // Adjust size as needed
                    ),
                    onSelected: (String value) {
                      // Handle menu item selection
                      switch (value) {
                        case 'add_to_queue':
                          playing.addToQueue(video);
                          break;
                        case 'add_to_playlist':
                          print('Add to Playlist');
                          break;
                        case 'share':
                          print('Share');
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem<String>(
                          value: 'add_to_queue',
                          child: Text('Add to Queue'),
                        ),
                        PopupMenuItem<String>(
                          value: 'add_to_playlist',
                          child: Text('Add to Playlist'),
                        ),
                        PopupMenuItem<String>(
                          value: 'share',
                          child: Text('Share'),
                        ),
                      ];
                    },
                  ),
                ),
              ],
            ),
            // Title and Channel Name
            Padding(
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
          ],
        ),
      ),
    );
  }
}
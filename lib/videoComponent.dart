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
        playing.assign(video, true);
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(15), bottom: Radius.circular(15)),
                  child: Image.network(
                    video.thumbnails![0].url!,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: -4,
                  right: -4,
                  child: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      size: 20,
                    ),
                    onSelected: (String value) {
                      switch (value) {
                        case 'add_to_queue':
                          if(playing.queue.contains(video)){
                            const snackdemo = SnackBar(
                              content: Text('Already in Queue'),
                              backgroundColor: Colors.white,
                              elevation: 10,
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.all(5),
                            ); ScaffoldMessenger.of(context).showSnackBar(snackdemo);
                          }
                          else{
                          playing.addToQueue(video);
                          const snackdemo = SnackBar(
                            content: Text('Added to Queue'),
                            backgroundColor: Colors.white,
                            elevation: 10,
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.all(5),
                          ); ScaffoldMessenger.of(context).showSnackBar(snackdemo);}
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
                        // PopupMenuItem<String>(
                        //   value: 'add_to_playlist',
                        //   child: Text('Add to Playlist'),
                        // ),
                        // PopupMenuItem<String>(
                        //   value: 'share',
                        //   child: Text('Share'),
                        // ),
                      ];
                    },
                  ),
                ),
                if (video.duration != null && video.duration!.isNotEmpty) // Check if duration is not null or empty
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        video.duration!, // Display the string duration directly
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
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
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
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
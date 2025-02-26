import 'package:flutter/material.dart';
import 'package:youtube_scrape_api/models/video.dart';
import 'YoutubeAudioStream.dart';
import 'package:provider/provider.dart';
import 'main.dart'; // Replace with the actual path
class VideoComponent extends StatelessWidget {
  final Video video;
  VideoComponent({
    required this.video,
  });

  @override
  Widget build(BuildContext context) {
    return
    GestureDetector(
      onTap:() {
        final playing = Provider.of<Playing>(context, listen: false);
        playing.assign(video);

          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => YoutubeAudioPlayer(videoId: video.videoId!), // Replace with your video ID
          //   ),
          // );
        // print(fetchYoutubeStreamUrl(video.videoId!));
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
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15),bottom: Radius.circular(15)), // Rounded top corners for image
            child: Image.network(
              video.thumbnails![0].url!,
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
    ));
  }
}
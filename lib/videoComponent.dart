import 'package:flutter/material.dart';
import 'package:youtube_scrape_api/models/video.dart';
import 'package:provider/provider.dart';
import 'main.dart'; // Replace with the actual path
import 'youtubeAudioStream.dart';
import 'favoriteUtils.dart';

class VideoComponent extends StatelessWidget {
  final Video video;

  VideoComponent({required this.video});

  @override
  Widget build(BuildContext context) {
    final playing = Provider.of<Playing>(context, listen: false);

    return FutureBuilder<bool>(
      future: isFavorites(video),
      builder: (context, snapshot) {
        bool _isLiked = snapshot.data ?? false; // Default to false if null

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
                    if (video.thumbnails != null && video.thumbnails!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(15),
                          bottom: Radius.circular(15),
                        ),
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
                              if (playing.queue.contains(video)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Already in Queue'),
                                    backgroundColor: Colors.white,
                                    elevation: 10,
                                    behavior: SnackBarBehavior.floating,
                                    margin: EdgeInsets.all(5),
                                  ),
                                );
                              } else {
                                playing.addToQueue(video);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Added to Queue'),
                                    backgroundColor: Colors.white,
                                    elevation: 10,
                                    behavior: SnackBarBehavior.floating,
                                    margin: EdgeInsets.all(5),
                                  ),
                                );
                              }
                              break;
                            case 'add_to_favorites':
                              saveToFavorites(video);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('added to favorites'),
                                  backgroundColor: Colors.white,
                                  elevation: 10,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(5),
                                ),
                              );
                              break;
                            case 'remove_from_favorites':
                              removeFavorites(video);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Removed from favorites'),
                                  backgroundColor: Colors.white,
                                  elevation: 10,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(5),
                                ),
                              );
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem<String>(
                              value: 'add_to_queue',
                              child: Text('Add to Queue'),
                            ),
                            _isLiked
                                ? PopupMenuItem<String>(
                              value: 'remove_from_favorites',
                              child: Text('Remove from favorites'),
                            )
                                : PopupMenuItem<String>(
                              value: 'add_to_favorites',
                              child: Text('Add to favorites'),
                            ),
                          ];
                        },
                      ),
                    ),
                    if (video.duration != null && video.duration!.isNotEmpty)
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
                            video.duration!,
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
                        video.title ?? 'No title',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        video.channelName ?? 'Unknown channel',
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
      },
    );
  }
}

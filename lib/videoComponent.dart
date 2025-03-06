import 'dart:io';

import 'package:flutter/material.dart';
import 'package:youtube_scrape_api/models/video.dart';
import 'package:provider/provider.dart';
import 'downloadUtils.dart';
import 'main.dart'; // Replace with the actual path
import 'youtubeAudioStream.dart';
import 'favoriteUtils.dart';
import 'connectivityProvider.dart';
import 'MyVideo.dart';

class VideoComponent extends StatefulWidget {
  final MyVideo video;

  VideoComponent({required this.video});

  @override
  _VideoComponentState createState() => _VideoComponentState();
}

class _VideoComponentState extends State<VideoComponent> {
  late Future<List<bool>> _future;

  @override
  void initState() {
    super.initState();
    _future = Future.wait([
      isFavorites(widget.video),
      isDownloaded(widget.video),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final playing = Provider.of<Playing>(context, listen: false);
    bool isOnline = Provider.of<NetworkProvider>(context).isOnline;
    return FutureBuilder<List<bool>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show loading indicator
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          return Text('No data available');
        } else {
          // Safely access data
          bool _isLiked =
              (snapshot.data![0] ?? false); // Default to false if null
          bool _isDownloaded =
              (snapshot.data![1] ?? false); // Default to false if null

          return GestureDetector(
            onTap: () {
              playing.assign(widget.video, true, _isDownloaded);
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
                          top: Radius.circular(15),
                          bottom: Radius.circular(15),
                        ),
                        child:

                        (widget.video.localimage != null)
                            ? Image.file(
                          File(widget.video.localimage!), // Use Image.file for local paths
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                            : (isOnline)
                            ? Image.network(
                          widget.video.thumbnails![0].url!,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                            : Image.asset(
                          'assets/icon.png', // Replace with your asset path
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )),
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
                                if (playing.queue.contains(widget.video)) {
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
                                  playing.addToQueue(widget.video, false);
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
                                saveToFavorites(widget.video);
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
                                removeFavorites(widget.video);
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
                              case 'add_to_downloads':
                                downloadAndSaveMetaData(context,widget.video);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('downloading in the background, will show up in downloads when complete'),
                                    backgroundColor: Colors.white,
                                    elevation: 10,
                                    behavior: SnackBarBehavior.floating,
                                    margin: EdgeInsets.all(5),
                                  ),
                                );
                                break;
                              case 'remove_from_downloads':
                                deleteDownload(widget.video);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('removed from downloads'),
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
                              _isDownloaded
                                  ? PopupMenuItem<String>(
                                      value: 'remove_from_downloads',
                                      child: Text('Remove from downloads'),
                                    )
                                  : PopupMenuItem<String>(
                                      value: 'add_to_downloads',
                                      child: Text('Download'),
                                    ),
                            ];
                          },
                        ),
                      ),
                      if (widget.video.duration != null &&
                          widget.video.duration!.isNotEmpty)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.video.duration!,
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
                          widget.video.title ?? 'No title',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.video.channelName ?? 'Unknown channel',
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
      },
    );
  }
}

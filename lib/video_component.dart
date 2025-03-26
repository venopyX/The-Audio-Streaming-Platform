import 'dart:async';
import 'dart:io';

import 'package:audiobinge/channel_videos_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'download_utils.dart';
import 'main.dart'; // Replace with the actual path
import 'favorite_utils.dart';
import 'connectivity_provider.dart';
import 'my_video.dart';
import 'colors.dart';

class DownloadService {
  final Map<String, double> _downloadProgress = {};
  final Map<String, bool> _downloadingState = {};
  final StreamController<Map<String, double>> _progressStreamController =
      StreamController<Map<String, double>>.broadcast();

  Stream<Map<String, double>> get progressStream =>
      _progressStreamController.stream;

  double getProgress(String videoId) {
    return _downloadProgress[videoId] ?? 0.0;
  }

  bool getDownloadingState(String videoId) {
    return _downloadingState[videoId] ?? false;
  }

  Future<void> startDownload(BuildContext context, MyVideo video) async {
    _downloadingState[video.videoId!] = true;
    downloadAndSaveMetaData(context, video, (progress) {
      _downloadProgress[video.videoId!] = progress;
      _progressStreamController.add(_downloadProgress);
      if (progress >= 1.0) {
        _downloadingState[video.videoId!] = false;
      }
    });
  }

  void dispose() {
    _progressStreamController.close();
  }
}

class VideoComponent extends StatefulWidget {
  final MyVideo video;

  const VideoComponent({super.key, required this.video});

  @override
  State<VideoComponent> createState() => _VideoComponentState();
}

class _VideoComponentState extends State<VideoComponent> {
  late Future<List<bool>> _future;
  StreamSubscription? _downloadSubscription;

  @override
  void initState() {
    super.initState();
    _future = Future.wait([
      isFavorites(widget.video),
      isDownloaded(widget.video),
    ]);
  }

  @override
  void dispose() {
    _downloadSubscription?.cancel(); // Cancel any ongoing download subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playing = Provider.of<Playing>(context, listen: false);
    bool isOnline = Provider.of<NetworkProvider>(context).isOnline;
    final downloadService = Provider.of<DownloadService>(context);

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
          bool isLiked = (snapshot.data![0] as bool? ?? false);
          bool isDownloaded = (snapshot.data![1] as bool? ?? false);

          return StreamBuilder<Map<String, double>>(
            stream: downloadService.progressStream,
            builder: (context, progressSnapshot) {
              final progress = progressSnapshot.hasData
                  ? progressSnapshot.data![widget.video.videoId!] ?? 0.0
                  : 0.0;
              final downloading =
                  downloadService.getDownloadingState(widget.video.videoId!);

              // Check if this video is the currently playing video
              final isCurrentVideo =
                  playing.video.videoId == widget.video.videoId;

              return GestureDetector(
                onTap: () {
                  playing.assign(widget.video, true);
                },
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(15),
                    border: isCurrentVideo
                        ? Border.all(
                            color: AppColors
                                .primaryColor, // Highlight border if current video
                            width: 2,
                          )
                        : null,
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
                            child: (widget.video.localimage != null)
                                ? Image.file(
                                    File(widget.video.localimage!),
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
                                        'assets/icon.png',
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
                                    if (playing.queue.contains(widget.video)) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text('Already in Queue'),
                                          backgroundColor: Colors.white,
                                          elevation: 10,
                                          behavior: SnackBarBehavior.floating,
                                          margin: EdgeInsets.all(5),
                                        ),
                                      );
                                    } else {
                                      playing.addToQueue(widget.video);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
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
                                        content: Text('Added to favorites'),
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
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text('Download started'),
                                      backgroundColor: Colors.white,
                                      elevation: 10,
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.all(5),
                                    ));
                                    downloadService.startDownload(
                                        context, widget.video);
                                    break;
                                  case 'remove_from_downloads':
                                    deleteDownload(widget.video);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Removed from downloads'),
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
                                  isLiked
                                      ? PopupMenuItem<String>(
                                          value: 'remove_from_favorites',
                                          child: Text('Remove from favorites'),
                                        )
                                      : PopupMenuItem<String>(
                                          value: 'add_to_favorites',
                                          child: Text('Add to favorites'),
                                        ),
                                  isDownloaded
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
                                  color: Colors.black.withValues(alpha: 0.7),
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
                          if (isCurrentVideo) // Show play icon if current video
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Icon(
                                Icons.play_arrow,
                                color: AppColors.primaryColor,
                                size: 24,
                              ),
                            ),
                        ],
                      ),
                      if (downloading)
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.black87,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryColor),
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
                            GestureDetector(
                              behavior: HitTestBehavior
                                  .opaque, // Makes the widget capture the tap
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChannelVideosPage(
                                      videoId: widget.video.videoId!,
                                      channelName:
                                          widget.video.channelName ?? '',
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                widget.video.channelName ?? 'Unknown channel',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(color: Colors.grey),
                              ),
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
      },
    );
  }
}

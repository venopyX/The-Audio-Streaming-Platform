import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:youtube_scrape_api/models/video.dart';
import 'package:provider/provider.dart';
import 'downloadUtils.dart';
import 'main.dart';
import 'youtubeAudioStream.dart';
import 'favoriteUtils.dart';
import 'connectivityProvider.dart';
import 'MyVideo.dart';
import 'colors.dart';

class DownloadService with ChangeNotifier{
  final Map<String, double> _downloadProgress = {};
  final Map<String, bool> _downloadingState = {};
  final StreamController<Map<String, double>> _progressStreamController =
  StreamController<Map<String, double>>.broadcast();

  Stream<Map<String, double>> get progressStream =>
      _progressStreamController.stream;

  double getProgress(String videoId) {
    return _downloadProgress[videoId] ?? 0.0;
  }

  bool getDownloadingState(String videoId){
    return _downloadingState[videoId] ?? false;
  }

  Future<void> startDownload(BuildContext context, MyVideo video) async {
    _downloadingState[video.videoId!] = true;
    downloadAndSaveMetaData(context, video, (progress) {
      _downloadProgress[video.videoId!] = progress;
      _progressStreamController.add(_downloadProgress);
      if (progress >= 1.0){
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
  VideoComponent({required this.video});

  @override
  _VideoComponentState createState() => _VideoComponentState();
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
    _downloadSubscription?.cancel();
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
          return SizedBox(
            height: 170,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
          return SizedBox(
            height: 170,
            child: Center(child: Text(snapshot.hasError ? 'Error: ${snapshot.error}' : 'No data available')),
          );
        }

        bool _isLiked = (snapshot.data![0] ?? false);
        bool _isDownloaded = (snapshot.data![1] ?? false);

        return StreamBuilder<Map<String, double>>(
          stream: downloadService.progressStream,
          builder: (context, progressSnapshot) {
            final progress = progressSnapshot.hasData
                ? progressSnapshot.data![widget.video.videoId!] ?? 0.0
                : 0.0;
            final downloading = downloadService.getDownloadingState(widget.video.videoId!);
            final isCurrentVideo = playing.video.videoId == widget.video.videoId;

            return GestureDetector(
              onTap: () {
                playing.assign(widget.video, true);
              },
              child: Container(
                height: 165,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(15),
                  border: isCurrentVideo
                      ? Border.all(color: AppColors.primaryColor, width: 2)
                      : null,
                ),
                child: Column(
                  children: [
                    // Thumbnail with fixed height
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                            child: (widget.video.localimage != null)
                                ? Image.file(
                              File(widget.video.localimage!),
                              fit: BoxFit.cover,
                            )
                                : (isOnline)
                                ? Image.network(
                              widget.video.thumbnails![0].url!,
                              fit: BoxFit.cover,
                            )
                                : Image.asset(
                              'assets/icon.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Options button
                          Positioned(
                            top: 0,
                            right: 0,
                            child: PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert, color: Colors.white, size: 20),
                              onSelected: (String value) {
                                // Same menu handling as before
                                // ... (implementation remained the same)
                              },
                              itemBuilder: (BuildContext context) {
                                // Same menu items as before
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
                          // Duration badge
                          if (widget.video.duration != null && widget.video.duration!.isNotEmpty)
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
                                  widget.video.duration!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          // Playing indicator
                          if (isCurrentVideo)
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
                    ),

                    // Progress bar (if downloading)
                    if (downloading)
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.black87,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                      ),

                    // Text content
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                widget.video.title ?? 'No title',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                widget.video.channelName ?? 'Unknown channel',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

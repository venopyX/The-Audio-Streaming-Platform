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

class VideoComponent extends StatefulWidget {
  final MyVideo video;

  VideoComponent({required this.video});

  @override
  _VideoComponentState createState() => _VideoComponentState();
}

class _VideoComponentState extends State<VideoComponent> {
  late Future<List<bool>> _future;
  double _downloadProgress = 0.0;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _future = Future.wait([
      isFavorites(widget.video),
      isDownloaded(widget.video),
    ]);
  }

  void _handleDownloadProgress(double progress) {
    setState(() {
      _downloadProgress = progress;
      _isDownloading = progress < 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final playing = Provider.of<Playing>(context, listen: false);
    bool isOnline = Provider.of<NetworkProvider>(context).isOnline;

    return FutureBuilder<List<bool>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            alignment: Alignment.center,
            child: SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
          return Text('No data available');
        } else {
          bool _isLiked = (snapshot.data![0] ?? false);
          bool _isDownloaded = (snapshot.data![1] ?? false);

          return GestureDetector(
            onTap: () {
              playing.assign(widget.video, true);
            },
            child: Container(
              // Fixed height container to guarantee no overflow
              height: 165,
              child: Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.black87,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail with fixed ratio
                    Container(
                      height: 90,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Thumbnail image
                          (widget.video.localimage != null)
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

                          // Menu button
                          Positioned(
                            top: 0,
                            right: 0,
                            child: PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.more_vert,
                                color: Colors.white,
                                size: 20,
                              ),
                              onSelected: (String value) {
                                // Popup menu handler logic
                              },
                              itemBuilder: (BuildContext context) {
                                // Menu items
                                return [];
                              },
                            ),
                          ),

                          // Duration indicator
                          if (widget.video.duration != null &&
                              widget.video.duration!.isNotEmpty)
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.video.duration!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Progress indicator
                    if (_isDownloading)
                      SizedBox(
                        height: 2,
                        child: LinearProgressIndicator(
                          value: _downloadProgress,
                          backgroundColor: Colors.grey[800],
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                        ),
                      ),

                    // Text content in an Expanded to use remaining space
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text(
                                widget.video.title ?? 'No title',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              widget.video.channelName ?? 'Unknown channel',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
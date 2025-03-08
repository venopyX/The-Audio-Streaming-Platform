// File: lib/videoComponent.dart
import 'dart:async';
import 'dart:io';

import 'package:audiobinge/channelVideosPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'MyVideo.dart';
import 'downloadUtils.dart';
import 'providers/medialProvider.dart';
import 'youtubeAudioStream.dart';
import 'providers/connectivityProvider.dart';
import 'colors.dart';
import 'main.dart';

/// DownloadService handles tracking download progress and state.
class DownloadService {
  final Map<String, double> _downloadProgress = {};
  final Map<String, bool> _downloadingState = {};
  final StreamController<Map<String, double>> _progressStreamController =
  StreamController<Map<String, double>>.broadcast();

  Stream<Map<String, double>> get progressStream => _progressStreamController.stream;

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

/// VideoComponent displays a video and allows actions such as adding/removing favorites or downloads.
/// When used on the downloads page (isDownloadPage = true), only the "Remove from downloads" option is shown.
class VideoComponent extends StatefulWidget {
  final MyVideo video;
  final bool isDownloadPage;
  const VideoComponent({Key? key, required this.video, this.isDownloadPage = false}) : super(key: key);

  @override
  _VideoComponentState createState() => _VideoComponentState();
}

class _VideoComponentState extends State<VideoComponent> {
  StreamSubscription? _downloadSubscription;

  @override
  void dispose() {
    _downloadSubscription?.cancel(); // Cancel any ongoing download subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playing = Provider.of<Playing>(context);
    final isOnline = Provider.of<NetworkProvider>(context).isOnline;
    final downloadService = Provider.of<DownloadService>(context);
    final mediaProvider = Provider.of<MediaProvider>(context);
    final bool isFav = mediaProvider.isFavorite(widget.video);
    final bool isDown = mediaProvider.isDownloaded(widget.video);

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
            height: 100,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(15),
              border: isCurrentVideo
                  ? Border.all(color: AppColors.primaryColor, width: 2)
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
        icon: Icon(Icons.more_vert, color: Colors.white, size: 20),
        onSelected: (String value) {
        if (value == 'remove_from_downloads') {
        mediaProvider.removeDownload(widget.video);
        deleteDownload(widget.video);
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
        content: Text('Removed from downloads'),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(5),
        ),
        );
        } else {
        // Default options when not on downloads page.
        switch (value) {
        case 'add_to_queue':
        if (playing.queue.contains(widget.video)) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
        content: Text('Already in Queue'),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(5),
        ),
        );
        } else {
        playing.addToQueue(widget.video);
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
        content: Text('Added to Queue'),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(5),
        ),
        );

        }
        break;
        case 'add_to_favorites':
        mediaProvider.addFavorite(widget.video);
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
        content: Text('Added to favorites'),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(5),
        ),
        );
        break;
        case 'remove_from_favorites':
        mediaProvider.removeFavorite(widget.video);
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
        content: Text('Removed from favorites'),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(5),
        ),
        );
        break;
        case 'add_to_downloads':
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(

        content: Text('Download started'),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(5),
        ),
        );
        downloadService.startDownload(context, widget.video);
        mediaProvider.addDownload(widget.video);
        break;
        }
        }
        },
        itemBuilder: (BuildContext context) {
        if (widget.isDownloadPage) {
        // When on the downloads page show only "remove" option.
        return [
        PopupMenuItem<String>(
        value: 'remove_from_downloads',
        child: Text('Remove from downloads'),
        )
        ];
        } else {
        // Default menu options.
        return [
        PopupMenuItem<String>(
        value: 'add_to_queue',
        child: Text('Add to Queue'),
        ),
        isFav
        ? PopupMenuItem<String>(
        value: 'remove_from_favorites',
        child: Text('Remove from favorites'),
        )
            : PopupMenuItem<String>(
        value: 'add_to_favorites',
        child: Text('Add to favorites'),
        ),
        isDown
        ? PopupMenuItem<String>(
        value: 'remove_from_downloads',
        child: Text('Remove from downloads'),
        )
            : PopupMenuItem<String>(
        value: 'add_to_downloads',
        child: Text('Download'),
        ),
        ];
        }
        },
        ),
        ),
        if (widget.video.duration != null &&
        widget.video.duration!.isNotEmpty)
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
        ],              ))]
        ),
        ),
        );
      },
    );
  }
}
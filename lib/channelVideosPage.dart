import 'package:audiobinge/bottomPlayer.dart';
import 'package:audiobinge/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'MyVideo.dart';
import 'videoComponent.dart';
import 'fetchYoutubeStreamUrl.dart';

class ChannelVideosPage extends StatefulWidget {
  final String videoId;
  final String channelName;
  const ChannelVideosPage(
      {super.key, required this.videoId, required this.channelName});

  @override
  _ChannelVideosPageState createState() => _ChannelVideosPageState();
}

class _ChannelVideosPageState extends State<ChannelVideosPage> {
  List<MyVideo> channelVideos = [];
  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _fetchChannelVideos();
  }

  Future<void> _fetchChannelVideos() async {
    print('object called');
    setState(() {
      _isLoading = true;
    });
    final scrapedVideos = await fetchVideosFromChannel(widget.videoId);
    setState(() {
      channelVideos = scrapedVideos
          .map((v) => MyVideo(
                videoId: v.videoId,
                duration: v.duration,
                title: v.title,
                channelName: v.channelName,
                views: v.views,
                uploadDate: v.uploadDate,
                thumbnails: v.thumbnails,
              ))
          .toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final playing = context.watch<Playing>();
    return Scaffold(
      appBar: AppBar(title: Text('${widget.channelName} Videos')),
      body: Stack(
        children: [
          _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.red))
              : channelVideos.isEmpty
                  ? Center(
                      child: Text('No videos found.',
                          style: TextStyle(fontSize: 20, color: Colors.white)))
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 20.0,
                      ),
                      itemCount: channelVideos.length,
                      itemBuilder: (context, index) {
                        return VideoComponent(video: channelVideos[index]);
                      },
                    ),
          // BottomPlayer overlay
          if (playing.video.title != null && playing.isPlayerVisible)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomPlayer(),
            ),
        ],
      ),
    );
  }
}

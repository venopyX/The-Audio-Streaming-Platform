import 'package:audiobinge/bottomPlayer.dart';
import 'package:audiobinge/downloadsPage.dart';
import 'package:audiobinge/favoritePage.dart';
import 'package:audiobinge/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'MyVideo.dart';
import 'videoComponent.dart';
import 'fetchYoutubeStreamUrl.dart';

class ChannelVideosPage extends StatefulWidget {
  final String videoId;
  final String channelName;
  static String channelAvatar =
      'https://t3.ftcdn.net/jpg/03/53/11/00/360_F_353110097_nbpmfn9iHlxef4EDIhXB1tdTD0lcWhG9.jpg';
  static String channelArt = '';
  const ChannelVideosPage(
      {super.key, required this.videoId, required this.channelName});

  @override
  _ChannelVideosPageState createState() => _ChannelVideosPageState();
}

class _ChannelVideosPageState extends State<ChannelVideosPage> {
  List<MyVideo> channelVideos = [];
  bool _isLoading = true; // Loading state
  int _selectedIndex = 0;
  List<Widget> get _pages =>
      [channelVideoScreen(), FavoriteScreen(), DownloadScreen()];

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
          .where((v) => v.title != null && v.title!.isNotEmpty)
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

  void _onItemTapped(int index, BuildContext context) {
    setState(() {
      if (_selectedIndex == 0 && index == 0) {
        Navigator.pop(context);
      }
      _selectedIndex = index;
    });
  }

  Widget channelVideoScreen() {
    return (_isLoading
        ? Center(child: CircularProgressIndicator(color: Colors.red))
        : channelVideos.isEmpty
            ? Center(
                child: Text('No videos found.',
                    style: TextStyle(fontSize: 20, color: Colors.white)))
            : Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    decoration: BoxDecoration(
                      // Add the image background using channelArt:
                      image: DecorationImage(
                        image: NetworkImage(ChannelVideosPage.channelArt),
                        fit: BoxFit.cover,
                      ),
                      // Optionally keep a background color as a fallback or overlay:
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  NetworkImage(ChannelVideosPage.channelAvatar),
                            ),
                            SizedBox(width: 12),
                            Text(
                              '${widget.channelName} Videos',
                              style: GoogleFonts.roboto(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: GridView.builder(
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
                  ),
                ],
              ));
  }

  @override
  Widget build(BuildContext context) {
    final playing = context.watch<Playing>();
    return Scaffold(
      appBar: CustomAppBar(),
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: _pages[_selectedIndex],
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
          // BottomPlayer overlay
          if (playing.video.title != null && playing.isPlayerVisible)
            Positioned(
              left: 0,
              right: 0,
              bottom:
                  kBottomNavigationBarHeight, // adjust to sit above the nav bar
              child: BottomPlayer(),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // adjust if needed
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Channel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_sharp),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download_for_offline_rounded),
            label: 'Downloads',
          ),
        ],
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }
}

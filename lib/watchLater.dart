import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_scrape_api/models/video.dart';
import 'package:youtube_scrape_api/youtube_scrape_api.dart';
import 'VideoComponent.dart'; // Import Google Fonts
import 'thumbnailUtils.dart';
import 'FavoriteUtils.dart';

class WatchLaterScreen extends StatefulWidget {
  const WatchLaterScreen({super.key});

  @override
  _WatchLaterScreenState createState() => _WatchLaterScreenState();
}

class _WatchLaterScreenState extends State<WatchLaterScreen> {
  List<Video> _videos = [];
  bool _isLoading = false;
  // Store fetched videos

  @override
  void initState() {
    super.initState();
    fetchWatchLater();
  }

  void fetchWatchLater() async {
    setState(() {
      _isLoading = true; // Start loading
    });
    YoutubeDataApi youtubeDataApi = YoutubeDataApi();
    List<Video> videos = await getFavorites();
    List<Video> processedVideos = [];
    for (var videoData in videos) {
      Video videoWithHighestThumbnail = processVideoThumbnails(videoData);
      processedVideos.add(videoWithHighestThumbnail);
    }

    setState(() {
      _videos = processedVideos;
      _isLoading = false; // Update the state with fetched videos
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search bar at the top
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Watch Later',
                  style: GoogleFonts.roboto(
                      fontSize: 32, fontWeight: FontWeight.w500),
                )),
          ),
          // Display trending video

          Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                      color: Colors.white,
                    )) // Loading indicator
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 columns
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 20.0,
                      ),
                      itemCount: _videos.length,
                      itemBuilder: (context, index) {
                        final video = _videos[index];
                        return VideoComponent(
                          video: video,
                        );
                      },
                    )),
        ],
      ),
    );
  }
}


import 'package:audiobinge/favoriteUtils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_scrape_api/models/video.dart';
import 'videoComponent.dart';
import 'package:shimmer/shimmer.dart';
import 'main.dart';
import 'package:provider/provider.dart';
import 'downloadUtils.dart';
import 'MyVideo.dart';
import 'colors.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  _DownloadScreenState createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  List<MyVideo> _videos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchDownloads();
  }

  void fetchDownloads() async {
    setState(() {
      _isLoading = true;
    });
    List<MyVideo> videos = await getDownloads();
    setState(() {
      _videos = videos;
      _isLoading = false;
    });
  }



  @override
  Widget build(BuildContext context) {
    final playing = context.watch<Playing>();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Downloads',
                  style: GoogleFonts.roboto(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (_videos.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed:()=> playing.setQueue(_videos,true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor, // Red color for the button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    icon: Icon(Icons.play_arrow, color: Colors.white),
                    label: Text(
                      'Play All',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 20.0,
              ),
              padding: EdgeInsets.all(16),
              itemCount: 10, // Show 10 shimmer placeholders while loading
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[800]!,
                  highlightColor: Colors.grey[700]!,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                );
              },
            )
                : _videos.isEmpty
                ? Center(
              child: Text(
                'No Downloads yet.',
                style: TextStyle(color: Colors.white),
              ),
            )
                : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 20.0,
              ),
              padding: EdgeInsets.all(16),
              itemCount: _videos.length,
              itemBuilder: (context, index) {
                final video = _videos[index];
                return VideoComponent(video: video);
              },
            ),
          ),
        ],
      ),
    );
  }
}




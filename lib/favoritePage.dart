import 'package:audiobinge/favoriteUtils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_scrape_api/models/video.dart';
import 'videoComponent.dart';
import 'package:shimmer/shimmer.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Video> _videos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  void fetchFavorites() async {
    setState(() {
      _isLoading = true;
    });
    List<Video> videos = await getFavorites();
    setState(() {
      _videos = videos;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Favorites',
                style: GoogleFonts.roboto(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                'No favorites yet.',
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
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_scrape_api/models/video.dart';
import 'package:youtube_scrape_api/youtube_scrape_api.dart';
import 'VideoComponent.dart';// Import Google Fonts

final TextEditingController _searchController = TextEditingController();

class YoutubeScreen extends StatefulWidget {
  const YoutubeScreen({super.key});

  @override
  _YoutubeScreenState createState() => _YoutubeScreenState();
}
class _YoutubeScreenState extends State<YoutubeScreen> {
  List<Video> _videos = [];
  bool _isLoading = false;
  // Store fetched videos

  @override
  void initState() {
    super.initState();
    fetchTrendingYoutube();
  }

  void fetchTrendingYoutube() async {
    setState(() {
      _isLoading = true; // Start loading
    });
    YoutubeDataApi youtubeDataApi = YoutubeDataApi();
    List<Video> videos = await youtubeDataApi.fetchTrendingVideo();
    setState(() {
      _videos = videos;
      _isLoading = false;// Update the state with fetched videos
    });
  }
  void searchYoutube() async{
    setState(() {
      _isLoading = true; // Start loading
    });
    YoutubeDataApi youtubeDataApi = YoutubeDataApi();
    List videos = await youtubeDataApi.fetchSearchVideo(_searchController.text);
    List<Video> temp = videos.whereType<Video>().toList(); // Use whereType for conciseness

    setState(() {
      _videos = temp;
      _isLoading = false;// Update _videos with the filtered list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          children: [
      // Search bar at the top
      Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50.0), // Rounded corners
            border: Border.all(
              color: Colors.black.withOpacity(1), // Dark border
              width: 1.0, // Border width
            ),
            boxShadow: [
        BoxShadow(
        color: Colors.black.withOpacity(1),
        blurRadius: 10,
        spreadRadius: 2,
        offset: const Offset(0, 4)), // Subtle shadow
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.transparent, // Transparent fill to match the container
          hintText: 'Search Youtube',
          hintStyle: GoogleFonts.roboto( // Apply Google Font
            color: Colors.grey, // Light grey hint text
            fontSize: 16,
          ),
          prefixIcon: IconButton(
            icon: SvgPicture.asset(
              'assets/icons/youtube.svg',
              color: Colors.black87,
              height: 24,
              width: 24,
              semanticsLabel: 'Youtube',
            ),
            onPressed: () {
            },
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min, // Ensure the row takes minimal space
            children: [
              IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: Colors.black87, // Grey clear icon
                ),
                onPressed: () => _searchController.clear(),
              ),
              IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Colors.black87, // Grey search icon
                ),
                onPressed: () {
                  // Perform the search action here
                  searchYoutube();
                },
              ),
            ],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0), // Rounded corners
            borderSide: BorderSide.none, // No border
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 20.0,
          ),
        ),
        style: GoogleFonts.roboto( // Apply Google Font
          color: Colors.black, // Black text color
          fontSize: 16,
        ),
      ),
    ),
    ),
    // Display trending video

    Expanded(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.white,)) // Loading indicator
            :GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 columns
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 20.0,

      ),
    itemCount: _videos.length,
    itemBuilder: (context, index) {
    final video = _videos[index];
    return VideoComponent(
    url: video.thumbnails![0].url!, // Display video thumbnail
    title: video.title!, // Display video title
    channel: video.channelName!,
        id:video.videoId!// Display channel name
    );
    },
    )),
    ],
    ),
    );
  }
}


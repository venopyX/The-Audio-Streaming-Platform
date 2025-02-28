import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:youtube_scrape_api/models/video.dart';
import 'package:youtube_scrape_api/youtube_scrape_api.dart';
import 'VideoComponent.dart';
import 'thumbnailUtils.dart';
import 'package:shimmer/shimmer.dart';

final TextEditingController _searchController = TextEditingController();

class YoutubeScreen extends StatefulWidget {
  const YoutubeScreen({super.key});

  @override
  _YoutubeScreenState createState() => _YoutubeScreenState();
}

class _YoutubeScreenState extends State<YoutubeScreen> {
  List<Video> _videos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchTrendingYoutube();
  }

  void fetchTrendingYoutube() async {
    setState(() {
      _isLoading = true;
    });
    YoutubeDataApi youtubeDataApi = YoutubeDataApi();
    List<Video> videos = await youtubeDataApi.fetchTrendingVideo();
    List<Video> processedVideos = [];
    for (var videoData in videos) {
      Video videoWithHighestThumbnail = processVideoThumbnails(videoData);
      processedVideos.add(videoWithHighestThumbnail);
    }

    setState(() {
      _videos = processedVideos;
      _isLoading = false;
    });
  }

  void searchYoutube(String query) async {
    setState(() {
      _isLoading = true;
    });
    YoutubeDataApi youtubeDataApi = YoutubeDataApi();
    List videos = await youtubeDataApi.fetchSearchVideo(query);
    List<Video> temp = videos.whereType<Video>().toList();

    List<Video> processedVideos = [];
    for (var videoData in videos) {
      Video videoWithHighestThumbnail = processVideoThumbnails(videoData);
      processedVideos.add(videoWithHighestThumbnail);
    }
    setState(() {
      _videos = processedVideos;
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
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: SvgPicture.asset(
                    'assets/icons/youtube.svg',
                    height: 20,
                    color: Colors.white,
                  ),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          _searchController.clear();
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {});
                            }
                          });
                        },
                      ),
                    IconButton(
                      icon: Icon(Icons.search, color: Colors.white),
                      onPressed: () {
                        searchYoutube(_searchController.text);
                      },
                    ),
                  ],
                ),
              ),
              style: TextStyle(color: Colors.white),
              onChanged: (text) {
                setState(() {});
              },
              onSubmitted: (query) {
                searchYoutube(_searchController.text);
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 20.0,
              ),
              padding: EdgeInsets.all(16),
              itemCount: _isLoading ? 10 : _videos.length, // Show shimmer placeholders when loading
              itemBuilder: (context, index) {
                if (_isLoading) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[800]!,
                    highlightColor: Colors.grey[700]!,
                    child: Container(
                      height: 100, // Adjust shimmer item height
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  );
                } else {
                  final video = _videos[index];
                  return VideoComponent(video: video);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
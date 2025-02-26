import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'fetchYoutubeStreamUrl.dart';

class YoutubeAudioPlayer extends StatefulWidget {
  final String videoId;
  YoutubeAudioPlayer({required this.videoId});

  @override
  _YoutubeAudioPlayerState createState() => _YoutubeAudioPlayerState();
}

class _YoutubeAudioPlayerState extends State<YoutubeAudioPlayer> {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  String title = "Song Title";
  String artist = "Artist Name";
  String thumbnailUrl = "https://via.placeholder.com/150";
  List<Map<String, String>> queue = [
    {"title": "Die for you", "artist": "The Weeknd"},
    {"title": "Save Your Tears", "artist": "The Weeknd"},
    {"title": "Starboy", "artist": "The Weeknd"}
  ];

  @override
  void initState() {
    super.initState();
    _streamAudio();
  }

  Future<void> _streamAudio() async {
    try {
      var url = await fetchYoutubeStreamUrl(widget.videoId);
      await audioPlayer.setSourceUrl(url);
      await audioPlayer.resume();
      setState(() => isPlaying = true);
    } catch (e) {
      print('Error streaming audio: $e');
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(child: Text("Main Content")),
          DraggableScrollableSheet(
            initialChildSize: 0.1,
            minChildSize: 0.1,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.keyboard_arrow_up, color: Colors.white),
                    ),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        children: [
                          Column(
                            children: [
                              Image.network(thumbnailUrl, height: 200),
                              SizedBox(height: 10),
                              Text(title, style: TextStyle(color: Colors.white, fontSize: 20)),
                              Text(artist, style: TextStyle(color: Colors.grey)),
                              SizedBox(height: 20),
                              Divider(color: Colors.white30),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Queue", style: TextStyle(color: Colors.white, fontSize: 18)),
                                    ...queue.map((song) => ListTile(
                                      title: Text(song["title"]!, style: TextStyle(color: Colors.white)),
                                      subtitle: Text(song["artist"]!, style: TextStyle(color: Colors.grey)),
                                      trailing: Icon(Icons.menu, color: Colors.white),
                                    ))
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(icon: Icon(Icons.skip_previous, color: Colors.white), onPressed: () {}),
                                  IconButton(
                                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 40),
                                    onPressed: () async {
                                      if (isPlaying) {
                                        await audioPlayer.pause();
                                      } else {
                                        await audioPlayer.resume();
                                      }
                                      setState(() => isPlaying = !isPlaying);
                                    },
                                  ),
                                  IconButton(icon: Icon(Icons.skip_next, color: Colors.white), onPressed: () {}),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

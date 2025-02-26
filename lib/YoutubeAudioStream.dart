import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'fetchYoutubeStreamUrl.dart';

class YoutubeAudioStream extends StatefulWidget {
  final String videoId;

  YoutubeAudioStream({required this.videoId});

  @override
  _YoutubeAudioStreamState createState() => _YoutubeAudioStreamState();
}

class _YoutubeAudioStreamState extends State<YoutubeAudioStream> {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;

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
      setState(() {
        isPlaying = true;
      });
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
      appBar: AppBar(title: Text('YouTube Audio Stream')),
      body: Center(
        child: IconButton(
          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: () async {
            if (isPlaying) {
              await audioPlayer.pause();
              setState(() {
                isPlaying = false;
              });
            } else {
              await audioPlayer.resume();
              setState(() {
                isPlaying = true;
              });
            }
          },
        ),
      ),
    );
  }
}
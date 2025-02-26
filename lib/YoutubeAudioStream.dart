import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'fetchYoutubeStreamUrl.dart';
import 'main.dart';
import 'package:provider/provider.dart';

class YoutubeAudioPlayer extends StatefulWidget {
  final String videoId;
  YoutubeAudioPlayer({required this.videoId});

  @override
  _YoutubeAudioPlayerState createState() => _YoutubeAudioPlayerState();
}

class _YoutubeAudioPlayerState extends State<YoutubeAudioPlayer> {
  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final playing = context.watch<Playing>();
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Player')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('hello'),
            Text('Duration: ${playing.duration.inSeconds} seconds'),
            Text('Position: ${playing.position.inSeconds} seconds'),
            Slider(
              activeColor: Colors.white,
              value: playing.position.inSeconds.toDouble(),
              max: playing.duration.inSeconds.toDouble(),
              onChanged: (double value) {

              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(playing.isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                    if (playing.isPlaying) {
                      playing.pauseAudio();
                    } else {
                      playing.playAudio(); // Replace with your audio URL
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

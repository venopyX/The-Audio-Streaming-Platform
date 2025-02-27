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
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Die for you',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'The Weeknd',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${playing.position.inSeconds}'),
                  Text('${playing.duration.inSeconds}'),
                ],
              ),
            ),
            Slider(
              activeColor: Colors.white,
              value: playing.position.inSeconds.toDouble(),
              max: playing.duration.inSeconds.toDouble(),
              onChanged: (double value) {},
              thumbColor: Color(0x00000000),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.shuffle, size: 32),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.skip_next, size: 32),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(playing.isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 52),
                  onPressed: () {
                    if (playing.isPlaying) {
                      playing.pauseAudio();
                    } else {
                      playing.playAudio(); // Replace with your audio URL
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.skip_next, size: 32),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.repeat, size: 32),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

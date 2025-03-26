import 'dart:io';

import 'package:audiobinge/channel_videos_page.dart';

import 'my_video.dart';

import 'fetch_youtube_stream_url.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'favorite_utils.dart';
import 'thumbnail_utils.dart';
import 'connectivity_provider.dart';

// LikeNotifier provider
class LikeNotifier extends ChangeNotifier {
  bool _isLiked = false;
  MyVideo? _currentVideo;

  bool get isLiked => _isLiked;

  void setVideo(MyVideo video) async {
    _currentVideo = video;
    _isLiked = await isFavorites(video);
    notifyListeners();
  }

  void toggleLike() {
    _isLiked = !_isLiked;
    if (_isLiked) {
      saveToFavorites(_currentVideo!);
    } else {
      removeFavorites(_currentVideo!);
    }
    notifyListeners();
  }
}

class YoutubeAudioPlayer extends StatefulWidget {
  final String videoId;
  const YoutubeAudioPlayer({super.key, required this.videoId});

  @override
  State<YoutubeAudioPlayer> createState() => _YoutubeAudioPlayerState();
}

class _YoutubeAudioPlayerState extends State<YoutubeAudioPlayer> {
  final bool _isInPlaylist = false; // Track playlist state
  bool _showLyrics = false; // Track lyrics visibility
  double playbackSpeed = 1.0; // Tracks the current playback speed
  bool _speedControlExpanded = false; // Track the speed control

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final playing = context.read<Playing>();
      context.read<LikeNotifier>().setVideo(playing.video);
    });
  }

  @override
  Widget build(BuildContext context) {
    final playing = context.watch<Playing>();
    final likeNotifier =
        context.watch<LikeNotifier>(); // Watch the LikeNotifier
    bool isOnline = Provider.of<NetworkProvider>(context).isOnline;

    // Set the current video in LikeNotifier
    likeNotifier.setVideo(playing.video);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Close the player
          },
        ),
        title: const Text('Now Playing'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.queue_music, color: Colors.white),
            onPressed: () {
              _showQueue(context, playing, isOnline);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Blurred Background
          Positioned.fill(
              child: (playing.video.localimage != null)
                  ? Image.file(
                      File(playing
                          .video.localimage!), // Use Image.file for local paths
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : (isOnline)
                      ? Image.network(
                          playing.video.thumbnails![0].url!,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/icon.png', // Replace with your asset path
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Album Art
              Container(
                height: 280,
                width: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(0, 4),
                    ),
                  ],
                  image: (playing.video.localimage != null)
                      ? DecorationImage(
                          image: FileImage(File(playing.video.localimage!)),
                          fit: BoxFit.cover,
                        )
                      : (isOnline)
                          ? DecorationImage(
                              image: NetworkImage(
                                  playing.video.thumbnails![0].url!),
                              fit: BoxFit.cover,
                            )
                          : DecorationImage(
                              image: AssetImage('assets/logo.png'),
                              fit: BoxFit.cover,
                            ),
                ),
              ),
              SizedBox(height: 30),

              // Song Title & Channel
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: 40,
                        child: buildMarqueeVideoTitle(playing.video.title!)),
                    SizedBox(height: 6),
                    GestureDetector(
                      behavior: HitTestBehavior
                          .opaque, // Makes the widget capture the tap
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChannelVideosPage(
                              videoId: playing.video.videoId!,
                              channelName: playing.video.channelName ?? '',
                            ),
                          ),
                        );
                      },
                      child: Text(
                        playing.video.channelName ?? 'Unknown channel',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Like, Add to Playlist, and Lyrics Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Consumer<LikeNotifier>(
                      builder: (context, likeNotifier, child) {
                    return _animatedButton(
                      likeNotifier.isLiked
                          ? Icons.favorite
                          : Icons.favorite_border,
                      () {
                        likeNotifier.toggleLike();
                      },
                      28,
                      color: likeNotifier.isLiked ? Colors.red : Colors.white,
                    );
                  }),
                  // SizedBox(width: 20),
                  // _animatedButton(
                  //   _isInPlaylist ? Icons.playlist_add_check : Icons.playlist_add,
                  //       () {
                  //     setState(() {
                  //       _isInPlaylist = !_isInPlaylist;
                  //     });
                  //   },
                  //   28,
                  //   color: _isInPlaylist ? Colors.green : Colors.white,
                  // ),
                  SizedBox(width: 20),
                  _animatedButton(
                    Icons.lyrics,
                    () {
                      setState(() {
                        _showLyrics = !_showLyrics;
                        fetchYoutubeClosedCaptions(playing.video.videoId!);
                      });
                    },
                    28,
                    color: _showLyrics ? Colors.blue : Colors.white,
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Lyrics Section (Conditional)
              if (_showLyrics)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    playing.currentCaption,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ),
              SizedBox(height: 20),
              // Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white38,
                        thumbColor: Colors.white,
                        thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 8),
                        overlayShape:
                            RoundSliderOverlayShape(overlayRadius: 16),
                      ),
                      child: Slider(
                        min: 0,
                        max: playing.duration.inSeconds.toDouble(),
                        value: playing.position.inSeconds.toDouble(),
                        onChanged: (double value) {
                          playing.seekAudio(Duration(seconds: value.toInt()));
                        },
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: buildTimeDisplay(
                            playing.position, playing.duration)),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _speedControlExpanded
                    ? Row(
                        children: [
                          Text("Speed", style: TextStyle(color: Colors.white)),
                          Expanded(
                            child: Slider(
                              min: 0.5,
                              max: 2.0,
                              divisions: 6,
                              value: playbackSpeed,
                              activeColor: Colors.white,
                              inactiveColor: Colors.white38,
                              onChanged: (double value) {
                                setState(() {
                                  playbackSpeed = value;
                                });
                                playing.audioPlayer.setSpeed(value);
                              },
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.expand_less, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _speedControlExpanded = false;
                              });
                            },
                          ),
                        ],
                      )
                    : GestureDetector(
                        onTap: () {
                          setState(() {
                            _speedControlExpanded = true;
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.speed, color: Colors.white),
                            SizedBox(width: 8),
                            Text("${playbackSpeed.toStringAsFixed(1)}x",
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
              ),
              SizedBox(height: 30),
              // Playback Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _animatedButton(Icons.shuffle, playing.toggleShuffle, 24,
                      color: playing.isShuffling ? Colors.blue : Colors.white),
                  SizedBox(width: 16),
                  _animatedButton(Icons.skip_previous, playing.previous, 32),
                  SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      playing.isPlaying ? playing.pause() : playing.play();
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Icon(
                        playing.isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        size: 72,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  _animatedButton(Icons.skip_next, () {
                    playing.next();
                  }, 32),
                  SizedBox(width: 16),
                  _animatedButton(
                      playing.isLooping == 0
                          ? Icons.repeat_rounded
                          : playing.isLooping == 1
                              ? Icons.repeat_one
                              : Icons.repeat_rounded, () {
                    playing.toggleLooping();
                  }, 24,
                      color: playing.isLooping == 0
                          ? Colors.white
                          : playing.isLooping == 1
                              ? Colors.white
                              : Colors.blue),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper function to create animated buttons
  Widget _animatedButton(IconData icon, VoidCallback onPressed, double size,
      {Color color = Colors.white}) {
    bool isButtonPressed = false;

    return GestureDetector(
      onTapDown: (_) => setState(() => isButtonPressed = true),
      onTapUp: (_) => setState(() => isButtonPressed = false),
      onTapCancel: () => setState(() => isButtonPressed = false),
      onTap: onPressed,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.1),
        ),
        child: ScaleTransition(
          scale: Tween(begin: 1.0, end: 0.9).animate(
            AlwaysStoppedAnimation(isButtonPressed ? 0.9 : 1.0),
          ),
          child: Icon(
            icon,
            size: size,
            color: color,
          ),
        ),
      ),
    );
  }

  // Show Queue Dialog with Currently Playing Highlighted
  void _showQueue(BuildContext context, Playing playing, bool isOnline) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Queue',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: playing.queue.length,
                  itemBuilder: (context, index) {
                    final video = playing.queue[index];
                    final isCurrent = video.videoId == playing.video.videoId;
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: (video.localimage != null)
                            ? Image.file(
                                File(video
                                    .localimage!), // Use Image.file for local paths
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              )
                            : (isOnline)
                                ? Image.network(
                                    video.thumbnails![0].url!,
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    'assets/icon.png', // Replace with your asset path
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  ),
                      ),
                      title: Text(
                        video.title!,
                        style: TextStyle(
                            color: isCurrent ? Colors.blue : Colors.white,
                            fontWeight: isCurrent
                                ? FontWeight.bold
                                : FontWeight.normal),
                      ),
                      subtitle: Text(
                        video.channelName!,
                        style: TextStyle(
                            color: isCurrent
                                ? Colors.blue.shade200
                                : Colors.white70),
                      ),
                      onTap: () {
                        playing.assign(video, false);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

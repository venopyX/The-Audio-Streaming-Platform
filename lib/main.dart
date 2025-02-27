import 'dart:ui';
import 'package:audiofy/fetchYoutubeStreamUrl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_scrape_api/models/video.dart';
import 'youtubepage.dart';
import 'twitchpage.dart';
import 'BottomPlayer.dart';
import 'package:audioplayers/audioplayers.dart';


void main() {
  runApp(
      MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => Playing()),
          ],
      child:const MyApp()));
}

class Playing with ChangeNotifier{
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  Video _video = Video();
  List<Video> _queue = [];

  final AudioPlayer _audioPlayer = AudioPlayer(); // AudioPlayer moved here
  bool _isPlaying = false; // Added isPlaying state
  bool _isLooping = false;


  Duration get duration => _duration;
  Duration get position => _position;
  Video get video => _video;
  AudioPlayer get audioPlayer => _audioPlayer;
  bool get isPlaying => _isPlaying;
  List<Video> get queue => _queue;


  bool get isLooping => _isLooping;
  void setIsPlaying(bool isit){
    if (isit){
      playAudio();
    }
    else{
      pauseAudio();
    }
    _isPlaying = isit;
    notifyListeners();
  }

  Playing() {
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    _audioPlayer.onDurationChanged.listen((Duration d) {
      _duration = d;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      _position = p;
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      _position = Duration.zero;
      _isPlaying = false;
      notifyListeners();
    });

    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });
  }



  Future<void> toggleLooping() async {
    _isLooping = !_isLooping;
    if (_isLooping) {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    } else {
      await _audioPlayer.setReleaseMode(ReleaseMode.release); // Or ReleaseMode.stop
    }
    notifyListeners();
  }

  void assign(Video v) async{
    _queue.clear();
    _queue.add(v);
    _video = v;
    resetAllDurationAndPosition();
    await pauseAudio();
    var url =await  fetchYoutubeStreamUrl(v.videoId!);
    streamAudio(url);
    notifyListeners();
  }

  void addToQueue(Video video) {
    _queue.add(video);
    print(_queue);
    notifyListeners();
  }
  void removeFromQueue(Video video) {
    _queue.remove(video);
    notifyListeners();
  }
  void clearQueue() {
    _queue.clear();
    notifyListeners();
  }
  void next() {
    if (_queue.isNotEmpty) {
      int currentIndex = _queue.indexOf(_video!);
      if (currentIndex < _queue.length - 1) {
        _video = _queue[currentIndex + 1];
      } else {
        // Optionally loop back to the first video or stop
        _video = _queue.first; // Loops back to the beginning.
        //_currentVideo = null; // Stops playing.
      }
      notifyListeners();
    }
  }

  void previous() {
    if (_queue.isNotEmpty) {
      int currentPosition = _position.inSeconds;
      if (currentPosition > 3) { // Check if position is greater than 2 seconds
        seekAudio(0.0 as Duration); // Rewind to the start
      } else {
        int currentIndex = _queue.indexOf(_video!);
        if (currentIndex > 0) {
          _video = _queue[currentIndex - 1];
          seekAudio(0 as Duration); // Seek to the start of the new song
        } else {
          // Optionally loop back to the last video or do nothing
          _video = _queue.last; // Loops back to the end
          seekAudio(0 as Duration); // Seek to the start of the new song.
        }
      }
      notifyListeners();
    }
  }

  void updateDuration(Duration d) {
    _duration = d;
    notifyListeners();
  }

  void updatePosition(Duration p) {
    _position = p;
    notifyListeners();
  }

  void resetPosition() {
    _position = Duration.zero;
    notifyListeners();
  }

  void resetDuration() {
    _duration = Duration.zero;
    notifyListeners();
  }

  void resetAllDurationAndPosition() {
    _position = Duration.zero;
    _duration = Duration.zero;
    notifyListeners();
  }

  Future<void> streamAudio(String url) async {
    try {
      await _audioPlayer.setSourceUrl(url);
      await _audioPlayer.resume();
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      print('Error streaming audio: $e');
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> playAudio() async {
    await _audioPlayer.resume();
    _isPlaying = true;
    notifyListeners();
  }

  Future<void> seekAudio(Duration position) async {
    await _audioPlayer.seek(position);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black87,
          brightness: Brightness.dark,
        ).copyWith(
          background: Colors.black,
          surface: Colors.black87,
          primary: Colors.black87,
        ),
        useMaterial3: true,
      ),
      home: YouTubeTwitchTabs(),
    );
  }
}

class YouTubeTwitchTabs extends StatefulWidget {
  const YouTubeTwitchTabs({super.key});

  @override
  _YouTubeTwitchTabsState createState() => _YouTubeTwitchTabsState();
}

class _YouTubeTwitchTabsState extends State<YouTubeTwitchTabs> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    YoutubeScreen(),
    TwitchScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final playing = context.watch<Playing>();
    return Scaffold(
      extendBody: true,
      appBar: CustomAppBar(),
      body: Stack(
        children: [
          // Main content
          _pages[_selectedIndex],

          // BottomPlayer positioned above the bottom navigation
          if(playing.video.title != null)
            Positioned(
            left: 0,
            right: 0,
            bottom: kBottomNavigationBarHeight, // Position above the bottom nav
            child: BottomPlayer(),
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(
            color: Colors.white.withOpacity(0.1),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white.withOpacity(0.5),
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.video_library),
                  label: 'YouTube',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.live_tv),
                  label: 'Twitch',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Extracted Custom AppBar
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          SizedBox(width: 10),
          Image.asset(
            'assets/logo.png',
            height: 200,
            width: 130,
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
import 'dart:ui';
import 'fetchYoutubeStreamUrl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as ytex;
import 'package:youtube_scrape_api/models/video.dart';
import 'youtubePage.dart';
import 'favoritePage.dart';
import 'bottomPlayer.dart';
import 'package:just_audio/just_audio.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
      MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => Playing()),
          ],
      child:const MyApp()));
}



class Playing with ChangeNotifier {
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  Video _video = Video();
  List<Video> _queue = [];
  ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []); // Initialize playlist
  List<ytex.ClosedCaption> captions = [];
  String currentCaption = "";

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  int _isLooping = 0;

  Duration get duration => _duration;
  Duration get position => _position;
  Video get video => _video;
  AudioPlayer get audioPlayer => _audioPlayer;
  bool get isPlaying => _isPlaying;
  List<Video> get queue => _queue;
  int get isLooping => _isLooping;

  Playing() {
    _initAudioPlayer();
  }

  void setIsPlaying(bool isit) {
    if (isit) {
      playAudio();
    } else {
      pauseAudio();
    }
    _isPlaying = isit;
    notifyListeners();
  }

  void _initAudioPlayer() {
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _duration = duration;
        notifyListeners();
      }
    });

    _audioPlayer.positionStream.listen((position) {
      _position = position;
      currentCaption = getCaptionAtTime(captions, position);
      notifyListeners();
    });

    _audioPlayer.playerStateStream.listen((playerState) {
      _isPlaying = playerState.playing;
      notifyListeners();

      if (playerState.processingState == ProcessingState.completed) {
        if (_isLooping == 1) {
          seekAudio(Duration.zero);
          playAudio();
        } else if (_isLooping == 2 && _queue.isNotEmpty) {
          _audioPlayer.seek(Duration.zero, index: 0);
        } else if (_queue.isNotEmpty) {
          next();
        } else {
          _isPlaying = false;
          notifyListeners();
        }
      }
    });

    _audioPlayer.currentIndexStream.listen((index) async {
      if (index != null && index >= 0 && index < _queue.length) {
        _video = _queue[index];
        captions = (await fetchYoutubeClosedCaptions(_video.videoId!));// Sync _video with the current track
        notifyListeners();
      }
    });
  }

  Future<void> toggleLooping() async {
    _isLooping = (_isLooping + 1) % 3;
    if (_isLooping == 0) {
      await _audioPlayer.setLoopMode(LoopMode.off);
    } else if (_isLooping == 1) {
      await _audioPlayer.setLoopMode(LoopMode.one);
    } else if (_isLooping == 2) {
      await _audioPlayer.setLoopMode(LoopMode.all);
    }
    notifyListeners();
  }

  Future<void> assign(Video v, bool clear) async {
    if (clear) {
      _queue.clear();
      _queue.add(v);
    }

    _video = v;
    resetPosition();
    await pauseAudio();

    var url = await fetchYoutubeStreamUrl(v.videoId!);
    final audioSource = AudioSource.uri(Uri.parse(url));
    _playlist = ConcatenatingAudioSource(children: [audioSource]);
    await _audioPlayer.setAudioSource(_playlist);

    await playAudio();
    notifyListeners();
  }

  Future<void> addToQueue(Video video) async {
    _queue.add(video); // Add video to the queue
    if (_video.title == null) {
      _video = video; // Set as current video if no video is playing
    }

    var url = await fetchYoutubeStreamUrl(video.videoId!);
    final audioSource = AudioSource.uri(Uri.parse(url));
    await _playlist.add(audioSource); // Add audio source to the playlist

    notifyListeners();
  }

  Future<void> removeFromQueue(Video video) async {
    final index = _queue.indexOf(video);
    if (index != -1) {
      _queue.removeAt(index); // Remove video from the queue
      await _playlist.removeAt(index); // Remove audio source from the playlist

      // If the removed video was the current video, update _video
      if (_video.videoId == video.videoId) {
        if (_queue.isNotEmpty) {
          _video = _queue[_audioPlayer.currentIndex ?? 0];
        } else {
          _video = Video(); // Reset _video if the queue is empty
        }
      }

      notifyListeners();
    }
  }

  Future<void> clearQueue() async {
    _queue.clear(); // Clear the queue
    _playlist = ConcatenatingAudioSource(children: []); // Clear the playlist
    await _audioPlayer.setAudioSource(_playlist);

    _video = Video(); // Reset _video
    notifyListeners();
  }

  Future<void> next() async {
    if (_queue.isNotEmpty) {
      await _audioPlayer.seekToNext();
      notifyListeners();
    }
  }

  Future<void> previous() async {
    if (_queue.isNotEmpty) {
      int currentPosition = _position.inSeconds;
      if (currentPosition > 3) {
        await seekAudio(Duration.zero);
      } else {
        await _audioPlayer.seekToPrevious();
      }
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
    notifyListeners();
    _duration = Duration.zero;
    notifyListeners();
  }

  Future<void> streamAudio(String url) async {
    try {
      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(url)));
      await playAudio();
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
    await _audioPlayer.play();
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
    FavoriteScreen(),
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
                  icon: Icon(Icons.watch_later),
                  label: 'Watch Later',
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
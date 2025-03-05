import 'dart:ui';
import 'package:just_audio_background/just_audio_background.dart';

import 'fetchYoutubeStreamUrl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as ytex;
import 'package:youtube_scrape_api/models/video.dart';
import 'youtubePage.dart';
import 'favoritePage.dart';
import 'bottomPlayer.dart';
import 'package:just_audio/just_audio.dart';
import 'youtubeAudioStream.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  runApp(
      MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => LikeNotifier()),
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
  String currentCaption = "no caption fo this media";

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  int _isLooping = 0;
  bool _isShuffling = false;
  bool _isloading = false;

  bool get isloading => _isloading;
  bool get isShuffling => _isShuffling;
  ConcatenatingAudioSource get playlist => _playlist;



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
      play();
    } else {
      pause();
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

      if(captions.isNotEmpty) {
        currentCaption = getCaptionAtTime(captions, position);
      } else{
        currentCaption = "No caption for this media";      }
      notifyListeners();
    });

    _audioPlayer.playerStateStream.listen((playerState) {
      _isPlaying = playerState.playing;
      notifyListeners();

      if (playerState.processingState == ProcessingState.completed) {
        if (_isLooping == 1) {
          seekAudio(Duration.zero);
          play();
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

  Future<void> toggleShuffle() async {
    _isShuffling = !_isShuffling;
    await _audioPlayer.setShuffleModeEnabled(_isShuffling); // Use just_audio's shuffle
    notifyListeners();
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
    _isloading = true;
    notifyListeners();
    if (clear) {
      _queue.clear();
      _queue.add(v);
    }

    _video = v;
    resetPosition();
    await pause();

    var url = await fetchYoutubeStreamUrl(v.videoId!);
    final audioSource = AudioSource.uri(Uri.parse(url),
      tag: MediaItem(
        // Specify a unique ID for each media item:
        id: v.videoId!,
        // Metadata to display in the notification:
        album: v.channelName,
        title: v.title!,
        artUri: Uri.parse(v.thumbnails![0].url!),
      ),);
    _playlist = ConcatenatingAudioSource(children: [audioSource]);
    await _audioPlayer.setAudioSource(_playlist);

    _isloading = false;
    notifyListeners();
    await play();

    notifyListeners();
  }

  Future<void> addToQueue(Video v) async {
    _queue.add(v); // Add video to the queue
    if (_video.title == null) {
      _video = v; // Set as current video if no video is playing
    }

    var url = await fetchYoutubeStreamUrl(v.videoId!);
    final audioSource = AudioSource.uri(Uri.parse(url),tag:MediaItem(
      // Specify a unique ID for each media item:
      id: v.videoId!,
      // Metadata to display in the notification:
      album: v.channelName,
      title: v.title!,
      artUri: Uri.parse(v.thumbnails![0].url!),
    ) );
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
  Future<void> setQueue(List<Video> videos) async{
    if (videos.isNotEmpty) {
      // Assign the first element
      assign(videos.first,true);

      // Add the remaining elements to the queue
      for (int i = 1; i < videos.length; i++) {
        addToQueue(videos[i]);
      }
    }

    notifyListeners();
  }

  Future<void> next() async {
    if (_queue.isNotEmpty) {
      _isloading = true;
      notifyListeners();
      await _audioPlayer.seekToNext();
      _isloading = false;
      notifyListeners();
    }
  }

  Future<void> previous() async {
    if (_queue.isNotEmpty) {
      _isloading = true;
      int currentPosition = _position.inSeconds;
      if (currentPosition > 3) {
        await seekAudio(Duration.zero);
      } else {
        await _audioPlayer.seekToPrevious();
      }
      _isloading = false;
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
    notifyListeners();
    _duration = Duration.zero;
    notifyListeners();
  }

  Future<void> streamAudio(String url) async {
    try {
      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(url)));
      await play();
    } catch (e) {
      print('Error streaming audio: $e');
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> play() async {
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
      appBar: CustomAppBar(
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade800, Colors.black],
          ),
        ),
        child: Stack(
          children: [
            // Main content with fade transition
            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: _pages[_selectedIndex],
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),

            // BottomPlayer positioned above the bottom navigation
            if (playing.video.title != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: kBottomNavigationBarHeight, // Position above the bottom nav
                child: BottomPlayer(),
              ),
          ],
        ),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: Colors.black.withOpacity(0.5),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.deepPurpleAccent,
              unselectedItemColor: Colors.grey,
              selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.video_library),
                  label: 'YouTube',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_sharp),
                  label: 'Favorites',
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
          // App Logo
          Image.asset(
            'assets/icon.png',
            height: 40, // Adjusted for better proportions
            width: 40,
          ),
          SizedBox(width: 10), // Spacing between logo and title
          // App Title
          Text(
            "AudioBinge",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(

      ),

    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
// File: lib/providers/medialProvider.dart
import 'package:flutter/foundation.dart';
import '../MyVideo.dart';

class MediaProvider extends ChangeNotifier {
  final List<MyVideo> _favorites = [];
  final List<MyVideo> _downloads = [];

  List<MyVideo> get favorites => List.unmodifiable(_favorites);
  List<MyVideo> get downloads => List.unmodifiable(_downloads);

  // Favorites methods
  void addFavorite(MyVideo video) {
    if (!_favorites.contains(video)) {
      _favorites.add(video);
      notifyListeners();
    }
  }

  void removeFavorite(MyVideo video) {
    if (_favorites.remove(video)) {
      notifyListeners();
    }
  }

  bool isFavorite(MyVideo video) {
    return _favorites.contains(video);
  }

  // Downloads methods
  void addDownload(MyVideo video) {
    if (!_downloads.contains(video)) {
      _downloads.add(video);
      notifyListeners();
    }
  }

  void removeDownload(MyVideo video) {
    if (_downloads.remove(video)) {
      notifyListeners();
    }
  }

  bool isDownloaded(MyVideo video) {
    return _downloads.contains(video);
  }

  // Fetch downloads asynchronously. Replace the simulated logic with actual fetch logic if needed.
  Future<void> fetchDownloads() async {
    // Simulate a delay for fetching downloads.
    await Future.delayed(const Duration(milliseconds: 300));

    // Update _downloads list with fetched data.
    // For example:
    // _downloads.clear();
    // _downloads.addAll(fetchedDownloads);

    // Notify listeners so the UI updates immediately.
    notifyListeners();
  }
}
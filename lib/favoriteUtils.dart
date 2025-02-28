import 'package:youtube_scrape_api/models/video.dart';
import 'package:localstore/localstore.dart';

final db = Localstore.instance;

Future<List<Video>> getFavorites() async {
  List<Video>watchLaterList = [];
  final favorites = await db.collection('favorites').get();

  print(favorites);
  return watchLaterList;
}

void saveToFavorites(Video video) {
  final id = video.videoId;

  db.collection('favorites').doc(id).set({
    'videoId': video.videoId,
    'duration': video.duration,
    'title': video.title,
    'channelName': video.channelName,
    'views': video.views,
    'uploadDate': video.uploadDate,
  });
}

void removeFavorites(Video video) {
  String? videoId = video.videoId;
  db.collection('favorites').doc(videoId).delete();
}

bool isFavorites(Video video) {
  String? videoId = video.videoId;
  db.collection('favorites').doc(videoId).get().then((value) {
    if (value == null) {
      return false;
    }
    return value.isEmpty;
  });
  return false;
}
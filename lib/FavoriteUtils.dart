import 'package:youtube_scrape_api/models/video.dart';
import 'package:localstore/localstore.dart';

final db = Localstore.instance;

Future<List<Video>> getFavorites() async {
  List<Video>watchLaterList = [];
  final favorites = await db.collection('favorites').get();
  final favoritesString = [];
  favorites?.forEach((key, value) => favoritesString.addAll(value));

  for (var favorite in favoritesString) {
    final favoriteElement = await db.collection('favorites').doc(favorite).get();
    Video video = Video(
      videoId: favorite.videoId,
      duration: favorite.duration,
      title: favorite.title,
      channelName: favorite.channelName,
      views: favorite.views,
      uploadDate: favorite.uploadDate,
    );
  }
  return watchLaterList;
}

void saveToFavorites(Video video) {
  final id = db.collection('favorites').doc().id;

  db.collection('favorites').doc(id).set({
    'videoId': video.videoId,
    'duration': video.duration,
    'title': video.title,
    'channelName': video.channelName,
    'views': video.views,
    'uploadDate': video.uploadDate,
  });
}

void removeFavorites(String youtubeurlid) {
  db.collection('favorites').doc(youtubeurlid).delete();
}

import 'package:youtube_scrape_api/models/video.dart';
import 'package:localstore/localstore.dart';

final db = Localstore.instance;

Future<List<Video>> getFavorites() async {
  List<Video>favoriteList = [];
  final favorites = await db.collection('favorites').get();
  Iterable? values = favorites?.values;
  for (final value in values!) {
    Video video = Video(
      videoId: value['videoId'],
      duration: value['duration'],
      title: value['title'],
      channelName: value['channelName'],
      views: value['views'],
      uploadDate: value['uploadDate'],
    );
    favoriteList.add(video);
  }
  return favoriteList;
}

void saveToFavorites(Video video) {
  final id = video.videoId;
  print("added to favs");
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
    return value.isNotEmpty;
  });
  return false;
}
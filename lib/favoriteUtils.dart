

import 'package:localstore/localstore.dart';
import 'package:youtube_scrape_api/models/thumbnail.dart';
import 'package:youtube_scrape_api/models/video.dart';

final db = Localstore.instance;

Future<List<Video>> getFavorites() async {
  List<Video>favoriteList = [];
  final favorites = await db.collection('favorites').get();
  Iterable? values = favorites?.values;

  for (final value in values!) {
    Thumbnail thumbnail = Thumbnail(
        url: value['url'],
        height: value['height'],
        width: value['width']
    );
    List<Thumbnail> thumbnails = [];
    thumbnails.add(thumbnail);

    Video video = Video(
      videoId: value['videoId'],
      duration: value['duration'],
      title: value['title'],
      channelName: value['channelName'],
      views: value['views'],
      uploadDate: value['uploadDate'],
      thumbnails: thumbnails
    );
    favoriteList.add(video);
  }
  return favoriteList;
}

void saveToFavorites(Video video) {
  final id = video.videoId;
  final thumbnail = video.thumbnails?.first;

  db.collection('favorites').doc(id).set({
    'videoId': video.videoId,
    'duration': video.duration,
    'title': video.title,
    'channelName': video.channelName,
    'views': video.views,
    'uploadDate': video.uploadDate,
    'url': thumbnail?.url,
    'height': thumbnail?.height,
    'weight': thumbnail?.width,
  });
}

void removeFavorites(Video video) {
  final id = video.videoId;
  db.collection('favorites').doc(id).delete();
}

bool isFavorites(Video video) {
  final id = video.videoId;

  final favorite = db.collection('favorites').get();
  return false;
}
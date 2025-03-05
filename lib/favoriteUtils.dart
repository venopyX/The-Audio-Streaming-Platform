import 'package:localstore/localstore.dart';
import 'package:youtube_scrape_api/models/thumbnail.dart';
import 'package:youtube_scrape_api/models/video.dart';


final db = Localstore.instance;

Future<List<Video>> getFavorites() async {
  List<Video>favoriteList = [];
  final favorites = await db.collection('favorites').get();
  Iterable? values = favorites?.values;

  if (values != null) { // Add null check here
    for (final value in values) {
      Thumbnail thumbnail = Thumbnail(
          url: value['url'],
          height: value['height'],
          width: value['width']);
      List<Thumbnail> thumbnails = [];
      thumbnails.add(thumbnail);

      Video video = Video(
          videoId: value['videoId'],
          duration: value['duration'],
          title: value['title'],
          channelName: value['channelName'],
          views: value['views'],
          uploadDate: value['uploadDate'],
          thumbnails: thumbnails);
      favoriteList.add(video);
    }
  }
  return favoriteList;
}


Future<bool> saveToFavorites(Video video) async {
  final id = video.videoId;
  final thumbnail = video.thumbnails?.isNotEmpty == true ? video.thumbnails!.first : null;

  try {
    await db.collection('favorites').doc(id).set({
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
    print("Video saved to favorites successfully.");
    return true; // Indicate success
  } catch (e) {
    print("Error saving video to favorites: $e");
    return false; // Indicate failure
  }
}

Future<bool> removeFavorites(Video video) async {
  final id = video.videoId;

  try {
    await db.collection('favorites').doc(id).delete();
    print("Video removed from favorites successfully.");
    return true; // Indicate success
  } catch (e) {
    print("Error removing video from favorites: $e");
    return false; // Indicate failure
  }
}

Future<bool> isFavorites(Video video) async {
  final id = video.videoId;
  try {
    final favorite = await db.collection('favorites').doc(id).get();
    return favorite != null; // Returns true if document exists, false otherwise
  } catch (e) {
    print("Error checking if video is in favorites: $e");
    return false; // Return false in case of an error
  }
}
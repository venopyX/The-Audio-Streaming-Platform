import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_scrape_api/models/video.dart';
import 'fetchYoutubeStreamUrl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:localstore/localstore.dart';
import 'package:youtube_scrape_api/models/thumbnail.dart';
import 'package:audiobinge/MyVideo.dart';
final db = Localstore.instance;

Future<void> downloadAndSaveMetaData(MyVideo video) async{
  String audiopath = await downloadAudio(video.videoId!, '${video.channelName!}-${video.title!}');
  String imagepath = await downloadImageFromUrl(video.thumbnails!.first.url!, '${video.channelName!}-${video.title!}');

  if(audiopath != "none"){
      await saveToDownloads(video, audiopath,imagepath);
  }

}
Future<String> downloadAudio(String id, String fileName) async {
  try {
    String? audioUrl = await fetchYoutubeStreamUrl(id);
    if (audioUrl == null) {
      print("Failed to get audio stream.");
      return "none";
    }

    String path = await getDownloadPath();
    String savePath = '$path/$fileName.mp3';

    Dio dio = Dio();
    await dio.download(audioUrl, savePath, onReceiveProgress: (received, total) {
      if (total != -1) {
        print('Downloading: ${(received / total * 100).toStringAsFixed(0)}%');
      }
    });

    print("Download complete: $savePath");
    return savePath;
  } catch (e) {
    print("Download failed: $e");
    return "none";
  }
}
Future<String> downloadImageFromUrl(String imageUrl, String fileName) async {
  try {
    if (imageUrl == null || imageUrl.isEmpty) {
      print("Image URL is invalid.");
      return "none";
    }

    String path = await getDownloadPath();
    String savePath = '$path/$fileName.jpg'; // Assuming jpg format, adjust if needed

    Dio dio = Dio();
    await dio.download(imageUrl, savePath, onReceiveProgress: (received, total) {
      if (total != -1) {
        print('Downloading image: ${(received / total * 100).toStringAsFixed(0)}%');
      }
    });

    print("Image download complete: $savePath");
    return savePath;
  } catch (e) {
    print("Image download failed: $e");
    return "none";
  }
}
Future<String> getDownloadPath() async {
  Directory directory = await getApplicationDocumentsDirectory(); // Internal storage
  return directory.path;
}



Future<bool> requestStoragePermission() async {
  PermissionStatus status = await Permission.storage.request();
  return status.isGranted;
}

Future<bool> saveToDownloads(MyVideo video,String audiopath, String imagepath) async {
  final id = video.videoId;
  final thumbnail = video.thumbnails?.isNotEmpty == true ? video.thumbnails!.first : null;
  print(audiopath);
  print(imagepath);
  try {
    await db.collection('downloads').doc(id).set({
      'videoId': video.videoId,
      'duration': video.duration,
      'title': video.title,
      'channelName': video.channelName,
      'views': video.views,
      'uploadDate': video.uploadDate,
      'url': thumbnail?.url,
      'height': thumbnail?.height,
      'weight': thumbnail?.width,
      'localaudio':audiopath,
      'localimage':imagepath
    });
    print("Video saved to download successfully.");
    return true; // Indicate success
  } catch (e) {
    print("Error saving video to download: $e");
    return false; // Indicate failure
  }
}

Future<List<MyVideo>> getDownloads() async {
  List<MyVideo>favoriteList = [];
  final favorites = await db.collection('downloads').get();
  Iterable? values = favorites?.values;

  if (values != null) { // Add null check here
    for (final value in values) {
      Thumbnail thumbnail = Thumbnail(
          url: value['url'],
          height: value['height'],
          width: value['width']);
      List<Thumbnail> thumbnails = [];
      thumbnails.add(thumbnail);

      MyVideo video = MyVideo(
          videoId: value['videoId'],
          duration: value['duration'],
          title: value['title'],
          channelName: value['channelName'],
          views: value['views'],
          uploadDate: value['uploadDate'],
          thumbnails: thumbnails,
          localaudio: value['localaudio'],
          localimage: value['localimage']
      );
      favoriteList.add(video);
    }
  }
return favoriteList;
}

Future<bool> isDownloaded(MyVideo video) async {
  final id = video.videoId;
  try {
    final favorite = await db.collection('downloads').doc(id).get();
    return favorite != null; // Returns true if document exists, false otherwise
  } catch (e) {
    print("Error checking if video is in favorites: $e");
    return false; // Return false in case of an error
  }
}


Future<bool> deleteDownload(MyVideo video) async {
  final id = video.videoId;
  try {
    // Delete the document from Firestore
    await db.collection('downloads').doc(id).delete();

    // Delete the audio file
    if (video.localaudio != null && video.localaudio!.isNotEmpty) {
      File audioFile = File(video.localaudio!);
      if (await audioFile.exists()) {
        await audioFile.delete();
        print("Audio file deleted: ${video.localaudio}");
      } else {
        print("Audio file not found: ${video.localaudio}");
      }
    }

    // Delete the image file
    if (video.localimage != null && video.localimage!.isNotEmpty) {
      File imageFile = File(video.localimage!);
      if (await imageFile.exists()) {
        await imageFile.delete();
        print("Image file deleted: ${video.localimage}");
      } else {
        print("Image file not found: ${video.localimage}");
      }
    }

    print("Video deleted from downloads successfully.");
    return true; // Indicate success
  } catch (e) {
    print("Error deleting video from downloads: $e");
    return false; // Indicate failure
  }
}
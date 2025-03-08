import 'package:youtube_scrape_api/models/thumbnail.dart';
import 'package:youtube_scrape_api/models/video.dart';
class MyVideo extends Video {
  final String? localimage;
  late final String? localaudio;
  // Add more custom fields as needed

  MyVideo({
    String? videoId,
    String? duration,
    String? title,
    String? channelName,
    String? views,
    String? uploadDate,
    List<Thumbnail>? thumbnails,
    this.localimage,
    this.localaudio,
    // Add custom fields to the constructor
  }) : super(
    videoId: videoId,
    duration: duration,
    title: title,
    channelName: channelName,
    views: views,
    uploadDate: uploadDate,
    thumbnails: thumbnails,
  );

  factory MyVideo.fromMap(Map<String, dynamic>? map, {String? localimage, String? localaudio}) {
    Video video = Video.fromMap(map); // Create a regular Video object first

    return MyVideo(
      videoId: video.videoId,
      duration: video.duration,
      title: video.title,
      channelName: video.channelName,
      views: video.views,
      uploadDate: video.uploadDate,
      thumbnails: video.thumbnails,
      localimage: localimage,
      localaudio: localaudio,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> videoJson = super.toJson();
    videoJson.addAll({
      "localimage": localimage,
      "localaudio": localaudio,
    });
    return videoJson;
  }
}


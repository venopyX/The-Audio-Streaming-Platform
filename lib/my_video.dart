import 'package:youtube_scrape_api/models/video.dart';
class MyVideo extends Video {
  final String? localimage;
  late final String? localaudio;
  // Add more custom fields as needed

  MyVideo({
    super.videoId,
    super.duration,
    super.title,
    super.channelName,
    super.views,
    super.uploadDate,
    super.thumbnails,
    this.localimage,
    this.localaudio,
    // Add custom fields to the constructor
  });

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

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> videoJson = super.toJson();
    videoJson.addAll({
      "localimage": localimage,
      "localaudio": localaudio,
    });
    return videoJson;
  }
}


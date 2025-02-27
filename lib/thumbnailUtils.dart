import 'package:youtube_scrape_api/models/video.dart'; // Import your Video class
import 'package:youtube_scrape_api/models/thumbnail.dart';

Thumbnail? getHighestQualityThumbnail(List<Thumbnail>? thumbnails) {
  if (thumbnails == null || thumbnails.isEmpty) {
    return null;
  }

  List<Thumbnail> sortedThumbnails = List.from(thumbnails);
  sortedThumbnails.sort((a, b) => b.width!.compareTo(a.width!));

  return sortedThumbnails.first;
}

Video processVideoThumbnails(Video video) {
  Thumbnail? highestThumbnail = getHighestQualityThumbnail(video.thumbnails);
  if (highestThumbnail != null) {
    return Video(
      videoId: video.videoId,
      duration: video.duration,
      title: video.title,
      channelName: video.channelName,
      views: video.views,
      uploadDate: video.uploadDate,
      thumbnails: [highestThumbnail],
    );
  } else {
    return video; // Return the original video if no thumbnails
  }
}
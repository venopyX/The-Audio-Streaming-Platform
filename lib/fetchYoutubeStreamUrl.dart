import 'package:youtube_explode_dart/youtube_explode_dart.dart';

Future<String> fetchYoutubeStreamUrl(String id) async{
  final yt = YoutubeExplode();
  final manifest = await yt.videos.streams.getManifest(id,
      // You can also pass a list of preferred clients, otherwise the library will handle it:
      ytClients: [
        YoutubeApiClient.ios,
        YoutubeApiClient.androidVr,
      ]);

  // Print all the available streams.
  print(manifest);
  final audio = manifest.audioOnly.withHighestBitrate();

  yt.close();
  return audio.url.toString();
}

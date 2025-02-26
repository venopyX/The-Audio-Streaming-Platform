import 'package:flutter/material.dart';
import 'YoutubeAudioStream.dart';
import 'main.dart';
import 'package:provider/provider.dart';


class BottomPlayer extends StatefulWidget {
  const BottomPlayer({super.key});

  @override
  State<BottomPlayer> createState() => _BottomPlayerState();
}

class _BottomPlayerState extends State<BottomPlayer> {
  @override
  Widget build(BuildContext context) {
    final playing = Provider.of<Playing>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        height: 59,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 83, 83, 83),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(5),
            topRight: Radius.circular(5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 250),
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                          YoutubeAudioPlayer(videoId: 'fRh_vgS2dFE'),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 1.0);
                            const end = Offset.zero;

                            final tween = Tween(begin: begin, end: end);
                            final offsetAnimation = animation.drive(tween);
                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 37,
                            width: 37,
                            decoration: BoxDecoration(
                              image:  DecorationImage(
                                image: NetworkImage(playing.video.thumbnails![0].url!),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                           SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width - 140,
                                height: 20,
                                child:  Text(
                                  playing.video.title!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontFamily: "AM",
                                    color: Colors.white,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                               Text(
                                playing.video.channelName!,
                                style: TextStyle(
                                  fontFamily: "AM",
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              playing.setIsPlaying(!playing.isPlaying);
                            },
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: playing.isPlaying
                                  ?Icon( Icons.pause)
                                  : Icon(Icons.play_arrow),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SliderTheme(
                data: SliderThemeData(
                  overlayShape: SliderComponentShape.noOverlay,
                  thumbShape: SliderComponentShape.noThumb,
                  trackShape: const RectangularSliderTrackShape(),
                  trackHeight: 3,
                ),
                child: SizedBox(
                  height: 8,
                  child: Slider(
                    activeColor: const Color.fromARGB(255, 230, 229, 229),
                    inactiveColor: Colors.grey,

                    value:playing.duration.inSeconds>0.0?playing.position.inSeconds / playing.duration.inSeconds:0.0,
                    onChanged: (onChanged) {},
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
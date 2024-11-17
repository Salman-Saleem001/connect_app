import 'package:connect_app/screens/splash/splash_first.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SplashVideo extends StatefulWidget {
  const SplashVideo({super.key});

  @override
  State<SplashVideo> createState() => _SplashVideoState();
}

class _SplashVideoState extends State<SplashVideo> {

  late VideoPlayerController controller;

  @override
  void initState() {
    // TODO: implement initState
    controller = VideoPlayerController.asset('assets/video/intro.mp4')
      ..initialize().then((_) {
        setState(() {}); // Ensure UI updates when the video is ready
        controller.play(); // Start playing the video
      });

    controller.addListener(() {
      if (controller.value.position == controller.value.duration) {
        // Navigate to another screen when video finishes
        Future.delayed(Duration(seconds: 1)).whenComplete((){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SplashFirst()),
          );
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: VideoPlayer(controller),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }
}

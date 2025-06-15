import 'dart:io';

import 'package:connect_app/screens/splash/splash_first.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    controller = VideoPlayerController.asset('assets/video/intro.mp4')
      ..initialize().then((_) {
        setState(() {}); // Ensure UI updates when the video is ready
        controller.play();// Start playing the video
        Future.delayed(Duration(seconds:5 )).whenComplete((){
          debugPrint("Getting Called");
          Get.off(()=> SplashFirst());
        });
      });

    // controller.addListener(() {
    //   if (controller.value.position == controller.value.duration) {
    //     // Navigate to another screen when video finishes
    //     debugPrint("Getting Called");
    //
    //   }
    // });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.size.width,
            height: controller.value.size.height,
            child: VideoPlayer(controller),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

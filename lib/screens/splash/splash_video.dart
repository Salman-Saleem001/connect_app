import 'dart:io';

import 'package:connect_app/screens/splash/splash_first.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../utils/app_colors.dart';

class SplashVideo extends StatefulWidget {
  const SplashVideo({super.key});

  @override
  State<SplashVideo> createState() => _SplashVideoState();
}

class _SplashVideoState extends State<SplashVideo> with SingleTickerProviderStateMixin {
  late VideoPlayerController controller;
  late AnimationController _fadeController;

  @override
  void initState() {
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1250));
    controller = VideoPlayerController.asset('assets/video/intro.mp4')
      ..initialize().then((_) {
        setState(() {}); // Ensure UI updates when the video is ready
        controller.play(); // Start playing the video
        Future.delayed(Duration(seconds: 7)).whenComplete(() {
          Get.off(() => SplashFirst());
        });
      });

    controller.addListener(() {
      Future.delayed(Duration(seconds: 5)).whenComplete((){
        _fadeController.forward();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: FadeTransition(
              opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_fadeController), child: VideoPlayer(controller)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }
}

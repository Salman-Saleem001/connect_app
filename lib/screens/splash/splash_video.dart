
import 'package:connect_app/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';


class SplashVideo extends StatefulWidget {
  const SplashVideo({super.key});

  @override
  State<SplashVideo> createState() => _SplashVideoState();
}

class _SplashVideoState extends State<SplashVideo> with SingleTickerProviderStateMixin {
  late VideoPlayerController controller;
  // late AnimationController _fadeController;

  @override
  void initState() {
    initializeVideoController().whenComplete((){
      controller.addListener(() {
        if(controller.value.position == controller.value.duration){
          debugPrint("Running.............");
          Get.off(() => SplashScreen());
        }
      });
    });
    super.initState();
  }

  Future<void> initializeVideoController() async {
    try{
      controller = VideoPlayerController.asset('assets/video/intro.mp4');
      await controller.initialize().then((_) {
          setState(() {}); // Ensure UI updates when the video is ready
          controller.play(); // Start playing the video
        });
    }catch(e) {
      debugPrint('Error initializing video controller: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
          // child: FadeTransition(
          //     opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_fadeController), child: ),
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

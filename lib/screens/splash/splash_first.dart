import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connect_app/screens/splash/splash_screen.dart';
import 'package:connect_app/utils/app_colors.dart';

class SplashFirst extends StatelessWidget {
  const SplashFirst({super.key});


  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      child: null,
      curve: Curves.easeInExpo,
      onEnd: () {
        Get.off(()=> SplashScreen());
      },
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(seconds: 3),
      builder: (BuildContext context, double value, Widget? child) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/images/bg_image1.png'))
          ),
          child: SizedBox.expand(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB( 20, 500,20,0),
                child: LinearProgressIndicator(
                  value: value,
                  color: AppColors.primaryColor,
                  backgroundColor: Colors.grey,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

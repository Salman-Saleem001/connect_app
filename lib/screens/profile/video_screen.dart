import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../globals/video_view.dart';
import '../../utils/app_colors.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key, required this.url});

  final String url;


  @override
  Widget build(BuildContext context) {
    return Card(
      shape: InputBorder.none,
      color: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          VideoView(
            url: url,
          ),
          Positioned(
            top: 70,
            left: 15,
            child: GestureDetector(
              onTap: () {
                Get.back();
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white,
                  border: Border.all(
                    color: AppColors.borderColor,
                    width: 1.0,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 20,
                  color: AppColors.primaryIconColor,
                ).paddingAll(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

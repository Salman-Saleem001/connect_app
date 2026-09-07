import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../globals/adaptive_helper.dart';
import '../../../../globals/container_properties.dart';
import '../../../../utils/app_colors.dart';

class ImageView extends StatelessWidget {
  final String url;
  const ImageView(this.url, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          Container(
            color: Colors.black,
            height: double.infinity,
            width: double.infinity,
            child: InteractiveViewer(
                child: CachedNetworkImage(
              imageUrl: url,
              progressIndicatorBuilder: (context, url, downloadProgress) => Padding(
                padding: const EdgeInsets.all(20.0),
                child: CircularProgressIndicator(
                    backgroundColor: AppColors.primaryColor, color: Colors.grey, value: downloadProgress.progress),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            )),
          ),
          Positioned(
            top: 20,
            left: 5,
            child: SafeArea(
              child: InkWell(
                onTap: () {
                  Get.back();
                },
                child: Center(
                  child: Container(
                    margin: EdgeInsets.only(left: 18, top: 10),
                    decoration: ContainerProperties.simpleDecoration(radius: 10, color: AppColors.primaryColor),
                    alignment: Alignment.center,
                    height: ht(37),
                    width: wd(32),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.white,
                      size: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

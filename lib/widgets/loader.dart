import 'package:connect_app/globals/app_views.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Loader {
  static showLoadingDialogue() {
    return showDialog(
        barrierDismissible: false,
        context: Get.overlayContext!,
        builder: (context) => Container(
              child: AppViews.showLoading(),
            ));
  }

  static dismiss() {
    Get.back();
  }
}

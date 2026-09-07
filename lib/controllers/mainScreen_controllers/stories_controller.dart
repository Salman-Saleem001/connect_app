import 'dart:developer';
import 'dart:io';

import 'package:connect_app/models/stories_model.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../globals/enum.dart';
import '../../globals/global.dart';
import '../../services/http_services.dart';
import '../../utils/login_details.dart';

class StoriesController extends GetxController {
  StoriesModel stories = StoriesModel();
  bool isLoading = true;

  @override
  onInit() {
    getStories();
    super.onInit();
  }

  // Create Stories Post Method

  Future<bool> createStories({required File selectedFile, required String caption}) async {
    log("Getting Run createStories");
    EasyLoading.show();
    var response = await HttpsServices.userStory(
        token: Get.find<UserDetail>().userData.token.toString(), caption: caption, selectedFile: selectedFile);

    if (response == null) {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "Message",
          strMsg: 'Something Went Wrong. Try Checking Your Internet Connect',
          toastType: TOAST_TYPE.toastError);
    } else if (response != null) {
      log("Here is my response===> $response");
      EasyLoading.dismiss();
      return true;
    } else {
      Global.showToastAlert(
          context: Get.overlayContext!, strTitle: "Message", strMsg: response, toastType: TOAST_TYPE.toastError);
    }

    EasyLoading.dismiss();
    return false;
  }

  Future<void> getStories() async {
    // debugPrint("Getting Run====>${Get.find<UserDetail>().userData.token.toString()}");

    EasyLoading.show();
    isLoading = true;
    update();
    var response = await HttpsServices.getStories(token: Get.find<UserDetail>().userData.token.toString());

    if (response == null) {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "Message",
          strMsg: 'Something Went Wrong. Try Checking Your Internet Connect',
          toastType: TOAST_TYPE.toastError);
    } else if (response is StoriesModel) {
      stories = response;
      log("Here is my Stories response===> ${response.toJson()}");
    } else {
      log("Error is my Stories response");

      Global.showToastAlert(
          context: Get.overlayContext!, strTitle: "Message", strMsg: response, toastType: TOAST_TYPE.toastError);
    }
    isLoading = false;
    update();
    EasyLoading.dismiss();
  }

  Future<void> viewStories({required int index, bool isSelf = false}) async {
    int id;
    if (isSelf) {
      if (stories.myStories?[index].isViewed == true) return;
      id = stories.myStories?[index].id ?? 0;
    } else {
      if (stories.feed?[index].isViewed == true) return;
      id = stories.feed?[index].id ?? 0;
    }

    HttpsServices.viewStories(id: id, token: Get.find<UserDetail>().userData.token.toString()).then((val) {
      if (val) {
        if (isSelf) {
          stories.myStories?[index].isViewed = true;
        } else {
          stories.feed?[index].isViewed = true;
        }
        update();
      }
    });
  }
}

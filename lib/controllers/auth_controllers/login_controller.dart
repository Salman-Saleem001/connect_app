import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../globals/database.dart';
import '../../globals/enum.dart';
import '../../globals/global.dart';
import '../../models/user.dart';
import '../../screens/main_screens/bottom_bar_screen.dart';
import '../../services/firebase_utils.dart';
import '../../services/http_services.dart';
import '../../utils/login_details.dart';

class LoginController extends GetxController {
  bool isRememberMe = false;
  bool obscure = true;
  String? token;

  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();

  FocusNode focusNodeEmail = FocusNode();


  storeToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    bool? check= sharedPreferences.getBool('notificationStatus')??true;
    if(check) {
      token = await FirebaseUtils().getToken();
    }else{
      token= '1';
    }
  }

  FocusNode focusNodePassword = FocusNode();

  TextEditingController controllerPhone = TextEditingController();

  FocusNode focusNodePhone = FocusNode();

  rememberMe(bool value) {
    isRememberMe = value;
    update();
  }

  toggle() {
    obscure = !obscure;
    update();
  }

  bool validation() {
    if (!Global.checkNull(controllerEmail.text.toString().trim())) {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "",
          strMsg: 'Please enter email',
          toastType: TOAST_TYPE.toastError);
      FocusScope.of(Get.overlayContext!).requestFocus(focusNodeEmail);
      return false;
    }
    if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(controllerEmail.text.toString().trim())) {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "",
          strMsg: 'Please enter a valid email',
          toastType: TOAST_TYPE.toastError);
      FocusScope.of(Get.overlayContext!).requestFocus(focusNodeEmail);
      return false;
    }
    if (!Global.checkNull(controllerPassword.text.toString().trim())) {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "ok",
          strMsg: 'Please enter password',
          toastType: TOAST_TYPE.toastError);
      FocusScope.of(Get.overlayContext!).requestFocus(focusNodePassword);
      return false;
    }

    return true;
  }

  var isLoading = false;

  forgetPassword() async {
    if (!validation()) return;
    try {} catch (e) {}

    Get.to(() => const NavBarScreen());
  }

  Future<void> getLogin() async {
    try {
      EasyLoading.show();
      var response = await HttpsServices.userLogin(
          email: controllerEmail.text.trim(),
          password: controllerPassword.text.trim(),
          fcmToken: token ?? '');
      EasyLoading.dismiss();

      if (response is UserModel) {
        if (kDebugMode) {
          print('user logged in with token = ${response.token}');
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("userJson", jsonEncode(response));

        Get.offAll(() => const NavBarScreen());
        var user = Get.put(UserDetail());
        await user.getUserData();
        Database().initializeUser();
        Global.showToastAlert(
            context: Get.overlayContext!,
            strTitle: "Success",
            strMsg: 'User Logged In Successfully',
            toastType: TOAST_TYPE.toastSuccess);
      } else if (response == null) {
        Global.showToastAlert(
            context: Get.overlayContext!,
            strTitle: "Failure",
            strMsg: 'Something went wrong. Please Try Again',
            toastType: TOAST_TYPE.toastError);
      } else {
        Global.showToastAlert(
            context: Get.overlayContext!,
            strTitle: "Failure",
            strMsg: response,
            toastType: TOAST_TYPE.toastError);
      }
    } catch (e) {
      EasyLoading.dismiss();
      if (kDebugMode) {
        print(e);
      }
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "ok",
          strMsg: 'Email or Password are incorrect. Please try again',
          toastType: TOAST_TYPE.toastError);
    }
  }
}

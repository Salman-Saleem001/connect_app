import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  @override
  void onInit() {
    super.onInit();
    storeToken();
  }

  Future<void> storeToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool? check = sharedPreferences.getBool('notificationStatus') ?? true;
    if (check) {
      token = await FirebaseUtils().getToken();
    } else {
      token = '1';
    }
  }

  FocusNode focusNodePassword = FocusNode();

  TextEditingController controllerPhone = TextEditingController();

  FocusNode focusNodePhone = FocusNode();

  void rememberMe(bool value) {
    isRememberMe = value;
    update();
  }

  void toggle() {
    obscure = !obscure;
    update();
  }

  bool validation() {
    if (!Global.checkNull(controllerEmail.text.toString().trim())) {
      Global.showToastAlert(
          context: Get.overlayContext!, strTitle: "", strMsg: 'Please enter email', toastType: TOAST_TYPE.toastError);
      FocusScope.of(Get.overlayContext!).requestFocus(focusNodeEmail);
      return false;
    }
    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
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

  Future<void> forgetPassword() async {
    if (!validation()) return;
    try {} catch (e) {}

    Get.to(() => const NavBarScreen());
  }

  Future<void> getLogin() async {
    try {
      EasyLoading.show();
      var response = await HttpsServices.userLogin(
          email: controllerEmail.text.trim(), password: controllerPassword.text.trim(), fcmToken: token ?? '');
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
            context: Get.overlayContext!, strTitle: "Failure", strMsg: response, toastType: TOAST_TYPE.toastError);
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

  Future<void> socialLoginApi({required String provider, required String socialToken}) async {
    try {
      EasyLoading.show();
      var response =
          await HttpsServices.socialLogin(fcmToken: token ?? '', socialToken: socialToken, provider: provider);
      EasyLoading.dismiss();
      if (response is UserModel) {
        debugPrint('user logged in with token = ${response.token}');

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
            context: Get.overlayContext!, strTitle: "Failure", strMsg: response, toastType: TOAST_TYPE.toastError);
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

  Future<void> handleAppleSignIn({required BuildContext context}) async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      if (credential.identityToken != null) {
        socialLoginApi(provider: "apple", socialToken: credential.identityToken!);
      }
    } catch (error) {
      debugPrint("handleAppleSignIn error -->$error");
    }
  }

  Future<void> handleGoogleSignIn({required BuildContext context}) async {
    try {
      await _googleSignIn.initialize();
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(scopeHint: [
        'email',
        'profile',
        'openid',
      ]);
      final GoogleSignInClientAuthorization? googleAuth = await googleUser.authorizationClient.authorizationForScopes([
        'email',
        'profile',
        'openid',
      ]);
      final GoogleSignInAuthentication googleAuthId = googleUser.authentication;

      if (googleAuth != null) {
        debugPrint("googleAuthId.idToken -->${googleAuthId.idToken}");
        socialLoginApi(provider: "google", socialToken: googleAuthId.idToken ?? "");
      }
    } catch (e) {
      debugPrint("handleGoogleSignIn error -->$e");
    }
  }
}

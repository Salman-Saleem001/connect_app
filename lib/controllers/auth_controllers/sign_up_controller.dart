// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../globals/enum.dart';
import '../../globals/global.dart';
import '../../services/http_services.dart';

class SignUpController extends GetxController {
  bool isDoctor = false;

  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerFirstName = TextEditingController();
  TextEditingController controllerLastName = TextEditingController();
  TextEditingController controllerPhone = TextEditingController();
  TextEditingController controllerConfirmPassword = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  TextEditingController controllerProfession = TextEditingController();
  TextEditingController controllerRegistration = TextEditingController();
  TextEditingController controllerNational = TextEditingController();
  TextEditingController controllerGender = TextEditingController();
  TextEditingController controllerVisa = TextEditingController();
  TextEditingController controllerUserName = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController controllerSearchPrefs = TextEditingController();

  int specId = 0;
  int genderId = 0;
  int nationalId = 0;
  int workPermiId = 0;

  FocusNode focusNodeEmail = FocusNode();
  FocusNode focusNodeFirstName = FocusNode();
  FocusNode focusNodeLastName = FocusNode();
  FocusNode focusNodePhone = FocusNode();
  FocusNode focusNodeConfirm = FocusNode();
  FocusNode focusNodePassword = FocusNode();
  FocusNode focusNodeProfession = FocusNode();
  FocusNode focusNodeRegistration = FocusNode();
  FocusNode focusNodeNational = FocusNode();
  FocusNode focusNodeDob = FocusNode();
  FocusNode focusNodeVisa = FocusNode();
  FocusNode focusSearchPrefs = FocusNode();
  FocusNode userNameNode = FocusNode();
  FocusNode bioNode = FocusNode();

  LatLng latlng = const LatLng(0, 0);
  List<String> selectedPreferences = [];

  dynamic name;

  bool terms = false;

  bool obscure = true;

  changeTerms() {
    terms = !terms;
    update();
  }

  changePerson() {
    isDoctor = !isDoctor;
    update();
  }

  Future<bool> initvalidation() async {
    if (!Global.checkNull(controllerFirstName.text.toString().trim())) {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "",
          strMsg: 'Please enter first name',
          toastType: TOAST_TYPE.toastError);
      FocusScope.of(Get.overlayContext!).requestFocus(focusNodeFirstName);
      return false;
    }
    if (!Global.checkNull(controllerLastName.text.toString().trim())) {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "",
          strMsg: 'Please enter last name',
          toastType: TOAST_TYPE.toastError);
      FocusScope.of(Get.overlayContext!).requestFocus(focusNodeLastName);
      return false;
    }
    // if (!Global.checkNull(controllerPhone.text.toString().trim())) {
    //   Global.showToastAlert(
    //       context: Get.overlayContext!,
    //       strTitle: "",
    //       strMsg: 'Please enter phone number',
    //       toastType: TOAST_TYPE.toastError);
    //   FocusScope.of(Get.overlayContext!).requestFocus(focusNodePhone);
    //   return false;
    // }

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
    if (!(controllerPassword.text.length > 7)) {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "ok",
          strMsg: 'Password must be at least 8 characters long',
          toastType: TOAST_TYPE.toastError);
      FocusScope.of(Get.overlayContext!).requestFocus(focusNodePassword);
      return false;
    }
    if ((controllerConfirmPassword.text != controllerPassword.text)) {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "ok",
          strMsg: 'Password must match',
          toastType: TOAST_TYPE.toastError);
      FocusScope.of(Get.overlayContext!).requestFocus(focusNodeConfirm);
      return false;
    }
    if ((!terms)) {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "ok",
          strMsg: 'You must be agreed with out terms & condition',
          toastType: TOAST_TYPE.toastError);
      return false;
    }
    return true;
  }

  var isLoading = false;

  Future<void> createUser() async {
    try {
      if (!(await initvalidation())) {
        return;
      }
      EasyLoading.show();

     var response =  await HttpsServices.userSignUP(
          email: controllerEmail.text.trim(),
          password: controllerPassword.text.trim(),
          confirmPassword: controllerConfirmPassword.text.trim(),
          firstName: controllerFirstName.text.trim(),
          lastName: controllerLastName.text.trim(),
          userName: controllerUserName.text.trim(),
          phone: controllerPhone.text.trim(),
          preferences: selectedPreferences,
          bio: bioController.text.trim()
      );
     print("response$response");
      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.dismiss();
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "",
          strMsg: e.toString(),
          toastType: TOAST_TYPE.toastError);
    }
  }

  // Future<void> resestPassowrd() async {
  //   try {
  //     if (!Global.checkNull(controllerEmail.text.toString().trim())) {
  //       Global.showToastAlert(
  //           context: Get.overlayContext!,
  //           strTitle: "",
  //           strMsg: 'Please enter email',
  //           toastType: TOAST_TYPE.toastError);
  //       FocusScope.of(Get.overlayContext!).requestFocus(focusNodeEmail);
  //       return;
  //     }
  //     EasyLoading.show();
  //     await FirebaseAuth.instance
  //         .sendPasswordResetEmail(email: controllerEmail.text.trim());
  //
  //     controllerEmail.clear();
  //     Global.showToastAlert(
  //         context: Get.overlayContext!,
  //         strTitle: "",
  //         strMsg:
  //         'If the email you provided exists in our databases as a valid user, you will receive an email with reset instructions',
  //         toastType: TOAST_TYPE.toastSuccess);
  //     EasyLoading.dismiss();
  //     Get.back();
  //     update();
  //   } on FirebaseAuthException catch (e) {
  //     EasyLoading.dismiss();
  //     if (e.code == 'user-not-found') {
  //       Global.showToastAlert(
  //           context: Get.overlayContext!,
  //           strTitle: "ok",
  //           strMsg:
  //           "We couldn't find an account with the provided email address",
  //           toastType: TOAST_TYPE.toastError);
  //     }
  //   }
  // }
}



import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';



class ForgetPasswordController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController otp = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  FocusNode emailNode = FocusNode();
  FocusNode passwordNode = FocusNode();
  FocusNode confirmPasswordNode = FocusNode();
  bool obscure = true;
  changeObscure() {
    obscure = !obscure;
    update();
  }

  bool confirmObscure = true;
  changeObscureConfirm() {
    confirmObscure = !confirmObscure;
    update();
  }

  bool isLoading = false;

  forgetPassword() async {
    // if (!Global.checkNull(emailController.text.toString().trim())) {
    //   Global.showToastAlert(
    //       context: Get.overlayContext!,
    //       strTitle: "",
    //       strMsg: 'Please enter email',
    //       toastType: TOAST_TYPE.toastError);
    //   FocusScope.of(Get.overlayContext!).requestFocus(emailNode);
    //   return false;
    // }

    // isLoading = true;
    // update();
    // HashMap<String, Object> requestParams = HashMap();
    // requestParams['email'] = emailController.text.trim();
    // var signInEmail = await AuthRepo().forgetPassword(requestParams);
    // signInEmail.fold((failure) {
    //   Global.showToastAlert(
    //       context: Get.overlayContext!,
    //       strTitle: "",
    //       strMsg: failure.MESSAGE,
    //       toastType: TOAST_TYPE.toastError);
    //   isLoading = false;
    //   update();
    // }, (mResult) {
    //   Global.showToastAlert(
    //       context: Get.overlayContext!,
    //       strTitle: "",
    //       strMsg: "${mResult.responseMessage}",
    //       toastType: TOAST_TYPE.toastSuccess);
    //   isLoading = false;
    //   update();
    //   Get.to(() => OTPScreen(otp: mResult.responseData as int));
    // });
    Get.back();
  }

  changePassword() async {
    // if (!(passwordController.text.contains(RegExp(r'[A-Z]')) &&
    //     passwordController.text.contains(new RegExp(r'[0-9]')) &&
    //     passwordController.text.contains(new RegExp(r'[a-z]')) &&
    //     passwordController.text.length > 7)) {
    //   Global.showToastAlert(
    //       context: Get.overlayContext!,
    //       strTitle: "ok",
    //       strMsg:
    //           'Password must contain one upper case, one lower case, one number or symbol and it must be at least 8 characters long',
    //       toastType: TOAST_TYPE.toastError);
    //   FocusScope.of(Get.overlayContext!).requestFocus(passwordNode);
    //   return false;
    // }
    // if (!Global.checkNull(passwordController.text.toString().trim())) {
    //   Global.showToastAlert(
    //       context: Get.overlayContext!,
    //       strTitle: "",
    //       strMsg: 'Please enter password',
    //       toastType: TOAST_TYPE.toastError);
    //   FocusScope.of(Get.overlayContext!).requestFocus(passwordNode);
    //   return false;
    // }
    // if (!Global.checkNull(confirmPasswordController.text.toString().trim())) {
    //   Global.showToastAlert(
    //       context: Get.overlayContext!,
    //       strTitle: "",
    //       strMsg: 'Please enter confirm password',
    //       toastType: TOAST_TYPE.toastError);
    //   FocusScope.of(Get.overlayContext!).requestFocus(confirmPasswordNode);
    //   return false;
    // }
    // if (confirmPasswordController.text.toString().trim() !=
    //     passwordController.text.trim()) {
    //   Global.showToastAlert(
    //       context: Get.overlayContext!,
    //       strTitle: "",
    //       strMsg: "Confirm password doesn’t match",
    //       toastType: TOAST_TYPE.toastError);
    //   FocusScope.of(Get.overlayContext!).requestFocus(confirmPasswordNode);
    //   return false;
    // }

    // isLoading = true;
    // update();
    // HashMap<String, Object> requestParams = HashMap();
    // requestParams['password'] = passwordController.text.trim();
    // requestParams['email'] = emailController.text.trim();
    // var signInEmail = await AuthRepo().changePassword(requestParams);
    // signInEmail.fold((failure) {
    //   Global.showToastAlert(
    //       context: Get.overlayContext!,
    //       strTitle: "",
    //       strMsg: failure.MESSAGE,
    //       toastType: TOAST_TYPE.toastError);
    //   isLoading = false;
    //   update();
    // }, (mResult) {
    //   isLoading = false;
    //   update();
    //   Get.off(() => passwordChangedScreen());
    // });
    // Get.off(() => passwordChangedScreen());
  }
}

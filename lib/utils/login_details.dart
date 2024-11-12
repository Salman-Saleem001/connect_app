import 'dart:convert';


import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connect_app/models/user.dart';

import 'package:connect_app/screens/splash/splash_screen.dart';

class UserDetail extends GetxController {
  // String userId = '';
  // String fname = '';
  // String lname = '';
  // String image = '';
  // String email = '';
  // String phone = '';


  UserModel userData = UserModel();

  Future<void> getUserData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userJson = sharedPreferences.getString('userJson')??"";

    if(userJson.isNotEmpty){
    userData = UserModel.fromJson(jsonDecode(userJson));
    debugPrint("Here is the User=====>${userData.toJson()}");
    }

    update();
  }


  Future<bool> isLogin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

 var value=  sharedPreferences.getString('userJson');
    if(value == null || value == ""){
      return false;
    }else{
      return  true;
    }

  }

  void setUser(dynamic data){
    userData= data;
    debugPrint("Here is the token===>${userData.token}");
    update();
  }

  Future<void> logout() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool? check = sharedPreferences.getBool('notificationStatus') ?? true;

    await sharedPreferences.clear();
    await sharedPreferences.remove('isLogin');
    await sharedPreferences.setBool('notificationStatus', check);
    userData = UserModel();
    update();
    Get.deleteAll();
    Get.offAll(() => const SplashScreen());
  }


  Future<void> updateImage(String n) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString('image', n);
    userData.user!.avatar = n;
    update();
  }

  Future<void> updateNotificationStatus(bool n) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
   await sharedPreferences.setBool('notificationStatus', n);
  }

  Future<void> updateProfile(String fn, String ln, img) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userJson = sharedPreferences.getString('userJson')??"";
    UserModel? details;
    if(userJson.isNotEmpty){
      details = UserModel.fromJson(jsonDecode(userJson));
    }

    if(details!=null){
      details.user?.firstName= fn;
      details.user?.lastName= ln;
      details.user?.avatar= img;
      await sharedPreferences.setString('userJson', jsonEncode(details.toJson()));
    }
    debugPrint(details?.toJson().toString());

    userData.user?.avatar = img;
    userData.user?.firstName = fn;
    userData.user?.lastName = ln;
    update();
  }
}

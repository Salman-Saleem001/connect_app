import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../globals/rest_api/app_apis.dart';
import '../models/posts_model.dart';
import '../services/http_services.dart';

class SearchScreenController extends GetxController {

  late TextEditingController trendingController;
  late FocusNode controllerNode ;
  late RxBool isSearchOn;
  late RxBool isSearchCompleted;
  late List<String> selectedPreferences;
  Rx<PostModel> recommendedPosts = PostModel(posts: <Post>[]).obs;

  var isLoading = false;

  @override
  void onInit() {
    // TODO: implement onInit

    trendingController= TextEditingController();
    controllerNode= FocusNode();
    isSearchOn= false.obs;
    isSearchCompleted= false.obs;
    selectedPreferences= [];
    super.onInit();
  }


  changeSearch(bool val){
    isSearchOn.value=val;
    update();
  }


  getSearchData(String query)async{
    isSearchCompleted.value=false;
    try{
      debugPrint(query);
      dynamic response= await HttpsServices.postApiCall(url: AppApis.getSearchData, body: {
        'query': query
      });

      dynamic data;
      if(response!= null){
        // debugPrint('Here is the data===>${await response.stream.bytesToString()}');
        data= jsonDecode(await response.stream.bytesToString());
      }

      if(data!=null){

        recommendedPosts.value= PostModel.fromJson(data);
        debugPrint('Here is the data===>${recommendedPosts.value.toJson()}');
        isSearchCompleted.value=true;
        update();
      }

    }catch(e){
      debugPrint('Error while searching===>$e}');
    }

  }

  Future<bool> followRequest(int id)async{
    EasyLoading.show();
    try{
      debugPrint('url ${AppApis.followUserApi}$id');
      var response=await  HttpsServices.postApiCall(url: '${AppApis.followUserApi}$id');
      if(response !=null){
        EasyLoading.dismiss();
        return true;
      }


    }catch(e){
      debugPrint('Some thing Went wrong====>$e');
    }
    EasyLoading.dismiss();
    return false;
  }
  Future<bool> unFollowRequest(int id)async{
    EasyLoading.show();
    try{
      debugPrint('url ${AppApis.unFollowUserApi}$id');
      var response=await  HttpsServices.postApiCall(url: '${AppApis.unFollowUserApi}$id');
      if(response !=null){
        EasyLoading.dismiss();
        return true;
      }


    }catch(e){
      debugPrint('Some thing Went wrong====>$e');
    }
    EasyLoading.dismiss();
    return false;
  }

  @override
  void dispose() {
    controllerNode.dispose();

    // TODO: implement dispose
    super.dispose();
  }

}

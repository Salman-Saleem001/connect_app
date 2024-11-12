import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../globals/enum.dart';
import '../../globals/global.dart';
import '../../globals/rest_api/app_apis.dart';
import '../../models/content_videos.dart';
import '../../models/country_model.dart';
import '../../models/posts_model.dart';
import '../../services/http_services.dart';
import '../../utils/login_details.dart';

class HomeFeedController extends GetxController {
  List<CameraDescription> cameras = <CameraDescription>[];
  final Completer<GoogleMapController> controller = Completer<GoogleMapController>();
  PostModel postModel = PostModel(posts: <Post>[]);
  late PageController pageController;
  List<String>? tags;
  RxBool fetchingTags= false.obs;
  RxBool fetchingPosts = false.obs;
  RxBool fetchingRecommendedPosts = false.obs;
  RxBool fetchingTrendingPosts = false.obs;
  RxList<Placemark> addresses= <Placemark>[].obs;
  Position? position;
  String? reviewDescrioption;
  double? rating;

  // RxList<bool> isLiked = <bool>[].obs;

  List<CscPicker> cscPicker = [];
  List<ContentVideos> videos = [];
  List<ContentVideos> addLater = [];
  List<ContentVideos> dynamicVideo = [];

  PostModel? recommendedPosts;
  PostModel trendingPosts = PostModel(posts: <Post>[]);
  PostModel featuredPosts = PostModel(posts: <Post>[]);
  PostModel eventPosts = PostModel(posts: <Post>[]);
  var selectedCategory = 'Recommended'.obs;

  RxBool fetchingRecommended = false.obs;
  RxBool fetchingTrending = false.obs;
  RxBool fetchingFeatured = false.obs;
  RxBool fetchingEvents = false.obs;

  @override
  void onInit() {
    debugPrint("OInit Run====>${Get.find<UserDetail>().userData.token.toString()}");
    pageController= PageController();
    getContent();
    getRecommendedContent();
    getTrendingContent();
    getFeaturedContent();
    getEventContent();
    getCameras();
    super.onInit();
  }

  bool loading = true;

  changeLike(int index) {

    // isLiked[index] = !isLiked[index];
    // postModel.posts?[index].likesCount = isLiked[index]
    //     ? (postModel.posts?[index].likesCount ?? 0) + 1
    //     : (postModel.posts?[index].likesCount ?? 0) - 1;
    update();
  }

  Future<void> getContent() async {
    // debugPrint("Getting Run====>${Get.find<UserDetail>().userData.token.toString()}");


    EasyLoading.show();
    fetchingPosts.value = true;
    var response = await HttpsServices.getPostsHome(
        token: Get.find<UserDetail>().userData.token.toString());

    if (response == null) {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "Message",
          strMsg: 'Something Went Wrong. Try Checking Your Internet Connect',
          toastType: TOAST_TYPE.toastError);
    } else if (response is PostModel) {
      postModel = response;
      debugPrint("Here is my response===> ${response.toJson()}");
    } else {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "Message",
          strMsg: response,
          toastType: TOAST_TYPE.toastError);
    }
    fetchingPosts.value = false;
    EasyLoading.dismiss();
  }

  Future<void> getRecommendedContent() async {
    // debugPrint("Getting Run====>${Get.find<UserDetail>().userData.token.toString()}");
    fetchingRecommended.value = true;
    EasyLoading.show(); // Show loading indicator

    var response = await HttpsServices.getPostsHome(token: Get.find<UserDetail>().userData.token.toString(),type: AppApis.getRecommendedPosts);

    if (response != null&& response is PostModel) {

      recommendedPosts = response; // Update the recommended posts
      // debugPrint("Here is my response===> ${recommendedPosts?.toJson().toString()}");
    } else {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "Message",
          strMsg: 'Failed to load recommended content.',
          toastType: TOAST_TYPE.toastError);
    }

    fetchingRecommended.value = false;
    EasyLoading.dismiss(); // Hide loading indicator
  }


  Future<void> getTrendingContent() async {
    fetchingTrending.value = true;
    var response = await HttpsServices.getPostsHome(token: Get.find<UserDetail>().userData.token.toString(),type: AppApis.getTrendingPosts);
    if (response != null && response is PostModel) {
      trendingPosts = response;
    }
    fetchingTrending.value = false;
  }

  Future<void> getFeaturedContent() async {
    fetchingFeatured.value = true;
    var response = await HttpsServices.getPostsHome(token: Get.find<UserDetail>().userData.token.toString());
    if (response != null && response is PostModel) {
      featuredPosts = response;
    }
    fetchingFeatured.value = false;
  }

  Future<void> getEventContent() async {
    fetchingEvents.value = true;
    var response = await HttpsServices.getPostsHome(token: Get.find<UserDetail>().userData.token.toString());
    if (response != null && response is PostModel) {
      eventPosts = response;
    }
    fetchingEvents.value = false;
  }




  Future<void> getTags() async {
    EasyLoading.show();
    fetchingTags.value = true;
    var response = jsonDecode(await HttpsServices.getApiCall(url: AppApis.getTags));

    if (response == null) {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "Message",
          strMsg: 'Something Went Wrong. Try Checking Your Internet Connect',
          toastType: TOAST_TYPE.toastError);
      return;
    }
    tags= response["tags"] == null ? [] : List<String>.from(response["tags"]!.map((x) => x["name"]));
    tags?.forEach((val){
      debugPrint('Here is my Tag===>$val ');
    });
    fetchingTags.value = false;
    EasyLoading.dismiss();
  }

  toggle(int id)async{

    var response= await  HttpsServices.likeToggle(id,Get.find<UserDetail>().userData.token.toString());



    if(response!=null){
      debugPrint("Here is the response===> ${response.toString()}");
    }

  }

postView(int id , String country )async{
    try{
      var response= await HttpsServices.postApiCall(url: '${AppApis.viewedPostApi}$id?country=$country&ip_address&device&latitude&longitude',);
      if(response!=null){
        debugPrint('Here is the response===>$response');
      }

    }catch(e){
      debugPrint("Error while view post is on");
    }
}



  Future<bool> setPost({
    required String title,
    required File video,
    required String info,
    required double lat,
    required double lng,
    required String city,
    required String state,
    required String country,
    required List<String> tags,
    required String expiryDate,
  }) async {
    debugPrint("Getting Run");
    EasyLoading.show();
    var response = await HttpsServices.userPost(
        token: Get.find<UserDetail>().userData.token.toString(),
        title: title,
        video: video,
        info: info,
        lat: lat,
        lng: lng,
        city: city,
        state: state,
        country: country,
        tags: tags,
        expiryDate: expiryDate);

    if (response == null) {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "Message",
          strMsg: 'Something Went Wrong. Try Checking Your Internet Connect',
          toastType: TOAST_TYPE.toastError);
    } else if (response !=null) {
      debugPrint("Here is my response===> $response");
      EasyLoading.dismiss();
      return true;
    } else {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "Message",
          strMsg: response,
          toastType: TOAST_TYPE.toastError);
    }

    EasyLoading.dismiss();
    return false;
  }


  Future<bool> sendTags(String val)async{
    try{
      var response=await  HttpsServices.postApiCall(url: AppApis.getTags, body: {
        "name" : val
      });

      if(response !=null){
        return true;
      }


    }catch(e){
      debugPrint('Some thing Went wrong====>$e');
    }

    return false;
  }


  changePage(int i) {
    if (i + 2 == videos.length) {
      videos.addAll(addLater);
      update();
    }
    if (videos.length > ((addLater.length * 2) + 5)) {
      videos.removeRange(0, addLater.length);
      update();
    }
    log('message');
  }

  getCameras() async {
    cameras = await availableCameras();
  }


  getLocation() async {
    Permission permission= Permission.location;
    if(await permission.status.isDenied || await permission.status.isPermanentlyDenied){
      permission.request().then((val){
        if(val.isDenied || val.isPermanentlyDenied){
          debugPrint("Permission denied");
        }
      });
    }
    position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    debugPrint('location: ${position?.latitude}');
    var data = await placemarkFromCoordinates(position?.latitude??0.0, position?.longitude??0.0);
    addresses.value = data;
    debugPrint(addresses.first.toJson().toString());
    update();
  }

  Future<bool> sendReview(int id)async{
    EasyLoading.show();
    try{
      debugPrint('url ${AppApis.ratePostApi}$id');
      var response=await  HttpsServices.postApiCall(url: '${AppApis.ratePostApi}$id', body: {
        "rating" : rating?.toInt(),
        "comment": reviewDescrioption
      });

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


  getStats(int id)async{
    try{
      // debugPrint('url ${AppApis.ratePostApi}$id');
      var response=await  HttpsServices.getApiCall(url: '${AppApis.statsOfVideoApi}$id',);

      if(response !=null){
        debugPrint('Resonse data stats===> $response');
      }


    }catch(e){
      debugPrint('Some thing Went wrong while getting stats====>$e');
    }
  }



  @override
  void dispose() {
    // TODO: implement dispose
    pageController.dispose();
    super.dispose();
  }

}

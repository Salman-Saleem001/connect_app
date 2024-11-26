import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../globals/enum.dart';
import '../../globals/global.dart';
import '../../globals/rest_api/app_apis.dart';
import '../../models/posts_model.dart';
import '../../services/http_services.dart';
import '../../utils/login_details.dart';

class ProfileController extends GetxController{

  Rx<PostModel> myPosts= PostModel(posts: []).obs;


  clear(){
    myPosts.value.posts?.clear();
  }

  getMyOwnPost()async{
    try{
      dynamic response= await HttpsServices.getApiCall(url: AppApis.baseUrl + AppApis.posts);
      

      myPosts.value= PostModel.fromJson(jsonDecode(response));

      List<Future<void>> thumbnailFutures = [];

      myPosts.value.posts?.forEach((element) {
        // Add each thumbnail generation task to the list
        if(element.thumbnail?.isEmpty==true){
          var thumbnailFuture = createThumbNai(element.video ?? '').then((thumbnail) {
            element.thumbnail = thumbnail;
          });
          thumbnailFutures.add(thumbnailFuture);
        }
      });

      // Wait for all thumbnail generation tasks to complete
      await Future.wait(thumbnailFutures);
      thumbnailFutures.clear();
      update();

    }catch(e){
      debugPrint('Error while getting Video');
    }
  }


  createThumbNai(String url) async {
    final fileName = await VideoThumbnail.thumbnailFile(
      video: url,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.WEBP,
      // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 100,
    );
    return fileName;
  }





  Future<void> updateProfile({required File image,
      required String firstName,
      required String lastName,
      required String email,
      required String dob,})async {

    try{
      EasyLoading.show();

      debugPrint('DateOf Birth==> $dob');
      dynamic response= await HttpsServices.updateUser(image: image, firstName: firstName, lastName: lastName, email: email, dob: dob);

      dynamic data= jsonDecode(response);

      if(response!=null){
        Global.showToastAlert(
            context: Get.overlayContext!,
            strTitle: "Success",
            strMsg: 'Profile updated Successfully',
            toastType: TOAST_TYPE.toastSuccess);
        debugPrint(data['user']['avatar'].toString());
        Get.find<UserDetail>().updateProfile(firstName, lastName, data['user']['avatar']);
        
      }else{
        Global.showToastAlert(
            context: Get.overlayContext!,
            strTitle: "Failure",
            strMsg: 'SomeThing went wrong',
            toastType: TOAST_TYPE.toastError);
      }

      response=null;
      data= null;
    }catch(e){
      debugPrint('Error while updating Profile====>$e ');
    }finally{
      // newString= null;

      EasyLoading.dismiss();
    }
  }


  Future<bool> deleteVideo(int id)async{
    EasyLoading.show();
    try{
      debugPrint('url ${AppApis.deleteVideoApi}$id');
      var response=await  HttpsServices.deleteApiCall(url: '${AppApis.deleteVideoApi}$id');
      if(response !=null){
        debugPrint("Here is the delete response===>$response");
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
    // TODO: implement dispose
    super.dispose();
  }
}
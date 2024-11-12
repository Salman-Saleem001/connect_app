import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../globals/enum.dart';
import '../globals/global.dart';
import '../globals/rest_api/app_apis.dart';
import '../models/posts_model.dart';
import '../models/user.dart';
import '../screens/auth_screens/login.dart';
import '../utils/login_details.dart';

class HttpsServices {
  static Future<dynamic> userSignUP({
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    required String userName,
    required String phone,
    required List<String> preferences,
    required String bio,
  }) async {
    try {
      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      var request =
          http.Request('POST', Uri.parse(AppApis.baseUrl + AppApis.register));
      debugPrint("request-->${request.body}");
      request.body = json.encode({
        "email": email,
        "password": password,
        "password_confirmation": confirmPassword,
        "first_name": firstName,
        "last_name": lastName,
        "username": userName,
        "phone": phone,
        "preferences": preferences,
        "bio": bio
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      debugPrint("response.statusCode.toString()-->${response.statusCode.toString()}");

      if (response.statusCode == 201) {
        debugPrint('A useful message');
        Global.showToastAlert(
            context: Get.overlayContext!,
            strTitle: "Success",
            strMsg: "User Sign-Up Successful, Please Login and Access Enjoy The Features",
            toastType: TOAST_TYPE.toastSuccess);
        Get.offAll(()=>const LoginScreen());
        return response;
      } else {
        debugPrint("response.reasonPhrase.toString()-->${response.reasonPhrase.toString()}");
        var temp = await response.stream.bytesToString();
        var tempJson = jsonDecode(temp);
        Global.showToastAlert(
            context: Get.overlayContext!,
            strTitle: "",
            strMsg: tempJson['message'],
            toastType: TOAST_TYPE.toastError);

        return tempJson['message'];
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "",
          strMsg: "Somethings went wrong. Please Try Again",
          toastType: TOAST_TYPE.toastError);
      return null;
    }
  }

  static Future<dynamic> userLogin({
    required String email,
    required String password,
    required String fcmToken
  }) async {
    try {
      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer 2|78eV3YjxHPBB8MzYPjfbBpwUbHc9hyqObD8p3P2A8ae52ac0'
      };
      var request =
          http.Request('POST', Uri.parse(AppApis.baseUrl + AppApis.login));
      request.body = json.encode({"email": email, "password": password,"fcm_token": fcmToken});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var temp = await response.stream.bytesToString();
        var tempJson = jsonDecode(temp);
        return UserModel.fromJson(tempJson);
      } else {
        var temp = await response.stream.bytesToString();
        var tempJson = jsonDecode(temp);
        debugPrint(response.reasonPhrase);
        return tempJson['message'];
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<dynamic> getPostsHome({
    required String token,
    String? type,
  }) async {
    try {
      var headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      };
      var request = http.Request(
          'GET', Uri.parse(AppApis.baseUrl + (type??AppApis.postsTimeLine)));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var temp = await response.stream.bytesToString();
        var tempJson = jsonDecode(temp);
        return PostModel.fromJson(tempJson);
      } else {
        return "No Latest Posts Found Around You";
        // debugPrint(response.reasonPhrase);
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<dynamic> userPost(
      {required String title,
      required File video,
      required String info,
      required double lat,
      required double lng,
      required String city,
      required String state,
      required String country,
      required List<String> tags,
      required String expiryDate,
      required String token}) async {
    try {
      var headers = {
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      };
      final request = http.MultipartRequest(
          'POST', Uri.parse(AppApis.baseUrl + AppApis.posts));

      request.headers.addAll(headers);

      // add the text form fields
      // final formFields = request.fields;
      request.fields['title'] = 'Test';
      request.fields['info'] = info;
      request.fields['lat'] = lat.toString();
      request.fields['lng'] = lng.toString();
      request.fields['city'] = city;
      request.fields['state'] = state;
      request.fields['country'] = country;
      request.fields['tags'] = jsonEncode(tags);
      request.fields['expiry date'] = expiryDate.toString();
      // Replace with your actual file path
      var file = await http.MultipartFile.fromPath(
        'video', // Field name
        video.path,
        contentType:
            MediaType('video', 'mp4'), // Set the content type appropriately
      );

      request.files.add(file);

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseBody = await response.stream.bytesToString();
        debugPrint('Response body: $responseBody');
        return responseBody;
      } else {
        debugPrint('Request failed with status: ${response.statusCode}');
        var responseBody = await response.stream.bytesToString();
        debugPrint('Response body: $responseBody');
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }


  static Future<dynamic> updateUser(
      {
        required File image,
        required String firstName,
        required String lastName,
        required String email,
        required String dob,
        }) async {
    try {
      var headers = {
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${Get.find<UserDetail>().userData.token.toString()}'
      };
      final request = http.MultipartRequest(
          'POST', Uri.parse(AppApis.baseUrl + AppApis.userProfile));

      request.headers.addAll(headers);
      request.fields['first_name'] = firstName;
      request.fields['last_name'] = lastName;
      request.fields['dob'] = dob;
      request.fields['email'] = email;
      // Replace with your actual file path
      var file = await http.MultipartFile.fromPath(
        'avatar', // Field name
        image.path,
        contentType:
        MediaType('video', 'png'), // Set the content type appropriately
      );

      request.files.add(file);

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        debugPrint('Response body: $responseBody');
        return responseBody;
      } else {
        debugPrint('Request failed with status: ${response.statusCode}');
        var responseBody = await response.stream.bytesToString();
        debugPrint('Response body: $responseBody');
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  static Future<dynamic> likeToggle(int id, String token) async {
    try {
      try {
        var headers = {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        };
        var request = http.Request('POST',
            Uri.parse(AppApis.baseUrl + AppApis.toggleLikes + id.toString()));
        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          debugPrint(await response.stream.bytesToString());
          return response;
        } else {
          debugPrint(response.statusCode.toString());
          return null;
        }
      } on Exception catch (e) {
        debugPrint(e.toString());
        return null;
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<dynamic> postApiCall(
      {required String url,
        Map<String, dynamic>? body,
      Map<String, String>? header}) async {
    try {
      var defaultHeaders = {
        'Accept': 'application/json',
        'Authorization':
        'Bearer ${Get.find<UserDetail>().userData.token.toString()}',
        'Content-Type': 'application/json',
      };
      var request =
          http.Request('POST', Uri.parse(url));
      if(body!=null){
        request.body = json.encode(body);
      }
      request.headers.addAll(header??defaultHeaders);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 201|| response.statusCode==200) {
        debugPrint('A useful message');
        return response;
      } else {
        debugPrint("Here is the status=====>${response.statusCode}");
        return null;
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<dynamic> getApiCall({
    String? url,
    Map<String, String>? headers,
  }) async {
      try {
        var defaultHeaders = {
          'Accept': 'application/json',
          'Authorization':
              'Bearer ${Get.find<UserDetail>().userData.token.toString()}'
        };
        var request = await http.get(Uri.parse(url ?? ''),
            headers: headers ?? defaultHeaders);
        // request.headers.addAll(headers??defaultHeaders);

        if (request.statusCode == 200) {
          // debugPrint('Here is the body===>${request.body.toString()}');
          return request.body;
        } else {
          debugPrint(request.statusCode.toString());
          return null;
        }
      } on Exception catch (e) {
        debugPrint(e.toString());
        return null;
      }
    }

  static Future<dynamic> deleteApiCall({
    String? url,
    Map<String, String>? headers,
  }) async {
    try {
      var defaultHeaders = {
        'Accept': 'application/json',
        'Authorization':
        'Bearer ${Get.find<UserDetail>().userData.token.toString()}'
      };
      var request = await http.delete(Uri.parse(url ?? ''),
          headers: headers ?? defaultHeaders);
      // request.headers.addAll(headers??defaultHeaders);

      if (request.statusCode == 200) {
        // debugPrint('Here is the body===>${request.body.toString()}');
        return request.body;
      } else {
        debugPrint(request.statusCode.toString());
        return null;
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}


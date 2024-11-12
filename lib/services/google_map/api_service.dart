import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart'as http;
class ApiRequest {
  // Get function for map

  Future getMap({
    String? url,
    Function(String)? onSuccess,
    Function(String)? onError,
  }) async {
    try {
      debugPrint("this is get Url: $url");

      var response = await http.get(Uri.parse(url!),)
          .timeout(const Duration(seconds: 60), onTimeout: () {
        throw Exception("Request Time Out");
      });
      debugPrint(response.statusCode.toString());
      if (response.statusCode == 200) {
        debugPrint("i am in status code 200 catch ${response.body}");
        onSuccess!(response.body);
      } else if (response.statusCode == 204) {
        debugPrint("i am in status code 204 catch ${response.toString()}");
        onError!(response.body);
      } else if (response.statusCode == 404) {
        debugPrint("i am in status code 404 catch ${response.toString()}");
        onError!(response.body);
      } else {
        debugPrint("i am in error  ${response.body}");
        onError!(response.body);
      }
    } catch (e) {
      debugPrint("i am in error catch ${e.toString()}");
      onError!(e.toString());
    }
  }


  Future getMap1({
    String? url,
    Function(String)? onSuccess,
    Function(String)? onError,
  }) async {
    try {
      debugPrint("this is get Url: $url");
      var client = HttpClient();
      // var response =await dio.get(url!,)
      HttpClientRequest request = await client.get(url??"", 80, '/file.txt');
          // .timeout(const Duration(seconds: 60), onTimeout: () {
        // throw Exception("Request Time Out");
      HttpClientResponse response = await request.close();


      // });
      debugPrint("HttpClient response======>${response.statusCode.toString()}");
      debugPrint("HttpClient response=======>${response.toString()}");
      // if (response.statusCode == 200) {
      //   onSuccess!(response.body);
      // } else if (response.statusCode == 204) {
      //   onError!(response.body);
      // } else if (response.statusCode == 404) {
      //   onError!(response.body);
      // } else {
      //   debugPrint("i am in error  ${response.body}");
      //   onError!(response.body);
      // }
    } catch (e) {
      debugPrint("i am in error catch ${e.toString()}");
      onError!(e.toString());
    }
  }
}

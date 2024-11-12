import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
// import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart' as lt;
import 'package:location/location.dart' as loc;
import 'package:connect_app/globals/enum.dart';
import 'package:connect_app/globals/global.dart';
import 'package:connect_app/services/google_map/map_key.dart';


class GoogleMapFunctions {
  static bool isList = true;
  static lt.LatLng defaultLatLng = const lt.LatLng(31.4564555, 74.2852029);
  static FindAutocompletePredictionsResponse? predictions;
  static final places = FlutterGooglePlacesSdk(MapKey.mapKey);
  static Future<void> predict(String val) async {
    isList = true;
    predictions = await places.findAutocompletePredictions(val);

    if (val.isEmpty) {
      predictions = null;
    }

    log('Result: $predictions');
  }

  static Future<bool> checkLocation({bool showError = true}) async {
    bool isPermissionGranted = false;
    loc.PermissionStatus status = await loc.Location.instance.hasPermission();

    if (loc.PermissionStatus.denied == status) {
      debugPrint("check============>");
      if (showError) {
        Global.showToastAlert(
            context: Get.overlayContext!,
            strTitle: "Message",
            strMsg: "Permission is denied",
            toastType: TOAST_TYPE.toastError);
      }

      await loc.Location.instance.requestPermission();
    } else if (loc.PermissionStatus.granted == status) {
      isPermissionGranted = true;
    } else if (loc.PermissionStatus.deniedForever == status) {
      log("check1==================>");
      if (showError) {
        Global.showToastAlert(
            context: Get.overlayContext!,
            strTitle: "Message",
            strMsg: "Permission is denied",
            toastType: TOAST_TYPE.toastError);
      }
    }
    return isPermissionGranted;
  }

  static Future<bool> checkLocation1({bool showError = true}) async {
    bool isPermissionGranted = false;
    loc.PermissionStatus status = await loc.Location.instance.hasPermission();

    if (status == loc.PermissionStatus.denied) {
      debugPrint("Permission denied");
      status = await loc.Location.instance.requestPermission();
      if (status == loc.PermissionStatus.granted) {
        isPermissionGranted = true;
      } else if (status == loc.PermissionStatus.deniedForever) {
        if (showError) {
          Global.showToastAlert(
              context: Get.overlayContext!,
              strTitle: "Message",
              strMsg: "Permission is permanently denied. Please enable it from settings.",
              toastType: TOAST_TYPE.toastError);
        }
      }
    } else if (status == loc.PermissionStatus.granted) {
      isPermissionGranted = true;
    } else if (status == loc.PermissionStatus.deniedForever) {
      if (showError) {
        Global.showToastAlert(
            context: Get.overlayContext!,
            strTitle: "Message",
            strMsg: "Permission is permanently denied. Please enable it from settings.",
            toastType: TOAST_TYPE.toastError);
      }
    }
    return isPermissionGranted;
  }
}

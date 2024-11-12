// import 'dart:async';
// import 'dart:developer';
// import 'dart:io';
//
// import 'dart:ui' as ui;
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:permission_handler/permission_handler.dart';
//
//
// class LocationController {
//   static const apiKey = 'AIzaSyAcg4t_7-h6LvAaYz80KlTCrKtWhfsVCm0';
//   static Future<LatLng> getCurrentLocation() async {
//     try {
//       PermissionStatus? status = await Permission.location.status;
//
//       if (await Permission.location.status.isGranted == false ||
//           await Permission.location.status.isLimited == false ||
//           (Platform.isIOS
//                   ? await Permission.location.status.isDenied == true
//                   : await Permission.location.status.isDenied == false) &&
//               await Permission.location.status.isPermanentlyDenied == false) {
//         status = await Permission.location.request();
//       }
//       if (status == PermissionStatus.granted ||
//           status == PermissionStatus.limited) {
//         Position locationData = await Geolocator.getCurrentPosition();
//
//         return LatLng(locationData.latitude, locationData.longitude);
//       } else {
//         Global.showToastAlert(
//             context: Get.overlayContext!,
//             strTitle: "ok",
//             strMsg: 'Please enable location from app settings',
//             toastType: TOAST_TYPE.toastInfo,
//             action: InkWell(
//                 onTap: () {
//                   openAppSettings();
//                 },
//                 child: Text(
//                   'Settings',
//                   style: subHeadingText(size: 15),
//                 )));
//         return LatLng(-36.9161458, 174.640739);
//       }
//     } catch (e) {
//       log(e.toString());
//       return LatLng(-36.9161458, 174.640739);
//     }
//   }
//
//   static Future<Uint8List> getBytesFromAsset(String path, int width) async {
//     ByteData data = await rootBundle.load('assets/images/$path');
//     ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
//         targetWidth: width);
//     ui.FrameInfo fi = await codec.getNextFrame();
//     return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
//         .buffer
//         .asUint8List();
//   }
//
//   static Future<List<LatLng>?> getPolyline(
//       Completer<GoogleMapController> mapController,
//       LatLng? fromLatLng,
//       LatLng? toLatLng,
//       Map<PolylineId, Polyline> polylines) async {
//     if (fromLatLng == null || toLatLng == null) return null;
//
//     List<LatLng> polylineCoordinates = [];
//     PolylinePoints polylinePoints = PolylinePoints();
//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       LocationController.apiKey,
//       PointLatLng(fromLatLng.latitude, fromLatLng.longitude),
//       PointLatLng(toLatLng.latitude, toLatLng.longitude),
//       travelMode: TravelMode.driving,
//     );
//     if (result.points.isNotEmpty) {
//       result.points.forEach((PointLatLng point) {
//         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//       });
//     }
//     addPolyLine(polylineCoordinates, polylines);
//     return polylineCoordinates;
//   }
//
//   static addPolyLine(
//     List<LatLng> polylineCoordinates,
//     Map<PolylineId, Polyline> polylines,
//   ) {
//     PolylineId id = PolylineId("k");
//     Polyline polyline = Polyline(
//         polylineId: id,
//         visible: true,
//         color: Colors.white,
//         points: polylineCoordinates,
//         width: 3);
//     polylines[id] = polyline;
//   }
//
//   static Future customCameraZoom(
//     Completer<GoogleMapController> mapController,
//     LatLng? fromLatLng,
//     LatLng? toLatLng,
//   ) async {
//     double miny = (fromLatLng!.latitude <= toLatLng!.latitude)
//         ? fromLatLng.latitude
//         : toLatLng.latitude;
//     double minx = (fromLatLng.longitude <= toLatLng.longitude)
//         ? fromLatLng.longitude
//         : toLatLng.longitude;
//     double maxy = (fromLatLng.latitude <= toLatLng.latitude)
//         ? toLatLng.latitude
//         : fromLatLng.latitude;
//     double maxx = (fromLatLng.longitude <= toLatLng.longitude)
//         ? toLatLng.longitude
//         : fromLatLng.longitude;
//
//     double southWestLatitude = miny;
//     double southWestLongitude = minx;
//
//     double northEastLatitude = maxy;
//     double northEastLongitude = maxx;
//
//     final GoogleMapController _controller = await mapController.future;
//     _controller.animateCamera(
//       CameraUpdate.newLatLngBounds(
//         LatLngBounds(
//           northeast: LatLng(northEastLatitude, northEastLongitude),
//           southwest: LatLng(southWestLatitude, southWestLongitude),
//         ),
//         100.0,
//       ),
//     );
//   }
//
//   static Timer? updateTime;
// }

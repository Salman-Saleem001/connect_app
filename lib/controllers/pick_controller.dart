// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_address_from_latlng/flutter_address_from_latlng.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'location_manager.dart';
//
// class PickScreenController extends GetxController {
//   LatLng? latLng;
//
//   final Set<Marker> markers = <Marker>{};
//
//   Completer<GoogleMapController> mapController = Completer();
//
//   CameraPosition initialLocation = const CameraPosition(
//     target: LatLng(-36.9161458, 174.640739),
//     zoom: 11.00,
//   );
//   TextEditingController fromLoc = TextEditingController();
//   FocusNode fromnodeloc = FocusNode();
//   List<String> places = [];
//   var markerPadding = false.obs;
//   void changeMarkerPadding(val) {
//     markerPadding(val);
//   }
//
//   var apiKey = 'AIzaSyAcg4t_7-h6LvAaYz80KlTCrKtWhfsVCm0';
//
//   getLocation() async {
//     try {
//       LatLng mLatLng_ = await LocationController.getCurrentLocation();
//       markers.clear();
//       final GoogleMapController _controller = await mapController.future;
//       _controller.animateCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(
//             target: mLatLng_,
//             zoom: 12,
//           ),
//         ),
//       );
//       update();
//     } catch (e) {
//       print(e);
//     }
//   }
//
//   Future<void> changeAddressBarValue() async {
//     if (places.isNotEmpty) return;
//     fromLoc.text = await FlutterAddressFromLatLng().getFormattedAddress(
//       latitude: latLng!.latitude,
//       longitude: latLng!.longitude,
//       googleApiKey: LocationController.apiKey,
//     );
//   }
//
//   bool showPlaces = false;
//
//   Future<void> findPlaces(
//       String placeId) async // to get google places api result
//   {
//     update();
//     var url =
//         'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeId&key=$apiKey&sessiontoken=1234567890';
//     var response = await http.get(Uri.parse(url));
//     var result = await json.decode(response.body);
//     List<dynamic> list = result['predictions'];
//     places.clear();
//     for (int i = 0; i < list.length; i++) {
//       var p = list[i]['description'];
//       places.add(p);
//     }
//     if (places.isNotEmpty) {
//       showPlaces = true;
//       update();
//     }
//     print(list);
//     update();
//   }
//
//   chooseLocation(String val) async {
//     try {
//       EasyLoading.show();
//
//       var url =
//           'https://maps.googleapis.com/maps/api/geocode/json?address=${val}&key=${LocationController.apiKey}';
//       var response = await http.get(Uri.parse(url));
//       var result = await json.decode(response.body);
//       double lat = result['results'][0]['geometry']['location']['lat'] ?? 0;
//       double lng = result['results'][0]['geometry']['location']['lng'] ?? 0;
//       EasyLoading.dismiss();
//       showPlaces = false;
//       places.clear();
//       update();
//       final GoogleMapController _controller = await mapController.future;
//       _controller.animateCamera(CameraUpdate.newCameraPosition(
//           CameraPosition(target: LatLng(lat, lng), zoom: 17.5)));
//       fromLoc.text = val;
//       latLng = LatLng(lat, lng);
//
//       update();
//     } catch (e) {
//       EasyLoading.dismiss();
//       log(e.toString());
//     }
//   }
// }

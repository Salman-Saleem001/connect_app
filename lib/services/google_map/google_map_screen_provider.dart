import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart' as lt;
import 'package:location/location.dart' as loc;
import 'package:connect_app/services/google_map/address_model.dart';
import 'package:connect_app/services/google_map/api_service.dart';
import 'package:connect_app/services/google_map/google_map_functions.dart';
import 'package:connect_app/services/google_map/google_map_lat_long_model.dart';
import 'package:connect_app/services/google_map/map_key.dart';
import 'package:connect_app/widgets/loader.dart';


class GoogleMapScreenProvider extends ChangeNotifier{
  GoogleMapController? mapsController;
  Set<Marker> markers = {};
  final ApiRequest apiRequests = ApiRequest();
  lt.LatLng? startLocation;
  TextEditingController searchTC = TextEditingController();
  PickLocationData? locationData;
  BitmapDescriptor? icon1;

  update(){
    notifyListeners();
  }

  Future getAddress(double lat, double lng) async {
    Loader();
    GoogleMapLatLongModel googleMapLatLongModel = GoogleMapLatLongModel();
    await apiRequests.getMap(
        url: getAddressFromlatlngUrl(lat, lng, MapKey.mapKey),
        onSuccess: (res) {
          googleMapLatLongModel =
              GoogleMapLatLongModel.fromJson(jsonDecode(res));
          startLocation = lt.LatLng(lat, lng);
          mapsController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: startLocation!, zoom: 18,)));
          markers.clear();
          markers.add(
            Marker(
              markerId: MarkerId("${startLocation}"),
              position: startLocation!,
              icon: icon1 ?? BitmapDescriptor.defaultMarker,
            ),
          );
          update();

          locationData = PickLocationData(
              geohash: "",
              lat: googleMapLatLongModel.results?.first.geometry?.location?.lat?.toDouble() ?? 0,
              lng: googleMapLatLongModel.results?.first.geometry?.location?.lng?.toDouble() ?? 0,
              country: "",
              city: "",
              state: "",
              streetAddress: "");
         searchTC.text = googleMapLatLongModel.results?.first.formattedAddress ?? "";
          update();
          debugPrint("SEARCHED LOCATION===========>${googleMapLatLongModel.results?.first.formattedAddress ?? ""}");
          debugPrint("SEARCHED LOCATION stored===========>${searchTC.text}");
          update();
          // Loader.dismiss();
        },
        onError: (e) {
          log(e.toString());
        });
  }

  Future<void> getLocation() async {
    Loader();
    loc.Location location = loc.Location();
    await location.changeSettings(
        accuracy: loc.LocationAccuracy.balanced,
        interval: 1000,
        distanceFilter: 0);
    loc.LocationData currentLocation = await location.getLocation();
    log("Accuracy is ${currentLocation.accuracy}Lat is ${currentLocation.latitude}Long is ${currentLocation.longitude}");

    startLocation = lt.LatLng(currentLocation.latitude!, currentLocation.longitude!);
    log("Success fully get the start location from google map screen provider");
    // Loader.dismiss();
    await getAddress(currentLocation.latitude!, currentLocation.longitude!);
  }

  Future<void> setDefaultLocation() async {
    startLocation = GoogleMapFunctions.defaultLatLng;
    update();

    await getAddress(startLocation!.latitude, startLocation!.longitude);
  }

}
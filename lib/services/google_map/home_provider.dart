import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeProvider extends ChangeNotifier{
  TextEditingController locationC = TextEditingController();
  LatLng startLocation=const LatLng(37.42796133580664,-122.085749655962);
  BitmapDescriptor? icon1;
  Set<Marker> markers = {};
  GoogleMapController? homeScreenMapController;
  void update(){
    return notifyListeners();
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../controllers/mainScreen_controllers/home_page_cont.dart';
import '../../utils/app_colors.dart';


class StatsMapScreen extends StatefulWidget {
  const StatsMapScreen({super.key, required this.id});

  final int id;

  @override
  State<StatsMapScreen> createState() => _StatsMapScreenState();
}

class _StatsMapScreenState extends State<StatsMapScreen> {

  late Set<Marker> dataOfMarker;
  final List<CountryData> data = [
    CountryData('Kyrgyzstan', 8.7, 41.2044, 74.7661),
    CountryData('Pakistan', 3.5, 30.3753, 69.3451),
    CountryData('India', 2.57, 20.5937, 78.9629),
    CountryData('Laos', 1.57, 19.8563, 102.4955),
    CountryData('Oman', 3.5, 21.4735, 55.9754),
  ];

  @override
  void initState() {
    super.initState();
    dataOfMarker={};
    for (var element in data) {
      dataOfMarker.add(Marker(markerId: MarkerId(element.name),
          position: LatLng(element.latitude, element.longitude),
          infoWindow: InfoWindow(
              title: element.name, snippet: element.views.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Card(
        shape: InputBorder.none,
        color: AppColors.white,
        child: GetBuilder(builder: (HomeFeedController homeController) {
          if (homeController.position != null) {
            homeController.getStats(widget.id);
            return Center(child: CircularProgressIndicator(
              color: AppColors.primaryColor,));
          } else {
            return GoogleMap(
              mapType: MapType.normal,
              markers: dataOfMarker,
              onMapCreated: (GoogleMapController controller) {
                homeController.controller.complete(controller);
              },
              initialCameraPosition: CameraPosition(
                target: dataOfMarker.first.position,
                zoom: 5,
              ),);
          }
        }),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    dataOfMarker.clear();
    super.dispose();
  }
}


class CountryData {
  CountryData(this.name, this.views, this.latitude, this.longitude);

  final String name;
  final double views;
  final double latitude;
  final double longitude;
}


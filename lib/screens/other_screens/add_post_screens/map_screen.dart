import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:connect_app/controllers/mainScreen_controllers/home_page_cont.dart';
import 'package:connect_app/utils/app_colors.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Card(
        shape: InputBorder.none,
        color: AppColors.white,
        child: GetBuilder(builder: (HomeFeedController homeController){
          if(homeController.position==null){
            return Center(child: CircularProgressIndicator(color: AppColors.primaryColor,));
          }else{
            return  GoogleMap(
              mapType: MapType.normal,
              markers: {
               Marker(markerId: const MarkerId('myLocation'),position: LatLng(homeController.position?.latitude??37.42796133580664, homeController.position?.longitude??-122.085749655962) )
              },
              onMapCreated: (GoogleMapController controller) {
                homeController.controller.complete(controller);
              },
              initialCameraPosition: CameraPosition(
              target: LatLng(homeController.position?.latitude??37.42796133580664, homeController.position?.longitude??-122.085749655962),
              zoom: 14.4746,
            ),);
          }
        }),
      ),
    );
  }
}

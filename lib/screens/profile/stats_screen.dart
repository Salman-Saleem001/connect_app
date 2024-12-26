import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../controllers/mainScreen_controllers/home_page_cont.dart';
import '../../utils/app_colors.dart';


class StatsMapScreen extends StatelessWidget {
  const StatsMapScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Card(
        shape: InputBorder.none,
        color: AppColors.white,
        child: GetBuilder(builder: (HomeFeedController homeController) {
          if (homeController.dataOfMarker == null) {

             homeController.getStats(id);

            return Center(child: CircularProgressIndicator(
              color: AppColors.primaryColor,));
          } else {
            // homeController.getStats(widget.id);
            return PopScope(
              onPopInvokedWithResult: (val,result){
                homeController.dataOfMarker= null;
              },
              child: Stack(
                children: [
                  if((homeController.dataOfMarker??{}).isEmpty|| id==-1)...[
                    Center(child: Text("No Stats available",style: TextStyle(fontSize: 18),),)
                  ]else
                  GoogleMap(
                    mapType: MapType.normal,
                    markers: homeController.dataOfMarker??{},
                    onMapCreated: (GoogleMapController controller) {
                      homeController.controller.complete(controller);
                    },
                    initialCameraPosition: CameraPosition(
                      target: homeController.dataOfMarker?.first.position??LatLng(30.3753, 69.3451),
                      zoom: 5,
                    ),),
                  Positioned(
                    top: 50,
                    left: 15,
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white,
                          border: Border.all(
                            color: AppColors.borderColor,
                            width: 1.0,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: AppColors.primaryIconColor,
                        ).paddingAll(10),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        }),
      ),
    );
  }
}

class CountryData {
  CountryData(this.name, this.views, this.latitude, this.longitude);

  final String name;
  final double views;
  final double latitude;
  final double longitude;
}


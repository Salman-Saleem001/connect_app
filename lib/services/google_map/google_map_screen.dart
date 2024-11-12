import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart' as lt;
import 'package:provider/provider.dart';
import 'package:connect_app/globals/enum.dart';
import 'package:connect_app/globals/global.dart';
import 'package:connect_app/services/google_map/google_map_screen_provider.dart';
import 'package:connect_app/services/google_map/home_provider.dart';
import 'package:connect_app/utils/app_colors.dart';

import '../../widgets/primary_button.dart';
import 'google_map_functions.dart';
import 'google_map_predict.dart';

class GoogleMapScreen extends StatefulWidget {
  final bool? showButton;
  final lt.LatLng selectedLocation;

  const GoogleMapScreen({
    super.key,
    this.showButton = true,
    required this.selectedLocation,
  });

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  var provider;

  Future<void> setCurrentLocation() async {
    provider.startLocation = widget.selectedLocation;
    provider.update();

    await provider.getAddress(
        provider.startLocation!.latitude, provider.startLocation!.longitude);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      provider = Provider.of<GoogleMapScreenProvider>(context, listen: false);

      ///Create Custom Marker
      provider.icon1 =await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(40.65, 50.0)),
        'assets/images/mapIcon1.png'
      );
      provider.update();
      if (widget.selectedLocation.latitude == 0 &&
          widget.selectedLocation.longitude == 0) {
        bool check = await GoogleMapFunctions.checkLocation(showError: false);
        if (check) {
          await provider.getLocation();
        } else {
          await provider.setDefaultLocation();
        }
      } else {
        await setCurrentLocation();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<GoogleMapScreenProvider>(builder: (context, googleMapProvider, _) {
        return Scaffold(
          extendBody: false,
          bottomNavigationBar: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 12, vertical: MediaQuery.sizeOf(context).width * 0.03),
            child: Consumer<HomeProvider>(
              builder: (context,homeProvider,_) {
                return
                  PrimaryButton(
                    label: 'done',
                    // whiteButton: true,
                    onPress: () async{
                  if(googleMapProvider.searchTC.text.isNotEmpty) {
                    homeProvider.locationC.text = googleMapProvider.searchTC
                        .text;
                    homeProvider.startLocation = googleMapProvider
                        .startLocation ?? const LatLng(0, 0);

                    ///Create Custom Marker
                    homeProvider.icon1 = await BitmapDescriptor
                        .fromAssetImage(
                        const ImageConfiguration(size: Size(40.65, 50.0)),
                        'assets/images/mapIcon1.png'
                    );
                    homeProvider.update();
                    homeProvider.markers.clear();
                    homeProvider.markers.add(
                      Marker(
                        markerId: MarkerId(
                            "${googleMapProvider.startLocation}"),
                        position: googleMapProvider.startLocation!,
                        icon: homeProvider.icon1 ??
                            BitmapDescriptor.defaultMarker,
                      ),
                    );
                    homeProvider.homeScreenMapController?.animateCamera(
                        CameraUpdate.newCameraPosition(CameraPosition(
                          target: homeProvider.startLocation!,
                          zoom: 14,
                        )));
                    homeProvider.update();
                    Navigator.pop(context);
                  }else{
                    Global.showToastAlert(
                        context: Get.overlayContext!,
                        strTitle: "Message",
                        strMsg: "Please select any location",
                        toastType: TOAST_TYPE.toastError);
                  }
                },
                  );
              }
            ),
          ),
          body: googleMapProvider.startLocation == null
              // ? const Center(child: CircularProgressIndicator())
              ? const Center(child: SizedBox())
              : Stack(
                  children: [
                    GoogleMap(
                      onTap: (lat) async {
                        if (widget.showButton!) {
                          await googleMapProvider.getAddress(lat.latitude, lat.longitude);
                        }
                      },
                      onMapCreated: (controller) async {
                        googleMapProvider.mapsController = controller;
                        controller.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: lt.LatLng(
                                  googleMapProvider.startLocation!.latitude,
                                  googleMapProvider.startLocation!.longitude),
                              zoom: 18,
                            ),
                          ),
                        );
                        googleMapProvider.update();
                      },
                      myLocationButtonEnabled: true,
                      myLocationEnabled: false,
                      trafficEnabled: false,
                      compassEnabled: true,
                      zoomControlsEnabled: widget.showButton!,
                      zoomGesturesEnabled: true,
                      mapToolbarEnabled: false,
                      minMaxZoomPreference: MinMaxZoomPreference.unbounded,
                      markers: googleMapProvider.markers,
                      mapType: MapType.terrain,
                      initialCameraPosition: CameraPosition(
                          target: googleMapProvider.startLocation!, zoom: 18),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 16, bottom: 12),
                      color: AppColors.white,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  decoration:  BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  child:  Icon(
                                    Icons.arrow_back_outlined,
                                    color: AppColors.lightColorBlue,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: SizedBox(
                                  // height: 40,
                                  child: TextFormField(
                                    readOnly: false,
                                    controller: googleMapProvider.searchTC,
                                    onChanged: ((value) {
                                      if (value.isNotEmpty) {
                                        GoogleMapFunctions.predict(value);
                                      }
                                      googleMapProvider.update();
                                    }),
                                    decoration: InputDecoration(
                                      // suffixIconConstraints:
                                      // BoxConstraints(minWidth: iconMinWidth ?? 60, minHeight: 50, maxHeight: 50),
                                      // contentPadding: EdgeInsets.symmetric(
                                      //     horizontal: horizontalPadding ?? 16, vertical: verticalPadding ?? 16),
                                      fillColor: AppColors.white,
                                      hintText: "Location",
                                      suffixIcon:
                                          googleMapProvider.searchTC.text.isNotEmpty
                                              ? GestureDetector(
                                                  onTap: () {
                                                    googleMapProvider.searchTC.clear();
                                                    googleMapProvider.markers.clear();
                                                    googleMapProvider.update();
                                                  },
                                                  child: const Icon(
                                                    Icons.cancel_outlined,
                                                    color: Colors.red,
                                                  ),
                                                )
                                              : null,
                                      // suffixIcon != null
                                      //     ? Container(child: suffixIcon)
                                      //     : null,
                                      hintStyle:  TextStyle(
                                        color: AppColors.lightColorBlue,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      isDense: true,
                                      enabledBorder:  OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        borderSide: BorderSide(
                                            color: AppColors.lightColorBlue),
                                      ),
                                      border:  OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        borderSide: BorderSide(
                                            color: AppColors.lightColorBlue),
                                      ),
                                      disabledBorder:  OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        borderSide: BorderSide(
                                            color: AppColors.lightColorBlue),
                                      ),
                                      focusedBorder:  OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        borderSide: BorderSide(
                                            color: AppColors.primaryColor),
                                      ),
                                      errorBorder: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        borderSide: BorderSide(
                                            color: AppColors.redColor),
                                      ),
                                      focusedErrorBorder:
                                           const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        borderSide: BorderSide(
                                            color: AppColors.redColor),
                                      ),
                                      filled: true,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  bool check =
                                      await GoogleMapFunctions.checkLocation();
                                  if (check) {
                                    await googleMapProvider.getLocation();
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  padding: EdgeInsets.symmetric(
                                      horizontal:MediaQuery.sizeOf(context).width * 0.01,
                                      vertical: MediaQuery.sizeOf(context).width * 0.01),
                                  decoration: BoxDecoration(
                                    color: const Color(0xffEEF1F3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child:  Icon(
                                    Icons.my_location,
                                    color: AppColors.primaryColor,
                                    size: 28,
                                  ),
                                ),
                              )
                            ],
                          ),
                          GoogleMapPredict(
                            address: (addrs) async {
                              googleMapProvider.locationData = addrs;

                              //set the address in text field
                              googleMapProvider.searchTC.text = addrs.streetAddress ?? "";

                              //set the lat lng
                              googleMapProvider.startLocation = lt.LatLng(
                                  addrs.lat ?? googleMapProvider.startLocation!.latitude,
                                  addrs.lng ??
                                      googleMapProvider.startLocation!.longitude);

                              //move the camera
                              googleMapProvider.mapsController?.animateCamera(
                                  CameraUpdate.newCameraPosition(CameraPosition(
                                target: googleMapProvider.startLocation!,
                                zoom: 18,
                              )));

                              //add the marker
                              googleMapProvider.markers.clear();
                              googleMapProvider.markers.add(
                                Marker(
                                  markerId: MarkerId("$googleMapProvider.startLocation"),
                                  position: googleMapProvider.startLocation!,
                                  icon: googleMapProvider.icon1!,
                                ),
                              );

                              //update
                              googleMapProvider.update();
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
        );
      }),
    );
  }
}

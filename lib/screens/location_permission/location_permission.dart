import 'package:connect_app/utils/app_colors.dart';
import 'package:connect_app/utils/text_styles.dart';
import 'package:connect_app/widgets/primary_button.dart';
import 'package:flutter/cupertino.dart'; // For iOS-style widgets
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Potentially import permission_handler here later
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/appbars.dart';

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

  Future<void> _requestLocationPermission() async {
    var status = await Permission.locationWhenInUse.request();
    SharedPreferences.getInstance().then((val) {
      val.setBool("isLocationPermissionAsked", true);
    });
    if (status.isGranted) {
      Get.back(); // Navigate back or to the next screen
    } else {
      // Handle denied permission
      Get.snackbar("Permission Denied", "Location permission is required for full app functionality.");
    }
  }

  // void _skipPermission() {
  //   debugPrint("Skipping location permission...");
  //   Get.back(); // Or navigate to a different screen
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        backButton: false,
        title: 'Location Access',
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(),
              Icon(
                CupertinoIcons.location_solid, // iOS location icon
                size: 100,
                color: AppColors.primaryColor,
              ),
              const SizedBox(height: 30),
              Text(
                'We need your location to show you more relevant video content.',
                textAlign: TextAlign.center,
                style: normalText(color: AppColors.primaryColor), // Using AppTextStyles
              ),
              const SizedBox(height: 20),
              Text(
                'By allowing location access, you\'ll discover trending videos and events happening near you, enriching your app experience.',
                textAlign: TextAlign.center,
                style: normalText(color: AppColors.lightText), // Using AppTextStyles
              ),
              Spacer(),
              PrimaryButton(label: "Continue", onPress: _requestLocationPermission),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

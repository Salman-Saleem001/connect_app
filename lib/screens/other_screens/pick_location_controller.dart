// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:connect_app/controllers/pick_controller.dart';
// import 'package:connect_app/globals/adaptive_helper.dart';
// import 'package:connect_app/utils/app_colors.dart';
// import 'package:connect_app/utils/text_styles.dart';
// import 'package:connect_app/widgets/appbars.dart';
// import 'package:connect_app/widgets/primary_button.dart';
// import 'package:connect_app/widgets/text_fields.dart';
//
// class PickLocation extends StatefulWidget {
//   final Function(String? address, LatLng latLng) onSubmit;
//   const PickLocation({super.key, required this.onSubmit});
//
//   @override
//   State<PickLocation> createState() => _PickLocationState();
// }
//
// class _PickLocationState extends State<PickLocation> {
//   var controller = Get.put(PickScreenController());
//   @override
//   void initState() {
//     controller.getLocation();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBackgroundColor,
//       bottomNavigationBar: Padding(
//         padding: EdgeInsets.only(
//             left: wd(20), right: wd(20), bottom: wd(10), top: 20),
//         child: PrimaryButton(
//             label: 'Confirm',
//             onPress: () {
//               if (controller.latLng == null || controller.fromLoc.text.isEmpty)
//                 return;
//               widget.onSubmit(controller.fromLoc.text, controller.latLng!);
//             }),
//       ),
//       appBar: customAppBar(title: 'Select Location', backButton: true),
//       body: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: GetBuilder<PickScreenController>(builder: (value) {
//           return Column(
//             children: [
//               SizedBox(
//                 height: ht(10),
//               ),
//               customTextFiled(
//                   controller.fromLoc, controller.fromnodeloc, [], null,
//                   hint: 'Search...', onchange: (String? val) {
//                 if (val!.length >= 3) {
//                   value.findPlaces(val);
//                 } else {
//                   value.places.clear();
//                   value.update();
//                 }
//               }),
//               SizedBox(
//                 height: ht(10),
//               ),
//               Expanded(
//                   child: Container(
//                       child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: GoogleMap(
//                       onMapCreated: (GoogleMapController c) {
//                         value.mapController.complete(c);
//                       },
//                       onCameraIdle: () async {
//                         controller.changeAddressBarValue();
//                       },
//                       onCameraMove: (position) {
//                         controller.changeMarkerPadding(true);
//
//                         value.latLng = LatLng(position.target.latitude,
//                             position.target.longitude);
//                       },
//                       markers: value.markers,
//                       initialCameraPosition: value.initialLocation,
//                       zoomControlsEnabled: false,
//                       myLocationEnabled: true,
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 25),
//                     child: Image.asset(
//                       'assets/images/pin.png',
//                       height: ht(120),
//                       color: Colors.red,
//                     ),
//                   ),
//                   Visibility(
//                     visible: value.showPlaces,
//                     child: Container(
//                       color: Colors.white,
//                       height: double.infinity,
//                       width: double.infinity,
//                       child: ListView.separated(
//                           separatorBuilder: (context, index) => const Padding(
//                                 padding: EdgeInsets.symmetric(horizontal: 20),
//                                 child: Divider(),
//                               ),
//                           itemCount: value.places.length,
//                           itemBuilder: ((context, index) => Card(
//                                 child: ListTile(
//                                   onTap: () {
//                                     FocusScope.of(context).unfocus();
//                                     value.chooseLocation(value.places[index]);
//                                   },
//                                   leading: const Icon(Icons.location_on),
//                                   title: Text(value.places[index],
//                                       style: normalText(size: 14)),
//                                 ),
//                               ))),
//                     ),
//                   )
//                 ],
//               ))),
//             ],
//           );
//         }),
//       ),
//     );
//   }
// }

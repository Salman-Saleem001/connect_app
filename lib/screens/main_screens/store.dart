// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:talentogram/controllers/mainScreen_controllers/store_controller.dart';
// import 'package:talentogram/globals/adaptive_helper.dart';
// import 'package:talentogram/globals/container_properties.dart';
// import 'package:talentogram/globals/database.dart';
// import 'package:talentogram/globals/enum.dart';
// import 'package:talentogram/globals/global.dart';
// import 'package:talentogram/globals/network_image.dart';
// import 'package:talentogram/models/item_model.dart';
// import 'package:talentogram/screens/other_screens/pick_location_controller.dart';
// import 'package:talentogram/screens/profile/account.dart';
// import 'package:talentogram/screens/profile/jobs/job_details.dart';
// import 'package:talentogram/utils/app_colors.dart';
// import 'package:talentogram/utils/text_styles.dart';
// import 'package:talentogram/widgets/appbars.dart';
// import 'package:talentogram/widgets/custom_bottom_option_sheet.dart';
//
//
// class StoreScreen extends StatefulWidget {
//   const StoreScreen({super.key});
//
//   @override
//   State<StoreScreen> createState() => _StoreScreenState();
// }
//
// class _StoreScreenState extends State<StoreScreen> {
//   StoreController controller = Get.put(StoreController());
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<StoreController>(builder: (value) {
//       return Scaffold(
//         backgroundColor: AppColors.scaffoldBackgroundColor,
//         appBar: customAppBar(
//             backButton: false,
//             lable: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Spacer(),
//                 GestureDetector(
//                   onTap: () {
//                     Get.to(() => MyAccount());
//                   },
//                   child: CircleAvatar(
//                     child: Icon(Icons.person),
//                   ),
//                 )
//               ],
//             )),
//         body: SafeArea(
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: wd(20)),
//             child: Column(
//               children: [
//                 if (!controller.isLoading) searchBar(),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 radiusNLocation(context),
//                 categories(value),
//                 5.hp,
//                 items(),
//               ],
//             ),
//           ),
//         ),
//       );
//     });
//   }
//
//   GetBuilder<StoreController> items() {
//     return GetBuilder<StoreController>(builder: (logic) {
//       return Expanded(
//         child: logic.isLoading
//             ? const Center(child: Center(child: CircularProgressIndicator()))
//             : StreamBuilder<List<DocumentSnapshot<ItemModel>>>(
//                 stream: Database.getNearByItems(
//                     logic.latLng, controller.searchController.text,
//                     radius: controller.radius),
//                 builder: (context, snap) {
//                   if (snap.hasError) {
//                     return Center(
//                         child: Text(
//                       "No Item Available",
//                       style: subHeadingText(color: Colors.white),
//                     ));
//                   }
//                   if (!snap.hasData) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   if (snap.data!.isEmpty) {
//                     return Center(
//                         child: Text(
//                       "No Item Available",
//                       style: subHeadingText(color: Colors.white),
//                     ));
//                   }
//
//                   return GridView.count(
//                     shrinkWrap: true,
//                     crossAxisSpacing: 20,
//                     mainAxisSpacing: 20,
//                     crossAxisCount: 2,
//                     childAspectRatio: 0.85,
//                     padding: const EdgeInsets.only(bottom: 100),
//                     children: List.generate(snap.data!.length, (index) {
//                       ItemModel itemModel = snap.data![index].data()!;
//                       return ItemWidget(
//                         itemModel: itemModel,
//                       );
//                     }),
//                   );
//                 }),
//       );
//     });
//   }
//
//   SizedBox categories(StoreController value) {
//     return SizedBox(
//       height: 60,
//       child: ListView.separated(
//           separatorBuilder: (ctx, i) => const SizedBox(
//                 width: 15,
//               ),
//           scrollDirection: Axis.horizontal,
//           itemCount: value.categories.keys.toList().length,
//           itemBuilder: (ctx, index) {
//             return GestureDetector(
//               onTap: () {
//                 value.changeCategory(index);
//               },
//               child: Container(
//                 margin: const EdgeInsets.symmetric(vertical: 10),
//                 padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
//                 alignment: Alignment.center,
//                 decoration: ContainerProperties.shadowDecoration(
//                     radius: 10,
//                     blurRadius: 5,
//                     spreadRadius: 3,
//                     color: value.selectedCat == index
//                         ? AppColors.primaryColor
//                         : Colors.white),
//                 child: Text(
//                   value.categories.keys.toList()[index],
//                   style: value.selectedCat == index
//                       ? headingText(color: Colors.white, size: 14)
//                       : normalText(size: 14),
//                 ),
//               ),
//             );
//           }),
//     );
//   }
//
//   Column searchBar() {
//     return Column(
//       children: [
//         GestureDetector(
//           onTap: () {
//             // Get.to(() => const MapScreen());
//           },
//           child: Container(
//             margin: const EdgeInsets.symmetric(horizontal: 10),
//             height: ht(50),
//             width: double.infinity,
//             decoration: ContainerProperties.borderDecoration(radius: 100),
//             child: Row(
//               children: [
//                 const SizedBox(
//                   width: 30,
//                 ),
//                 Expanded(
//                     child: Text(
//                   'Show Map',
//                   style: regularText(color: AppColors.primaryColor),
//                 )),
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: ContainerProperties.simpleDecoration(
//                       radius: 100, color: AppColors.primaryColor),
//                   width: 100,
//                   height: ht(50),
//                   child: Image.asset('assets/images/ic_maps.png'),
//                 )
//               ],
//             ),
//           ),
//         ),
//         // 10.hp,
//         // customTextFiled(
//         //     controller.searchController, controller.searchNode, [], null,
//         //     hint: 'Search...', onchange: (a) {
//         //   controller.update();
//         // })
//       ],
//     );
//   }
// }
//
// Row radiusNLocation(BuildContext context) {
//   return Row(
//     children: [
//       Expanded(
//         child: Align(
//           alignment: Alignment.centerLeft,
//           child: GestureDetector(
//             onTap: () {
//               customBottomSheet(
//                   Get.find<StoreController>()
//                       .radiusList
//                       .map((e) => e.toString())
//                       .toList(),
//                   -1, (i) {
//                 Get.find<StoreController>().changeRadius(i);
//               });
//             },
//             child: Container(
//               padding: EdgeInsets.symmetric(vertical: 3, horizontal: 6),
//               decoration: ContainerProperties.simpleDecoration(
//                   radius: 80, color: AppColors.primaryColor),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Image.asset(
//                     'assets/images/ic_radius.png',
//                     height: 20,
//                   ),
//                   10.wp,
//                   Text(
//                     Get.find<StoreController>().radius.toString() + "Km",
//                     style: regularText(color: Colors.white),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//       Expanded(
//         child: GestureDetector(
//           onTap: () {
//             Get.to(() => PickLocation(onSubmit: (loc, latlng) {
//                   Get.back();
//                   Get.find<StoreController>().updateLocation(loc ?? '', latlng);
//                 }));
//           },
//           child: Row(
//             children: [
//               Image.asset(
//                 'assets/images/ic_marker.png',
//                 height: 16,
//                 color: AppColors.primaryColor,
//               ),
//               const SizedBox(
//                 width: 5,
//               ),
//               Expanded(
//                 child: Text(
//                   Get.find<StoreController>().location,
//                   maxLines: 1,
//                   style: normalText(size: 14, color: Colors.white),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ],
//   );
// }
//
// class ItemWidget extends StatelessWidget {
//   ItemWidget(
//       {super.key, required this.itemModel, this.isMylistingPage = false});
//   final ItemModel? itemModel;
//   final bool isMylistingPage;
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         if (itemModel!.category == ItemType.accomodation) {
//         } else {
//           Get.to(() => AppliedJobDetails(
//                 itemModel: itemModel!,
//                 showApplyButton: true,
//               ));
//         }
//       },
//       child: Container(
//           width: 60,
//           alignment: Alignment.center,
//           decoration: ContainerProperties.shadowDecoration(
//             yd: 3,
//             radius: 10,
//             blurRadius: 5,
//             spreadRadius: 3,
//           ),
//           child: Stack(
//             children: [
//               Column(
//                 children: [
//                   Expanded(
//                       child: Stack(
//                     children: [
//                       Center(
//                         child: ClipRRect(
//                           borderRadius: const BorderRadius.vertical(
//                               top: Radius.circular(5)),
//                           child: !Global.checkNull(itemModel?.pitures)
//                               ? Image.asset(
//                                   'assets/images/ic_upload.png',
//                                   fit: BoxFit.cover,
//                                 )
//                               : NetworkImageCustom(
//                                   image: itemModel?.pitures ?? '',
//                                   fit: BoxFit.cover,
//                                 ),
//                         ),
//                       ),
//                       Container(
//                         decoration: const BoxDecoration(
//                             color: Colors.black12,
//                             borderRadius: BorderRadius.vertical(
//                                 top: Radius.circular(10))),
//                       ),
//                     ],
//                   )),
//                   Padding(
//                     padding:
//                         const EdgeInsets.symmetric(vertical: 6, horizontal: 5),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: Text(
//                                       itemModel!.title,
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: headingText(size: 12),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Text(
//                                 itemModel!.description,
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: normalText(size: 12),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           )),
//     );
//   }
// }

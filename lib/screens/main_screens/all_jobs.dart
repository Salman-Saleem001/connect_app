// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:talentogram/controllers/cv_controller.dart';
// import 'package:talentogram/controllers/mainScreen_controllers/navbar_controller.dart';
// import 'package:talentogram/controllers/mainScreen_controllers/store_controller.dart';
// import 'package:talentogram/globals/adaptive_helper.dart';
// import 'package:talentogram/globals/database.dart';
// import 'package:talentogram/globals/enum.dart';
// import 'package:talentogram/models/item_model.dart';
// import 'package:talentogram/screens/main_screens/store.dart';
// import 'package:talentogram/screens/profile/jobs/job_details.dart';
// import 'package:talentogram/utils/app_colors.dart';
// import 'package:talentogram/utils/text_styles.dart';
// import 'package:talentogram/widgets/appbars.dart';
// import 'package:talentogram/widgets/primary_button.dart';
//
// class AllJobs extends StatefulWidget {
//   const AllJobs({super.key});
//
//   @override
//   State<AllJobs> createState() => _AllJobsState();
// }
//
// class _AllJobsState extends State<AllJobs> {
//   var storeController = Get.put(CvController());
//   var controller = Get.put(NavBarController());
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<StoreController>(builder: (value) {
//       return Scaffold(
//         backgroundColor: AppColors.scaffoldBackgroundColor,
//         appBar: customAppBar(backButton: false, title: 'All Jobs'),
//         body: SafeArea(
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: wd(15), vertical: ht(15)),
//             child: Column(
//               children: [
//                 radiusNLocation(context),
//                 20.hp,
//                 Expanded(
//                   child: StreamBuilder<List<DocumentSnapshot<ItemModel>>>(
//                       stream: Database.getNearByJobs(value.latLng,
//                           radius: value.radius),
//                       builder: (context, snap) {
//                         if (snap.hasError) {
//                           return Center(
//                               child: Text(
//                             // snap.error.toString(),
//                             "No Jobs Available",
//                             style: subHeadingText(color: Colors.white),
//                           ));
//                         }
//                         if (!snap.hasData) {
//                           return const Center(
//                               child: CircularProgressIndicator());
//                         }
//                         if (snap.data!.isEmpty) {
//                           return Center(
//                               child: Text(
//                             "No Jobs Available",
//                             style: subHeadingText(color: Colors.white),
//                           ));
//                         }
//
//                         return ListView.builder(
//                             physics: const NeverScrollableScrollPhysics(),
//                             shrinkWrap: true,
//                             itemCount: snap.data!.length,
//                             itemBuilder: (context, index) {
//                               ItemModel? jobModel = snap.data?[index].data();
//                               return Container(
//                                 margin: EdgeInsets.only(bottom: 10),
//                                 decoration: BoxDecoration(
//                                     border: Border.all(
//                                         color: AppColors.primaryColor),
//                                     borderRadius:
//                                         BorderRadius.all(Radius.circular(10))),
//                                 padding: EdgeInsets.only(right: 10, left: 10),
//                                 child: Column(
//                                   children: [
//                                     ListTile(
//                                       contentPadding: EdgeInsets.zero,
//                                       title: Row(
//                                         children: [
//                                           Expanded(
//                                             child: Text(
//                                               jobModel!.title,
//                                               style: regularText(
//                                                 color: AppColors.bgGrey,
//                                               ),
//                                             ),
//                                           ),
//                                           Text(
//                                             jobModel.location,
//                                             style: regularText(
//                                                 color: AppColors.borderColor,
//                                                 size: 8),
//                                           ),
//                                         ],
//                                       ),
//                                       subtitle: Text(
//                                         jobModel.description,
//                                         style: regularText(
//                                             color: AppColors.txtGrey, size: 10),
//                                       ),
//                                     ),
//                                     Divider(
//                                       height: 1,
//                                       color: AppColors.borderColor,
//                                     ),
//                                     16.hp,
//                                     PrimaryButton(
//                                       label: 'View',
//                                       onPress: () {
//                                         Get.to(() => AppliedJobDetails(
//                                               itemModel: jobModel,
//                                               showApplyButton: true,
//                                             ));
//                                       },
//                                       radius: 4,
//                                       buttonHight: 45,
//                                     ),
//                                     16.hp,
//                                   ],
//                                 ),
//                               );
//                             });
//                       }),
//                 ),
//                 20.hp,
//               ],
//             ),
//           ),
//         ),
//       );
//     });
//   }
// }

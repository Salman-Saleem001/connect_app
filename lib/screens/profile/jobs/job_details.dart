// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import 'package:talentogram/globals/adaptive_helper.dart';
// import 'package:talentogram/globals/container_properties.dart';
// import 'package:talentogram/globals/database.dart';
// import 'package:talentogram/globals/enum.dart';
// import 'package:talentogram/models/application_model.dart';
//
// import 'package:talentogram/models/item_model.dart';
// import 'package:talentogram/screens/other_screens/select_cv.dart';
// import 'package:talentogram/utils/app_colors.dart';
//
// import 'package:talentogram/utils/text_styles.dart';
// import 'package:talentogram/widgets/appbars.dart';
// import 'package:talentogram/widgets/primary_button.dart';
//
// class AppliedJobDetails extends StatefulWidget {
//   final ItemModel itemModel;
//   final bool showApplyButton;
//
//   const AppliedJobDetails(
//       {super.key, required this.itemModel, this.showApplyButton = false});
//
//   @override
//   State<AppliedJobDetails> createState() => _AppliedJobDetailsState();
// }
//
// class _AppliedJobDetailsState extends State<AppliedJobDetails> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBackgroundColor,
//       appBar: customAppBar(backButton: true, title: 'Job Details'),
//       body: SafeArea(
//         child: ListView(
//           padding: EdgeInsets.symmetric(horizontal: wd(15), vertical: ht(15)),
//           children: [
//             const SizedBox(
//               height: 20,
//             ),
//             Text(widget.itemModel.title,
//                 style: headingText(color: AppColors.bgGrey, size: 18)),
//             Text(
//               widget.itemModel.description,
//               style: regularText(size: 12, color: AppColors.borderColor),
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
//               decoration: ContainerProperties.simpleDecoration(
//                   color: AppColors.bgGrey, radius: 10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Description :",
//                       style: headingText(color: AppColors.bgGrey, size: 18)),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   Text(
//                     widget.itemModel.description,
//                     style: regularText(size: 12, color: AppColors.borderColor),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
//               decoration: ContainerProperties.simpleDecoration(
//                   color: AppColors.bgGrey, radius: 10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Text(
//                         "Location:",
//                         style: headingText(color: AppColors.bgGrey, size: 16),
//                       ),
//                       const SizedBox(
//                         width: 10,
//                       ),
//                       Text(
//                         widget.itemModel.location,
//                         style: regularText(color: AppColors.borderColor),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       Text(
//                         "Hourly Rate:",
//                         style: headingText(color: AppColors.bgGrey, size: 16),
//                       ),
//                       const SizedBox(
//                         width: 10,
//                       ),
//                       Text(
//                         "\$ ${widget.itemModel.itemDetails['hourlyRate'] ?? 0}",
//                         style: regularText(color: AppColors.borderColor),
//                       ),
//                     ],
//                   ),
//                   0.hp,
//                 ],
//               ),
//             ),
//             40.hp,
//             // if (widget.showApplyButton)
//             StreamBuilder<QuerySnapshot<ApplicantModel>>(
//                 stream: Database.checkJobAppliedOrNot(widget.itemModel.id),
//                 builder: (context, snap) {
//                   if (snap.hasError) {
//                     return Center(
//                         child: Text(
//                       // snap.error.toString(),
//                       "",
//                       style: subHeadingText(color: Colors.white),
//                     ));
//                   }
//                   if (!snap.hasData) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   if (snap.data!.docs.isEmpty) {
//                     return PrimaryButton(
//                         label: 'Apply',
//                         onPress: () {
//                           Get.to(() => SelectCvs(itemModel: widget.itemModel));
//                         });
//                   }
//                   return Center(
//                       child: Text(
//                     "",
//                     style: subHeadingText(color: Colors.white),
//                   ));
//                 }),
//           ],
//         ),
//       ),
//     );
//   }
// }

//
// import 'package:flutter/material.dart';
//
// import 'package:get/get.dart';
// import 'package:talentogram/globals/adaptive_helper.dart';
// import 'package:talentogram/globals/container_properties.dart';
// import 'package:talentogram/screens/profile/jobs/applied_jobs.dart';
// import 'package:talentogram/screens/profile/edit_details.dart';
// import 'package:talentogram/screens/profile/my_cv.dart';
// import 'package:talentogram/utils/app_colors.dart';
// import 'package:talentogram/utils/login_details.dart';
// import 'package:talentogram/utils/text_styles.dart';
// import 'package:talentogram/widgets/appbars.dart';
// import 'package:talentogram/widgets/primary_button.dart';
//
// import 'change_password.dart';
//
// class MyAccount extends StatefulWidget {
//   const MyAccount({super.key});
//
//   @override
//   State<MyAccount> createState() => _MyAccountState();
// }
//
// class _MyAccountState extends State<MyAccount> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: customAppBar(title: 'Profile'),
//       backgroundColor: AppColors.scaffoldBackgroundColor,
//       body: SafeArea(
//         child: ListView(
//           padding: EdgeInsets.symmetric(horizontal: wd(25), vertical: ht(30)),
//           children: [
//             SizedBox(
//               height: ht(20),
//             ),
//             top_box(),
//             SizedBox(
//               height: ht(40),
//             ),
//             setting_container(),
//             SizedBox(
//               height: 10,
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 0),
//               decoration: ContainerProperties.simpleDecoration(
//                   color: AppColors.bgGrey, radius: 15),
//               child: Column(
//                 children: [
//                   ListTile(
//                     onTap: () {
//                       // Get.to(() => const AppliedJobs());
//                     },
//                     // leading: CircleAvatar(
//                     //   backgroundColor: Colors.transparent,
//                     //   child: Padding(
//                     //     padding: const EdgeInsets.all(4.0),
//                     //     child:
//                     //         Icon(Icons.help_outline, color: AppColors.txtGrey),
//                     //   ),
//                     // ),
//                     title: Text(
//                       'My Applied Jobs',
//                       style: regularText(
//                         color: AppColors.txtGrey,
//                       ),
//                     ),
//                     trailing: Icon(Icons.keyboard_arrow_right,
//                         color: AppColors.borderColor),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 0),
//               decoration: ContainerProperties.simpleDecoration(
//                   color: AppColors.bgGrey, radius: 15),
//               child: Column(
//                 children: [
//                   ListTile(
//                     // onTap: () {
//                     //   Get.to(() => const MyCVs());
//                     // },
//                     // leading: CircleAvatar(
//                     //   backgroundColor: Colors.transparent,
//                     //   child: Padding(
//                     //     padding: const EdgeInsets.all(4.0),
//                     //     child:
//                     //         Icon(Icons.help_outline, color: AppColors.txtGrey),
//                     //   ),
//                     // ),
//                     title: Text(
//                       'My CVs',
//                       style: regularText(
//                         color: AppColors.txtGrey,
//                       ),
//                     ),
//                     trailing: Icon(Icons.keyboard_arrow_right,
//                         color: AppColors.borderColor),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 15),
//               decoration: ContainerProperties.simpleDecoration(
//                   color: AppColors.bgGrey, radius: 15),
//               child: Column(
//                 children: [
//                   ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: Colors.transparent,
//                       child: Padding(
//                         padding: const EdgeInsets.all(4.0),
//                         child:
//                             Icon(Icons.help_outline, color: AppColors.txtGrey),
//                       ),
//                     ),
//                     title: Text(
//                       'Help & Support',
//                       style: regularText(
//                         color: AppColors.txtGrey,
//                       ),
//                     ),
//                   ),
//                   ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: Colors.transparent,
//                       child: Padding(
//                         padding: const EdgeInsets.all(4.0),
//                         child: Icon(Icons.policy_outlined,
//                             color: AppColors.txtGrey),
//                       ),
//                     ),
//                     title: Text(
//                       'Terms & Policies',
//                       style: regularText(
//                         color: AppColors.txtGrey,
//                       ),
//                     ),
//                   ),
//                   ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: Colors.transparent,
//                       child: Padding(
//                         padding: const EdgeInsets.all(4.0),
//                         child: Icon(Icons.policy_outlined,
//                             color: AppColors.txtGrey),
//                       ),
//                     ),
//                     title: Text(
//                       'Report a problem',
//                       style: regularText(
//                         color: AppColors.txtGrey,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             PrimaryButton(
//                 label: 'Logout',
//                 onPress: () {
//                   Get.find<UserDetail>().logout();
//                 })
//           ],
//         ),
//       ),
//     );
//   }
//
//   Container setting_container() {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 15),
//       decoration: ContainerProperties.simpleDecoration(
//           color: AppColors.bgGrey, radius: 15),
//       child: Column(
//         children: [
//           ListTile(
//             onTap: () {
//               Get.to(() => const EditDetails());
//             },
//             leading: CircleAvatar(
//               backgroundColor: AppColors.bgGrey.withOpacity(0.09),
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Icon(Icons.person_outlined, color: AppColors.bgGrey),
//               ),
//             ),
//             title: Text(
//               'My Account',
//               style: subHeadingText(color: AppColors.bgGrey, size: 13),
//             ),
//             subtitle: Text(
//               'Make changes to your account',
//               style: regularText(color: AppColors.borderColor, size: 11),
//             ),
//             trailing:
//                 Icon(Icons.keyboard_arrow_right, color: AppColors.borderColor),
//           ),
//           ListTile(
//             onTap: () {
//               Get.to(() => NewPassword());
//             },
//             leading: CircleAvatar(
//               backgroundColor: AppColors.bgGrey.withOpacity(0.09),
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Icon(Icons.lock_outlined, color: AppColors.bgGrey),
//               ),
//             ),
//             title: Text(
//               'Change Password',
//               style: subHeadingText(color: AppColors.bgGrey, size: 13),
//             ),
//             subtitle: Text(
//               'Manage your account security',
//               style: regularText(color: AppColors.borderColor, size: 11),
//             ),
//             trailing:
//                 Icon(Icons.keyboard_arrow_right, color: AppColors.borderColor),
//           ),
//           const SizedBox(
//             height: 11,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Container top_box() {
//     return Container(
//       decoration: ContainerProperties.simpleDecoration(
//           color: AppColors.primaryColor, radius: 15),
//       padding: EdgeInsets.symmetric(horizontal: ht(25), vertical: ht(18)),
//       child: GetBuilder<UserDetail>(builder: (value) {
//         return Row(children: [
//           Center(
//             child: CircleAvatar(
//               backgroundColor: AppColors.scaffoldGrey,
//               radius: 27,
//               child: value.userData.user!.avatar == ''
//                   ? const Icon(Icons.image)
//                   : ClipRRect(
//                       borderRadius: BorderRadius.circular(100),
//                       child: Image.network(
//                         value.userData.user!.avatar!,
//                         fit: BoxFit.cover,
//                         height: double.infinity,
//                         width: double.infinity,
//                       ),
//                     ),
//             ),
//           ),
//           SizedBox(
//             width: wd(5),
//           ),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.only(bottom: 0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "${value.userData.user!.firstName} ${value.userData.user!.lastName}",
//                     style: subHeadingText(color: Colors.white, size: 14),
//                   ),
//                   Text(
//                     "${value.userData.user!.email}",
//                     style: regularText(color: AppColors.bgGrey, size: 12),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Center(
//             child: GestureDetector(
//               onTap: () {
//                 Get.to(() => EditDetails());
//               },
//               child: const Icon(
//                 Icons.edit,
//                 size: 30,
//                 color: Colors.white,
//               ),
//             ),
//           )
//         ]);
//       }),
//     );
//   }
// }

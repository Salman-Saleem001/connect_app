// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:get/get.dart';
// import 'package:talentogram/controllers/mainScreen_controllers/store_controller.dart';
// import 'package:talentogram/globals/adaptive_helper.dart';
// import 'package:talentogram/globals/chat_database.dart';
// import 'package:talentogram/globals/container_properties.dart';
// import 'package:talentogram/globals/database.dart';
// import 'package:talentogram/globals/enum.dart';
// import 'package:talentogram/globals/network_image.dart';
// import 'package:talentogram/models/group_chat_model.dart';
// import 'package:talentogram/models/user.dart';
// import 'package:talentogram/screens/main_screens/chat_view/chat_room.dart';
// import 'package:talentogram/screens/main_screens/store.dart';
// import 'package:talentogram/utils/app_colors.dart';
// import 'package:talentogram/utils/login_details.dart';
// import 'package:talentogram/utils/text_styles.dart';
// import 'package:talentogram/widgets/appbars.dart';
// import 'package:talentogram/widgets/primary_button.dart';
//
// class Buddies extends StatefulWidget {
//   const Buddies({super.key});
//
//   @override
//   State<Buddies> createState() => _BuddiesState();
// }
//
// class _BuddiesState extends State<Buddies> {
//   checkStatus() {}
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBackgroundColor,
//       appBar: customAppBar(backButton: false, title: 'Buddies'),
//       body: GetBuilder<StoreController>(builder: (logic) {
//         return SafeArea(
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: wd(15), vertical: ht(15)),
//             child: Column(
//               children: [
//                 radiusNLocation(context),
//                 20.hp,
//                 Expanded(
//                   child: StreamBuilder<List<DocumentSnapshot<UserModel>>>(
//                       stream: Database.getNearByBuddies(logic.latLng, '',
//                           radius: logic.radius),
//                       builder: (context, snap) {
//                         if (snap.hasError) {
//                           return Center(
//                               child: Text(
//                             // snap.error.toString(),
//                             "No Buddies Available",
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
//                             "No Buddies Available",
//                             style: subHeadingText(color: Colors.white),
//                           ));
//                         }
//
//                         return ListView.builder(
//                             padding: EdgeInsets.only(bottom: 70),
//                             shrinkWrap: true,
//                             itemCount: snap.data?.length,
//                             itemBuilder: (context, index) {
//                               UserModel? userModel = snap.data?[index].data();
//                               if (userModel?.id ==
//                                   Get.find<UserDetail>().userId) {
//                                 return Container();
//                               }
//                               return buddieContainer(userModel);
//                             });
//                       }),
//                 )
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }
// }
//
// Container buddieContainer(UserModel? userModel) {
//   return Container(
//     margin: EdgeInsets.only(bottom: 20),
//     padding: const EdgeInsets.symmetric(horizontal: 16),
//     decoration: ContainerProperties.simpleDecoration(
//         color: AppColors.bgGrey, radius: 8),
//     child: Column(
//       children: [
//         6.hp,
//         ListTile(
//             contentPadding: EdgeInsets.zero,
//             title: Row(
//               children: [
//                 CircleAvatar(
//                   radius: 17,
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(80),
//                     child: NetworkImageCustom(
//                       image: userModel?.image,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//                 10.wp,
//                 Expanded(
//                   child: Text(
//                     (userModel?.fname ?? '') + " " + (userModel?.lname ?? ''),
//                     style: regularText(
//                       color: AppColors.bgGrey,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             subtitle: Container(
//                 margin: const EdgeInsets.symmetric(vertical: 8),
//                 decoration: ContainerProperties.simpleDecoration(
//                   color: Colors.white,
//                 ),
//                 height: 300,
//                 child: NetworkImageCustom(
//                   image: userModel?.image,
//                   fit: BoxFit.cover,
//                 ))),
//         Divider(
//           height: 1,
//           color: AppColors.borderColor,
//         ),
//         16.hp,
//         // StreamBuilder<
//         //         QuerySnapshot<ChatGroupModel>>(
//         //     stream: Database.getChatRoomStatus([
//         //       userModel?.id,
//         //       Get.find<UserDetail>().userId
//         //     ]),
//         //     builder: (context, snap) {
//         //       final querySnapshot = snap.data;
//         //       final List<ChatGroupModel>
//         //           chatGroups = querySnapshot!.docs
//         //               .map((doc) =>
//         //                   ChatGroupModel.fromMap(
//         //                       doc))
//         //               .toList();
//
//         //       if (snap.hasError) {
//         //         return Center(
//         //             child: Text(
//         //           // snap.error.toString(),
//         //           "",
//         //           style: subHeadingText(
//         //               color: Colors.white),
//         //         ));
//         //       }
//         //       if (!snap.hasData) {
//         //         return const Center(
//         //             child:
//         //                 CircularProgressIndicator());
//         //       }
//         //       if (snap.hasData) {
//         //         return Center(
//         //             child: Text(
//         //           // "has data",
//         //           chatGroups.
//         //           style: subHeadingText(
//         //               color: Colors.white),
//         //         ));
//         //       }
//         //       return Center(
//         //           child: Text(
//         //         "",
//         //         style: subHeadingText(
//         //             color: Colors.white),
//         //       ));
//         //     }),
//         // fff
//         StreamBuilder<QuerySnapshot<ChatGroupModel>>(
//             stream: Database.getChatRoomStatus(userModel?.id ?? ""),
//             builder: (context, snap) {
//               // print(chatGroups);
//               if (snap.hasError) {
//                 return Center(child: Container());
//               }
//               if (!snap.hasData) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               final querySnapshot = snap.data;
//               if (querySnapshot?.docs.isNotEmpty ?? false) {
//                 String label = 'Connect';
//                 String status =
//                     querySnapshot?.docs.first.data().status ?? "Accepted";
//                 if (status == 'rejected') {
//                   label = 'Request Rejected';
//                 } else if (status == 'accepted') {
//                   label = 'Chat Now';
//                 } else if (status == 'pending') {
//                   label = 'Request Sent';
//                 }
//                 return PrimaryButton(
//                   label: label,
//                   onPress: () async {
//                     if (status == 'rejected') {
//                       return;
//                     } else {
//                       Get.to(ChatDetailScreen(
//                           chat: querySnapshot!.docs.first.data()));
//                     }
//                   },
//                   radius: 8,
//                   buttonHight: 40,
//                 );
//               }
//               return PrimaryButton(
//                 label: 'Connect',
//                 onPress: () async {
//                   EasyLoading.show();
//                   await FireDatabase.createChatRoom(userModel!)
//                       .then((id) async {
//                     if (id != 'null') {
//                       var chatGroupModel = await Database.getSingleChat(id);
//                       if (chatGroupModel.exists) {
//                         Get.to(() => ChatDetailScreen(
//                               chat: chatGroupModel.data()!,
//                             ));
//                       }
//                     }
//                   });
//
//                   EasyLoading.dismiss();
//                 },
//                 radius: 8,
//                 buttonHight: 40,
//               );
//             }),
//
//         16.hp,
//       ],
//     ),
//   );
// }

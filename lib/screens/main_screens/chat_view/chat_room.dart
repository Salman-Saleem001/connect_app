// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:talentogram/controllers/chat/chat_detail_controller.dart';
// import 'package:talentogram/globals/adaptive_helper.dart';
// import 'package:talentogram/globals/app_views.dart';
// import 'package:talentogram/globals/database.dart';
// import 'package:talentogram/globals/enum.dart';
// import 'package:talentogram/globals/network_image.dart';
// import 'package:talentogram/models/chat_model.dart';
// import 'package:talentogram/models/group_chat_model.dart';
// import 'package:talentogram/models/local_chat_model.dart';
// import 'package:talentogram/models/user.dart';
// import 'package:talentogram/screens/main_screens/chat_view/widget/chat_list_item.dart';
// import 'package:talentogram/utils/app_colors.dart';
// import 'package:talentogram/utils/login_details.dart';
// import 'package:talentogram/utils/text_styles.dart';
// import 'package:talentogram/widgets/primary_button.dart';
//
// class ChatDetailScreen extends StatefulWidget {
//   ChatGroupModel chat;
//   ChatDetailScreen({Key? key, required this.chat}) : super(key: key);
//
//   @override
//   ChatDetailScreenState createState() => ChatDetailScreenState();
// }
//
// class ChatDetailScreenState extends State<ChatDetailScreen> {
//   var controller = Get.put(ChatDetailController());
//
//   late Stream<QuerySnapshot> stream;
//
//   @override
//   void initState() {
//     controller.id = widget.chat.roomId;
//     controller.userId = widget.chat.roomId;
//     stream = FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.chat.roomId)
//         .collection('messages')
//         .orderBy('timestamp', descending: true)
//         .snapshots();
//
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: AppColors.scaffoldBackgroundColor,
//         body: SafeArea(
//             child: Stack(
//           children: [
//             Column(
//               children: [
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       GestureDetector(
//                         onTap: () {
//                           Get.back();
//                         },
//                         child: const Icon(
//                           Icons.arrow_back_ios,
//                           color: Colors.white,
//                         ),
//                       ),
//                       10.wp,
//                       Expanded(
//                         child: StreamBuilder<DocumentSnapshot<UserModel>>(
//                             stream: Database.getSingleUser(
//                                 widget.chat.user1.id ==
//                                         Get.find<UserDetail>().userId
//                                     ? widget.chat.user2.id
//                                     : widget.chat.user1.id),
//                             builder: (context, snap) {
//                               GroupChatUser user = widget.chat.user1.id ==
//                                       Get.find<UserDetail>().userId
//                                   ? widget.chat.user2
//                                   : widget.chat.user1;
//                               String name = snap.hasData
//                                   ? '${snap.data?.data()?.fname ?? ""} ${snap.data?.data()?.lname ?? ''}'
//                                   : user.name;
//                               String image = snap.hasData
//                                   ? (snap.data?.data()?.image ?? '')
//                                   : '';
//                               return Container(
//                                 decoration: const BoxDecoration(
//                                     border: Border(
//                                         bottom:
//                                             BorderSide(color: Colors.white10))),
//                                 alignment: Alignment.center,
//                                 padding:
//                                     const EdgeInsets.symmetric(vertical: 13),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: [
//                                     Container(
//                                       margin: const EdgeInsets.only(
//                                         right: 10,
//                                       ),
//                                       child: ClipRRect(
//                                         borderRadius: BorderRadius.circular(50),
//                                         child: NetworkImageCustom(
//                                             image: image,
//                                             fit: BoxFit.cover,
//                                             height: 40,
//                                             width: 40),
//                                       ),
//                                     ),
//                                     10.wp,
//                                     Expanded(
//                                         child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       children: [
//                                         Container(
//                                             alignment: Alignment.centerLeft,
//                                             child: Row(
//                                               children: [
//                                                 Expanded(
//                                                     child: Text(
//                                                   name,
//                                                   style: subHeadingText(
//                                                       size: 16,
//                                                       color: Colors.white),
//                                                 )),
//                                               ],
//                                             )),
//                                       ],
//                                     )),
//                                   ],
//                                 ),
//                               );
//                             }),
//                       )
//                     ],
//                   ),
//                 ),
//                 Expanded(child: messages(context)),
//               ],
//             ),
//             if (widget.chat.status == 'pending' &&
//                 widget.chat.createdBy != Get.find<UserDetail>().userId)
//               Positioned(
//                 top: 100,
//                 left: 15,
//                 right: 15,
//                 child: Row(
//                   children: [
//                     Expanded(
//                         child: PrimaryButton(
//                       label: 'Accept',
//                       whiteButton: true,
//                       onPress: () {
//                         FirebaseFirestore.instance
//                             .collection('chats')
//                             .doc(widget.chat.roomId)
//                             .update({'status': 'accepted'});
//                         widget.chat.status = 'accepted';
//                         setState(() {});
//                       },
//                       color: const Color(0xff83FF49),
//                     )),
//                     20.wp,
//                     Expanded(
//                         child: PrimaryButton(
//                       label: 'Decline',
//                       whiteButton: true,
//                       onPress: () {
//                         FirebaseFirestore.instance
//                             .collection('chats')
//                             .doc(widget.chat.roomId)
//                             .update({'status': 'rejected'});
//                         widget.chat.status = 'rejected';
//                         setState(() {});
//                       },
//                       color: const Color(0xffFF4949),
//                     )),
//                   ],
//                 ),
//               )
//           ],
//         )));
//   }
//
//   Stack messages(BuildContext context) {
//     return Stack(
//       children: [
//         Column(
//           children: [
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                   stream: stream,
//                   builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//                     if (snapshot.hasError) {
//                       return const Text('Something went wrong');
//                     }
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const SizedBox();
//                     }
//
//                     return ListView.builder(
//                       padding: const EdgeInsets.all(10),
//                       reverse: true,
//                       itemCount: snapshot.data!.docs.length,
//                       itemBuilder: (BuildContext contextM, index) {
//                         ChatModel chatModel =
//                             ChatModel.fromMap(snapshot.data!.docs[index]);
//
//                         LocalChatModel chat = LocalChatModel(
//                             time: chatModel.timeStamp,
//                             message: chatModel.message,
//                             files: chatModel.files,
//                             mMsgType:
//                                 chatModel.from == Get.find<UserDetail>().userId
//                                     ? MsgType.right
//                                     : MsgType.left);
//
//                         return ChatListItem(
//                           mChatModel: chat,
//                           onTap: () {},
//                         );
//                       },
//                     );
//                   }),
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             GetBuilder<ChatDetailController>(builder: (value) {
//               return SizedBox(
//                 height: value.isShowEmojis ? 260 : 60,
//               );
//             })
//           ],
//         ),
//         Column(
//           children: [
//             Flexible(
//               flex: 1,
//               child: Container(),
//             ),
//             _textField(context),
//             _emojiSection()
//           ],
//         ),
//
//         // AppViews.showLoadingWithStatus(isShowLoader)
//       ],
//     );
//   }
//
//   GetBuilder<ChatDetailController> _emojiSection() {
//     return GetBuilder<ChatDetailController>(builder: (value) {
//       return Visibility(
//           visible: value.isShowEmojis,
//           child: SizedBox(
//             height: 200,
//             child: ListView(
//               padding: const EdgeInsets.all(10),
//               children: [
//                 Wrap(
//                   runAlignment: WrapAlignment.start,
//                   alignment: WrapAlignment.center,
//                   runSpacing: 10,
//                   spacing: 10,
//                   children: List.generate(
//                       value.emojis.length,
//                       (index) => InkWell(
//                             onTap: () {
//                               value.addEmojis(value.emojis[index]);
//                             },
//                             child: Text(
//                               value.emojis[index],
//                               style: const TextStyle(fontSize: 27),
//                             ),
//                           )),
//                 )
//               ],
//             ),
//           ));
//     });
//   }
//
//   Column _textField(BuildContext context) {
//     return Column(
//       children: [
//         GetBuilder<ChatDetailController>(builder: (value) {
//           return Visibility(
//             visible: value.loading,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: LinearProgressIndicator(
//                 color: Colors.grey.withOpacity(0.3),
//               ),
//             ),
//           );
//         }),
//         Row(
//           children: [
//             Expanded(
//               child: Container(
//                 height: ht(45),
//                 margin: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                     color: const Color(0xff383838).withOpacity(0.8),
//                     borderRadius: BorderRadius.circular(100)),
//                 child: TextField(
//                   onTap: () => controller.disableEmoji(),
//                   textInputAction: TextInputAction.done,
//                   keyboardType: TextInputType.text,
//                   style: normalText(color: Colors.white),
//                   controller: controller.controllerMessage,
//                   textAlign: TextAlign.start,
//                   decoration: InputDecoration(
//                     // fillColor: AppColors.primaryColor,
//                     prefixIconConstraints: const BoxConstraints(minWidth: 35),
//                     suffixIcon: const Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         // IconButton(
//                         //   icon: Transform.rotate(
//                         //       angle: -1,
//                         //       child: Icon(
//                         //         Icons.attachment,
//                         //         color: AppColors.brownText,
//                         //       )),
//                         //   onPressed: () {
//                         //     controller.showImagePicker(context);
//                         //   },
//                         // ),
//                       ],
//                     ),
//                     // prefixIcon: InkWell(
//                     //   child: GetBuilder<ChatDetailController>(builder: (value) {
//                     //     return Container(
//                     //         margin: const EdgeInsets.only(left: 10, right: 20),
//                     //         alignment: Alignment.center,
//                     //         width: 30,
//                     //         child: Icon(
//                     //           !value.isShowEmojis
//                     //               ? Icons.emoji_emotions
//                     //               : Icons.keyboard,
//                     //           color: AppColors.brownText,
//                     //         ));
//                     //   }),
//                     //   onTap: () {
//                     //     controller.showEmoji();
//                     //     FocusScope.of(context).unfocus();
//                     //   },
//                     // ),
//                     contentPadding: const EdgeInsets.only(top: 7, left: 15),
//                     focusedBorder: AppViews.textFieldRoundBorder(),
//                     border: AppViews.textFieldRoundBorder(),
//                     disabledBorder: AppViews.textFieldRoundBorder(),
//                     focusedErrorBorder: AppViews.textFieldRoundBorder(),
//                     hintText: "Type your message...",
//                     hintStyle: regularText(color: Colors.grey),
//                     // filled: true,
//                   ),
//                 ),
//                 // color: Colors.red,
//               ),
//             ),
//             Container(
//               margin: const EdgeInsets.all(8),
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                   color: AppColors.primaryColor, shape: BoxShape.circle),
//               child: GetBuilder<ChatDetailController>(builder: (value) {
//                 return InkWell(
//                   onTap: () {
//                     controller.sendMessage();
//                   },
//                   child: SizedBox(
//                     width: ht(45),
//                     height: ht(45),
//                     child: FittedBox(
//                       fit: BoxFit.scaleDown,
//                       child: Icon(
//                         Icons.send,
//                         color: AppColors.bgGrey,
//                       ),
//                     ),
//                   ),
//                 );
//               }),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

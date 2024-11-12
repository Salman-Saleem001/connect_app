import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connect_app/controllers/chat/chat_detail_controller.dart';
import 'package:connect_app/globals/database.dart';
import 'package:connect_app/screens/main_screens/chat_view/chatScreen.dart';
import 'package:connect_app/utils/app_colors.dart';
import 'package:connect_app/utils/text_styles.dart';
import 'package:connect_app/widgets/appbars.dart';
import 'package:connect_app/widgets/text_fields.dart';

import '../../models/chat_model_data.dart';

// ignore: must_be_immutable
class FollowRequestsScreen extends StatelessWidget {
  TextEditingController notesController = TextEditingController();
  FocusNode notesNode = FocusNode();

  FollowRequestsScreen(
      {super.key, required this.thumbnail, required this.videoId});

  final String thumbnail;
  final int videoId;

  @override
  Widget build(BuildContext context) {
    var chatController = Get.put(ChatDetailController());
    return Scaffold(
      appBar: customAppBar(title: 'Follow Requests', marginTop: 25),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.file(
                  File(thumbnail),
                  fit: BoxFit.cover,
                  height: 160,
                  width: 120,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'The Round',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {
                            // Handle more options
                          },
                        ),
                      ],
                    ),
                    const Text(
                      'Roddy Roundicch',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    Text('1.7M videos',
                        style: regularText(color: AppColors.textLight)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          customTextFieldOptionalPreffix(notesController, notesNode, [],
              suffixIcon: Icon(
                Icons.search,
                color: AppColors.textLight,
              ),
              hint: 'Search'),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: Database().getRequestOnVideos(videoId: videoId),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Something went wrong',
                    style: normalText(color: AppColors.textLight),
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox();
              }
              return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: snapshot.data?.docs.length,
                padding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                itemBuilder: (BuildContext contextM, index) {
                  final chat = ChatDataModel.fromJson(snapshot.data!.docs[index]
                      .data() as Map<String, dynamic>);
                  return CommentItem(
                    avatarUrl: chat.userAvatar ?? '',
                    name: chat.userName ?? '',
                    location: '',
                    commentTime: getTime(chat.lastMessageTime ?? ''),
                    onTapYes: () {
                      chatController.updateStatus(
                          secondUserId: chat.senderId ?? '',
                          status: "Accepted",
                          videoId: videoId);
                    },
                    onTapNo: () {
                      chatController.updateStatus(
                          secondUserId: chat.senderId ?? '',
                          status: "Rejected",
                          videoId: videoId);
                    },
                    status: chat.myStatus == 'Accepted' ? true : false, onMessageTap: () {
                    List<String> tags=[];
                    chat.tags?.split("#").forEach((element){
                      if(element.isNotEmpty){
                        tags.add('#$element');
                      }
                    });
                    chatController.isDataFetched.value=true;
                    chatController.chatDataModel.value= chat;
                    debugPrint(chatController.chatDataModel.value?.toJson().toString());
                    Get.to(() => ChatDetailScreenNew (
                      userName: chat.userName??'',
                      tags: tags,
                      description: chat.description,
                      videoId: chat.videoId,
                      userAvatar: chat.userAvatar,
                    ),
                    );
                  },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class CommentItem extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final String location;
  final String commentTime;
  final VoidCallback onTapYes;
  final VoidCallback onTapNo;
  final bool status;
  final VoidCallback onMessageTap;

  const CommentItem({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.location,
    required this.commentTime,
    required this.onTapYes,
    required this.onTapNo,
    required this.status, required this.onMessageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.transparent, // Make the container transparent
        border: Border.all(
            color: Colors
                .grey.shade300), // Add a border with a color of your choice
        borderRadius:
            BorderRadius.circular(10), // Optional: Add rounded corners
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 10, right: 5, left: 10, bottom: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserAvatarImage(userAvatar: avatarUrl),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            location,
                            style: normalText(
                                size: 14, color: AppColors.textLight),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'commented $commentTime',
                        style: normalText(size: 12, color: AppColors.textLight),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: status
                  ? GestureDetector(
              onTap: onMessageTap,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: AppColors.greenColor, borderRadius: BorderRadius.circular(10)),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Message',style: TextStyle(color: Colors.white),),
                      ),
                    ),
                  )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: onTapYes,
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppColors.greenColor, // Background color
                              shape: BoxShape.circle, // Circular shape
                            ),
                            child: const Icon(
                              Icons.check_outlined,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: onTapNo,
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Colors.red, // Background color
                              shape: BoxShape.circle, // Circular shape
                            ),
                            child: const Icon(
                              Icons.not_interested,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connect_app/controllers/chat/chat_detail_controller.dart';
import 'package:connect_app/globals/database.dart';
import 'package:connect_app/globals/enum.dart';
import 'package:connect_app/globals/global.dart';
import 'package:connect_app/screens/other_screens/addRating_screen.dart';
import 'package:connect_app/screens/other_screens/add_post_screens/camera_screens.dart';
import 'package:connect_app/screens/other_screens/add_post_screens/video_view.dart';
import 'package:connect_app/utils/app_colors.dart';
import 'package:connect_app/utils/text_styles.dart';
import 'package:connect_app/widgets/appbars.dart';
import 'package:connect_app/widgets/text_fields.dart';

import '../../../controllers/mainScreen_controllers/home_page_cont.dart';
import '../../../models/chat_model_data.dart';
import '../../../utils/login_details.dart';

class ChatDetailScreenNew extends StatelessWidget {
  const ChatDetailScreenNew({
    super.key,
    this.secondUserId,
    this.userName,
    this.tags,
    this.description,
    this.videoId,
    this.userAvatar,
  });

  final String? secondUserId;
  final int? videoId;
  final String? userName;
  final String? description;
  final String? userAvatar;
  final List<String>? tags;

  @override
  Widget build(BuildContext context) {
    var homeFeedController = Get.put(HomeFeedController());
    var chatController = Get.put(ChatDetailController());
    if (chatController.chatDataModel.value == null) {
      // debugPrint("Here");
      chatController.getSingleChatDetail(
          secondUserId: secondUserId ?? '', videoId: videoId ?? 0);
    }

    return PopScope(
      onPopInvokedWithResult: (val, result) {
        chatController.chatDataModel.value = null;
        chatController.deleteSingleFile();
      },
      child: Scaffold(
        appBar: customAppBar(backButton: true, marginTop: 25, actions: [
          GestureDetector(
            onTap: () {
              Get.to(RatingScreen(
                userAvatar: userAvatar,
                videoId: videoId,
              ))?.whenComplete(() {
                homeFeedController.rating = null;
                homeFeedController.reviewDescrioption = null;
              });
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.borderColor,
                  width: 1.0,
                ),
              ),
              child: Center(child: Image.asset('assets/images/ic_support.png')),
            ),
          )
        ]),
        body: Column(
          children: [
            Expanded(
              child: GetBuilder(builder: (ChatDetailController chatController) {
                if (chatController.isDataFetched.value) {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              UserAvatarImage(
                                userAvatar: userAvatar,
                                radius: 35,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '@${userName ?? ''}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text('Last seen 5 mins ago',
                                      style: normalText(
                                          size: 14, color: Colors.grey)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 16, left: 16),
                          child: Divider(
                            color: AppColors.borderColor,
                            thickness: 0.5,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColorBottom,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                description ??
                                    'Anyone heading to Phoenix Game Tonight?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: tags?.map((val) {
                                      return hashtagChip(val);
                                    }).toList() ??
                                    [],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              Obx(() {
                                if (chatController.chatDataModel.value ==
                                    null) {
                                  return Row(
                                    children: [
                                      UserAvatarImage(userAvatar: userAvatar),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () async {
                                            String chatRoomId;
                                            if (int.parse(secondUserId ?? '0') >
                                                (Get.find<UserDetail>()
                                                        .userData
                                                        .user
                                                        ?.id ??
                                                    0)) {
                                              chatRoomId =
                                                  '${int.parse(secondUserId ?? '0')}${Get.find<UserDetail>().userData.user?.id ?? 0}$videoId';
                                            } else {
                                              chatRoomId =
                                                  '${Get.find<UserDetail>().userData.user?.id ?? 0}${int.parse(secondUserId ?? '0')}$videoId';
                                            }
                                            await Get.to(CameraScreen(
                                              cameras:
                                                  homeFeedController.cameras,
                                              fromMessage: true,
                                              onSend: () async {
                                                String? tag;
                                                tags?.forEach((element) {
                                                  tag = (tag ?? '') + element;
                                                });
                                                await chatController
                                                    .createChatRoom(
                                                        secondUser:
                                                            secondUserId ?? '',
                                                        chatRoomId: chatRoomId,
                                                        userName:
                                                            userName ?? '',
                                                        tags: tag ?? '',
                                                        description:
                                                            description ?? '',
                                                        videoId: videoId ?? 0,
                                                        avatar:
                                                            userAvatar ?? '')
                                                    .whenComplete(() {
                                                  chatController
                                                      .getSingleChatDetail(
                                                          secondUserId:
                                                              secondUserId ??
                                                                  '',
                                                          videoId:
                                                              videoId ?? 0);
                                                });
                                              },
                                            ));
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    'Record Video Reply to connect with ${userName ?? ''}',
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey,
                                                    // Set the background color to grey
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            1000), // Circular shape
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  // Optional: Add padding if needed
                                                  child: const Icon(
                                                    Icons.videocam,
                                                    color: Colors
                                                        .white, // Set the icon color to white
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  bool check = chatController
                                          .chatDataModel.value?.senderId ==
                                      (Get.find<UserDetail>()
                                                  .userData
                                                  .user
                                                  ?.id ??
                                              0)
                                          .toString();
                                  return Align(
                                    alignment: check
                                        ? Alignment.topLeft
                                        : Alignment.bottomRight,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (check) ...[
                                              UserAvatarImage(
                                                  userAvatar:
                                                      Get.find<UserDetail>()
                                                          .userData
                                                          .user
                                                          ?.avatar),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                            ],
                                            Builder(builder: (_) {
                                              if (chatController.thumbnail !=
                                                  null) {
                                                return GestureDetector(
                                                  behavior:
                                                      HitTestBehavior.opaque,
                                                  onTap: () {
                                                    Get.to(
                                                      VideoView(
                                                        url: chatController
                                                                .chatDataModel
                                                                .value
                                                                ?.messageData ??
                                                            '',

                                                      ),
                                                    );
                                                  },
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: Stack(
                                                      alignment:
                                                          Alignment.center,
                                                      children: [
                                                        Image.file(
                                                          File(chatController
                                                                  .thumbnail ??
                                                              ''),
                                                          height: 100,
                                                          width: 90,
                                                          fit: BoxFit.cover,
                                                        ),
                                                        const Icon(
                                                          Icons.play_arrow,
                                                          color: Colors.white,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }
                                              chatController.generateThumbnail(
                                                  chatController.chatDataModel
                                                          .value?.messageData ??
                                                      '');
                                              return CircularProgressIndicator(
                                                color: AppColors.primaryColor,
                                              );
                                            }),
                                            if (!check) ...[
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              UserAvatarImage(
                                                  userAvatar: userAvatar),
                                            ]
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          getTime(chatController.chatDataModel
                                                  .value?.lastMessageTime ??
                                              ''),
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        if (!check &&
                                            chatController.chatDataModel.value
                                                    ?.myStatus ==
                                                'Pending')
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              GestureDetector(
                                                behavior:
                                                    HitTestBehavior.opaque,
                                                onTap: () {
                                                  debugPrint('Hello');
                                                  chatController.updateStatus(
                                                      secondUserId:
                                                          chatController
                                                                  .chatDataModel
                                                                  .value
                                                                  ?.senderId ??
                                                              '',
                                                      status: "Accepted",
                                                      videoId: videoId ?? 0);
                                                },
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: ColoredBox(
                                                    color:
                                                        AppColors.primaryColor,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        'Accept Connection',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                AppColors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              GestureDetector(
                                                behavior:
                                                    HitTestBehavior.opaque,
                                                onTap: () {
                                                  chatController.updateStatus(
                                                      secondUserId:
                                                          secondUserId ?? '',
                                                      status: "Rejected",
                                                      videoId: videoId ?? 0);
                                                },
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: ColoredBox(
                                                    color: AppColors.bgGrey
                                                        .withOpacity(.3),
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text(
                                                        'Decline',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            // color: AppColors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                      ],
                                    ),
                                  );
                                }
                              }),
                            ],
                          ),
                        ),
                        chatController.chatDataModel.value?.chatsId != null
                            ? StreamBuilder(
                                stream: chatController.getMessages(
                                    chatRoomId: chatController
                                            .chatDataModel.value?.chatsId ??
                                        ""),
                                builder: (_,
                                    AsyncSnapshot<QuerySnapshot<Object?>>
                                        snapshot) {
                                  if (snapshot.hasData) {
                                    return Column(
                                      children: snapshot.data!.docs.reversed
                                          .map((element) {
                                        final chat = ChatDataModel.fromJson(
                                            element.data()
                                                as Map<String, dynamic>);
                                        bool check = chat.senderId ==
                                            (Get.find<UserDetail>()
                                                        .userData
                                                        .user
                                                        ?.id ??
                                                    0)
                                                .toString();
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Align(
                                            alignment: check
                                                ? Alignment.topLeft
                                                : Alignment.bottomRight,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    if (check) ...[
                                                      UserAvatarImage(
                                                          userAvatar: Get.find<
                                                                  UserDetail>()
                                                              .userData
                                                              .user
                                                              ?.avatar),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                    ],
                                                    if (chat.lastMessageType ==
                                                        'video') ...[
                                                      GestureDetector(
                                                        behavior:
                                                            HitTestBehavior
                                                                .opaque,
                                                        onTap: () {
                                                          Get.to(VideoView(
                                                            url:
                                                                chat.messageData ??
                                                                    '',
                                                          ));
                                                        },
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child:
                                                              const ColoredBox(
                                                            color: Colors.black,
                                                            child: SizedBox(
                                                              height: 100,
                                                              width: 90,
                                                              child: Icon(
                                                                Icons
                                                                    .play_arrow,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ] else
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                        child: ColoredBox(
                                                          color: check
                                                              ? AppColors.bgGrey
                                                                  .withOpacity(
                                                                      .2)
                                                              : AppColors
                                                                  .primaryColorBottom,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10.0),
                                                            child: Text(
                                                              chat.messageData ??
                                                                  "",
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  color: check
                                                                      ? Colors
                                                                          .black
                                                                      : AppColors
                                                                          .white),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    if (!check) ...[
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      UserAvatarImage(
                                                          userAvatar:
                                                              userAvatar),
                                                    ]
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  getTime(
                                                      chat.lastMessageTime ??
                                                          ''),
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    );
                                    // final chat = ChatDataModel.fromJson(snapshot.data!.docs[index].data() as Map<String, dynamic>);
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                })
                            : const SizedBox.shrink(),
                      ],
                    ),
                  );
                } else {
                  return const SizedBox();
                }
              }),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10, bottom: 10, top: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: Colors.grey),
                    onPressed: () {},
                  ),
                  Expanded(
                      child: customTextFieldOptionalPreffix(
                          borderRadius: 1000,
                          hint: 'Type as message...',
                          chatController.controllerMessage,
                          FocusNode(),
                          [])),
                  const SizedBox(width: 10),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.primaryColorBottom.withOpacity(0.4),
                          width: 5), // 5p
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(200),
                        child: ColoredBox(
                          color: AppColors.primaryColorBottom,
                          child: GetBuilder(
                              builder: (ChatDetailController controller) {
                            return GestureDetector(
                              onTap: () async {
                                if (controller.chatDataModel.value == null) {
                                  String chatRoomId;
                                  if (int.parse(secondUserId ?? '0') >
                                      (Get.find<UserDetail>()
                                              .userData
                                              .user
                                              ?.id ??
                                          0)) {
                                    chatRoomId =
                                        '${int.parse(secondUserId ?? '0')}${Get.find<UserDetail>().userData.user?.id ?? 0}';
                                  }
                                  chatRoomId =
                                      '${Get.find<UserDetail>().userData.user?.id ?? 0}${int.parse(secondUserId ?? '0')}';
                                  Get.to(CameraScreen(
                                    cameras: homeFeedController.cameras,
                                    fromMessage: true,
                                    onSend: () async {
                                      String? tag;
                                      tags?.forEach((element) {
                                        tag = (tag ?? '') + element;
                                      });
                                      await chatController
                                          .createChatRoom(
                                              secondUser: secondUserId ?? '',
                                              chatRoomId: chatRoomId,
                                              userName: userName ?? '',
                                              tags: tag ?? '',
                                              description: description ?? '',
                                              videoId: videoId ?? 0,
                                              avatar: userAvatar ?? '')
                                          .whenComplete(() {
                                        chatController.getSingleChatDetail(
                                            secondUserId: secondUserId ?? '',
                                            videoId: videoId ?? 0);
                                      });
                                    },
                                  ));
                                } else if (controller
                                        .chatDataModel.value?.otherStatus ==
                                    'Accepted') {
                                  chatController.sendMessage(
                                    chatRoomId: chatController
                                            .chatDataModel.value?.chatsId ??
                                        '',
                                  );
                                  chatController.updateLastMessage(
                                      secondUser: (controller.chatDataModel
                                                      .value?.senderId ??
                                                  '') ==
                                              Database.userId
                                          ? (controller.chatDataModel.value
                                                  ?.receiverId ??
                                              '')
                                          : (controller.chatDataModel.value
                                                  ?.senderId ??
                                              ''),
                                      videId: videoId ?? 0);
                                } else if (controller
                                        .chatDataModel.value?.otherStatus ==
                                    'Rejected') {
                                  Global.showToastAlert(
                                      context: context,
                                      strMsg: 'Chat request rejected',
                                      toastType: TOAST_TYPE.toastWarning);
                                } else {
                                  Global.showToastAlert(
                                      context: context,
                                      strMsg:
                                          'The Person has not accepted your request',
                                      toastType: TOAST_TYPE.toastWarning);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                    controller.chatDataModel.value == null
                                        ? Icons.videocam
                                        : Icons.send,
                                    color: Colors.white),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget hashtagChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}

class UserAvatarImage extends StatelessWidget {
  const UserAvatarImage({
    super.key,
    required this.userAvatar,
    this.radius,
  });

  final String? userAvatar;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    bool isAbsolute = Uri.parse(userAvatar ?? '').isAbsolute;
    return CircleAvatar(
      radius: radius ?? 20,
      backgroundImage: isAbsolute
          ? NetworkImage(
              userAvatar ??
                  'https://wallpapers.com/images/hd/mr-bean-cartoon-riding-car-cxwhk07yek890rh1.jpg',
            )
          : null,
      foregroundImage: !isAbsolute
          ? const NetworkImage(
              'https://cdn-icons-png.flaticon.com/512/61/61205.png',
            )
          : null,
      backgroundColor: AppColors.white,
    );
  }
}

getTime(dynamic val) {
  int timeDifferenceMicroseconds = 0;
  try {
    timeDifferenceMicroseconds = DateTime.now().microsecondsSinceEpoch -
        DateTime.parse(val).microsecondsSinceEpoch;
  } catch (e) {
    timeDifferenceMicroseconds =
        (DateTime.now().microsecondsSinceEpoch - val.microsecondsSinceEpoch)
            .toInt();
  }
  Duration timeDifference = Duration(microseconds: timeDifferenceMicroseconds);

  String formattedTimeDifference;
  if (timeDifference.inDays > 0) {
    formattedTimeDifference = '${timeDifference.inDays} days ago';
  } else if (timeDifference.inHours > 0) {
    formattedTimeDifference = '${timeDifference.inHours} hours ago';
  } else if (timeDifference.inMinutes > 0) {
    formattedTimeDifference = '${timeDifference.inMinutes} minutes ago';
  } else {
    if (timeDifference.inSeconds < 60) {
      formattedTimeDifference = 'just Now';
    } else {
      formattedTimeDifference = '${timeDifference.inSeconds} seconds ago';
    }
  }
  return formattedTimeDifference;
}

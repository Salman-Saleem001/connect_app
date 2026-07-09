import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_app/controllers/chat/chat_detail_controller.dart';
import 'package:connect_app/controllers/mainScreen_controllers/home_page_cont.dart';
import 'package:connect_app/controllers/mainScreen_controllers/stories_controller.dart';
import 'package:connect_app/globals/database.dart';
import 'package:connect_app/globals/enum.dart';
import 'package:connect_app/globals/network_image.dart';
import 'package:connect_app/models/chat_model_data.dart';
import 'package:connect_app/models/stories_model.dart';
import 'package:connect_app/screens/main_screens/chat_view/chat_screen.dart';
import 'package:connect_app/screens/main_screens/chat_view/status_view.dart';
import 'package:connect_app/utils/app_colors.dart';
import 'package:connect_app/utils/text_styles.dart';
import 'package:connect_app/widgets/appbars.dart';
import 'package:connect_app/widgets/text_fields.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/login_details.dart';
import '../../other_screens/add_post_screens/camera_screens.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  late TextEditingController search;
  late Database database;

  @override
  void initState() {
    // TODO: implement initState
    search = TextEditingController();
    database = Database();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: AppColors.scaffoldBackgroundColor,
        appBar: customAppBar(title: 'Chats', backButton: false),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              10.hp,
              customTextFieldOptionalPrefix(search, FocusNode(), [],
                  suffixIcon: Icon(
                    Icons.search,
                    color: AppColors.textLight,
                  ),
                  hint: 'Search Chats', onchange: (a) {
                setState(() {});
              }),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  height: MediaQuery.sizeOf(context).height * .08,
                  child: GetBuilder<StoriesController>(
                    init: StoriesController(),
                    builder: (StoriesController controller) {
                      if (controller.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      int length = (controller.stories.feed?.length ?? 0) + 1;
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (_, index) {
                          if (index == 0) {
                            return Stack(
                              fit: StackFit.loose,
                              alignment: Alignment.bottomRight,
                              children: [
                                GradientBorderWidget(
                                  showBorder:
                                      controller.stories.myStories?.any((element) => element.isViewed == false) ??
                                          false,
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.to(() => StatusView(statuses: controller.stories.myStories ?? []));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(100),
                                        child: NetworkImageCustom(
                                          width: 65,
                                          height: 70,
                                          image: Get.find<UserDetail>().userData.user?.avatar ?? "",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Get.to(CameraScreen(
                                      cameras: Get.put(HomeFeedController()).cameras,
                                      fromMessage: true,
                                      fromStory: true,
                                      onSend: (String val) async {
                                        controller.createStories(selectedFile: File(val), caption: '').then((val) {
                                          Get.until((route) => route.isFirst);
                                          controller.getStories();
                                        });
                                      },
                                    ));
                                  },
                                  child: DecoratedBox(
                                    decoration: ShapeDecoration(
                                      shape: const CircleBorder(),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [AppColors.txtGrey, AppColors.primaryColor],
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color: AppColors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: GestureDetector(
                              onTap: () {
                                Get.to(
                                  () => StatusView(
                                    statuses: [controller.stories.myStories?[index - 1] ?? MyStories.fromJson({})],
                                  ),
                                );
                              },
                              child: GradientBorderWidget(
                                showBorder: controller.stories.feed?[index - 1].isViewed == false,
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: NetworkImageCustom(
                                      width: 60,
                                      height: 50,
                                      image: controller.stories.myStories?[index - 1].user?.avatar ?? "",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: length,
                      );
                    },
                  ),
                ),
              ),
              categories(),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: database.getChats(selected: selectedCat),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                      if (snapshot.data?.docs.isEmpty == true) {
                        return Center(
                          child: Text(
                            'No chats',
                            style: subHeadingText(color: AppColors.textLight),
                          ),
                        );
                      }
                      return chats(snapshot);
                    }),
              )
            ],
          ),
        ));
  }

  ListView chats(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    return ListView.builder(
      // physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: snapshot.data?.docs.length,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      itemBuilder: (BuildContext contextM, index) {
        final chat = ChatDataModel.fromJson(snapshot.data!.docs[index].data() as Map<String, dynamic>);
        return ChatListItem(
          chatDataModel: chat,
        );
      },
    );
  }

  int selectedCat = 0;
  SizedBox categories() {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        separatorBuilder: (ctx, i) => const SizedBox(
          width: 15,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: status.length,
        itemBuilder: (ctx, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCat = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: index == selectedCat
                        ? Colors.red // Replace with AppColors.primaryColorBottom if defined
                        : Colors.transparent,
                    width: 2.0,
                  ),
                ),
              ),
              child: Text(
                status[index],
                style: TextStyle(
                  color: index == selectedCat
                      ? Colors.red // Replace with AppColors.primaryColorBottom if defined
                      : Colors.grey, // Replace with AppColors.textPrimary if defined
                  fontSize: 12, // Adjust the font size as needed
                  fontWeight: index == selectedCat ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<String> status = ['My Replies', 'My videos'];

  @override
  void dispose() {
    // TODO: implement dispose
    search.dispose();
    super.dispose();
  }
}

class GradientBorderWidget extends StatelessWidget {
  const GradientBorderWidget({
    super.key,
    required this.child,
    this.showBorder = true,
  });

  final bool showBorder;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: CircleBorder(),
        gradient: showBorder
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.white,
                  AppColors.primaryColor,
                ],
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: DecoratedBox(
          decoration: ShapeDecoration(shape: const CircleBorder(), color: AppColors.white),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: child,
          ),
        ),
      ),
    );
  }
}

class ChatListItem extends StatelessWidget {
  const ChatListItem({
    super.key,
    required this.chatDataModel,
  });

  final ChatDataModel chatDataModel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white10))),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(
                right: 10,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: NetworkImageCustom(
                  image: chatDataModel.userAvatar,
                  fit: BoxFit.cover,
                  height: 60,
                  width: 60,
                ),
              ),
            ),
            const SizedBox(width: 10), // Replaces 10.wp for consistent spacing
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    chatDataModel.description ?? '',
                    style: subHeadingText(size: 16, color: AppColors.textPrimary),
                  ),
                  Text(
                    chatDataModel.tags ?? '',
                    style: normalText(color: AppColors.primaryColor),
                  ),
                  Text(
                    getTime(chatDataModel.lastMessageTime),
                    style: normalText(color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        List<String> tags = [];
        chatDataModel.tags?.split("#").forEach((element) {
          if (element.isNotEmpty) {
            tags.add('#$element');
          }
        });

        var chatController = Get.put(ChatDetailController());
        chatController.isDataFetched.value = true;
        chatController.chatDataModel.value = chatDataModel;
        debugPrint(chatController.chatDataModel.value?.toJson().toString());
        Get.to(
          () => ChatDetailScreenNew(
            userName: chatDataModel.userName ?? '',
            tags: tags,
            description: chatDataModel.description,
            videoId: chatDataModel.videoId,
            userAvatar: chatDataModel.userAvatar,
          ),
        );
      },
    );
  }
}

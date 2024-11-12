
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_app/globals/database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connect_app/controllers/chat/chat_detail_controller.dart';

import 'package:connect_app/globals/enum.dart';
import 'package:connect_app/globals/network_image.dart';
import 'package:connect_app/models/chat_model_data.dart';
import 'package:connect_app/screens/main_screens/chat_view/chatScreen.dart';
import 'package:connect_app/utils/app_colors.dart';
import 'package:connect_app/utils/text_styles.dart';
import 'package:connect_app/widgets/appbars.dart';
import 'package:connect_app/widgets/text_fields.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  TextEditingController search = TextEditingController();
  Database  database=Database();




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: AppColors.scaffoldBackgroundColor,
        appBar: customAppBar(title: 'Chats', backButton: false),
        body: chatList());
  }

  Padding chatList() {


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          10.hp,
          customTextFieldOptionalPreffix(search, FocusNode(), [],
              suffixIcon: Icon(
                Icons.search,
                color: AppColors.textLight,
              ),
              hint: 'Search Chats', onchange: (a) {
            setState(() {});
          }),
          categories(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: database.getChats(selected: selectedCat),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
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
                  if (snapshot.data?.docs.isEmpty==true) {
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
    );
  }

  ListView chats(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: snapshot.data?.docs.length,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      itemBuilder: (BuildContext contextM, index) {
        final chat = ChatDataModel.fromJson(snapshot.data!.docs[index].data() as Map<String, dynamic>);
        return ChatListItem(chatDataModel: chat,

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
                        ? Colors
                            .red // Replace with AppColors.primaryColorBottom if defined
                        : Colors.transparent,
                    width: 2.0,
                  ),
                ),
              ),
              child: Text(
                status[index],
                style: TextStyle(
                  color: index == selectedCat
                      ? Colors
                          .red // Replace with AppColors.primaryColorBottom if defined
                      : Colors
                          .grey, // Replace with AppColors.textPrimary if defined
                  fontSize: 12, // Adjust the font size as needed
                  fontWeight: index == selectedCat
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }



  List<String> status = ['My Replies', 'My videos'];
}

class ChatListItem extends StatelessWidget {
  const ChatListItem({
    super.key, required this.chatDataModel,

  });

  final ChatDataModel chatDataModel;


  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white10))),
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
                    chatDataModel.description??'',
                    style: subHeadingText(
                        size: 16, color: AppColors.textPrimary),
                  ),
                  Text(
                      chatDataModel.tags??'',
                      style: normalText(color: AppColors.primaryColor),
                    ),
                  Text(
                      getTime(chatDataModel.lastMessageTime??''),
                      style: normalText(color: Colors.black87),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: () {

        List<String> tags=[];
        chatDataModel.tags?.split("#").forEach((element){
          if(element.isNotEmpty){
            tags.add('#$element');
          }
        });

        var chatController= Get.put(ChatDetailController());
        chatController.isDataFetched.value=true;
        chatController.chatDataModel.value= chatDataModel;
        debugPrint(chatController.chatDataModel.value?.toJson().toString());
        Get.to(() => ChatDetailScreenNew (
          userName: chatDataModel.userName??'',
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

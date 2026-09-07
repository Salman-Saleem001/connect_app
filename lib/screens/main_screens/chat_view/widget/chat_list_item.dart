import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connect_app/screens/main_screens/chat_view/widget/voice_bubble.dart';
import 'package:flutter/material.dart';

import '../../../../controllers/chat/audio_player_controller.dart';
import '../../../../globals/enum.dart';
import '../../../../models/chat_model.dart';
import '../../../../models/local_chat_model.dart';
import '../../../../utils/app_colors.dart';
import 'document_message_bubble.dart';
import 'image_view.dart';
import 'images_list.dart';
import 'location_model_bubble.dart';

class ChatListItemNew extends StatelessWidget {
  final LocalChatModel mChatModel;
  final Function onTap;
  final AudioPlayerController? audioPlayerController;

  const ChatListItemNew({
    super.key,
    required this.mChatModel,
    required this.onTap,
    this.audioPlayerController,
  });

  @override
  Widget build(BuildContext context) {
    // Check if this is a voice message
    if (mChatModel.messageType == MessageType.voice && mChatModel.voiceData != null && audioPlayerController != null) {
      return VoiceMessageBubble(
        voiceData: mChatModel.voiceData!,
        msgType: mChatModel.mMsgType,
        time: mChatModel.time,
        playerController: audioPlayerController!,
      );
    }

    // Check if this is a video message
    if (mChatModel.messageType == MessageType.video && mChatModel.voiceData != null) {
      // return VideoMessageBubble(
      //   videoData: mChatModel.voiceData!,
      //   msgType: mChatModel.mMsgType,
      //   time: mChatModel.time,
      // );
    }

    // Check if this is a document message
    if (mChatModel.messageType == MessageType.document && mChatModel.voiceData != null) {
      return DocumentMessageBubble(
        documentData: mChatModel.voiceData!,
        msgType: mChatModel.mMsgType,
        time: mChatModel.time,
      );
    }

    // Check if this is a location message
    if (mChatModel.messageType == MessageType.location && mChatModel.voiceData != null) {
      return LocationMessageBubble(
        locationData: mChatModel.voiceData!,
        msgType: mChatModel.mMsgType,
        time: mChatModel.time,
      );
    }
    if (mChatModel.messageType == MessageType.image && mChatModel.files.isNotEmpty) {
      return Visibility(
        visible: mChatModel.files.isNotEmpty ? true : false,
        child: mChatModel.files.length == 1
            ? InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => ImageView(mChatModel.files.first)));
            },
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 250,
                maxHeight: 250,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: mChatModel.files.first,
                  fit: BoxFit.cover,
                  width: 250,
                  height: 250,
                  progressIndicatorBuilder: (context, url, downloadProgress) => Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: downloadProgress.progress,
                        color: Colors.grey,
                        backgroundColor: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.error,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ))
            : InkWell(
          onTap: () {
            mChatModel.files.length >= 2
                ? Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ImagesList(
                  images: mChatModel.files,
                )))
                : () {};
          },
          child: IgnorePointer(
            child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 10),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: mChatModel.files.length > 4 ? 4 : mChatModel.files.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150, childAspectRatio: 3 / 3, crossAxisSpacing: 5, mainAxisSpacing: 5),
                itemBuilder: (ctx, index) {
                  return index == 3
                      ? Blur(
                      blur: 0,
                      blurColor: Colors.black87,
                      overlay: Center(
                          child: Text(
                            "+${mChatModel.files.length - 3}",
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          )),
                      child: CachedNetworkImage(
                        imageUrl: mChatModel.files[index],
                        fit: BoxFit.cover,
                        progressIndicatorBuilder: (context, url, downloadProgress) => Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              value: downloadProgress.progress,
                              color: Colors.grey,
                              backgroundColor: AppColors.primaryColor,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.error,
                            size: 18,
                          ),
                        ),
                      ))
                      : CachedNetworkImage(
                    imageUrl: mChatModel.files[index],
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (context, url, downloadProgress) => Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.grey,
                          value: downloadProgress.progress,
                          backgroundColor: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.error,
                        size: 18,
                      ),
                    ),
                  );
                }),
          ),
        ),
      );
    }

    // Otherwise render normal text/image message
    final isSender = mChatModel.mMsgType == MsgType.right;
    return Flexible(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: ColoredBox(
          color: isSender ? AppColors.primaryColorBottom : AppColors.bgGrey.withValues(alpha: .2),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
            child: Text(
              mChatModel.message,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w400, color: isSender ? AppColors.white : Colors.black),
              maxLines: 100,
            ),
          ),
        ),
      ),
    );
  }

}

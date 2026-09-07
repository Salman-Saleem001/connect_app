
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_app/screens/main_screens/chat_view/widget/voice_player_widget.dart';
import 'package:flutter/material.dart';

import '../../../../controllers/chat/audio_player_controller.dart';
import '../../../../globals/enum.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/audio_utils.dart';
import '../chat_screen.dart';

class VoiceMessageBubble extends StatelessWidget {
  final Map<String, dynamic> voiceData;
  final MsgType msgType;
  final Timestamp time;
  final AudioPlayerController playerController;

  const VoiceMessageBubble({
    super.key,
    required this.voiceData,
    required this.msgType,
    required this.time,
    required this.playerController,
  });

  @override
  Widget build(BuildContext context) {
    final isSender = msgType == MsgType.right;
    final audioUrl = voiceData['url'] as String? ?? '';
    final duration = voiceData['duration'] as int? ?? 0;
    final fileSize = voiceData['fileSize'] as int? ?? 0;

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSender
              ? AppColors.primaryColor.withValues(alpha:0.9)
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isSender ? 20 : 0),
            bottomRight: Radius.circular(isSender ? 0 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: isSender
                  ? AppColors.primaryColor.withValues(alpha:0.25)
                  : Colors.black.withValues(alpha:0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Voice player
            VoicePlayerWidget(
              audioUrl: audioUrl,
              durationInSeconds: duration,
              isSender: isSender,
              playerController: playerController,
            ),
            const SizedBox(height: 4),
            // File size and time
            Text(
              AudioUtils.formatFileSize(fileSize),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSender ? Colors.white.withValues(alpha:0.85) : AppColors.txtGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }


}
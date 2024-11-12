import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../globals/enum.dart';

class LocalChatModel {
  String message;
  Timestamp time;
  List files;
  MsgType mMsgType;

  LocalChatModel({
    Key? key,
    required this.time,
    required this.message,
    required this.files,
    required this.mMsgType,
  });
}

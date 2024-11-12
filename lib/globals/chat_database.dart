// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../models/chat_model.dart';
import '../models/user.dart';
import '../utils/login_details.dart';

class FireDatabase {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<String> createChatRoom(UserModel otheruser) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .where('check',
              arrayContains: '${otheruser.user!.id}${Get.find<UserDetail>().userData.user!.id.toString()}')
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs[0].id;
      }
      DocumentReference df = await _firestore.collection('chats').add({
        'users': [Get.find<UserDetail>().userData.user!.id.toString(), otheruser.user!.id],
        'lastMessage': "",
        'createdBy': Get.find<UserDetail>().userData.user!.id.toString(),
        'status': 'pending',
        'lastMessageBy': Get.find<UserDetail>().userData.user!.id.toString(),
        'unreadCount': 0,
        'user1': {
          'id': Get.find<UserDetail>().userData.user!.id.toString(),
          'name':
              Get.find<UserDetail>().userData.user!.id.toString() + " " + Get.find<UserDetail>().userData.user!.id.toString(),
        },
        'user2': {
          'id': otheruser.user!.id,
          'name': otheruser.user!.firstName! + " " + otheruser.user!.lastName!,
        },
        'check': [
          '${otheruser.user!.id}${Get.find<UserDetail>().userData.user!.id.toString()}',
          '${Get.find<UserDetail>().userData.user!.id.toString()}${otheruser.user!.id}'
        ],
        'timestamp': Timestamp.now()
      });
      return df.id;
    } catch (e) {
      debugPrint(e.toString());
      return 'null';
    }
  }

  static Future<bool> addMessage(String docId, ChatModel chat) async {
    try {
      log(chat.to.toString());
      await _firestore
          .collection('chats')
          .doc(docId)
          .collection('messages')
          .add({
        "from": Get.find<UserDetail>().userData.user!.id.toString(),
        "to": chat.to,
        "message": chat.files.isNotEmpty && chat.message.isEmpty
            ? "Attachment"
            : chat.message,
        "files": chat.files,
        "timestamp": chat.timeStamp,
      });
      await _firestore.collection('chats').doc(docId).update({
        'lastMessageBy': Get.find<UserDetail>().userData.user!.id.toString(),
        'unreadCount': FieldValue.increment(1),
        'lastMessage': chat.message,
        'timestamp': Timestamp.now(),
      });

      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static changeUserAvailability(bool val) async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(Get.find<UserDetail>().userData.user!.id.toString().toString())
        .update({'online': val});
  }
}

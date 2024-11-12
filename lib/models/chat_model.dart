// To parse this JSON data, do
//
//     final exploreUserModel = exploreUserModelFromMap(jsonString);

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  ChatModel({
    required this.from,
    required this.to,
    required this.message,
    required this.files,
    required this.timeStamp,
  });

  String from;
  String to;
  String message;
  List files;
  Timestamp timeStamp;

  factory ChatModel.fromMap(DocumentSnapshot json) => ChatModel(
        from: json["from"],
        to: json["to"],
        files: json["files"],
        message: json["message"],
        timeStamp: json["timestamp"],
      );
}

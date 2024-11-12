// To parse this JSON data, do
//
//     final chatModel = chatModelFromJson(jsonString);

import 'dart:convert';

ChatDataModel chatModelFromJson(String str) => ChatDataModel.fromJson(json.decode(str));

String chatModelToJson(ChatDataModel data) => json.encode(data.toJson());

class ChatDataModel {
  int? videoId;
  String? myStatus;
  String? otherStatus;
  String? chatsId;
  String? description;
  String? lastMessageTime;
  String? lastMessageType;
  String? messageData;
  String? receiverId;
  String? senderId;
  String? tags;
  String? userName;
  String? userAvatar;

  ChatDataModel({
    this.videoId,
    this.myStatus,
    this.otherStatus,
    this.chatsId,
    this.lastMessageTime,
    this.lastMessageType,
    this.messageData,
    this.receiverId,
    this.senderId,
    this.tags,
    this.userName,
    this.description,
    this.userAvatar
  });

  factory ChatDataModel.fromJson(Map<String, dynamic> json) => ChatDataModel(
    videoId: json['videoId'],
    myStatus: json["myStatus"],
    otherStatus: json["otherStatus"],
    chatsId: json["chatsId"],
    lastMessageTime: json["lastMessageTime"],
    lastMessageType: json["lastMessageType"],
    messageData: json["messageData"],
    receiverId: json["receiverId"],
    senderId: json["senderId"],
    tags: json["tags"],
    description: json["description"],
    userName: json["userName"],
    userAvatar: json["avatar"]
  );

  Map<String, dynamic> toJson() => {
    "videoId": videoId,
    "myStatus": myStatus,
    "otherStatus": otherStatus,
    "chatsId": chatsId,
    "lastMessageTime": lastMessageTime,
    "lastMessageType": lastMessageType,
    "messageData": messageData,
    "receiverId": receiverId,
    "senderId": senderId,
    "tags": tags,
    "userName": userName,
    "description": description,
    "avatar": userAvatar
  };
}

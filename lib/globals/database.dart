import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../models/chat_model_data.dart';
import '../models/doc_model.dart';
import '../models/group_chat_model.dart';
import '../models/item_model.dart';
import '../models/order_model.dart';
import '../models/request_model.dart';
import '../utils/login_details.dart';



class Database {
  static FirebaseFirestore instance = FirebaseFirestore.instance;
  static FirebaseStorage storageInstance = FirebaseStorage.instance;
  static String userId =  (Get.find<UserDetail>().userData.user?.id ?? 0).toString();
  initializeUser(){
    userId= (Get.find<UserDetail>().userData.user?.id ?? 0).toString();
    }

  Stream<QuerySnapshot<Object?>>? getChats({required int selected}) {
    if(selected==0){
      debugPrint('userId==>$userId');
      return instance
          .collection('chatRooms')
          .doc(userId)
          .collection(userId).where('senderId', isEqualTo: userId )
          .snapshots();
    }else {
      return instance
          .collection('chatRooms')
          .doc(userId)
          .collection(userId).where('receiverId', isEqualTo: userId )
          .snapshots();
    }
  }


  Stream<QuerySnapshot<Object?>>? getRequestOnVideos({required int videoId}) {
    debugPrint(userId);
      return instance
          .collection('chatRooms')
          .doc(userId)
          .collection(userId).where('receiverId', isEqualTo: userId ).where('videoId', isEqualTo: videoId)
          .snapshots();

  }


  getSingleChatDetail({required String secondUserId, required int videoId}) async {
    try {
      DocumentSnapshot documentReference = await instance
          .collection('chatRooms')
          .doc(userId)
          .collection(userId)
          .doc('$secondUserId$videoId')
          .get();
      debugPrint(
          "Here is my document==> ${documentReference.data().toString()}");
      return documentReference.data();
    } on FirebaseException catch (e) {
      debugPrint("Error while getting Single Chat Detail $e");
    }
  }

  Future<String?> uploadToStorage(File file) async {
    try {
      final DateTime now = DateTime.now();
      final int millSeconds = now.millisecondsSinceEpoch;
      final String month = now.month.toString();
      final String date = now.day.toString();
      final String storageId = (millSeconds.toString() + userId);
      final String today = ('$month-$date');

      Reference ref =
          storageInstance.ref().child("video").child(today).child(storageId);
      UploadTask uploadTask = ref.putFile(
          file,
          SettableMetadata(
            contentType: 'video/mp4',
            customMetadata: {'picked-file-path': file.path},
          ));
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});

      debugPrint(' Video Uploaded');
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      if (downloadUrl.isNotEmpty) {

        return downloadUrl;
      }
    } catch (error) {
      debugPrint('error while Uploading==> $error');
      return null;
    }
    return null;
  }

  Future createChatRoom(
      {required String secondUser,
      required String chatRoomId,
      required String userName,
      required String description,
      required String tags,
      required String videoUrl,
      required String userAvatar,
      required int videId,
      }) async {
    try {
      instance
          .collection('chatRooms')
          .doc(userId)
          .collection(userId)
          .doc('$secondUser$videId')
          .set(<String, dynamic>{
            'videoId': videId,
        'senderId': userId,
        'receiverId': secondUser,
        'userName': userName,
        'tags': tags,
        'myStatus': 'Accepted',
        'otherStatus': 'Pending',
        'lastMessageType': 'video',
        'description': description,
        'messageData': videoUrl,
        'avatar': userAvatar,
        'lastMessageTime': DateTime.now().toIso8601String(),
        'chatsId': chatRoomId,
      });
      instance
          .collection('chatRooms')
          .doc(secondUser)
          .collection(secondUser)
          .doc('$userId$videId')
          .set({
        'videoId': videId,
        'senderId': userId,
        'receiverId': secondUser,
        'userName': Get.find<UserDetail>().userData.user?.username,
        'tags': tags,
        'myStatus': 'Pending',
        'otherStatus': 'Accepted',
        'description': description,
        'lastMessageType': 'video',
        'messageData': videoUrl,
        'avatar': Get.find<UserDetail>().userData.user?.avatar,
        'lastMessageTime': DateTime.now().toIso8601String(),
        'chatsId': chatRoomId,
      });
    } on FirebaseException catch (e) {
      debugPrint("while Creating A chat room $e");
    }
  }


  Future updateChatRoom(
      {required String secondUser,
        required int videId,
      }) async {
    try {
      instance
          .collection('chatRooms')
          .doc(userId)
          .collection(userId)
          .doc('$secondUser$videId')
          .update({
           'lastMessageTime': DateTime.now().toIso8601String(),
      });
      instance
          .collection('chatRooms')
          .doc(secondUser)
          .collection(secondUser)
          .doc('$userId$videId')
          .update({
           'lastMessageTime': DateTime.now().toIso8601String(),});
    } on FirebaseException catch (e) {
      debugPrint("while updating last time $e");
    }
  }

  Future<bool> setAcceptanceStatus({required String secondUserId, required String status,required int videoId}) async {
    try {
      debugPrint({"sender": secondUserId, "status": status}.toString());
        await instance
          .collection('chatRooms')
          .doc(secondUserId)
          .collection(secondUserId)
          .doc('$userId$videoId')
          .update({'otherStatus': status});

      await instance
          .collection('chatRooms')
          .doc(userId)
          .collection(userId)
          .doc('$secondUserId$videoId')
          .update({'myStatus': status});
      return true;
    } on FirebaseException catch (e) {
      debugPrint('Error while setAcceptanceStatus $e');
      return false;
    }
  }

  sendMessage({required String chatRoomId,required ChatDataModel model})async{
    try{

      instance.collection('chats').doc(chatRoomId).collection(chatRoomId).add({
        'senderId': userId,
        'userName': Get.find<UserDetail>().userData.user?.username,
        'lastMessageType': model.lastMessageType,
        'messageData': model.messageData,
        'lastMessageTime': DateTime.now().toIso8601String(),
      });


    }on FirebaseException catch(e){
      debugPrint('Error while  sendMessage $e');
    }
  }





  getMessages({required String chatRoomId}){
    return instance
          .collection('chats')
          .doc(chatRoomId)
          .collection(chatRoomId).orderBy('lastMessageTime',descending: true)
          .snapshots();
  }


  static Future<bool> listItem(ItemModel itemModel) async {
    try {
      if (itemModel.id != '') {
        await instance
            .collection("items")
            .doc(itemModel.id)
            .update(itemModel.toMap());
      } else {
        await instance.collection("items").add(itemModel.toMap());
      }
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  static Future<bool> submitOrder(OrderModel orderModel) async {
    try {
      await instance.collection("orders").add(orderModel.toMap());

      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  static Future<bool> submitRequest(RequestModel requestModel) async {
    try {
      await instance.collection("requests").add(requestModel.toMap());

      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  static Future<bool> addToWishlist(String itemId) async {
    try {
      EasyLoading.show();
      await instance.collection("wishlist").add({
        'itemId': itemId,
        'userId': Get.find<UserDetail>().userData.user!.id.toString()
      });
      EasyLoading.dismiss();
      return true;
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString());
      return false;
    }
  }

  static Future<bool> removeWishlist(String id) async {
    try {
      EasyLoading.show();
      await instance.collection("wishlist").doc(id).delete();
      EasyLoading.dismiss();
      return true;
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString());
      return false;
    }
  }

  static Future<bool> updateRequesStatus(String id, String status) async {
    try {
      EasyLoading.show();
      await instance.collection("requests").doc(id).update({'status': status});
      EasyLoading.dismiss();

      return true;
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString());
      return false;
    }
  }

  static Future<bool> updateOrderStatus(
      String id, String status, List picture) async {
    try {
      EasyLoading.show();
      if (status == OrderStatus.ordered) {
        await instance
            .collection("orders")
            .doc(id)
            .update({'status': status, 'pictures': picture});
      } else {
        await instance
            .collection("orders")
            .doc(id)
            .update({'status': status, 'dropPicture': picture});
      }
      EasyLoading.dismiss();
      return true;
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString());
      return false;
    }
  }

  static Future<bool> updateReviewStatus(String id) async {
    try {
      EasyLoading.show();

      await instance.collection("orders").doc(id).update({
        'ratingDone': true,
      });

      EasyLoading.dismiss();
      return true;
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString());
      return false;
    }
  }

  static Future<OrderModel?> checkPreviousReviews() async {
    try {
      var query = await instance
          .collection('orders')
          .withConverter<OrderModel>(
              fromFirestore: (r, _) => OrderModel.fromDocumentSnapshot(r),
              toFirestore: (r, _) => r.toMap())
          .where(
            'ratingDone',
            isEqualTo: false,
          )
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        return query.docs.first.data();
      }
      return null;
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString());
      return null;
    }
  }

  static Stream<QuerySnapshot<DocModel>> getMyDocs(String type) {
    return instance
        .collection('users')
        .doc(userId)
        .collection('data')
        .withConverter<DocModel>(
            fromFirestore: (r, _) => DocModel.fromDocumentSnapshot(r),
            toFirestore: (r, _) => r.toMap())
        .where(
          'type',
          isEqualTo: type,
        )
        .snapshots();
  }

  static Future<QuerySnapshot<DocModel>> getMyDocsFuture(String type) {
    return instance
        .collection('users')
        .doc(userId)
        .collection('data')
        .withConverter<DocModel>(
            fromFirestore: (r, _) => DocModel.fromDocumentSnapshot(r),
            toFirestore: (r, _) => r.toMap())
        .where(
          'type',
          isEqualTo: type,
        )
        .get();
  }

  static Stream<QuerySnapshot<ItemModel>> getMyListing() {
    return instance
        .collection('items')
        .withConverter<ItemModel>(
            fromFirestore: (r, _) => ItemModel.fromDocumentSnapshot(r),
            toFirestore: (r, _) => r.toMap())
        .where(
          'userId',
          isEqualTo: Get.find<UserDetail>().userData.user!.id.toString(),
        )
        .where('status',
            whereIn: [ItemStatus.available, ItemStatus.inUse]).snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> checkWishlist(String id) {
    return instance
        .collection('wishlist')


        .where(
          'userId',
          isEqualTo: Get.find<UserDetail>().userData.user!.id.toString(),
        )
        .where('itemId', isEqualTo: id)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyWishlist() {
    return instance
        .collection('wishlist')
        .where(
          'userId',
          isEqualTo: Get.find<UserDetail>().userData.user!.id.toString(),
        )
        .snapshots();
  }

  static Stream<QuerySnapshot<RequestModel>> getMyRequest() {
    return instance
        .collection('requests')
        .withConverter<RequestModel>(
            fromFirestore: (r, _) => RequestModel.fromDocumentSnapshot(r),
            toFirestore: (r, _) => r.toMap())
        .where(
          'requestBy',
          isEqualTo: Get.find<UserDetail>().userData.user!.id.toString(),
        )
        .where('status', whereIn: [
      RequestStatus.requested,
      RequestStatus.accepted
    ]).snapshots();
  }

  static Stream<QuerySnapshot<OrderModel>> getMyOrder(int status,
      {bool getIncoming = false}) {
    String key = getIncoming ? 'requestTo' : 'requestBy';
    if (status == 0) {
      return instance
          .collection('orders')
          .withConverter<OrderModel>(
              fromFirestore: (r, _) => OrderModel.fromDocumentSnapshot(r),
              toFirestore: (r, _) => r.toMap())
          .where(
            key,
            isEqualTo: Get.find<UserDetail>().userData.user!.id.toString(),
          )
          .snapshots();
    } else if (status == 1) {
      return instance
          .collection('orders')
          .withConverter<OrderModel>(
              fromFirestore: (r, _) => OrderModel.fromDocumentSnapshot(r),
              toFirestore: (r, _) => r.toMap())
          .where(
            key,
            isEqualTo: Get.find<UserDetail>().userData.user!.id.toString(),
          )
          .where('status', isEqualTo: OrderStatus.picked)
          .snapshots();
    } else {
      return instance
          .collection('orders')
          .withConverter<OrderModel>(
              fromFirestore: (r, _) => OrderModel.fromDocumentSnapshot(r),
              toFirestore: (r, _) => r.toMap())
          .where(
            key,
            isEqualTo: Get.find<UserDetail>().userData.user!.id.toString(),
          )
          .where('status', isEqualTo: OrderStatus.drop)
          .snapshots();
    }
  }

  static Future<DocumentSnapshot<ChatGroupModel>> getSingleChat(String id) {
    return FirebaseFirestore.instance
        .collection('chats')
        .withConverter<ChatGroupModel>(
            fromFirestore: (r, _) => ChatGroupModel.fromMap(r),
            toFirestore: (r, _) => r.toMap())
        .doc(id)
        .get();
  }

  static Stream<QuerySnapshot<ChatGroupModel>> getChatRoomStatus(
      String userId) {
    return instance
        .collection('chats')
        .withConverter<ChatGroupModel>(
            fromFirestore: (r, _) => ChatGroupModel.fromMap(r),
            toFirestore: (r, _) => r.toMap())
        .where('check',
            arrayContains:
                '${userId}${Get.find<UserDetail>().userData.user!.id.toString()}')
        // .where('jobId', isEqualTo: jobId)
        .snapshots();
    // .data();
  }
}


import 'dart:io';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:connect_app/services/local_notifications_helper.dart';

class FirebaseUtils {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;


 Future<String?> getToken() async{
   String? deviceId;
   try {
     NotificationSettings notificationSettings =
     await _firebaseMessaging.requestPermission(
       alert: true,
       badge: true,
       provisional: false,
       sound: true,
     );
     if (notificationSettings.authorizationStatus ==
         AuthorizationStatus.authorized) {
       if (Platform.isIOS) {
         deviceId = await _firebaseMessaging.getAPNSToken()??'';
         await Future<void>.delayed(
           const Duration(
             seconds: 1,
           ),
         );
         deviceId = await _firebaseMessaging.getToken()??'';
         debugPrint("Authorized Token");
       } else {
         deviceId = await _firebaseMessaging.getToken()??'';
       }
     } else {
       debugPrint('Notifications are not allowed on iOS.');
       deviceId = await _firebaseMessaging.getToken()??'';
       debugPrint("Device=====>$deviceId");
     }
   } catch (e) {
     debugPrint('Error getting FCM token: $e');
   }
    return deviceId;
  }

  deleteToken()async{
   try{
    await  _firebaseMessaging.deleteToken();
   }catch(e){
     debugPrint('Error while deleting token');
   }
  }

  Future<void> pushNotifications() async {
    // 2. Instantiate Firebase Messaging
    // _firebaseMessaging.subscribeToTopic('global');
    _firebaseMessaging.getInitialMessage().then((message) {});
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      LocalNotificationChannel.display(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});
    FirebaseMessaging.onMessage.listen((event) async {
      LocalNotificationChannel.display(event);
    });
  }

}

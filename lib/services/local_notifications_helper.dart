import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationChannel {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static initializer() {
    InitializationSettings initializationSettings =
        const InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'));

    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      NotificationDetails notificationDetails = const NotificationDetails(
          android: AndroidNotificationDetails(
              'high_importance_channel', 'high_importance_channel channal',
              importance: Importance.max, priority: Priority.max));
      await _flutterLocalNotificationsPlugin.show(
          id,
          message.notification?.title,
          message.notification?.body,
          notificationDetails);
    } catch (e) {
      log(e.toString());
    }
  }

}

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:new_school/sliding_transition.dart';
import 'package:new_school/screens/notifications_page.dart';
import '../main.dart';

class NotificationService {
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'channel_Id',
    'channel_Name',
    description: 'channel_description',
    importance: Importance.high,
  );

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    navigatorKey.currentState?.push(
      SlidingPageTransitionRL(page: const NotificationsPage()),
    );
  }

  static Future<void> init() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveNotificationResponse,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showInstantNotification(String title, String body) async {
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        "channel_Id",
        "channel_Name",
        channelDescription: "channel_description",
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
      ),
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformChannelSpecifics,
      payload: "",
    );
  }
}

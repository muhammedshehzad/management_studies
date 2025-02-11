import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:new_school/sliding_transition.dart';
import 'package:new_school/screens/notifications_page.dart';
import '../main.dart'; // For navigatorKey

class NotificationService {
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'channel_Id',          // Replace with your channel id.
    'channel_Name',        // Replace with your channel name.
    description: 'channel_description', // Replace with your channel description.
    importance: Importance.high,
  );

  // A single static instance of the notifications plugin.
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// Callback to handle notification taps.
  static Future<void> onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    // Navigate to the NotificationsPage when the notification is tapped.
    navigatorKey.currentState?.push(
      SlidingPageTransitionRL(page: const NotificationsPage()),
    );
  }

  /// Initializes the local notifications.
  static Future<void> init() async {
    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings("@mipmap/ic_launcher");

    const InitializationSettings initializationSettings =
    InitializationSettings(android: androidInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveNotificationResponse,
    );

    // Create the notification channel.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Request notification permissions (for Android 13+ or if needed).
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showInstantNotification(String title, String body) async {
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        "channel_Id",          // Your channel id.
        "channel_Name",        // Your channel name.
        channelDescription: "channel_description",
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
      ),
    );

    // Use a unique notification ID based on the current time.
    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformChannelSpecifics,
      payload: "", // Optional payload.
    );
  }
}

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> checkForOldNotifications(String userId) async {
    // print("Checking for old notifications for user: $userId");

    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isNotified', isEqualTo: false)
        .get();

    // print("Found ${snapshot.docs.length} old notifications");

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final String title = data['title'] ?? 'Old Notification';
      final String message = data['message'] ?? 'You have a pending update';
      // print("Showing old notification: $title - $message");
      await showNotification(title, message);
      doc.reference.update({'isNotified': true});
    }
  }

  static Future<void> showNotification(String title, String body) async {
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
    );
  }
}

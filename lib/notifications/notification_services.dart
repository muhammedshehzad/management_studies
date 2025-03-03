import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    await requestPermissions();

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> requestPermissions() async {
    final androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      final bool granted =
          await androidImplementation.requestNotificationsPermission() ?? false;
      if (!granted) {
        print("Notification permission not granted on Android");
      }
    }

    final iosImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosImplementation != null) {
      final bool? granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      if (granted == false) {
        print("Notification permission not granted on iOS");
      }
    }
  }

  static Future<void> checkForOldNotifications(String userId) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isNotified', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final String title = data['title'] ?? 'Old Notification';
      final String message = data['message'] ?? 'You have a pending update';
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

Future<void> sendNotification({
  required String userId,
  required String title,
  required String message,
  required String type,
  Map<String, dynamic>? payload,
}) async {
  await FirebaseFirestore.instance.collection('notifications').add({
    'userId': userId,
    'title': title,
    'message': message,
    'type': type,
    'timestamp': DateTime.now().toUtc(),
    'isRead': false,
    'isNotified': false,
    'payload': payload,
  });
}

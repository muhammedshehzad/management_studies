import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? payload;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.payload,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: data['title'] as String,
      message: data['message'] as String,
      type: data['type'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] as bool? ?? false,
      payload: data['payload'] as Map<String, dynamic>?,
    );
  }
}

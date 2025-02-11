import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationServiceOneSignal {
  final String url = "https://api.onesignal.com/notifications?c=push";
  final String appId = "22793882-55dc-4053-b6f8-ca0d73087ce0";
  final String oneSignalApiKey =
      "os_v2_app_ej4trasv3rafhnxyzigxgcd44d4rs3tz7lbuzrn26nc35t4nda42elztgwiywoddjg4degc6u6r4cniqldwjesigs3kw6faeny2nqva";

  /// Sends a OneSignal push notification.
  ///
  /// [title] and [message] are displayed to the user.
  /// [dataPayload] is an optional map that contains extra custom data.
  Future<void> sendNotification({
    required String title,
    required String message,
    Map<String, dynamic>? dataPayload,
  }) async {
    try {
      // Build the body with extra data if provided.
      final Map<String, dynamic> body = {
        "app_id": appId,
        "headings": {"en": title},
        "contents": {"en": message},
        // Include custom data for use within your app
        if (dataPayload != null) "data": dataPayload,
        // You can change "included_segments" to target specific users if needed.
        "included_segments": ["Total Subscriptions"],
      };

      // Encode the body as JSON.
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Key $oneSignalApiKey",
          "accept": "application/json",
          "content-type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while sending notification: $e');
    }
  }
}

import 'dart:developer';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class NotiHelper {
  NotiHelper._();

  static Future<void> initNotif() async {
    // Set OneSignal log level for debugging
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    // Initialize OneSignal with your App ID (Remove `await` since it's void)
    OneSignal.initialize('22793882-55dc-4053-b6f8-ca0d73087ce0');

    // Request push notification permission (pass `false` or `true`)
    bool permissionGranted =
        await OneSignal.Notifications.requestPermission(true);

    log("Push notification permission granted: $permissionGranted");
  }
}

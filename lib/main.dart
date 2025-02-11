import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_school/screens/login_page.dart';
import 'package:new_school/screens/notification_model.dart';
import 'package:new_school/screens/notification_services.dart';
import 'package:new_school/screens/notifications_page.dart';
import 'package:new_school/screens/profile_details_page.dart';
import 'package:new_school/screens/profile_page.dart';
import 'package:new_school/screens/sign_in_page.dart';
import 'package:new_school/screens/sign_up_page.dart';
import 'package:new_school/settings/settings_page.dart';
import 'package:new_school/settings/two-factor_authentication.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Dashboard/dashboard.dart';
import 'drawer_screens/Canteen/cart_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.init();

  final User? currentUser = FirebaseAuth.instance.currentUser;
  final String currentUserId = currentUser?.uid ?? "";

  if (currentUserId.isNotEmpty) {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: currentUserId)
        .where('isNotified', isEqualTo: false)
        .get();
    for (var doc in snapshot.docs) {
      final notification = NotificationModel.fromFirestore(doc);
      await NotificationService.showInstantNotification(
        notification.title,
        notification.message,
      );
      doc.reference.update({'isNotified': true});
    }
  }

  if (currentUserId.isNotEmpty) {
    FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: currentUserId)
        .where('isNotified', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final notification = NotificationModel.fromFirestore(change.doc);
          NotificationService.showInstantNotification(
            notification.title,
            notification.message,
          );
          change.doc.reference.update({'isNotified': true});
        }
      }
    });
  }


  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? email = prefs.getString('email');
  final String? role = prefs.getString('role');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MyApp(
        initialRoute: email == null
            ? '/signin'
            : role == 'Admin'
            ? '/dashboardAdmin'
            : role == 'Teacher'
            ? '/dashboardTeacher'
            : '/dashboardStudent',
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(color: Colors.blueGrey.shade50),
        scaffoldBackgroundColor: Colors.blueGrey.shade50,
        fontFamily: GoogleFonts.montserrat().fontFamily,
      ),
      initialRoute: initialRoute,
      routes: {
        '/loginStudent': (context) => const Loginpage(type: 'Student'),
        '/loginTeacher': (context) => const Loginpage(type: 'Teacher'),
        '/loginAdmin': (context) => const Loginpage(type: 'Admin'),
        '/dashboardAdmin': (context) => const Dashboard(role: 'Admin'),
        '/dashboardStudent': (context) => const Dashboard(role: 'Student'),
        '/dashboardTeacher': (context) => const Dashboard(role: 'Teacher'),
        '/signup': (context) => const SignUp(),
        '/signin': (context) => const SignIn(),
        '/profile': (context) => const ProfilePage(),
        '/profileDetails': (context) => const ProfileDetailsPage(),
        '/settings': (context) => const SettingsPage(),
        '/twoFactorAuth': (context) => const TwoFactorAuth(),
        '/notifications': (context) => const NotificationsPage(),
      },
    );
  }
}

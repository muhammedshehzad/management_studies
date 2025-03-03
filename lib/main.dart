import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_school/screens/login_page.dart';
import 'package:new_school/notifications/notification_services.dart';
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
import 'drawer_screens/leaves/leave_status_provider.dart';
import 'drawer_screens/leaves/sync_manager.dart';
import 'firebase_auth_implementation/firebase_options.dart';
import 'isar_storage/isar_user_service.dart';
import 'notifications/backservice.dart';
import 'drawer_screens/Canteen/cart_provider.dart';
import 'package:isar/isar.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
late Isar isar;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  isar = await IsarUserService.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.init();
  await initializeService();
  SyncManager().init();

  try {
    await IsarUserService.init();
  } catch (e) {
    print(e);
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? email = prefs.getString('email');
  final String? role = prefs.getString('role');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => LeaveStatusProvider()),
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

import 'package:firebase_auth/firebase_auth.dart';
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

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, prefSnapshot) {
              if (!prefSnapshot.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              final String? role = prefSnapshot.data?.getString('role');
              return Dashboard(
                role: role ?? 'Student',
              );
            },
          );
        } else {
          return const SignIn();
        }
      },
    );
  }
}

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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => LeaveStatusProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
      home: const Wrapper(),
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

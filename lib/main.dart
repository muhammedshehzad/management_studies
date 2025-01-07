import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_school/firebase_auth_implementation/firebase_options.dart';
import 'package:new_school/screens/login_page.dart';
import 'package:new_school/screens/profile_details_page.dart';
import 'package:new_school/screens/profile_page.dart';
import 'package:new_school/screens/sign_in_page.dart';
import 'package:new_school/screens/sign_up_page.dart';
import 'package:new_school/settings/settings_page.dart';
import 'package:new_school/settings/two-factor_authentication.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Dashboard/dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? email = prefs.getString('email');
  final String? role = prefs.getString('role');

  runApp(
    MyApp(
      initialRoute: email == null
          ? '/signin'
          : role == 'Admin'
              ? '/dashboardAdmin'
              : role == 'Teacher'
                  ? '/dashboardTeacher'
                  : '/dashboardStudent',
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(color: Colors.blueGrey.shade50),
        scaffoldBackgroundColor: Colors.blueGrey.shade50,
        fontFamily: GoogleFonts.montserrat().fontFamily,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        '/loginStudent': (context) =>const Loginpage(type: 'Student'),
        '/loginTeacher': (context) =>const Loginpage(type: 'Teacher'),
        '/loginAdmin': (context) =>const Loginpage(type: 'Admin'),
        '/dashboardAdmin': (context) =>const Dashboard(role: 'Admin'),
        '/dashboardStudent': (context) =>const Dashboard(role: 'Student'),
        '/dashboardTeacher': (context) =>const Dashboard(role: 'Teacher'),
        '/signup': (context) =>const SignUp(),
        '/signin': (context) =>const SignIn(),
        '/profile': (context) =>const ProfilePage(),
        '/profileDetails': (context) =>const ProfileDetailsPage(),
        '/settings': (context) =>const SettingsPage(),
        '/twoFactorAuth': (context) => const TwoFactorAuth(),
      },
    );
  }
}

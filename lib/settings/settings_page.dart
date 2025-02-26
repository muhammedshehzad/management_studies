import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_school/screens/sign_up_page.dart';
import 'package:new_school/settings/terms_of_use.dart';
import 'package:new_school/settings/two-factor_authentication.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../screens/sign_in_page.dart';
import '../sliding_transition.dart';
import 'change_password.dart';
import 'privacy_policy.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isEditing = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isOnline = false;
  StreamSubscription? _connectivitySubscription;

  @override
  void initState() {
    checkInternet();
    super.initState();
  }

  Future<void> checkInternet() async {
    bool connected = await hasInternet();
    setState(() {
      isOnline = connected;
    });

    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) async {
      bool connected =
          results.any((result) => result != ConnectivityResult.none) &&
              await hasInternet();
      setState(() {
        isOnline = connected;
      });
    });
  }

  Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Settings",
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            CustomTile(
              label: 'Change password',
              onPressed: () {
                Navigator.push(
                  context,
                  SlidingPageTransitionRL(
                    page: ChangePassword(),
                  ),
                );
              },
              image: 'lib/assets/changepassword.png',
            ),
            CustomTile(
              label: 'Two-factor authentication',
              onPressed: () {
                Navigator.push(
                  context,
                  SlidingPageTransitionRL(
                    page: TwoFactorAuth(),
                  ),
                );
              },
              image: 'lib/assets/two-factor-authentication.png',
            ),
            CustomTile(
              label: 'Privacy Policy',
              onPressed: () {
                Navigator.push(
                  context,
                  SlidingPageTransitionRL(
                    page: PrivacyPolicy(),
                  ),
                );
              },
              image: 'lib/assets/privacy.png',
            ),
            CustomTile(
              label: 'Terms of use',
              onPressed: () {
                Navigator.push(
                  context,
                  SlidingPageTransitionRL(
                    page: TermsOfUse(),
                  ),
                );
              },
              image: 'lib/assets/terms.png',
            ),
            CustomTile(
              label: 'Logout',
              onPressed: () async {
                if (isOnline) {
                  try {
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.remove('email');
                    await prefs.remove('profileImagePath');
                    await prefs.remove('role');
                    await FirebaseAuth.instance.signOut();

                    Navigator.pushAndRemoveUntil(
                      context,
                      SlidingPageTransitionLR(page: SignIn()),
                      (Route<dynamic> route) => false,
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Logout failed. Please try again.')),
                    );
                  }
                } else {
                  checkInternet();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'No internet connection detected. Please check your connection and try again later.',
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: const EdgeInsets.all(10),
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.red.shade500,
                    ),
                  );
                }
              },
              image: 'lib/assets/logout(1).png',
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTile extends StatelessWidget {
  const CustomTile({
    super.key,
    required this.label,
    required this.image,
    required this.onPressed,
  });

  final String label;
  final String image;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: SizedBox(
          height: 60,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 3,
            color: Colors.blueGrey.shade100,
            shadowColor: Colors.black.withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Image.asset(
                    image,
                    height: 25,
                    width: 25,
                    color: Colors.blueGrey.shade700,
                  ),
                  const SizedBox(width: 20),
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

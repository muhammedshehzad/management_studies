
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_school/settings/terms_of_use.dart';
import 'package:new_school/settings/two-factor_authentication.dart';

import 'package:shared_preferences/shared_preferences.dart';


import '../screens/sign_in_page.dart';
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
            const SizedBox(height: 0),
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ChangePassword()));
              },
              image: 'lib/assets/changepassword.png',
            ),
            CustomTile(
              label: 'Two-factor authentication',
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TwoFactorAuth()));
              },
              image: 'lib/assets/two-factor-authentication.png',
            ),
            CustomTile(
              label: 'Privacy Policy',
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PrivacyPolicy()));
              },
              image: 'lib/assets/privacy.png',
            ),
            CustomTile(
              label: 'Terms of use',
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TermsOfUse()));
              },
              image: 'lib/assets/terms.png',
            ),
            CustomTile(
              label: 'Logout',
              onPressed: () async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.remove('email');
                await prefs.remove('profileImagePath');
                await prefs.remove('role');
                await FirebaseAuth.instance.signOut();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => SignIn()),
                  (Route<dynamic> route) => false,
                );
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
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: SizedBox(
          height: 60,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      height: 28,
                      width: 28,
                      child: Image.asset(
                        image,
                        fit: BoxFit.cover,
                      )),
                  const SizedBox(width: 15),
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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

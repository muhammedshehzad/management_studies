import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_school/screens/profile_details_page.dart';
import 'package:new_school/screens/school_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../settings/settings_page.dart';
import '../sliding_transition.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? selectedImage;
  String uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> saveImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImagePath', path);
  }

  Future<String?> getImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profileImagePath');
  }

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final path = await getImagePath();
    if (path != null) {
      setState(() {
        selectedImage = File(path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('An error occurred'));
                  }
                  if (snapshot.hasData && snapshot.data!.data() != null) {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    final String role = data["role"] ?? 'N/A';
                    String profileImageUrl = data['url'] ?? '';
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 8.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.blueGrey.shade500,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: profileImageUrl != null &&
                                        profileImageUrl!.isNotEmpty
                                    ? ClipOval(
                                        child: Image.network(
                                          profileImageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Icon(
                                              Icons.account_circle,
                                              size: 80,
                                              color: Colors.white,
                                            );
                                          },
                                        ),
                                      )
                                    : Icon(
                                        Icons.account_circle,
                                        size: 80,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      data["username"] ?? 'N/A',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      data["email"] ?? 'N/A',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      role,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.white60,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
              const SizedBox(height: 10),
              CustomTile(
                label: 'Profile',
                icon: Icons.person_2_outlined,
                onPressed: () async {
                  final updatedPath = await Navigator.push(
                    context,
                    SlidingPageTransitionRL(
                      page: ProfileDetailsPage(),
                    ),
                  );
                  if (updatedPath != null) {}
                },
              ),
              StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('An error occurred'));
                    }
                    if (snapshot.hasData && snapshot.data!.data() != null) {
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      final String role = data["role"] ?? 'N/A';
                      return CustomTile(
                        label: 'School Details',
                        icon: Icons.school_outlined,
                        onPressed: () async {
                          final updatedNewPath = await Navigator.push(
                            context,
                            SlidingPageTransitionRL(
                              page: SchoolDetailsPage(
                                role: role,
                              ),
                            ),
                          );
                          if (updatedNewPath != null) {}
                        },
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  }),
              CustomTile(
                label: 'Settings',
                icon: Icons.settings_outlined,
                onPressed: () async {
                  final settingsPath = await Navigator.push(
                    context,
                    SlidingPageTransitionRL(
                      page: SettingsPage(),
                    ),
                  );
                  if (settingsPath != null) {

                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTile extends StatelessWidget {
  const CustomTile({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
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
                  Icon(
                    icon,
                    size: 25,
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

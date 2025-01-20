import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileDetailsPage extends StatefulWidget {
  const ProfileDetailsPage({super.key});

  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  File? selectedImage;
  File? tempImage;
  final picker = ImagePicker();

  Future _pickImage() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnedImage != null) {
      setState(() {
        tempImage = File(returnedImage.path);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SizedBox() as SnackBar);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected.')),
      );
    }
  }

  Future<void> saveImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImagePath', path);
  }

  Future<String?> getImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profileImagePath');
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>>? profilebuilder() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .snapshots();
    }
    _loadImage();
    return null;
  }

  bool isEditing = false;
  final _db = FirebaseFirestore.instance;
  String? userid;

  Future<void> updateUser(String userId) async {
    final updatedData = {
      "username": nameController.text,
      "email": emailController.text,
      "address": addressController.text,
      "phone": phoneController.text,
      "url": selectedImage != null ? selectedImage!.path : "null"
    };

    try {
      await _db.collection("Users").doc(userId).update(updatedData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User details updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update user.")),
      );
    }
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;

    setState(() {
      userid = uid;
    });

    // Load profile data immediately
    if (userid != null) {
      _loadProfileData();
      _loadImage();
    }
  }

  Future<void> _loadProfileData() async {
    if (userid != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userid)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
        setState(() {
          nameController.text = data["username"] ?? 'N/A';
          emailController.text = data["email"] ?? 'N/A';
          addressController.text = data["address"] ?? 'N/A';
          phoneController.text = data["phone"] ?? 'N/A';
        });
      }
    }
  }

  Future<void> _loadImage() async {
    final path = await getImagePath();
    if (path != null && mounted) {
      setState(() {
        selectedImage = File(path);
      });
    } else if (userid != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userid)
          .get();
      if (snapshot.exists) {
        final url = snapshot['url'];
        if (url != null) {
          setState(() {
            selectedImage = File(url);
          });
        }
      }
    }
  }

  bool _controllersInitialized = false;

  @override
  Widget build(BuildContext context) {
    final profile = profilebuilder();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: profile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error loading profile data.',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return const Center(
              child: Text(
                'No profile data found.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final data = snapshot.data!.data()!;
          if (isEditing) {
            nameController.text = data["username"] ?? 'N/A';
            emailController.text = data["email"] ?? 'N/A';
            addressController.text = data["address"] ?? 'N/A';
            phoneController.text = data["phone"] ?? 'N/A';
            _controllersInitialized = true;
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: isEditing ? _pickImage : null,
                  child: CircleAvatar(
                    radius: 90,
                    backgroundColor: Colors.blueGrey.shade100,
                    backgroundImage: tempImage != null
                        ? FileImage(tempImage!)
                        : selectedImage != null
                            ? FileImage(selectedImage!)
                            : NetworkImage(data['url'] ?? '') as ImageProvider,
                    child: tempImage == null && selectedImage == null
                        ? const Icon(Icons.camera_alt,
                            size: 50, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 9.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${data["role"] ?? 'N/A'} Details :",
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                buildEditableRow(
                  'Name',
                  nameController,
                  isEditing,
                  data["username"] ?? 'N/A',
                ),
                buildEditableRow(
                  'Mail',
                  emailController,
                  isEditing,
                  data["email"] ?? 'N/A',
                ),
                buildEditableRow(
                  'Address',
                  addressController,
                  isEditing,
                  data["address"] ?? 'N/A',
                ),
                buildEditableRow(
                  'Phone Number',
                  phoneController,
                  isEditing,
                  "+91 ${data["phone"] ?? 'N/A'}",
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width ,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xff3e948e),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () async {
                        if (isEditing) {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            if (tempImage != null) {
                              selectedImage = tempImage;
                              await saveImagePath(selectedImage!.path);
                            }
                            await updateUser(user.uid);
                          }
                        }
                        setState(() {
                          isEditing = !isEditing;
                        });
                      },
                      child: Text(
                        isEditing ? 'Save Changes' : 'Edit Profile',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                )


              ],
            ),
          );
        },
      ),
    );
  }
}

Widget buildEditableRow(String label, TextEditingController controller,
    bool isEditing, String details) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 8),
    child: TextField(
      minLines: 1,
      maxLines: 4,
      readOnly: !isEditing,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      controller: controller,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    ),
  );
}

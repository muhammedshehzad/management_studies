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
      ScaffoldMessenger.of(context).showSnackBar(
        const SizedBox() as SnackBar
      );
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
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;

    setState(() {
      userid = uid;
    });
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final path = await getImagePath();
    if (path != null && mounted) {
      setState(() {
        selectedImage = File(path);
      });
    } else {
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
          if (!_controllersInitialized) {
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
                  onTap: isEditing
                      ? () async {
                    await _pickImage();
                  }
                      : null,
                  child: Container(
                    height: 250,
                    width: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 5,
                      ),                      image: DecorationImage(
                        image: tempImage != null
                            ? FileImage(tempImage!)
                            : selectedImage != null
                            ? FileImage(selectedImage!)
                            : data['url'] != null
                            ? FileImage(File(data['url'] ?? ""))
                            : NetworkImage(data['url'] ?? '') as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: !isEditing
                        ? Container(
                      child: const Center(
                        child: Text(''),
                      ),
                    )
                        : null,
                  ),
                ),

                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "User Details -( ${data["role"] ?? 'N/A'} )",
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.black87),
                      ),
                      IconButton(
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
                        icon: Icon(
                          isEditing ? Icons.check : Icons.edit,
                          size: 24,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                buildEditableRow(
                  'lib/assets/name.png',
                  'Name',
                  nameController,
                  isEditing,
                  data["username"] ?? 'N/A',
                ),
                buildEditableRow(
                  'lib/assets/email.png',
                  'Mail',
                  emailController,
                  isEditing,
                  data["email"] ?? 'N/A',
                ),
                buildEditableRow(
                  'lib/assets/address.png',
                  'Address',
                  addressController,
                  isEditing,
                  data["address"] ?? 'N/A',
                ),
                buildEditableRow(
                  'lib/assets/phone.png',
                  'Phone Number',
                  phoneController,
                  isEditing,
                  "+91 ${data["phone"] ?? 'N/A'}",
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Widget buildEditableRow(String image, String label,
    TextEditingController controller, bool isEditing, String details) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    child: Container(
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey, width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$label: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.blueGrey,
                  ),
                ),
                isEditing
                    ? Expanded(
                      child: TextField(
                                        minLines: 1,
                                        maxLines: 3,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                          ),
                          controller: controller,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                    )
                    : Text(
                        details,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w400),
                  overflow: TextOverflow.ellipsis,
                      ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}














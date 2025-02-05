import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_school/sliding_transition.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfileDetailsPage extends StatefulWidget {
  const ProfileDetailsPage({super.key});

  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  File? selectedImage;
  File? tempImage;
  final picker = ImagePicker();
  String? imageurl;

  Future<void> _pickImage() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnedImage != null) {
      setState(() {
        tempImage = File(returnedImage.path);
      });
      await imageUpload();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected.')),
      );
    }
  }

  bool isUploading = false;

  Future<void> imageUpload() async {
    if (tempImage == null) return;

    setState(() {
      isUploading = true;
    });

    final url = Uri.parse('https://api.cloudinary.com/v1_1/dfcehequr/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'images'
      ..files.add(await http.MultipartFile.fromPath('file', tempImage!.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responsedata = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responsedata);
      final jsonMap = jsonDecode(responseString);
      setState(() {
        final uploadedUrl = jsonMap['url'] ?? '';
        imageurl = uploadedUrl;
        print('Uploaded Image URL: $imageurl');
        saveImagePath(uploadedUrl);
        updateUser(userid!);
        isUploading = false; // Stop loading
      });
    } else {
      setState(() {
        isUploading = false; // Stop loading on failure
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image to Cloudinary.')),
      );
    }
  }

  Widget buildPhotoView(String imageurl) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Stack(
            children: [
              PhotoView(
                imageProvider: NetworkImage(imageurl!),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2.0,
                backgroundDecoration: const BoxDecoration(
                  color: Colors.black,
                ),
              ),
              Positioned(
                top: 30,
                right: 0,
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.close,
                    size: 30,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  Widget buildProfileImage(String imageUrl) {
    return imageUrl.startsWith('http')
        ? Image.network(imageUrl, fit: BoxFit.cover)
        : Image.asset('assets/default_profile_image.png', fit: BoxFit.cover);
  }

  Future<void> updateUser(String userId) async {
    final updatedData = {
      "username": nameController.text,
      "email": emailController.text,
      "address": addressController.text,
      "phone": phoneController.text,
      "url": imageurl ?? "null"
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

    if (userid != null) {
      _loadProfileData();
      _loadImage();
    }
  }

  Future<void> imageUplod() async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/dfcehequr/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'images'
      ..files.add(await http.MultipartFile.fromPath('file', imageurl!));
    final response = await request.send();
    if (response.statusCode == 200) {
      final responsedata = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responsedata);
      final jsonMap = jsonDecode(responseString);
      setState(() {
        final url = jsonMap['url'];
        imageurl = url;
        print(imageurl);
      });
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
          var userData = snapshot.data!.data();
          String profileImageUrl = userData?['url'] ?? '';
          return SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: isEditing
                      ? _pickImage
                      : () {
                          if (profileImageUrl.isNotEmpty) {
                            Navigator.push(
                                context,
                                SlidingPageTransitionRL(
                                  page: PhotoViewScreen(
                                      imageUrl: profileImageUrl),
                                ));
                          }
                        },
                  child: CircleAvatar(
                    radius: 90,
                    backgroundColor: Colors.blueGrey.shade100,
                    backgroundImage: profileImageUrl.isNotEmpty
                        ? NetworkImage(profileImageUrl)
                        : null,
                    child: isUploading // Show loading indicator while uploading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : (profileImageUrl.isEmpty &&
                                tempImage == null &&
                                selectedImage == null)
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
                            fontSize: 16,
                            color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
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
                    width: MediaQuery.of(context).size.width,
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
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
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

class PhotoViewScreen extends StatelessWidget {
  final String imageUrl;

  const PhotoViewScreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Stack(
            children: [
              PhotoView(
                imageProvider: NetworkImage(imageUrl),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2.0,
                backgroundDecoration: const BoxDecoration(
                  color: Colors.black,
                ),
              ),
              Positioned(
                top: 30,
                right: 0,
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

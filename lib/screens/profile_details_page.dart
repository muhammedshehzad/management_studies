import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isar/isar.dart';
import 'package:new_school/sliding_transition.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:new_school/isar_storage/isar_user_service.dart';
import '../isar_storage/user_model.dart';
import '../main.dart';

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
  bool isUploading = false;
  bool isEditing = false;
  bool _controllersInitialized = false;
  String? userid;
  final _db = FirebaseFirestore.instance;
  bool _isLoading = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final User? user = FirebaseAuth.instance.currentUser;
    userid = user?.uid;
    if (userid != null) {
      _loadProfileData();
      loadProfileFromIsar().then((_) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      });
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getProfileData() async {
    if (userid != null) {
      return FirebaseFirestore.instance.collection('Users').doc(userid).get();
    }
    throw Exception("User not logged in");
  }

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
        SnackBar(
          content: const Text('No image selected.'),
          backgroundColor: Colors.red.shade500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<String?> imageUpload() async {
    if (tempImage == null) return null;

    setState(() {
      isUploading = true;
    });

    final url = Uri.parse('https://api.cloudinary.com/v1_1/dfcehequr/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'images'
      ..files.add(await http.MultipartFile.fromPath('file', tempImage!.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = jsonDecode(responseString);
      setState(() {
        isUploading = false;
      });
      return jsonMap['url'];
    } else {
      setState(() {
        isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload image to Cloudinary.'),
          backgroundColor: Colors.red.shade500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 2),
        ),
      );
      return null;
    }
  }

  Future<bool> isConnected() async {
    var result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> saveImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImagePath', path);
  }

  Future<String?> getImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profileImagePath');
  }

  Future<void> _loadProfileData() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      await loadProfileFromIsar();
    } else {
      try {
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
            imageurl = data['url'];
          });
          await _saveProfileToIsar(data);
          if (data['url'] != null) {
            await saveImagePath(data['url']!);
          }
        }
      } catch (e) {
        await loadProfileFromIsar();
      }
    }
  }

  Future<void> _saveProfileToIsar(Map<String, dynamic> data) async {
    final user = UserModel()
      ..uid = userid!
      ..username = data['username'] ?? 'N/A'
      ..email = data['email'] ?? 'N/A'
      ..role = data['role'] ?? 'N/A'
      ..url = data['url'] ?? ''
      ..department = data['department'] ?? ''
      ..address = data['address'] ?? ''
      ..phone = data['phone'] ?? 'N/A';

    await IsarUserService.isar!.writeTxn(() async {
      await IsarUserService.isar!.userModels.put(user);
    });
  }

  Future<void> loadProfileFromIsar() async {
    if (!IsarUserService.isInitialized) {
      await IsarUserService.init();
    }

    final user = await IsarUserService.isar?.userModels
        .filter()
        .uidEqualTo(userid!)
        .findFirst();

    if (user != null) {
      setState(() {
        nameController.text = user.username ?? 'N/A';
        emailController.text = user.email ?? 'N/A';
        addressController.text = user.address ?? 'N/A';
        phoneController.text = user.phone ?? 'N/A';
        imageurl = user.url;
      });
      if (user.url != null && user.url!.isNotEmpty) {
        await saveImagePath(user.url!);
      }
    }
  }

  Future<void> _loadImage() async {
    final path = await getImagePath();
    if (path != null && mounted) {
      setState(() {
        selectedImage = File(path);
      });
      return;
    }

    final user = await IsarUserService.isar!.userModels
        .filter()
        .uidEqualTo(userid!)
        .findFirst();
    if (user != null && user.url != null && user.url!.isNotEmpty) {
      setState(() {
        selectedImage = File(user.url!);
      });
      await saveImagePath(user.url!);
    }
  }

  Future<void> updateUser(String userId) async {
    String? uploadedImageUrl;

    if (tempImage != null) {
      uploadedImageUrl = await imageUpload();
    }

    final updatedData = {
      "username": nameController.text,
      "email": emailController.text,
      "address": addressController.text,
      "phone": phoneController.text,
      "url": uploadedImageUrl ?? imageurl,
    };

    await updateUserOffline(userId, updatedData);

    bool online = await isConnected();
    if (online) {
      try {
        await _db.collection("Users").doc(userId).update(updatedData);

        DocumentSnapshot snapshot =
            await _db.collection("Users").doc(userId).get();
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          final user = UserModel()
            ..uid = userId
            ..username = data['username'] ?? 'N/A'
            ..email = data['email'] ?? 'N/A'
            ..role = data['role'] ?? 'N/A'
            ..url = data['url'] ?? ''
            ..department = data['department'] ?? ''
            ..address = data['address'] ?? ''
            ..phone = data['phone'] ?? 'N/A';

          await IsarUserService.isar!.writeTxn(() async {
            final existingUser = await IsarUserService.isar!.userModels
                .filter()
                .uidEqualTo(userId)
                .findFirst();
            if (existingUser != null) {
              user.id = existingUser.id;
            }
            await IsarUserService.isar!.userModels.put(user);
          });

          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text("User details updated successfully!"),   backgroundColor: Colors.green.shade500,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(10),
              duration: const Duration(seconds: 2),),
          );
        }
      } catch (e) {
        print("Error updating Firestore: $e");
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Failed to update user online."), backgroundColor: Colors.red.shade500,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(10),
            duration: const Duration(seconds: 2),),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
            content: Text(
                "Offline: Changes saved locally and will sync when online."),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 2),),
      );
    }
  }

  Future<void> updateUserOffline(
      String userId, Map<String, dynamic> updatedData) async {
    setState(() => isEditing = false);

    // Ensure Isar is initialized
    if (!IsarUserService.isInitialized) {
      await IsarUserService.init();
    }

    final localUser = await IsarUserService.isar!.userModels
            .filter()
            .uidEqualTo(userId)
            .findFirst() ??
        UserModel();

    localUser.uid = userId;
    localUser.username = updatedData["username"] ?? localUser.username;
    localUser.email = updatedData["email"] ?? localUser.email;
    localUser.address = updatedData["address"] ?? localUser.address;
    localUser.phone = updatedData["phone"] ?? localUser.phone;
    localUser.url = updatedData["url"] ?? localUser.url;

    await IsarUserService.isar!.writeTxn(() async {
      await IsarUserService.isar!.userModels.put(localUser);
    });
    print('Local Isar updated.');
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
                imageProvider: NetworkImage(imageurl),
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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: isEditing
                          ? _pickImage
                          : imageurl?.isNotEmpty ?? false
                              ? () {
                                  Navigator.push(
                                      context,
                                      SlidingPageTransitionRL(
                                        page: PhotoViewScreen(
                                            imageUrl: imageurl!),
                                      ));
                                }
                              : null,
                      child: CircleAvatar(
                        radius: 90,
                        backgroundColor: Colors.blueGrey.shade100,
                        backgroundImage: tempImage != null
                            ? FileImage(tempImage!) as ImageProvider
                            : (imageurl?.isNotEmpty ?? false
                                ? NetworkImage(imageurl!)
                                : null),
                        child: isUploading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : (imageurl == null && tempImage == null)
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
                          FutureBuilder<DocumentSnapshot>(
                            future: _db.collection('Users').doc(userid).get(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data!.exists) {
                                final role =
                                    snapshot.data!.get('role') ?? 'N/A';
                                return Text(
                                  "$role Details :",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    buildEditableRow(
                      'Name',
                      nameController,
                      isEditing,
                    ),
                    buildEditableRow(
                      'Mail',
                      emailController,
                      isEditing,
                    ),
                    buildEditableRow(
                      'Address',
                      addressController,
                      isEditing,
                    ),
                    buildEditableRow(
                      'Phone Number',
                      phoneController,
                      isEditing,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
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
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              if (isEditing) {
                                await updateUser(user.uid);
                                setState(() => isEditing = false);
                              } else {
                                setState(() => isEditing = true);
                              }
                            }
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
              ));
  }
}

Widget buildEditableRow(
  String label,
  TextEditingController controller,
  bool isEditing,
) {
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

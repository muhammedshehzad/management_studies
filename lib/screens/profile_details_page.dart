import 'dart:async';
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
  bool _isOnline = true;
  StreamSubscription? _connectivitySubscription;
  StreamSubscription<User?>? _userSubscription;
  bool _isUpdatingEmail = false;

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

      _userSubscription =
          FirebaseAuth.instance.userChanges().listen((User? user) {
        if (user != null && mounted) {
          _handleUserChange(user);
        }
      });
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
    checkInternet();
  }

  Future<void> _handleUserChange(User user) async {
    if (_isUpdatingEmail) return;

    final currentEmailInController = emailController.text;
    if (user.email != null && user.email != currentEmailInController) {
      print("Detected email change in Firebase: ${user.email}");
      setState(() {
        emailController.text = user.email!;
      });

      await _db.collection('Users').doc(userid).update({
        'email': user.email,
      });

      final snapshot = await _db.collection('Users').doc(userid).get();
      if (snapshot.exists) {
        final data = snapshot.data()!;
        await _saveProfileToIsar(data, updateEmail: true);
      }

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text("Email updated successfully in profile!"),
      //     backgroundColor: Colors.green.shade500,
      //     behavior: SnackBarBehavior.floating,
      //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      //     margin: const EdgeInsets.all(10),
      //     duration: const Duration(seconds: 2),
      //   ),
      // );
    }
  }

  Future<void> checkInternet() async {
    bool connected = await hasInternet();
    setState(() {
      _isOnline = connected;
    });

    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) async {
      bool connected =
          results.any((result) => result != ConnectivityResult.none) &&
              await hasInternet();
      setState(() {
        _isOnline = connected;
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
          await _saveProfileToIsar(data, updateEmail: true);
          if (data['url'] != null) {
            await saveImagePath(data['url']!);
          }
        }
      } catch (e) {
        await loadProfileFromIsar();
      }
    }
  }

  Future<void> _saveProfileToIsar(Map<String, dynamic> data,
      {bool updateEmail = true}) async {
    await IsarUserService.isar!.writeTxn(() async {
      final existingUser = await IsarUserService.isar!.userModels
          .filter()
          .uidEqualTo(userid!)
          .findFirst();

      final user = existingUser ?? UserModel();
      user.uid = userid!;
      user.username = data['username'] ?? 'N/A';
      user.role = data['role'] ?? 'N/A';
      user.url = data['url'] ?? '';
      user.department = data['department'] ?? '';
      user.address = data['address'] ?? '';
      user.phone = data['phone'] ?? 'N/A';

      if (updateEmail) {
        user.email = data['email'] ?? 'N/A';
      } else {
        user.email = existingUser?.email ?? data['email'] ?? 'N/A';
      }

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

  Future<void> updateUser(String userId) async {
    String? uploadedImageUrl;
    bool emailChanged = false;
    String originalEmail = '';
    final currentUser = FirebaseAuth.instance.currentUser;
    String? newEmail;

    if (currentUser != null) {
      originalEmail = currentUser.email ?? '';
      emailChanged = originalEmail != emailController.text &&
          emailController.text.isNotEmpty;
      if (emailChanged) {
        newEmail = emailController.text;
      }
      print(
          "Original email: $originalEmail, New email: ${emailController.text}, Changed: $emailChanged");
    }
    if (tempImage != null) {
      uploadedImageUrl = await imageUpload();
    }

    bool online = await isConnected();
    final updatedData = {
      "username": nameController.text,
      "email": emailChanged && !online ? originalEmail : emailController.text,
      "address": addressController.text,
      "phone": phoneController.text,
      "url": uploadedImageUrl ?? imageurl,
    };

    await updateUserOffline(userId, updatedData);

    if (online && emailChanged) {
      setState(() => _isUpdatingEmail = true);
      print("Email before reauth: ${emailController.text}");
      final password = await _promptForPassword();
      if (password == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Email change cancelled."),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(10),
        ));
        return;
      }

      final reauthSuccess = await reauthenticateUser(password);
      if (!reauthSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Authentication failed. Please check your password."),
          backgroundColor: Colors.red.shade500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(10),
        ));
        return;
      }

      print("Sending verification email to: ${emailController.text}");
      await currentUser?.verifyBeforeUpdateEmail(emailController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "A verification email has been sent to ${emailController.text}. Please verify to complete the change."),
          backgroundColor: Colors.blue.shade500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 5),
        ),
      );
      await Future.delayed(Duration(seconds: 1));
      final updatedUser = FirebaseAuth.instance.currentUser;
      if (updatedUser != null && updatedUser.email != originalEmail) {
        await _handleUserChange(updatedUser);
      }
      setState(() => _isUpdatingEmail = false);
      await _refreshProfile(); // Force UI and data refresh
    } else if (online) {
      await _db.collection("Users").doc(userId).update(updatedData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("User details updated successfully!"),
          backgroundColor: Colors.green.shade500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (emailChanged) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Offline: Email change requires internet. Saved locally."),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(10),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Offline: Changes saved locally and will sync when online."),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(10),
        ),
      );
      await _refreshProfile(); // Ensure UI is updated after any change
    }

    final snapshot = await _db.collection("Users").doc(userId).get();
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      await _saveProfileToIsar(data, updateEmail: !emailChanged);
    }
  }

  Future<void> _refreshProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _handleUserChange(user);
      await _loadProfileData();
    }
  }

  Future<void> updateUserOffline(
      String userId, Map<String, dynamic> updatedData) async {
    setState(() => isEditing = false);

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
    localUser.email = localUser.email ?? 'N/A';
    localUser.address = updatedData["address"] ?? localUser.address;
    localUser.phone = updatedData["phone"] ?? localUser.phone;
    localUser.url = updatedData["url"] ?? localUser.url;

    await IsarUserService.isar!.writeTxn(() async {
      await IsarUserService.isar!.userModels.put(localUser);
    });
    print('Local Isar updated (email not changed).');
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _userSubscription?.cancel();
    nameController.dispose();
    emailController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<String?> _promptForPassword() async {
    final passwordController = TextEditingController();
    bool isPasswordVisible = false;

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Confirm your password',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To change your email address, please confirm your current password.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 24),
                    TextField(
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        hintText: 'Enter your current password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: const Color(0xff3e948e),
                            width: 2,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Colors.grey[600],
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey[600],
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          Navigator.pop(context, value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, null);
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (passwordController.text.isNotEmpty) {
                          Navigator.pop(context, passwordController.text);
                          final reauthSuccess =
                              await reauthenticateUser(passwordController.text);
                          if (reauthSuccess) {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              await user.verifyBeforeUpdateEmail(
                                  emailController.text);
                              await _refreshProfile();
                              await Future.delayed(Duration(seconds: 1));
                              final updatedUser =
                                  FirebaseAuth.instance.currentUser;
                              if (updatedUser != null) {
                                await _handleUserChange(updatedUser);
                              }
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff3e948e),
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Confirm',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool> reauthenticateUser(String password) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      print("Reauth error: $e");
      return false;
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
                    buildEditableRow('Name', nameController, isEditing, false),
                    buildEditableRow(
                        'Mail', emailController, isEditing, !_isOnline),
                    buildEditableRow(
                        'Address', addressController, isEditing, false),
                    buildEditableRow(
                        'Phone Number', phoneController, isEditing, false),
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

Widget buildEditableRow(String label, TextEditingController controller,
    bool isEditing, bool forceReadOnly) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
    child: TextField(
      minLines: 1,
      maxLines: 4,
      readOnly: !isEditing || forceReadOnly,
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

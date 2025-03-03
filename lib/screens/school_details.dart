import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../isar_storage/isar_user_service.dart';
import '../isar_storage/school_details_model.dart';

class SchoolDetailsPage extends StatefulWidget {
  final String role;

  const SchoolDetailsPage({super.key, required this.role});

  @override
  State<SchoolDetailsPage> createState() => _SchoolDetailsPageState();
}

class _SchoolDetailsPageState extends State<SchoolDetailsPage> {
  File? selectedNewImage;
  File? temporaryImage;
  final picker = ImagePicker();
  String? schoolimageurl;
  File? tempImage;

  Future<void> _pickImage() async {
    final returnedSchoolImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnedSchoolImage != null) {
      setState(() {
        temporaryImage = File(returnedSchoolImage.path);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Uploading image...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      await imageUpload();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('No image selected.'),behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 2),),
      );
    }
  }

  Future<bool> isConnected() async {
    var result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> imageUpload() async {
    if (temporaryImage == null) return;

    final url = Uri.parse('https://api.cloudinary.com/v1_1/dfcehequr/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'images'
      ..files
          .add(await http.MultipartFile.fromPath('file', temporaryImage!.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responsedata = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responsedata);
      final jsonMap = jsonDecode(responseString);
      setState(() {
        schoolimageurl = jsonMap['url'];
        print('Uploaded Image URL: $schoolimageurl');
      });
      await saveImagePath(schoolimageurl!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image to Cloudinary.')),
      );
    }
  }

  Future<void> saveImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImageNewPath', path);
  }

  Future<String?> getImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profileImageNewPath');
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>>? detailsbuilder() {
    final user = FirebaseAuth.instance.currentUser;
    print("User UID: ${FirebaseAuth.instance.currentUser?.uid}");

    if (user != null) {
      return FirebaseFirestore.instance
          .collection('School')
          .doc("9NekuNXmyxdNxWekn282")
          .snapshots();
    }
    return const Stream.empty();
  }

  bool isEditing = false;
  final _db = FirebaseFirestore.instance;
  String? schoolid;

  Future<void> updateSchool(String? schoolId) async {
    if (schoolId == null) {
      print('Error: schoolId is null');
      return;
    }

    final existingSchool = await IsarUserService.isar!.schoolDetails
        .filter()
        .idEqualTo(1)
        .findFirst();
    print(existingSchool);

    final updatedSchoolData = {
      "schoolname": schoolNameController.text,
      "schooltype": schoolTypeController.text,
      "schoollocation": schoolLocationController.text,
      "schoolcontact": schoolContactController.text,
      "schoolwebsite": schoolWebsiteController.text,
      "url": schoolimageurl ?? existingSchool?.schoolImageUrl ?? '',
    };

    await updateSchoolOffline(schoolId, updatedSchoolData);

    bool online = await isConnected();
    if (online) {
      try {
        await _db
            .collection("School")
            .doc(schoolId)
            .set(updatedSchoolData, SetOptions(merge: true));

        DocumentSnapshot snapshot =
            await _db.collection("School").doc(schoolId).get();
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          final schoolDetails = SchoolDetails()
            ..schoolName = data['schoolname'] ?? schoolNameController.text
            ..schoolType = data['schooltype'] ?? schoolTypeController.text
            ..schoolLocation =
                data['schoollocation'] ?? schoolLocationController.text
            ..schoolContact =
                data['schoolcontact'] ?? schoolContactController.text
            ..schoolWebsite =
                data['schoolwebsite'] ?? schoolWebsiteController.text
            ..schoolImageUrl =
                data['url'] ?? existingSchool?.schoolImageUrl ?? '';

          await IsarUserService.isar!.writeTxn(() async {
            await IsarUserService.isar!.schoolDetails.put(schoolDetails);
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('School details updated successfully!')),
        );
      } catch (e) {
        print("Error updating Firestore: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update school online.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Offline: Changes saved locally and will sync when online.")),
      );
    }
  }

  Future<void> updateSchoolOffline(
      String schoolId, Map<String, dynamic> updatedData) async {
    setState(() => isEditing = false);

    final isar = IsarUserService.isar!;
    final localSchool =
        await isar.schoolDetails.filter().idEqualTo(1).findFirst();

    if (localSchool != null) {
      localSchool
        ..schoolName = updatedData["schoolname"] ?? localSchool.schoolName
        ..schoolType = updatedData["schooltype"] ?? localSchool.schoolType
        ..schoolLocation =
            updatedData["schoollocation"] ?? localSchool.schoolLocation
        ..schoolContact =
            updatedData["schoolcontact"] ?? localSchool.schoolContact
        ..schoolWebsite =
            updatedData["schoolwebsite"] ?? localSchool.schoolWebsite
        ..schoolImageUrl = updatedData["url"] ?? localSchool.schoolImageUrl;

      await isar.writeTxn(() async {
        await isar.schoolDetails.put(localSchool);
      });

      print('Local Isar updated: $updatedData');
    } else {
      print('No existing school record found in Isar.');
    }
  }

  final TextEditingController schoolNameController = TextEditingController();
  final TextEditingController schoolTypeController = TextEditingController();
  final TextEditingController schoolLocationController =
      TextEditingController();
  final TextEditingController schoolContactController = TextEditingController();
  final TextEditingController schoolWebsiteController = TextEditingController();
  final TextEditingController schoolAffiliationController =
      TextEditingController();

  @override
  void initState() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;
    loadSchoolDetailsFromIsar();
    setState(() {
      schoolid = uid;
    });
    super.initState();
  }

  bool _controllersInitialized = false;

  Future<void> loadSchoolDetailsFromIsar() async {
    final cachedData = await IsarUserService.isar!.schoolDetails.get(1);
    if (cachedData != null) {
      setState(() {
        schoolNameController.text = cachedData.schoolName;
        schoolTypeController.text = cachedData.schoolType;
        schoolLocationController.text = cachedData.schoolLocation;
        schoolContactController.text = cachedData.schoolContact;
        schoolWebsiteController.text = cachedData.schoolWebsite;
        schoolimageurl = cachedData.schoolImageUrl;
      });
    }
  }

  Future<String?> fetchImage() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('School').get();
    if (querySnapshot.docs.isEmpty) return null;
    DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
    String? schoolImageUrl = documentSnapshot['url'];
    return schoolImageUrl;
  }

  @override
  Widget build(BuildContext context) {
    final school = detailsbuilder();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<String?>(
              future: fetchImage(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircleAvatar(
                    radius: 90,
                    backgroundColor: Colors.blueGrey.shade100,
                    backgroundImage:
                        (schoolimageurl != null && schoolimageurl!.isNotEmpty)
                            ? NetworkImage(schoolimageurl!)
                            : null,
                    child: (schoolimageurl == null || schoolimageurl!.isEmpty)
                        ? const Icon(Icons.camera_alt,
                            size: 50, color: Colors.white)
                        : null,
                  ));
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error loading image URL',
                        style: TextStyle(color: Colors.red)),
                  );
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: 90,
                        backgroundColor: Colors.blueGrey.shade100,
                        backgroundImage:
                            (schoolimageurl != null && schoolimageurl!.isNotEmpty)
                                ? NetworkImage(schoolimageurl!)
                                : null, // or a placeholder image
                        child: (schoolimageurl == null || schoolimageurl!.isEmpty)
                            ? const Icon(Icons.camera_alt,
                                size: 50, color: Colors.white)
                            : null,
                      ),
                    ),
                  );
                }

                String schoolImageUrl = snapshot.data!;

                return GestureDetector(
                  onTap: isEditing
                      ? () async {
                          await _pickImage();
                        }
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: CircleAvatar(
                      radius: 90,
                      backgroundColor: Colors.blueGrey.shade100,
                      backgroundImage:
                          (schoolimageurl != null && schoolimageurl!.isNotEmpty)
                              ? NetworkImage(schoolimageurl!)
                              : null, // or a placeholder image
                      child: (schoolimageurl == null || schoolimageurl!.isEmpty)
                          ? const Icon(Icons.camera_alt,
                              size: 50, color: Colors.white)
                          : null,
                    ),
                  ),
                );
              },
            ),
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: school,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                      body: const Center(child: CircularProgressIndicator()));
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
                  return Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "School Details : ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    color: Colors.black87),
                              ),
                              if (widget.role == 'Admin')
                                IconButton(
                                  onPressed: () async {
                                    if (isEditing) {
                                      await updateSchool(
                                          '9NekuNXmyxdNxWekn282');
                                      setState(() {
                                        isEditing = false;
                                      });
                                    } else {
                                      setState(() {
                                        isEditing = true;
                                      });
                                    }
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
                          'Name',
                          schoolNameController,
                          isEditing,
                        ),
                        buildEditableRow(
                          'Type',
                          schoolTypeController,
                          isEditing,
                        ),
                        buildEditableRow(
                          'Location',
                          schoolLocationController,
                          isEditing,
                        ),
                        buildEditableRow(
                          'Contact',
                          schoolContactController,
                          isEditing,
                        ),
                        buildEditableRow(
                          'Website',
                          schoolWebsiteController,
                          isEditing,
                        ),
                        buildEditableRow(
                          'Affiliation',
                          schoolAffiliationController,
                          isEditing,
                        ),
                        const SizedBox(
                          height: 30,
                        )
                      ],
                    ),
                  );
                }

                final schooldata = snapshot.data!.data()!;
                if (!_controllersInitialized) {
                  schoolNameController.text = schooldata["schoolname"] ?? 'N/A';
                  schoolTypeController.text = schooldata["schooltype"] ?? 'N/A';
                  schoolLocationController.text =
                      schooldata["schoollocation"] ?? 'N/A';
                  schoolContactController.text =
                      schooldata["schoolcontact"] ?? 'N/A';
                  schoolWebsiteController.text =
                      schooldata["schoolwebsite"] ?? 'N/A';
                  schoolAffiliationController.text =
                      schooldata["schoolaffiliation"] ?? 'N/A';
                  _controllersInitialized = true;
                }

                return Column(
                  children: [
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "School Details : ",
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: Colors.black87),
                          ),
                          if (widget.role == 'Admin')
                            IconButton(
                              onPressed: () async {
                                if (isEditing) {
                                  await updateSchool('9NekuNXmyxdNxWekn282');
                                  setState(() {
                                    isEditing = false;
                                  });
                                } else {
                                  setState(() {
                                    isEditing = true;
                                  });
                                }
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
                      'Name',
                      schoolNameController,
                      isEditing,
                    ),
                    buildEditableRow(
                      'Type',
                      schoolTypeController,
                      isEditing,
                    ),
                    buildEditableRow(
                      'Location',
                      schoolLocationController,
                      isEditing,
                    ),
                    buildEditableRow(
                      'Contact',
                      schoolContactController,
                      isEditing,
                    ),
                    buildEditableRow(
                      'Website',
                      schoolWebsiteController,
                      isEditing,
                    ),
                    buildEditableRow(
                      'Affiliation',
                      schoolAffiliationController,
                      isEditing,
                    ),
                    SizedBox(
                      height: 30,
                    )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
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

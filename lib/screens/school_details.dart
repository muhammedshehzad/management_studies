import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
  late Isar isar;

  Future _pickImage() async {
    final returnedSchoolImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnedSchoolImage != null) {
      setState(() {
        temporaryImage = File(returnedSchoolImage.path);
      });
      await imageUpload();
      ScaffoldMessenger.of(context)
          .showSnackBar(const CircularProgressIndicator() as SnackBar);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected.')),
      );
    }
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
        final uploadedUrl = jsonMap['url'];
        schoolimageurl = uploadedUrl;
        print('Uploaded Image URL: $schoolimageurl');
        saveImagePath(uploadedUrl);
        updateSchool(schoolid!);
      });
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

    print("Fetching current school data for ID: $schoolId");

    final currentData = await _db.collection("School").doc(schoolId).get();

    if (!currentData.exists) {
      print("No existing school data found for ID: $schoolId");
      return;
    }

    print("Existing data found. Preparing update...");

    final updatedSchoolData = {
      "schoolname": schoolNameController.text,
      "schooltype": schoolTypeController.text,
      "schoollocation": schoolLocationController.text,
      "schoolcontact": schoolContactController.text,
      "schoolwebsite": schoolWebsiteController.text,
      "url": schoolimageurl ?? currentData["url"]
    };

    await _db.collection("School").doc(schoolId).update(updatedSchoolData);

    final schoolDetails = SchoolDetails()
      ..schoolName = schoolNameController.text
      ..schoolType = schoolTypeController.text
      ..schoolLocation = schoolLocationController.text
      ..schoolContact = schoolContactController.text
      ..schoolWebsite = schoolWebsiteController.text
      ..schoolImageUrl = schoolimageurl ?? '';

    if (isar == null) {
      print("no dataa");
      return;
    }

    await isar.writeTxn(() async {
      final id = await isar.schoolDetails.put(schoolDetails);
      print("updated $id");
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('School details updated successfully!')),
    );
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
    initializeIsar();
    loadSchoolDetailsFromIsar();
    setState(() {
      schoolid = uid;
    });
    super.initState();
  }

  Future<void> initializeIsar() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([SchoolDetailsSchema], directory: dir.path);
  }

  bool _controllersInitialized = false;

  Future<void> loadSchoolDetailsFromIsar() async {
    final cachedData = await isar.schoolDetails.get(1);
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
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: school,
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
                'No school data found.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final schooldata = snapshot.data!.data()!;
          if (!_controllersInitialized) {
            schoolNameController.text = schooldata["schoolname"] ?? 'N/A';
            schoolTypeController.text = schooldata["schooltype"] ?? 'N/A';
            schoolLocationController.text =
                schooldata["schoollocation"] ?? 'N/A';
            schoolContactController.text = schooldata["schoolcontact"] ?? 'N/A';
            schoolWebsiteController.text = schooldata["schoolwebsite"] ?? 'N/A';
            schoolAffiliationController.text =
                schooldata["schoolaffiliation"] ?? 'N/A';
            _controllersInitialized = true;
          }
          String schoolImageUrl = schooldata?['url'] ?? '';

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
                    height: MediaQuery.of(context).size.height * .275,
                    width: MediaQuery.of(context).size.width * .6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1),
                      image: DecorationImage(
                        image: NetworkImage(schoolImageUrl),
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
                              final user = FirebaseAuth.instance.currentUser;
                              updateSchool('9NekuNXmyxdNxWekn282');
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
                  'Name',
                  schoolNameController,
                  isEditing,
                  schooldata["schoolname"] ?? 'N/A',
                ),
                buildEditableRow(
                  'Type',
                  schoolTypeController,
                  isEditing,
                  schooldata["schooltype"] ?? 'N/A',
                ),
                buildEditableRow(
                  'Location',
                  schoolLocationController,
                  isEditing,
                  schooldata["schoollocation"] ?? 'N/A',
                ),
                buildEditableRow(
                  'Contact',
                  schoolContactController,
                  isEditing,
                  "${schooldata["schoolcontact"] ?? 'N/A'}",
                ),
                buildEditableRow(
                  'Website',
                  schoolWebsiteController,
                  isEditing,
                  "${schooldata["schoolwebsite"] ?? 'N/A'}",
                ),
                buildEditableRow(
                  'Affiliation',
                  schoolAffiliationController,
                  isEditing,
                  "${schooldata["schoolaffiliation"] ?? 'N/A'}",
                ),
                SizedBox(
                  height: 30,
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

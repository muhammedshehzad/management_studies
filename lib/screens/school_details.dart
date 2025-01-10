import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future _pickImage() async {
    final returnedSchoolImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnedSchoolImage != null) {
      setState(() {
        temporaryImage = File(returnedSchoolImage.path);
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const CircularProgressIndicator() as SnackBar);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected.')),
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

  Future<void> updateSchool(String schoolId) async {
    try {
      final currentData = await _db.collection("School").doc("9NekuNXmyxdNxWekn282").get();

      if (currentData.exists) {
        final lasturl = currentData.data()?['url'] ?? "null";

        final updatedSchoolData = {
          "schoolname": schoolNameController.text,
          "schooltype": schoolTypeController.text,
          "schoollocation": schoolLocationController.text,
          "schoolcontact": schoolContactController.text,
          "schoolwebsite": schoolWebsiteController.text,
          "schoolaffiliation": schoolAffiliationController.text,
          "url": selectedNewImage != null ? selectedNewImage!.path : lasturl,
        };

        await _db.collection("School").doc("9NekuNXmyxdNxWekn282").update(updatedSchoolData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("School details updated successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch existing school data.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update School data.")),
      );
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
    print("User role: ${widget.role}");

    setState(() {
      schoolid = uid;
    });
    super.initState();
  }

  Future<void> _loadImage() async {
    final path = await getImagePath();
    if (path != null && mounted) {
      setState(() {
        selectedNewImage = File(path);
      });
    } else {
      final snapshot = await FirebaseFirestore.instance
          .collection('School')
          .doc('9NekuNXmyxdNxWekn282')
          .get();

      if (snapshot.exists) {
        final url = snapshot['url'];
        if (url != null) {
          setState(() {
            selectedNewImage = File(url);
          });
        }
      }
    }
  }

  bool _controllersInitialized = false;

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
                    height: MediaQuery.of(context).size.height*.475,
                    width: MediaQuery.of(context).size.width*.95,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      shape: BoxShape.rectangle,
                      border: Border.all(color: Colors.black, width: 1),
                      image: DecorationImage(
                        image:

                                     FileImage(File(schooldata['url'] ?? "")),
                        // temporaryImage != null
                                    // : NetworkImage(schooldata['url'] ?? '')
                                    //     as ImageProvider,
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
                              if (user != null) {
                                if (temporaryImage != null) {
                                  selectedNewImage = temporaryImage;
                                  await saveImagePath(selectedNewImage!.path);
                                } else {}
                                await updateSchool(user.uid);
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
                  'lib/assets/schoolname.png',
                  'Name',
                  schoolNameController,
                  isEditing,
                  schooldata["schoolname"] ?? 'N/A',
                ),
                buildEditableRow(
                  'lib/assets/schooltypee.png',
                  'Type',
                  schoolTypeController,
                  isEditing,
                  schooldata["schooltype"] ?? 'N/A',
                ),
                buildEditableRow(
                  'lib/assets/schoollocation.png',
                  'Location',
                  schoolLocationController,
                  isEditing,
                  schooldata["schoollocation"] ?? 'N/A',
                ),
                buildEditableRow(
                  'lib/assets/schoolcontact.png',
                  'Contact',
                  schoolContactController,
                  isEditing,
                  "${schooldata["schoolcontact"] ?? 'N/A'}",
                ),
                buildEditableRow(
                  'lib/assets/schoolwebsite.png',
                  'Website',
                  schoolWebsiteController,
                  isEditing,
                  "${schooldata["schoolwebsite"] ?? 'N/A'}",
                ),
                buildEditableRow(
                  'lib/assets/schoolaffiliate.png',
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
                    ? TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                        controller: controller,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w400),
                      )
                    : Text(
                        details,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w400),
                      ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

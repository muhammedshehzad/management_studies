import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class HomeworkDetails extends StatefulWidget {
  final String docId;

  const HomeworkDetails({super.key, required this.docId});

  @override
  State<HomeworkDetails> createState() => _HomeworkDetailsState();
}

class _HomeworkDetailsState extends State<HomeworkDetails> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String fileName = '';
  List<XFile> pickedFiles = [];
  String? imageurl;

  Future<DocumentSnapshot<Map<String, dynamic>>> fetchDetails() async {
    return firestore.collection('homeworks').doc(widget.docId).get();
  }

  Future<List<XFile>> insertFiles(BuildContext context) async {
    final picker = ImagePicker();
    final List<XFile>? selectedFiles = await picker.pickMultiImage();
    if (selectedFiles != null && selectedFiles.isNotEmpty) {
      return selectedFiles;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No images selected')),
      );
      return [];
    }
  }

  Future<void> _uploadImage(String docId) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/dfcehequr/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'images'
      ..files.add(await http.MultipartFile.fromPath('file', imageurl!));
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = jsonDecode(responseString);

      setState(() {
        imageurl = jsonMap['url'];
      });

      final homeworkDoc =
          await firestore.collection('homeworks').doc(docId).get();
      List<String> currentImageUrls = [];
      if (homeworkDoc.exists) {
        final data = homeworkDoc.data()!;
        var existingUrls = data['imageurl'];
        if (existingUrls is List) {
          currentImageUrls = List<String>.from(existingUrls);
        } else if (existingUrls is String) {
          currentImageUrls = [existingUrls];
        }
      }

      currentImageUrls.add(imageurl!);

      await firestore.collection('homeworks').doc(docId).update({
        'imageurl': currentImageUrls,
      });
    } else {
      print("Failed to upload image. Status code: ${response.statusCode}");
    }
  }

  Future<void> addNewImageToList() async {
    List<XFile> newFiles = await insertFiles(context);
    if (newFiles.isNotEmpty) {
      for (var file in newFiles) {
        imageurl = file.path;

        if (pickedFiles.isNotEmpty &&
            pickedFiles.any((item) => item.path == imageurl)) {
          return;
        }

        await _uploadImage(widget.docId);

        if (imageurl != null) {
          setState(() {
            pickedFiles.add(XFile(imageurl!));
          });
        }
      }
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Homework Details"),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: fetchDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'No data found.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          List<String> imageList = [];
          final data = snapshot.data!.data()!;
          var imageUrls = data['imageurl'];
          if (imageUrls is List) {
            imageList = imageUrls.whereType<String>().toList();
          } else if (imageUrls is String) {
            imageList = [imageUrls];
          }

          List<String> allImageUrls = [];

          allImageUrls.addAll(imageList);

          for (var file in pickedFiles) {
            if (file.path.startsWith('http')) {
              if (!allImageUrls.contains(file.path)) {
                allImageUrls.add(file.path);
              }
            } else {
              if (!allImageUrls.contains(file.path)) {
                allImageUrls.add(file.path);
              }
            }
          }
          Future<void> deleteImageFromFirestore(String imageUrl) async {
            try {
              final docRef = FirebaseFirestore.instance
                  .collection('homeworks')
                  .doc(widget.docId);

              final docSnapshot = await docRef.get();
              final data = docSnapshot.data();
              if (data != null && data['imageurl'] != null) {
                List<dynamic> imageUrls = List.from(data['imageurl']);

                imageUrls.remove(imageUrl);

                await docRef.update({
                  'imageurl': imageUrls,
                });
              }
            } catch (e) {
              print("Error deleting image: $e");
            }
          }

          final sections = [
            [
              CustomRow2("Subject", data['subject'] ?? 'N/A'),
              CustomRow2("Title", data['title'] ?? 'N/A'),
              CustomRow2(
                "Deadline",
                (data['deadline'] != null && data['deadline'] is Timestamp)
                    ? DateFormat('dd-MM-yyyy').format(
                        (data['deadline'] as Timestamp).toDate().toLocal())
                    : 'N/A',
              ),
              CustomRow2("Status", data['status'] ?? 'N/A'),
              CustomRow2("AssignedBy", data['assignedby'] ?? 'N/A'),
              CustomRow2("Estimated Time", data['estimatedtime'] ?? 'N/A'),
              SizedBox(
                height: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        'Upload Image attachments:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          if (allImageUrls.isNotEmpty)
                            ...allImageUrls.map((url) {
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: url.startsWith('http')
                                        ? Image.network(
                                            url,
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            File(url),
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  Positioned(
                                    top: -10,
                                    right: -10,
                                    child: IconButton(
                                      onPressed: () async {
                                        String imageUrlToDelete = url;
                                        await deleteImageFromFirestore(
                                            imageUrlToDelete);

                                        setState(() {
                                          allImageUrls.remove(imageUrlToDelete);
                                        });
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.redAccent.shade400,
                                      ),
                                      tooltip: 'Delete Image',
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          GestureDetector(
                            onTap: addNewImageToList,
                            child: Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.blueGrey.shade400),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade200,
                              ),
                              child: Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: Colors.blueGrey.shade400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              CustomRow2("Description", data['description'] ?? 'N/A'),
              SizedBox(height: 16),
              Text(
                'Progress:',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.blueGrey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: .7,
                backgroundColor: Colors.grey[300],
                color: Colors.green,
              ),
            ],
          ];

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: sections.length + 1,
            itemBuilder: (context, index) {
              if (index == sections.length) {
                return null;
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildSection(children: sections[index]),
              );
            },
          );
        },
      ),
    );
  }
}

Widget _buildSection({required List<Widget> children}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade300,
          blurRadius: 6,
          spreadRadius: 2,
        ),
      ],
    ),
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );
}

Widget CustomRow2(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${label}:',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Colors.blueGrey[600],
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: Colors.blueGrey[800],
          ),
          overflow: TextOverflow.fade,
        ),
      ],
    ),
  );
}

Widget CustomRow(String label1, String value1, String label2, String value2) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label1: $value1',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.blueGrey[700],
          ),
        ),
        Text(
          '$label2: $value2',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: label2.toLowerCase() == "status" &&
                    value2.toLowerCase() == "passed"
                ? Colors.green
                : Colors.red,
          ),
        ),
      ],
    ),
  );
}

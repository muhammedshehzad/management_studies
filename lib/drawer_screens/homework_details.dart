import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class HomeworkDetailsPage extends StatefulWidget {
  final String docId;

  const HomeworkDetailsPage({super.key, required this.docId});

  @override
  State<HomeworkDetailsPage> createState() => _HomeworkDetailsPageState();
}

class _HomeworkDetailsPageState extends State<HomeworkDetailsPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String fileName = '';
  List<XFile> pickedFiles = [];
  String? imageurl;
  List<String> allPdfUrls = [];
  List<String> allImageUrls = [];

  Future<DocumentSnapshot<Map<String, dynamic>>> fetchDetails() async {
    return firestore.collection('homeworks').doc(widget.docId).get();
  }

  Future<void> insertFiles(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      List<XFile> selectedFiles = result.files.map((file) {
        return XFile(file.path!);
      }).toList();

      for (var file in selectedFiles) {
        if (file.path.endsWith('.pdf')) {
          await pickPdfAndUpload(file);
        } else {
          await _uploadImage(file);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No files selected')),
      );
    }
  }

  Future<void> _uploadImage(XFile file) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/dfcehequr/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'images'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = jsonDecode(responseString);

      setState(() {
        imageurl = jsonMap['url'];
        allImageUrls.add(imageurl!);
      });

      final homeworkDoc =
      await firestore.collection('homeworks').doc(widget.docId).get();
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

      await firestore.collection('homeworks').doc(widget.docId).update({
        'imageurl': currentImageUrls,
      });
    } else {
      print("Failed to upload image. Status code: ${response.statusCode}");
    }
  }

  Future<void> pickPdfAndUpload(XFile file) async {
    final cloudName = 'dfcehequr';
    final uploadPreset = 'pdfsaver';

    final url = Uri.parse('https://api.cloudinary.com/v1_1/dfcehequr/upload');

    try {
      var request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final responseJson = jsonDecode(responseString);

        String pdfUrl = responseJson['secure_url'];
        final homeworkDoc = await FirebaseFirestore.instance
            .collection('homeworks')
            .doc(widget.docId)
            .get();

        List<String> currentPdfUrls = [];
        if (homeworkDoc.exists) {
          final data = homeworkDoc.data()!;
          var existingUrls = data['pdfUrls'];
          if (existingUrls is List) {
            currentPdfUrls = List<String>.from(existingUrls);
          } else if (existingUrls is String) {
            currentPdfUrls = [existingUrls];
          }
        }
        currentPdfUrls.add(pdfUrl);
        await FirebaseFirestore.instance
            .collection('homeworks')
            .doc(widget.docId)
            .update({
          'pdfUrls': currentPdfUrls,
        });

        setState(() {
          allPdfUrls.add(pdfUrl);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF uploaded successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload PDF')),
        );
      }
    } catch (e) {
      print('Error uploading PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading PDF')),
      );
    }
  }

  Future<void> addNewImageToList() async {
    await insertFiles(context);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Homework Details"),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: firestore.collection('homeworks').doc(widget.docId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('No data found.',
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
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
          List<String> pdfList = [];
          var pdfUrls = data['pdfUrls'];
          if (pdfUrls is List) {
            pdfList = pdfUrls.whereType<String>().toList();
          } else if (pdfUrls is String) {
            pdfList = [pdfUrls];
          }
          List<String> allPdfUrls = [];

          allPdfUrls.addAll(pdfList);

          for (var file in pickedFiles) {
            if (file.path.startsWith('http')) {
              if (!allPdfUrls.contains(file.path)) {
                allPdfUrls.add(file.path);
              }
            } else {
              if (!allPdfUrls.contains(file.path)) {
                allPdfUrls.add(file.path);
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

          Future<void> deletePdfFromFirestore(String pdfUrl) async {
            try {
              final docRef = FirebaseFirestore.instance
                  .collection('homeworks')
                  .doc(widget.docId);

              final docSnapshot = await docRef.get();
              final data = docSnapshot.data();
              if (data != null && data['pdfUrls'] != null) {
                List<dynamic> pdfUrls = List.from(data['pdfUrls']);
                pdfUrls.remove(pdfUrl);
                await docRef.update({
                  'pdfUrls': pdfUrls,
                });
              }
            } catch (e) {
              print("Error deleting PDF: $e");
            }
          }

          Widget buildPhotoView(String url) {
            return Scaffold(
              // appBar: AppBar(
              //   elevation: 0,
              //   automaticallyImplyLeading: true,
              // ),
              body: Center(
                child: SizedBox(
                  height: double.infinity,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      PhotoView(
                        imageProvider: url.startsWith('http')
                            ? NetworkImage(url)
                            : FileImage(File(url)) as ImageProvider,
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 2.0,
                        backgroundDecoration: const BoxDecoration(
                          color: Colors.transparent,
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
                        'Upload Attachments:',
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
                          // Display images
                          if (allImageUrls.isNotEmpty)
                            ...allImageUrls.map((url) {
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              buildPhotoView(url),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.blueGrey.shade400),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ClipRRect(
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
                                    ),
                                  ),
                                  Positioned(
                                    top: -10,
                                    right: -11,
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
                                        Icons.delete_sharp,
                                        color: Colors.redAccent.shade400,
                                      ),
                                      tooltip: 'Delete Image',
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),

                          // Display PDFs
                          if (allPdfUrls.isNotEmpty)
                            ...allPdfUrls.map((pdfUrl) {
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PDFFF(
                                            docId: widget.docId,
                                          ),
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.blueGrey.shade400),
                                          borderRadius:
                                          BorderRadius.circular(8),
                                          color: Colors.grey.shade200,
                                        ),
                                        child: Icon(
                                          Icons.picture_as_pdf,
                                          size: 42,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: -10,
                                    right: -11,
                                    child: IconButton(
                                      onPressed: () async {
                                        String pdfUrlToDelete = pdfUrl;
                                        await deletePdfFromFirestore(
                                            pdfUrlToDelete);

                                        setState(() {
                                          allPdfUrls.remove(pdfUrlToDelete);
                                        });
                                      },
                                      icon: Icon(
                                        Icons.delete_sharp,
                                        color: Colors.redAccent.shade400,
                                      ),
                                      tooltip: 'Delete PDF',
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),

                          // Add new image button
                          GestureDetector(
                            onTap: addNewImageToList,
                            child: Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.blueGrey.shade400, width: 2),
                                borderRadius: BorderRadius.circular(16),
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
              CustomRow2("Progress", data['progress'] ?? 'Almost Complete'),
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

class PDFFF extends StatefulWidget {
  final String docId;

  const PDFFF({super.key, required this.docId});

  @override
  State<PDFFF> createState() => _PDFFFState();
}

class _PDFFFState extends State<PDFFF> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  Future<String> fetchPdfUrlFromFirestore() async {
    try {
      final homeworkDoc = await FirebaseFirestore.instance
          .collection('homeworks')
          .doc(widget.docId)
          .get();

      if (homeworkDoc.exists) {
        final data = homeworkDoc.data()!;
        var existingUrls = data['pdfUrls'];

        if (existingUrls is List && existingUrls.isNotEmpty) {
          return existingUrls[0];
        } else {
          throw Exception('No PDFs found in Firestore.');
        }
      } else {
        throw Exception('Homework document not found.');
      }
    } catch (e) {
      throw Exception('Error fetching PDF URL from Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<String>(
        future: fetchPdfUrlFromFirestore(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData) {
            final pdfUrl = snapshot.data!;
            return Stack(
              children: [
                SfPdfViewer.network(
                  pdfUrl,
                  key: _pdfViewerKey,
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.close,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            );
          }

          return Center(child: Text('No PDF URL available.'));
        },
      ),
    );
  }
}
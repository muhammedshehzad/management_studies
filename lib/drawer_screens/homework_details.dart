import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
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
  Set<String> _loadingFiles = {};

  Future<DocumentSnapshot<Map<String, dynamic>>> fetchDetails() async {
    return firestore.collection('homeworks').doc(widget.docId).get();
  }

  Future<void> insertFiles(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      List<XFile> selectedFiles =
          result.files.map((file) => XFile(file.path!)).toList();

      for (var file in selectedFiles) {
        setState(() {
          _loadingFiles.add(file.path);
        });

        if (file.path.endsWith('.pdf')) {
          await pickPdfAndUpload(file);
        } else {
          await _uploadImage(file);
        }

        setState(() {
          _loadingFiles.remove(file.path);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No files selected'),
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
        pickedFiles.add(file);
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
    final url = Uri.parse('https://api.cloudinary.com/v1_1/dfcehequr/upload');
    try {
      var request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = 'pdfsaver'
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final responseJson = jsonDecode(responseString);

        String pdfUrl = responseJson['secure_url'];
        final homeworkDoc =
            await firestore.collection('homeworks').doc(widget.docId).get();

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
        await firestore.collection('homeworks').doc(widget.docId).update({
          'pdfUrls': currentPdfUrls,
        });

        setState(() {
          allPdfUrls.add(pdfUrl);
          pickedFiles.add(file);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF uploaded successfully'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(10),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green.shade500,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload PDF'),
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
    } catch (e) {
      print('Error uploading PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading PDF'),
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

  Future<void> addNewImageToList() async {
    await insertFiles(context);
  }

  List<String> _parseUrls(dynamic urls) {
    if (urls is List) {
      return urls.whereType<String>().toList();
    } else if (urls is String) {
      return [urls];
    }
    return [];
  }

  List<String> _mergeUrls(
      List<String> firestoreUrls, List<dynamic> pickedFiles, String type) {
    final allUrls = List<String>.from(firestoreUrls);
    for (var file in pickedFiles) {
      if (!allUrls.contains(file.path)) {
        allUrls.add(file.path);
      }
    }
    return allUrls;
  }

  Future<void> _deleteFile(String url, String fieldName) async {
    try {
      final docRef = firestore.collection('homeworks').doc(widget.docId);
      final docSnapshot = await docRef.get();
      final data = docSnapshot.data();
      if (data != null && data[fieldName] != null) {
        final urls = List.from(data[fieldName])..remove(url);
        await docRef.update({fieldName: urls});
      }
    } catch (e) {
      print("Error deleting file: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Homework Details"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream:
              firestore.collection('homeworks').doc(widget.docId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: TextStyle(color: Colors.red[700]),
                ),
              );
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(
                child: Text(
                  'No data found.',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }

            final data = snapshot.data!.data()!;
            final imageList = _parseUrls(data['imageurl']);
            final pdfList = _parseUrls(data['pdfUrls']);
            final allImageUrls = _mergeUrls(imageList, pickedFiles, 'image');
            final allPdfUrls = _mergeUrls(pdfList, pickedFiles, 'pdf');

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Info Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 120,
                                child: Text(
                                  "Subject",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey[700],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  data['subject'] ?? 'N/A',
                                  style: TextStyle(color: Colors.grey[800]),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 120,
                                child: Text(
                                  "Title",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey[700],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  data['title'] ?? 'N/A',
                                  style: TextStyle(color: Colors.grey[800]),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 120,
                                child: Text(
                                  "Deadline",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey[700],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  (data['deadline'] is Timestamp)
                                      ? DateFormat('dd-MM-yyyy').format(
                                          (data['deadline'] as Timestamp)
                                              .toDate())
                                      : 'N/A',
                                  style: TextStyle(color: Colors.grey[800]),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 120,
                                child: Text(
                                  "Status",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey[700],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  data['status'] ?? 'N/A',
                                  style: TextStyle(color: Colors.grey[800]),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 120,
                                child: Text(
                                  "Assigned By",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey[700],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  data['assignedby'] ?? 'N/A',
                                  style: TextStyle(color: Colors.grey[800]),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 120,
                                child: Text(
                                  "Estimated Time",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey[700],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  data['estimatedtime'] ?? 'N/A',
                                  style: TextStyle(color: Colors.grey[800]),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 120,
                                child: Text(
                                  "Progress",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey[700],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  data['progress'] ?? 'Almost Complete',
                                  style: TextStyle(color: Colors.grey[800]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Attachments",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[800],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            ...allImageUrls.map((url) {
                              final isLoading = _loadingFiles.contains(url);
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  GestureDetector(
                                    onTap: isLoading
                                        ? null
                                        : () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => Scaffold(
                                                  body: Stack(
                                                    children: [
                                                      PhotoView(
                                                        imageProvider: url
                                                                .startsWith(
                                                                    'http')
                                                            ? NetworkImage(url)
                                                            : FileImage(
                                                                    File(url))
                                                                as ImageProvider,
                                                        minScale:
                                                            PhotoViewComputedScale
                                                                .contained,
                                                        maxScale:
                                                            PhotoViewComputedScale
                                                                    .covered *
                                                                2.0,
                                                        backgroundDecoration:
                                                            const BoxDecoration(
                                                                color: Colors
                                                                    .black),
                                                      ),
                                                      SafeArea(
                                                        child: IconButton(
                                                          icon: const Icon(
                                                              Icons.close,
                                                              color:
                                                                  Colors.white),
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.blueGrey[300]!),
                                        borderRadius: BorderRadius.circular(8),
                                        color:
                                            isLoading ? Colors.grey[300] : null,
                                      ),
                                      child: isLoading
                                          ? Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.blueGrey[400],
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: url.startsWith('http')
                                                  ? Image.network(url,
                                                      fit: BoxFit.cover)
                                                  : Image.file(File(url),
                                                      fit: BoxFit.cover),
                                            ),
                                    ),
                                  ),
                                  if (!isLoading)
                                    Positioned(
                                      top: -10,
                                      right: -10,
                                      child: IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.red[400], size: 20),
                                        onPressed: () {
                                          _deleteFile(url, 'imageurl');
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                ],
                              );
                            }),
                            ...allPdfUrls.map((url) {
                              final isLoading = _loadingFiles.contains(url);
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  GestureDetector(
                                    onTap: isLoading
                                        ? null
                                        : () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) => PDFFF(
                                                      docId: widget.docId)),
                                            ),
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.blueGrey[300]!),
                                        borderRadius: BorderRadius.circular(8),
                                        color: isLoading
                                            ? Colors.grey[300]
                                            : Colors.grey[200],
                                      ),
                                      child: isLoading
                                          ? Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.blueGrey[400],
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Icon(Icons.picture_as_pdf,
                                              size: 42, color: Colors.blueGrey),
                                    ),
                                  ),
                                  if (!isLoading)
                                    Positioned(
                                      top: -10,
                                      right: -10,
                                      child: IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.red[400], size: 20),
                                        onPressed: () {
                                          _deleteFile(url, 'pdfUrls');
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                ],
                              );
                            }),
                            GestureDetector(
                              onTap: addNewImageToList,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.blueGrey[400]!, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[200],
                                ),
                                child: Icon(Icons.add,
                                    size: 40, color: Colors.blueGrey[400]),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Description Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Description",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['description'] ?? 'N/A',
                          style: TextStyle(color: Colors.grey[800]),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
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

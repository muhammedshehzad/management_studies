import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import '../pdf_converter/pdf.dart';

class StudentDetails extends StatefulWidget {
  final String docId;

  const StudentDetails({super.key, required this.docId});

  @override
  State<StudentDetails> createState() => _StudentDetailsState();
}

class _StudentDetailsState extends State<StudentDetails> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>> fetchDetails() async {
    return firestore.collection('records').doc(widget.docId).get();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Details"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () async {
                final snapshot = await fetchDetails();
                final data = snapshot.data()!;

                final studentData = {
                  'name': data['name'] ?? 'N/A',
                  'email': data['email'] ?? 'N/A',
                  'regno': data['regno'] ?? 'N/A',
                  'academicyear': data['academicyear'] ?? 'N/A',
                  'admno': data['admno'] ?? 'N/A',
                  'admdate': data['admdate'] ?? 'N/A',
                  'department': data['department'] ?? 'N/A',
                  'hod': data['hod'] ?? 'N/A',
                  'fathername': data['fathername'] ?? 'N/A',
                  'fatherjob': data['fatherjob'] ?? 'N/A',
                  'fatherphone': data['fatherphone'] ?? 'N/A',
                  'mothername': data['mothername'] ?? 'N/A',
                  'motherjob': data['motherjob'] ?? 'N/A',
                  'motherphone': data['motherphone'] ?? 'N/A',
                  'score': "${data['score'] ?? 0}",
                  'percentage': "${data['percentage'] ?? 0}",
                  'grade': data['grade'] ?? 'N/A',
                  'status': data['status'] ?? 'N/A',
                };

                final pdfFile = await PdfApi.generateStudentPdf(studentData);
                await PdfApi.openFile(pdfFile);
              },
              icon: SizedBox(
                height: 30,
                width: 30,
                child: Image.asset('lib/assets/pdf.png'),
              ),),
        ],
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
                'No record found.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final data = snapshot.data!.data()!;

          final sections = [
            [
              CustomRow2("Name", data['name'] ?? 'N/A'),
              CustomRow2("Email", data['email'] ?? 'N/A'),
            ],
            [
              CustomRow2("Registration Number", data['regno'] ?? 'N/A'),
              CustomRow2("Academic Year", data['academicyear'] ?? 'N/A'),
              CustomRow2("Admission Number", data['admno'] ?? 'N/A'),
              CustomRow2("Date of Admission", data['admdate'] ?? 'N/A'),
            ],
            [
              CustomRow2("Department", data['department'] ?? 'N/A'),
              CustomRow2("HOD", data['hod'] ?? 'N/A'),
            ],
            [
              CustomRow2("Father's Name", data['fathername'] ?? 'N/A'),
              CustomRow2("Occupation", data['fatherjob'] ?? 'N/A'),
              CustomRow2("Phone", data['fatherphone'] ?? 'N/A'),
            ],
            [
              CustomRow2("Mother's Name", data['mothername'] ?? 'N/A'),
              CustomRow2("Occupation", data['motherjob'] ?? 'N/A'),
              CustomRow2("Phone", data['motherphone'] ?? 'N/A'),
            ],
            [
              CustomRow("Score", "${data['score'] ?? 0}/1200", "Percentage",
                  "${data['percentage'] ?? 0}%"),
              CustomRow("Grade", data['grade'] ?? 'N/A', "Status",
                  data['status'] ?? 'N/A'),
            ],
          ];

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: sections.length + 1,
            itemBuilder: (context, index) {
              if (index == sections.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xff3e948e),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Close',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
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
    child: Column(children: children),
  );
}

Widget CustomRow2(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 13,
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
          overflow: TextOverflow.ellipsis,

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

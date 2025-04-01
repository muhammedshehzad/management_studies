import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:new_school/isar_storage/academic_records_model.dart';
import '../isar_storage/isar_user_service.dart';
import '../pdf_converter/pdf.dart';

class StudentDetails extends StatefulWidget {
  final String docId;
  final bool isOffline;

  const StudentDetails({
    super.key,
    required this.docId,
    this.isOffline = false,
  });

  State<StudentDetails> createState() => _StudentDetailsState();
}

class _StudentDetailsState extends State<StudentDetails> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> fetchDetails() async {
    if (widget.isOffline) {
      final student = await IsarUserService.isar!.studentDetailModels
          .where()
          .uidEqualTo(widget.docId)
          .findFirst();

      if (student == null) {
        throw Exception('Student record not found');
      }

      return {
        'name': student.name,
        'email': student.email,
        'regno': student.registerNumber,
        'academicyear': student.academicYear,
        'admno': student.admissionNumber,
        'admdate': student.admissionDate,
        'department': student.department,
        'hod': student.hod,
        'fathername': student.fatherName,
        'fatherjob': student.fatherOccupation,
        'fatherphone': student.fatherPhone,
        'mothername': student.motherName,
        'motherjob': student.motherOccupation,
        'motherphone': student.motherPhone,
        'score': student.score,
        'percentage': student.percentage,
        'grade': student.grade,
        'status': student.status,
      };
    } else {
      final doc = await firestore.collection('records').doc(widget.docId).get();
      if (!doc.exists) {
        throw Exception('Student record not found');
      }
      return doc.data()!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Details"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              final data = await fetchDetails();

              String admissionDate;
              if (data['admdate'] is Timestamp) {
                admissionDate = DateFormat('dd-MM-yyyy')
                    .format((data['admdate'] as Timestamp).toDate());
              } else if (data['admdate'] is String) {
                admissionDate = data['admdate'];
              } else if (data['admdate'] is DateTime) {
                admissionDate = DateFormat('dd-MM-yyyy')
                    .format(data['admdate'] as DateTime);
              } else {
                admissionDate = 'N/A';
              }

              final studentData = {
                'name': data['name'] ?? 'N/A',
                'email': data['email'] ?? 'N/A',
                'regno': data['regno'] ?? 'N/A',
                'academicyear': data['academicyear'] ?? 'N/A',
                'admno': data['admno'] ?? 'N/A',
                'admdate': admissionDate,
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
            ),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'No record found.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final data = snapshot.data!;

          final sections = [
            [
              CustomRow2("Name", data['name'] ?? 'N/A'),
              CustomRow2("Email", data['email'] ?? 'N/A'),
            ],
            [
              CustomRow2("Registration Number", data['regno'] ?? 'N/A'),
              CustomRow2("Academic Year", data['academicyear'] ?? 'N/A'),
              CustomRow2("Admission Number", data['admno'] ?? 'N/A'),
              CustomRow2(
                  "Date of Admission",
                  data['admdate'] is Timestamp
                      ? DateFormat('dd-MM-yyyy')
                          .format((data['admdate'] as Timestamp).toDate())
                      : data['admdate'] is DateTime
                          ? DateFormat('dd-MM-yyyy')
                              .format(data['admdate'] as DateTime)
                          : data['admdate']?.toString() ?? 'N/A'),
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

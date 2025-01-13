import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../pdf_converter/pdf.dart';

class HomeworkDetails extends StatefulWidget {
  final String docId;

  const HomeworkDetails({super.key, required this.docId});

  @override
  State<HomeworkDetails> createState() => _HomeworkDetailsState();
}

class _HomeworkDetailsState extends State<HomeworkDetails> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>> fetchDetails() async {
    return firestore.collection('homeworks').doc(widget.docId).get();
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

          final data = snapshot.data!.data()!;

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
              CustomRow2("Description", data['description'] ?? 'N/A'),
              SizedBox(height: 10),
              Text(
                'Progress:',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.blueGrey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 6),
              LinearProgressIndicator(
                value: .7,
                backgroundColor: Colors.grey[300],
                color: Colors.green,
              ),
              SizedBox(height: 10),
            ],
          ];
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: sections.length + 1,
            itemBuilder: (context, index) {
              if (index == sections.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    height: 46,
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

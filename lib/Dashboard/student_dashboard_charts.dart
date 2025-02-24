import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<String?> fetchLatestAcademicYear() async {
  QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('records').get();
  if (querySnapshot.docs.isEmpty) return null;

  List<String> academicYears = querySnapshot.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    return data['academicyear'] as String;
  }).toList();

  academicYears.sort();
  return academicYears.last;
}

class LeaderboardList extends StatelessWidget {
  const LeaderboardList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blueGrey.shade700,
            Colors.blueGrey.shade300,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<String?>(
            future: fetchLatestAcademicYear(),
            builder: (context, snapshot) {
              String academicYearText =
                  snapshot.hasData && snapshot.data != null
                      ? snapshot.data!
                      : "Unknown";
              return Text(
                "Top 5 Students of Year $academicYearText",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchTopStudents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "No top students available",
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }
                final students = snapshot.data!;
                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    var student = students[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: index == 0
                              ? Colors.amber
                              : (index == 1
                                  ? Colors.grey
                                  : (index == 2
                                      ? Colors.brown.shade400
                                      : const Color(0xFF90CAF9))),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        title: Text(
                          student['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Grade: ${student['grade']} | Score: ${student['score']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<double?> fetchAttendanceForCurrentUser() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;

  String currentUserId = user.uid;

  QuerySnapshot notificationsSnapshot = await FirebaseFirestore.instance
      .collection('Leaves')
      .where('status', isEqualTo: 'Approved')
      .where('userId', isEqualTo: currentUserId)
      .get();

  int approvedLeaves = notificationsSnapshot.docs.length;

  double attendance = 100 - ((approvedLeaves / 80) * 100);

  return attendance;
}

Future<List<Map<String, dynamic>>> fetchTopStudents() async {
  List<String> gradePriority = [
    'A+',
    'A',
    'B+',
    'B',
    'C+',
    'C',
    'D',
    'D+',
    'E'
  ];

  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('records')
      .orderBy('score', descending: true)
      .get();

  List<Map<String, dynamic>> students = [];

  for (String grade in gradePriority) {
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data['grade'] == grade) {
        students.add(data);
      }
      if (students.length >= 5) break;
    }
    if (students.length >= 5) break;
  }

  return students;
}

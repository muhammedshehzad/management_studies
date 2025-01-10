import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_school/drawer_screens/student_details.dart';

class HomeworkAssignmentsScreen extends StatefulWidget {
  @override
  State<HomeworkAssignmentsScreen> createState() =>
      _HomeworkAssignmentsScreenState();
}

class _HomeworkAssignmentsScreenState extends State<HomeworkAssignmentsScreen> {
  Query? query;
  String searchtext = '';
  final TextEditingController Search = TextEditingController();

  @override
  void initState() {
    super.initState();
    query = FirebaseFirestore.instance.collection('homeworks');
  }

  void Seacrhh(String query) {
    setState(() {
      searchtext = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Homework and Assignments'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Padding(
                //   padding: const EdgeInsets.only(left: 8.0),
                //   child: Text(
                //     'Homeworks & Assignments',
                //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                //   ),
                // ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),
                  child: TextField(
                    controller: Search,
                    onChanged: Seacrhh,
                    decoration: InputDecoration(
                      hintText: 'Search homeworks',
                      filled: true,
                      fillColor: Colors.blueGrey.shade50,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: query?.snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            'No records found.',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        );
                      }

                      final allRecords = snapshot.data!.docs;
                      final filteredRecords = allRecords.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final subject =
                            data['subject']?.toString().toLowerCase() ?? '';
                        final title =
                            data['title']?.toString().toLowerCase() ?? '';
                        final deadline = (data['deadline'] as Timestamp?)
                                ?.toDate()
                                .toString() ??
                            '';
                        final status =
                            data['status']?.toString().toLowerCase() ?? '';
                        final matchesSearch = searchtext.isEmpty ||
                            subject.contains(searchtext) ||
                            title.contains(searchtext) ||
                            status.contains(searchtext) ||
                            deadline.contains(searchtext);

                        return matchesSearch;
                      }).toList();

                      if (filteredRecords.isEmpty) {
                        return const Center(
                          child: Text(
                            'No matching records found.',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: filteredRecords.length,
                        itemBuilder: (context, index) {
                          final record = filteredRecords[index];
                          final data = record.data() as Map<String, dynamic>;
                          final subject = data['subject'] ?? 'N/A';
                          final title = data['title'] ?? 'No title';
                          final deadline =
                              (data['deadline'] as Timestamp?)?.toDate() ??
                                  DateTime.now();
                          final formattedDeadline =
                              DateFormat('dd-MM-yyyy').format(deadline);
                          final status = data['status'] ?? 'No status';

                          return CustomStudentTile(
                            subject,
                            title,
                            formattedDeadline,
                            status,
                            () {
                              // Handle onTap here
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 12,
            left: 8,
            right: 8,
            child: Container(
              height: 40,
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xff3e948e),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomeWorkDetails()));
                },
                child: const Text(
                  'Add data',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomStudentTile extends StatelessWidget {
  const CustomStudentTile(
      this.subject, this.title, this.deadline, this.status, this.ontap);

  final String subject;
  final String title;
  final String deadline;
  final String status;
  final void Function() ontap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: .5,
      child: ListTile(
        onTap: ontap,
        title: Text(subject,
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        subtitle: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            '${title}',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: Colors.black54,
            ),
            overflow: TextOverflow.clip,
          ),
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Deadline: ${deadline}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            SizedBox(
              height: 5,
            ),
            Text(
              status,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeWorkDetails extends StatefulWidget {
  HomeWorkDetails({super.key});

  @override
  State<HomeWorkDetails> createState() => _HomeWorkDetailsState();
}

class _HomeWorkDetailsState extends State<HomeWorkDetails> {
  TextEditingController _subject = TextEditingController();

  TextEditingController _title = TextEditingController();

  TextEditingController _deadlines = TextEditingController();

  TextEditingController _status = TextEditingController();

  Future<void> _submitnewData() async {
    final subject = _subject.text;
    final title = _title.text;
    final deadline = _deadlines.text;
    final status = _status.text;

    if (status.isEmpty ||
        deadline.isEmpty ||
        title.isEmpty ||
        subject.isEmpty) {
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final deadlines = DateFormat('dd-MM-yyyy').parse(deadline);
        final deadlineTimestamp = Timestamp.fromDate(deadlines);
        await FirebaseFirestore.instance.collection('homeworks').add({
          'status': status,
          'subject': subject,
          'title': title,
          'deadline': deadlineTimestamp,
        });

        Navigator.pop(context);
      }
    } catch (error) {
      print('Error adding data: $error');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error adding data')));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2050),
    );
    if (selectedDate != null && selectedDate != DateTime.now()) {
      setState(() {
        final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
        _deadlines.text = dateFormat.format(selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Homework details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
          child: Column(
            children: [
              TextField(
                controller: _subject,
                decoration: const InputDecoration(labelText: 'Subject'),
              ),
              TextField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _deadlines,
                decoration: const InputDecoration(labelText: 'Deadline'),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              TextField(
                controller: _status,
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xff3e948e),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: _submitnewData,
                    child: const Text(
                      'Submit',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

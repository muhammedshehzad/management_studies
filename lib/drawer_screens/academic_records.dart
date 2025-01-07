import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_school/drawer_screens/student_details.dart';

class AcademicRecords extends StatefulWidget {
  const AcademicRecords({super.key});

  @override
  State<AcademicRecords> createState() => _AcademicRecordsState();
}

class _AcademicRecordsState extends State<AcademicRecords> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController SearchBar = TextEditingController();
  String searchtext = '';
  String _filterGrade = 'All';

  Stream<QuerySnapshot<Map<String, dynamic>>> records() {
    return firestore.collection('records').snapshots();
  }

  void SeachName(String query) {
    setState(() {
      searchtext = query.toLowerCase();
    });
  }

  void _updateFilter(String grade) {
    setState(() {
      _filterGrade = grade;
    });
  }

  @override
  Widget build(BuildContext context) {
    final recordStream = records();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Records'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _updateFilter,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All Grades')),
              const PopupMenuItem(value: 'E', child: Text('All Failed')),
              const PopupMenuItem(value: 'A+', child: Text('Grade A+')),
              const PopupMenuItem(value: 'A', child: Text('Grade A')),
              const PopupMenuItem(value: 'B+', child: Text('Grade B+')),
              const PopupMenuItem(value: 'B', child: Text('Grade B')),
              const PopupMenuItem(value: 'C+', child: Text('Grade C+')),
              const PopupMenuItem(value: 'C', child: Text('Grade C')),
              const PopupMenuItem(value: 'D+', child: Text('Grade D+')),
              const PopupMenuItem(value: 'D', child: Text('Grade D')),
            ],
            icon: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/assets/filter.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: SearchBar,
              onChanged: SeachName,
              decoration: InputDecoration(
                hintText: 'Search students',
                filled: true,
                fillColor: Colors.blueGrey.shade50,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: recordStream,
              builder: (context, snapshot) {
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
                  final data = doc.data();
                  final name = (data['name'] ?? '').toLowerCase();
                  final email = (data['email'] ?? '').toLowerCase();
                  final grade = (data['grade'] ?? '');

                  final matchesSearch =
                      name.contains(searchtext) || email.contains(searchtext);

                  final matchesFilter =
                      _filterGrade == 'All' || grade == _filterGrade;

                  return matchesSearch && matchesFilter;
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
                    final data = filteredRecords[index].data();
                    final status = data['status'] ?? 'N/A';
                    final name = data['name'] ?? 'No name';
                    final email = data['email'] ?? 'No email';
                    final score = num.tryParse(data['score'].toString()) ?? 0;
                    final percentage =
                        num.tryParse(data['percentage'].toString()) ?? 0;
                    final grade = data['grade'] ?? 'N/A';
                    final academicyear = data['academicyear'] ?? 'N/A';
                    final department = data['department'] ?? 'N/A';
                    final fatherjob = data['fatherjob'] ?? 'N/A';
                    final fathername = data['fathername'] ?? 'N/A';
                    final fatherphone = data['fatherphone'] ?? 'N/A';
                    final hod = data['hod  '] ?? 'N/A';
                    final motherjob = data['motherjob'] ?? 'N/A';
                    final mothername = data['mothername'] ?? 'N/A';
                    final motherphone = data['motherphone'] ?? 'N/A';
                    final regno = data['regno'] ?? 'N/A';

                    return CustomStudentTile(
                      status,
                      name,
                      email,
                      score,
                      percentage,
                      grade,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentDetails(docId: record.id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            child: Container(
              height: 40,
              width: 400,
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
                          builder: (context) => FormViewStudentsMark()));
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
    this.status,
    this.name,
    this.email,
    this.score,
    this.percentage,
    this.grade,
    this.ontap,
  );

  final String status;
  final String name;
  final String email;
  final num score;
  final num percentage;
  final String grade;
  final void Function() ontap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0),
      child: Card(
        elevation: .5,
        child: ListTile(
          onTap: ontap,
          leading: CircleAvatar(
            radius: 23,
            backgroundColor: Colors.blueGrey.shade300,
            child: Text(
              status,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                  color: Colors.black87),
            ),
          ),
          title: Text(name, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black87)),
          subtitle:  Flexible(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                '${email}',
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.black54,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${score}/1200',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5)),
              Text("${percentage}%",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5)),
              Text('Grade: ${grade}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class FormViewStudentsMark extends StatefulWidget {
  const FormViewStudentsMark({super.key});

  @override
  State<FormViewStudentsMark> createState() => _FormViewStudentsMarkState();
}

class _FormViewStudentsMarkState extends State<FormViewStudentsMark> {
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _scoreController = TextEditingController();
  final TextEditingController _percentageController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _academicyear = TextEditingController();
  final TextEditingController _department = TextEditingController();
  final TextEditingController _fatherjob = TextEditingController();
  final TextEditingController _fathername  = TextEditingController();
  final TextEditingController _fatherphone  = TextEditingController();
  final TextEditingController _hod  = TextEditingController();
  final TextEditingController _motherjob  = TextEditingController();
  final TextEditingController _mothername  = TextEditingController();
  final TextEditingController _motherphone  = TextEditingController();
  final TextEditingController _regno  = TextEditingController();
  final TextEditingController _admno  = TextEditingController();
  final TextEditingController _admdate  = TextEditingController();

  Future<void> _submitData() async {
    final status = _statusController.text;
    final name = _nameController.text;
    final email = _emailController.text;
    final score = _scoreController.text;
    final percentage = _percentageController.text;
    final grade = _gradeController.text;
    final academicyear = _academicyear.text;
    final department = _department.text;
    final fatherjob = _fatherjob.text;
    final fathername = _fathername.text;
    final fatherphone = _fatherphone.text;
    final hod = _hod.text;
    final motherjob = _motherjob.text;
    final mothername = _mothername.text;
    final motherphone = _motherphone.text;
    final regno = _regno.text;
    final admno = _admno.text;
    final admdate = _admdate.text;

    if (status.isEmpty ||
        name.isEmpty ||
        email.isEmpty ||
        score.isEmpty ||
        percentage.isEmpty ||
        grade.isEmpty) {
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final score = num.tryParse(_scoreController.text) ?? 0;
        final percentage = num.tryParse(_percentageController.text) ?? 0;

        await FirebaseFirestore.instance.collection('records').add({
          'status': status,
          'name': name,
          'email': email,
          'score': score,
          'percentage': percentage,
          'grade': grade,
          'academicyear': academicyear,
          'department': department,
          'fatherjob': fatherjob,
          'fathername': fathername,
          'fatherphone': fatherphone,
          'hod': hod,
          'motherjob': motherjob,
          'mothername': mothername,
          'motherphone': motherphone,
          'regno': regno,
          'admno': admno,
          'admdate': admdate,

        });

        Navigator.pop(context);
      }
    } catch (error) {
      print('Error adding data: $error');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error adding data')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Student Data')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _scoreController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Score'),
              ),
              TextField(
                controller: _percentageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Percentage'),
              ),
              TextField(
                controller: _gradeController,
                decoration: const InputDecoration(labelText: 'Grade'),
              ),
              TextField(
                controller: _statusController,
                decoration: const InputDecoration(labelText: 'Status'),
              ), TextField(
                controller: _academicyear,
                decoration: const InputDecoration(labelText: 'Academic Year'),
              ),
              TextField(
                controller: _regno,
                decoration: const InputDecoration(labelText: 'Register Number'),
              ),
              TextField(
                controller: _admno,
                decoration: const InputDecoration(labelText: "Admission Number"),
              ),
              TextField(
                controller: _admdate,
                decoration: const InputDecoration(labelText: "Admission Date"),
              ),

              TextField(
                controller: _department,
                decoration: const InputDecoration(labelText: 'Department'),
              ),
              TextField(
                controller: _hod,
                decoration: const InputDecoration(labelText: 'HOD'),
              ),
              TextField(
                controller: _fathername,
                decoration: const InputDecoration(labelText: 'Name of Father'),
              ),
              TextField(
                controller: _fatherjob,
                decoration: const InputDecoration(labelText: "Father's Occupation"),
              ), TextField(
                controller: _fatherphone,
                decoration: const InputDecoration(labelText: "Father's Phone Number"),
              ),
              TextField(
                controller: _mothername,
                decoration: const InputDecoration(labelText: 'Name of Mother'),
              ),
              TextField(
                controller: _motherjob,
                decoration: const InputDecoration(labelText: "Mother's Occupation"),
              ),
              TextField(
                controller: _motherphone,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Mother's Phone Number"),
              ),

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Container(
                  height: 40,
                  width: 400,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xff3e948e),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: _submitData,
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

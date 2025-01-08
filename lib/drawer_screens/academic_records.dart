import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_school/drawer_screens/student_details.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class AcademicRecords extends StatefulWidget {
  const AcademicRecords({super.key});

  @override
  State<AcademicRecords> createState() => _AcademicRecordsState();
}

class _AcademicRecordsState extends State<AcademicRecords> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController SearchBar = TextEditingController();
  String searchtext = '';
  String _filterGrade = '';
  String currentfilter = 'None';
  String _selectedDate = '';
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';
  String? selectedname;
  Query? query;
  List<dynamic> filteredRecords = [];
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(days: 300));

  Stream<QuerySnapshot<Map<String, dynamic>>> records() {
    return firestore.collection('records').snapshots();
  }

  void fetchDateRecords(DateTime? startDate, DateTime? endDate) {
    FirebaseFirestore.instance
        .collection('records')
        .where('admdate', isGreaterThanOrEqualTo: startDate)
        .where('admdate', isLessThanOrEqualTo: endDate)
        .snapshots()
        .listen((querySnapshot) {
      setState(() {
        querySnapshot.docs.map((doc) => doc.data()).toList();
      });
    });
  }

  void fetchclearquery(DateTime start, DateTime end) {
    setState(() {
      query = FirebaseFirestore.instance
          .collection('records')
          .where('admdate', isGreaterThanOrEqualTo: startDate)
          .where('admdate', isLessThanOrEqualTo: endDate);
    });
    print('Filtered Records: $filteredRecords');
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is PickerDateRange) {
        startDate = args.value.startDate;
        endDate = args.value.endDate ?? args.value.startDate;
        fetchclearquery(startDate, endDate);
        print('$startDate - $endDate ');
      } else if (args.value is DateTime) {
        _selectedDate = args.value.toString();
      } else if (args.value is List<DateTime>) {
        _dateCount = args.value.length.toString();
      } else {
        _rangeCount = args.value.length.toString();
      }
    });
  }

  void clearQuery() {
    setState(() {
      query = FirebaseFirestore.instance.collection('records');
    });
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
        leading: IconButton(
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                    return SizedBox(
                      height: 500,
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Filter By",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Select a filtering method: ",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  DropdownButton<String>(
                                    value: currentfilter,
                                    items: <String>[
                                      'None',
                                      'Student\'s Name',
                                      'Date range',
                                      'Grade',
                                    ].map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        currentfilter = value!;
                                        print(currentfilter);
                                      });
                                    },
                                  ),
                                  Spacer(),
                                  ElevatedButton(
                                      onPressed: () {
                                        clearQuery();
                                      },
                                      child: Text("Clear Filter"))
                                ],
                              ),
                              if (currentfilter == 'None') ...[
                                Container(
                                  height: 250,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey[200],
                                  ),
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Text('No Filter Category Selected'),
                                  ),
                                ),
                              ],
                              if (currentfilter == 'Date range') ...[
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey[200],
                                      ),
                                      padding: const EdgeInsets.all(8.0),
                                      child: SfDateRangePicker(
                                        onSelectionChanged: _onSelectionChanged,
                                        selectionMode:
                                            DateRangePickerSelectionMode.range,
                                        initialSelectedRange: PickerDateRange(
                                          DateTime.now().subtract(
                                              const Duration(days: 6)),
                                          DateTime.now()
                                              .add(const Duration(days: 0)),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        fetchDateRecords(startDate, endDate);
                                        print('$fetchDateRecords');
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Apply Date Filter"),
                                    ),
                                  ],
                                ),
                              ],
                              if (currentfilter == 'Student\'s name') ...[
                                Container(
                                  height: 300,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey[200],
                                  ),
                                  padding: const EdgeInsets.all(8.0),
                                  child: StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection('doctors')
                                        .snapshots(),
                                    builder: (context,
                                        AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }
                                      if (snapshot.hasError) {
                                        // ignore: avoid_print
                                        print(
                                            'Error fetching data: ${snapshot.error}');
                                        return const Center(
                                            child: Text('Error fetching data'));
                                      }

                                      if (snapshot.hasData &&
                                          snapshot.data!.docs.isEmpty) {
                                        return const Center(
                                            child: Text('No Doctors found'));
                                      }
                                      return ListView.builder(
                                          itemCount: snapshot.data!.docs.length,
                                          itemBuilder: (context, index) {
                                            final doctorsdata =
                                                snapshot.data!.docs[index];
                                            final name = doctorsdata['name'];
                                            // final uid = doctorsdata['uid'];
                                            // final type = doctorsdata['type'];
                                            // final url =
                                            // doctorsdata['imageurl'];
                                            // final available =
                                            // doctorsdata['available'];
                                            // final rating =
                                            doctorsdata['rating'];

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5),
                                              child: Material(
                                                elevation: 4,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                child: Card(
                                                  color: const Color.fromARGB(
                                                      136, 79, 34, 153),
                                                  shadowColor:
                                                      const Color.fromARGB(
                                                          24, 99, 69, 155),
                                                  elevation: 15,
                                                  child: ListTile(
                                                      onTap: () {
                                                        print(selectedname);
                                                        setState(() {
                                                          selectedname = name;
                                                          // fetchQuery(
                                                          //     selectedname!);
                                                        });
                                                      },
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 16,
                                                              vertical: 12),
                                                      leading: Text(
                                                        name,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      trailing: CircleAvatar(
                                                        radius: 10,
                                                        child: CircleAvatar(
                                                            radius: 8,
                                                            backgroundColor:
                                                                selectedname ==
                                                                        name
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .black),
                                                      )),
                                                ),
                                              ),
                                            );
                                          });
                                    },
                                  ),
                                ),
                              ],
                              if (currentfilter == 'Grade') ...[
                                GradeFilterButton(
                                  onSelected: (selectedGrade) {
                                    setState(() {
                                      _filterGrade = selectedGrade;
                                    });
                                    print('Selected Grade: $selectedGrade');
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  });
                },
              );
            },
            icon: Icon(Icons.tune)),
        title: const Text('Academic Records'),
        // actions: [
        //   PopupMenuButton<String>(
        //     onSelected: _updateFilter,
        //     itemBuilder: (context) => [
        //       const PopupMenuItem(value: 'All', child: Text('All Grades')),
        //       const PopupMenuItem(value: 'E', child: Text('All Failed')),
        //       const PopupMenuItem(value: 'A+', child: Text('Grade A+')),
        //       const PopupMenuItem(value: 'A', child: Text('Grade A')),
        //       const PopupMenuItem(value: 'B+', child: Text('Grade B+')),
        //       const PopupMenuItem(value: 'B', child: Text('Grade B')),
        //       const PopupMenuItem(value: 'C+', child: Text('Grade C+')),
        //       const PopupMenuItem(value: 'C', child: Text('Grade C')),
        //       const PopupMenuItem(value: 'D+', child: Text('Grade D+')),
        //       const PopupMenuItem(value: 'D', child: Text('Grade D')),
        //     ],
        //     icon: Container(
        //       height: 30,
        //       width: 30,
        //       decoration: BoxDecoration(
        //         image: DecorationImage(
        //           image: AssetImage('lib/assets/filter.png'),
        //           fit: BoxFit.cover,
        //         ),
        //       ),
        //     ),
        //   ),
        // ],
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
            child: StreamBuilder(
              stream: query!.snapshots(),
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
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toLowerCase();
                  final email = (data['email'] ?? '').toLowerCase();

                  // Check if the search text matches the name or email
                  final matchesSearch = searchtext.isEmpty ||
                      name.contains(searchtext.toLowerCase()) ||
                      email.contains(searchtext.toLowerCase());

                  return matchesSearch;
                }).toList();

                if (filteredRecords.isEmpty) {
                  return Center(child: Text('No records found.'));
                }
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

                    // final academicyear = data['academicyear'] ?? 'N/A';
                    // final department = data['department'] ?? 'N/A';
                    // final fatherjob = data['fatherjob'] ?? 'N/A';
                    // final fathername = data['fathername'] ?? 'N/A';
                    // final fatherphone = data['fatherphone'] ?? 'N/A';
                    // final hod = data['hod'] ?? 'N/A';
                    // final motherjob = data['motherjob'] ?? 'N/A';
                    // final mothername = data['mothername'] ?? 'N/A';
                    // final motherphone = data['motherphone'] ?? 'N/A';
                    // final regno = data['regno'] ?? 'N/A';
                    // final admdate = data['admdate']  ??  'N/A';
                    //
                    // final allRecords = snapshot.data!.docs;

                    final status = data['status'] ?? 'N/A';
                    final name = data['name'] ?? 'No name';
                    final email = data['email'] ?? 'No email';
                    final score = num.tryParse(data['score'].toString()) ?? 0;
                    final percentage =
                        num.tryParse(data['percentage'].toString()) ?? 0;
                    final grade = data['grade'] ?? 'N/A';

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
                            builder: (context) =>
                                StudentDetails(docId: record.id),
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

class GradeFilterButton extends StatefulWidget {
  final Function(String) onSelected;

  const GradeFilterButton({Key? key, required this.onSelected})
      : super(key: key);

  @override
  _GradeFilterButtonState createState() => _GradeFilterButtonState();
}

class _GradeFilterButtonState extends State<GradeFilterButton> {
  List<String> grades = ['All']; // Default option
  Future<List<String>> fetchGrades() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('records').get();

      // Extract unique grade values
      final grades = querySnapshot.docs
          .map((doc) => doc.data()) // Ensure correct type
          .map((data) =>
              data['grade'] as String?) // Safely cast grade to String?
          .where((grade) => grade != null) // Filter out null grades
          .cast<String>() // Ensure a List<String>
          .toSet() // Ensure unique grades
          .toList();

      // Sort grades (optional)
      grades.sort();

      return grades;
    } catch (e) {
      print('Error fetching grades: $e');
      return []; // Return an empty list if an error occurs
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchGrades();
  }

  Future<void> _fetchGrades() async {
    final fetchedGrades = await fetchGrades();
    setState(() {
      grades = ['All'] + fetchedGrades; // Prepend 'All' option
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: widget.onSelected,
      itemBuilder: (context) => grades
          .map(
            (grade) => PopupMenuItem(
              value: grade,
              child: Text(grade == 'All' ? 'All Grades' : 'Grade $grade'),
            ),
          )
          .toList(),
      icon: Center(
        child: Text(
          'Select Grade',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
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
          title: Text(name,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87)),
          subtitle: Container(
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
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${score}/1200',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5)),
              Text("${percentage}%",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5)),
              Text('Grade: ${grade}',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5)),
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
  final TextEditingController _fathername = TextEditingController();
  final TextEditingController _fatherphone = TextEditingController();
  final TextEditingController _hod = TextEditingController();
  final TextEditingController _motherjob = TextEditingController();
  final TextEditingController _mothername = TextEditingController();
  final TextEditingController _motherphone = TextEditingController();
  final TextEditingController _regno = TextEditingController();
  final TextEditingController _admno = TextEditingController();
  final TextEditingController _admdate = TextEditingController();

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
              ),
              TextField(
                controller: _academicyear,
                decoration: const InputDecoration(labelText: 'Academic Year'),
              ),
              TextField(
                controller: _regno,
                decoration: const InputDecoration(labelText: 'Register Number'),
              ),
              TextField(
                controller: _admno,
                decoration:
                    const InputDecoration(labelText: "Admission Number"),
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
                decoration:
                    const InputDecoration(labelText: "Father's Occupation"),
              ),
              TextField(
                controller: _fatherphone,
                decoration:
                    const InputDecoration(labelText: "Father's Phone Number"),
              ),
              TextField(
                controller: _mothername,
                decoration: const InputDecoration(labelText: 'Name of Mother'),
              ),
              TextField(
                controller: _motherjob,
                decoration:
                    const InputDecoration(labelText: "Mother's Occupation"),
              ),
              TextField(
                controller: _motherphone,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: "Mother's Phone Number"),
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

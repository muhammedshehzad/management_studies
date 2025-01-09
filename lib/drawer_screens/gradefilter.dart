import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_school/drawer_screens/student_details.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

class AcademicRecords extends StatefulWidget {
  const AcademicRecords({super.key});

  @override
  State<AcademicRecords> createState() => _AcademicRecordsState();
}

class _AcademicRecordsState extends State<AcademicRecords> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController SearchBar = TextEditingController();
  String searchtext = '';
  String _selectedDate = '';
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';
  String _filterGrade = 'All';
  Query? query;
  String currentfilter = 'None';
  String? selectedname;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(days: 300));
  List<dynamic> filteredRecords = [];

  Stream<QuerySnapshot<Map<String, dynamic>>> records() {
    return FirebaseFirestore.instance
        .collection('your_collection_name')
        .snapshots();
  }

  void fetchRecords(DateTime? startDate, DateTime? endDate) {
    setState(() {
      // Trigger refresh by calling setState with updated filters
    });
  }

  void SeacrhName(String query) {
    setState(() {
      searchtext = query.toLowerCase();
    });
  }

  void searchQuery() {
    setState(() {
      query = FirebaseFirestore.instance
          .collection('records')
          .where('academicyear',
              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .orderBy('descending')
          .startAt([SearchBar.text]).endAt([SearchBar.text + '\uf8ff']);
    });
  }

  void fetchQuery(String name) {
    setState(() {
      query = FirebaseFirestore.instance
          .collection('appointments')
          .where('patientid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('doctorsname', isEqualTo: selectedname);
    });
  }

  void clearQuery() {
    setState(() {
      startDate = DateTime.now();
      endDate = DateTime.now();
      _filterGrade = 'All';
      selectedname = null;
      searchtext = '';
    });
  }

  void fetchclearquery(DateTime start, DateTime end) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('records')
          .orderBy('admdate', descending: false)
          .startAt([Timestamp.fromDate(start)]).endAt(
              [Timestamp.fromDate(end)]).get();

      setState(() {
        filteredRecords = querySnapshot.docs.map((doc) => doc.data()).toList();
      });

      print('Filtered Records: $filteredRecords');
      print('from ${startDate} to ${endDate}');
    } catch (e) {
      print('Error fetching records: $e');
    }
  }

  void _updateFilter(String grade) {
    setState(() {
      _filterGrade = grade;
    });
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      startDate = args.value.startDate;
      endDate = args.value.endDate;
      if (args.value is PickerDateRange) {
        startDate = args.value.startDate;
        endDate = args.value.endDate ?? args.value.startDate;
        fetchclearquery(startDate, endDate);
        print('$startDate - $endDate');
      } else if (args.value is DateTime) {
        _selectedDate = args.value.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final recordStream = records();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Records'),
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
                                              const Duration(days: 1)),
                                          DateTime.now()
                                              .add(const Duration(days: 1)),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (startDate != null &&
                                            endDate != null) {
                                          fetchRecords(startDate,
                                              endDate); // Fetch records based on new date range
                                        }
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
                                                          fetchQuery(
                                                              selectedname!);
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
                                PopupMenuButton<String>(
                                    onSelected: _updateFilter,
                                    itemBuilder: (context) => [
                                          const PopupMenuItem(
                                              value: 'All',
                                              child: Text('All Grades')),
                                          const PopupMenuItem(
                                              value: 'E',
                                              child: Text('All Failed')),
                                          const PopupMenuItem(
                                              value: 'A+',
                                              child: Text('Grade A+')),
                                          const PopupMenuItem(
                                              value: 'A',
                                              child: Text('Grade A')),
                                          const PopupMenuItem(
                                              value: 'B+',
                                              child: Text('Grade B+')),
                                          const PopupMenuItem(
                                              value: 'B',
                                              child: Text('Grade B')),
                                          const PopupMenuItem(
                                              value: 'C+',
                                              child: Text('Grade C+')),
                                          const PopupMenuItem(
                                              value: 'C',
                                              child: Text('Grade C')),
                                          const PopupMenuItem(
                                              value: 'D+',
                                              child: Text('Grade D+')),
                                          const PopupMenuItem(
                                              value: 'D',
                                              child: Text('Grade D')),
                                        ],
                                    icon: Center(
                                        child: Text(
                                      'Select Grade',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ))),
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
              onChanged: (value) {
                print(SearchBar.text);
                SeacrhName(SearchBar.text);
              },
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
                final selectedStartDate =
                    DateTime(2024, 01, 01); // Example start date
                final selectedEndDate = DateTime(2025, 01, 01);
                final filteredRecords = allRecords.where((doc) {
                  final data = doc.data();
                  final name = (data['name'] ?? '').toLowerCase();
                  final email = (data['email'] ?? '').toLowerCase();
                  final grade = (data['grade'] ?? '');
                  final admdate = (data['admdate'] as Timestamp).toDate();
                  final isWithinRange = admdate.isAfter(
                          selectedStartDate.subtract(Duration(days: 1))) &&
                      admdate.isBefore(selectedEndDate.add(Duration(days: 1)));

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
        _admdate.text = dateFormat.format(selectedDate);
      });
    }
  }

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
        final admDateTime = DateFormat('dd-MM-yyyy').parse(admdate);
        final admTimestamp = Timestamp.fromDate(admDateTime);
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
          'admdate': admTimestamp,
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
                readOnly: true,
                onTap: () =>
                    _selectDate(context), // Trigger date picker when tapped
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
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
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

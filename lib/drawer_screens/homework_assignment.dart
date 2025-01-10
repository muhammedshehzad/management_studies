import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:side_sheet/side_sheet.dart';

class HomeworkAssignmentsScreen extends StatefulWidget {
  @override
  State<HomeworkAssignmentsScreen> createState() =>
      _HomeworkAssignmentsScreenState();
}

class _HomeworkAssignmentsScreenState extends State<HomeworkAssignmentsScreen> {
  Query? query;
  String searchtext = '';
  final TextEditingController Search = TextEditingController();
  List<String> subject = ['All'];
  String? selectedsubjectFilter;
  String _filterSubject = '';
  List<DocumentSnapshot> filteredSubRecords = [];
  List<DocumentSnapshot> allSubRecords = [];

  @override
  void initState() {
    super.initState();
    _filterSubject = 'All';
    query = FirebaseFirestore.instance.collection('homeworks');
    _fetchInitialData();
  }

  void Seacrhh(String query) {
    setState(() {
      searchtext = query.toLowerCase();
    });
  }

  void _applyDeptFilter() {
    setState(() {
      if (_filterSubject == 'All') {
        filteredSubRecords = allSubRecords; // Show all records
      } else {
        filteredSubRecords = allSubRecords
            .where((doc) => doc['subject'] == _filterSubject)
            .toList();
      }
    });
  }

  void clearQuery() {
    setState(() {
      _filterSubject = 'All';
      query = FirebaseFirestore.instance.collection('homeworks');
    });
  }

  Future<void> _fetchInitialData() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('homeworks').get();
    setState(() {
      allSubRecords = querySnapshot.docs;
      _applyDeptFilter();
    });
  }

  Future<void> _submitnewData() async {
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Homework and Assignments'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                SideSheet.right(
                  sheetBorderRadius: 6,
                  body: DefaultTabController(
                    animationDuration: Duration(milliseconds: 300),
                    length: 3,
                    child: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return SizedBox(
                          height: 400,
                          child: Column(
                            children: [
                              // Header Section
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Filters",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                              // Tab Bar
                              TabBar(
                                indicatorColor: Color(0xff3e948e),
                                labelColor: Colors.black87,
                                unselectedLabelColor: Colors.grey,
                                tabs: [
                                  Tab(text: "Subject"),
                                  Tab(text: "Status"),
                                  Tab(text: "Date"),
                                ],
                              ),
                              // Tab Bar Views
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    // Grade Tab
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Select a Subject",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                          // GradeFilterButton(
                                          //   onSelected: (selectedGrade) {
                                          //     setState(() {
                                          //       // _filterGrade = selectedGrade;
                                          //       // _applyFilter();
                                          //     });
                                          //   },
                                          // ),
                                          SubjectFilterButton(
                                              onSelected: (selectedSubject) {
                                            setState(() {
                                              _filterSubject = selectedSubject;
                                              _applyDeptFilter();
                                            });
                                          })
                                        ],
                                      ),
                                    ),
                                    // Department Tab
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Select a Status",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                        ],
                                      ),
                                    ),
                                    // Date Tab
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Apply Filter Button
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Color(0xff3e948e),
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      clearQuery();
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Clear Filters',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  context: context,
                );
              },
              icon: Icon(Icons.filter_list_sharp))
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                        final matchesSubject =
                            _filterSubject.toLowerCase() == 'all' ||
                                subject.trim().toLowerCase() ==
                                    _filterSubject.trim().toLowerCase();
                        return matchesSearch && matchesSubject;
                      }).toList();

                      if (filteredRecords.isEmpty) {
                        return const Center(
                          child: Text(
                            'No matching records found.',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () {
                          setState(() {
                            query = FirebaseFirestore.instance
                                .collection('homeworks');
                            Search.text = "";
                            searchtext = "";
                          });
                          return _submitnewData();
                        },
                        child: ListView.builder(
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
                              () {},
                            );
                          },
                        ),
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

class SubjectFilterButton extends StatefulWidget {
  final Function(String) onSelected;

  const SubjectFilterButton({Key? key, required this.onSelected})
      : super(key: key);

  @override
  _SubjectFilterButtonState createState() => _SubjectFilterButtonState();
}

class _SubjectFilterButtonState extends State<SubjectFilterButton> {
  List<String> subject = ['All'];
  String? selectedsubjectFilter; // Selected value
  String _filterSubject = '';
  List<DocumentSnapshot> filteredSubRecords = [];
  List<DocumentSnapshot> allSubRecords = []; // All fetched records

  void _applyDeptFilter() {
    setState(() {
      if (_filterSubject == 'All') {
        filteredSubRecords = allSubRecords;
      } else {
        filteredSubRecords = allSubRecords
            .where((doc) => doc['homeworks'] == _filterSubject)
            .toList();
      }
    });
  }

  Future<List<String>> fetchSubject() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('homeworks').get();

      final subjects = querySnapshot.docs
          .map((doc) => doc.data())
          .map((data) => data['subject'] as String?)
          .where((subject) => subject != null)
          .cast<String>()
          .toSet()
          .toList();

      subjects.sort();
      return subjects;
    } catch (e) {
      print('Error fetching departments: $e');
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _fetchSubjects();
    });
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    final fetchedDepartments = await fetchSubject();
    setState(() {
      subject = ['All'] + fetchedDepartments;
      selectedsubjectFilter = subject.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedsubjectFilter,
      items: subject.map((String subject) {
        return DropdownMenuItem<String>(
          value: subject,
          child: Text(
            subject == 'All' ? 'All Subjects' : subject,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          selectedsubjectFilter = newValue!;
          _filterSubject = newValue;
          widget.onSelected(newValue!);
          print(selectedsubjectFilter);
        });
      },
      hint: Text(
        'Select Dept',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      icon: const Icon(
        Icons.arrow_drop_down,
        color: Colors.blueGrey,
      ),
      dropdownColor: Colors.white,
      underline: Container(height: 0),
    );
  }
}

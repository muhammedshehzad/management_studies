import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:side_sheet/side_sheet.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'homework_details.dart';

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
  String selectedStatus = "All";
  List<Map<String, dynamic>> allstatusRecords = [];
  List<Map<String, dynamic>> filteredstatusRecords = [];
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(days: 300));
  String _selectedDate = '';
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';
  List<DocumentSnapshot> allRecords = [];

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

  void _applySubjectFilter() {
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

  void _applystatusFilter() {
    setState(() {
      if (selectedStatus == 'All') {
        filteredstatusRecords = List.from(allstatusRecords);
      } else {
        filteredstatusRecords = allstatusRecords
            .where((doc) => doc['status'] == selectedStatus)
            .toList();
      }
    });
  }

  void clearQuery() {
    setState(() {
      _filterSubject = 'All';
      selectedStatus = 'All';
      _applySubjectFilter();
      _applystatusFilter();
      // query = FirebaseFirestore.instance.collection('homeworks');
    });
  }

  void fetchclearquery(DateTime start, DateTime end) {
    setState(() {
      query = FirebaseFirestore.instance
          .collection('homeworks')
          .where('deadline', isGreaterThanOrEqualTo: startDate)
          .where('deadline', isLessThanOrEqualTo: endDate);
    });
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

  // Future<void> _fetchRecords() async {
  //   try {
  //     final querySnapshot =
  //     await FirebaseFirestore.instance.collection('homeworks').get();
  //     setState(() {
  //       allRecords = querySnapshot.docs;
  //       _applystatusFilter();
  //     });
  //   } catch (e) {
  //     print('Error fetching records: $e');
  //   }
  // }

  Future<void> _fetchInitialData() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('homeworks').get();
    setState(() {
      allSubRecords = querySnapshot.docs;

      allstatusRecords = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      allRecords = querySnapshot.docs;
      _applySubjectFilter();
      _applystatusFilter();
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
                                          SubjectFilterButton(
                                              onSelected: (selectedSubject) {
                                            setState(() {
                                              _filterSubject = selectedSubject;
                                              _applySubjectFilter();
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
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 16,
                                          ),
                                          Wrap(
                                            spacing: 14,
                                            alignment:
                                                WrapAlignment.spaceEvenly,
                                            children: [
                                              ChoiceChip(
                                                label: Text("All"),
                                                labelStyle: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: selectedStatus == "All"
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                                selected:
                                                    selectedStatus == "All",
                                                selectedColor:
                                                    Colors.blueGrey.shade600,
                                                backgroundColor:
                                                    Colors.blueGrey.shade200,
                                                onSelected: (bool selected) {
                                                  setState(() {
                                                    selectedStatus = selected
                                                        ? "All"
                                                        : selectedStatus;
                                                    print(
                                                        "Selected Status: $selectedStatus");
                                                    _applystatusFilter();
                                                  });
                                                },
                                              ),
                                              ChoiceChip(
                                                label: Text("Completed"),
                                                labelStyle: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: selectedStatus ==
                                                          "Completed"
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                                selected: selectedStatus ==
                                                    "Completed",
                                                selectedColor:
                                                    Colors.green.shade600,
                                                backgroundColor:
                                                    Colors.green.shade200,
                                                onSelected: (bool selected) {
                                                  setState(() {
                                                    selectedStatus = selected
                                                        ? "Completed"
                                                        : selectedStatus;
                                                    print(
                                                        "Selected Status: $selectedStatus");
                                                    _applystatusFilter();
                                                  });
                                                },
                                              ),
                                              ChoiceChip(
                                                label: Text("Pending"),
                                                labelStyle: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: selectedStatus ==
                                                          "Pending"
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                                selected:
                                                    selectedStatus == "Pending",
                                                selectedColor:
                                                    Colors.red.shade600,
                                                backgroundColor:
                                                    Colors.red.shade200,
                                                onSelected: (bool selected) {
                                                  setState(() {
                                                    selectedStatus = selected
                                                        ? "Pending"
                                                        : selectedStatus;
                                                    print(
                                                        "Selected Status: $selectedStatus");
                                                    _applystatusFilter();
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
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
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: SfDateRangePicker(
                                              onSelectionChanged:
                                                  _onSelectionChanged,
                                              selectionMode:
                                                  DateRangePickerSelectionMode
                                                      .range,
                                              initialSelectedRange:
                                                  PickerDateRange(
                                                DateTime.now().subtract(
                                                    Duration(days: 6)),
                                                DateTime.now(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Container(
                                  width: MediaQuery.of(context).size.width * .9,
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

                        final matchesStatus =
                            selectedStatus.toLowerCase() == 'all' ||
                                status.trim().toLowerCase() ==
                                    selectedStatus.trim().toLowerCase();

                        return matchesSearch && matchesSubject && matchesStatus;
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
                            selectedStatus = "All";
                            _filterSubject = 'All';
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
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        HomeworkDetails(docId: record.id),
                                  ),
                                );
                              },
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
  TextEditingController _assignedby = TextEditingController();
  TextEditingController _description = TextEditingController();
  TextEditingController _estimatedtime = TextEditingController();

  Future<void> _submitnewData() async {
    final subject = _subject.text;
    final title = _title.text;
    final deadline = _deadlines.text;
    final status = _status.text;
    final assignedby = _assignedby.text;
    final description = _description.text;
    final estimatedtime = _estimatedtime.text;

    if (status.isEmpty ||
        deadline.isEmpty ||
        title.isEmpty ||
        subject.isEmpty ||
        description.isEmpty ||
        estimatedtime.isEmpty ||
        assignedby.isEmpty
    ) {
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
          'assignedby': assignedby,
          'description': description,
          'estimatedtime': estimatedtime,
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
                controller: _description,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: _deadlines,
                decoration: const InputDecoration(labelText: 'Deadline'),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              DropdownButtonFormField<String>(
                value: _status.text.isEmpty ? null : _status.text,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(
                      value: "Completed", child: Text("Completed")),
                  DropdownMenuItem(value: "Pending", child: Text("Pending")),

                ],
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _status.text = newValue;
                  }
                },
              ),
              TextField(
                controller: _assignedby,
                decoration: const InputDecoration(labelText: 'Assigned By'),
              ),
              TextField(
                controller: _estimatedtime,
                decoration: const InputDecoration(labelText: 'Estimated Time'),
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

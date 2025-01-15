import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:side_sheet/side_sheet.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:uuid/uuid.dart';

import 'homework_details.dart';

class HomeWorkScreen extends StatefulWidget {
  late final String docId;

  @override
  _HomeWorkScreenState createState() => _HomeWorkScreenState();
}

class _HomeWorkScreenState extends State<HomeWorkScreen> {
  static const PAGE_SIZE = 9;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String _filterSubject = 'All';
  String selectedStatus = 'All';
  List<QueryDocumentSnapshot<Map<String, dynamic>>> allRecords = [];

  Future<DocumentSnapshot<Map<String, dynamic>>> fetchDetails() async {
    return firestore.collection('homeworks').doc(widget.docId).get();
  }

  Query query = FirebaseFirestore.instance
      .collection('homeworks')
      .orderBy('deadline')
      .limit(PAGE_SIZE);

  DocumentSnapshot? _lastDocument;
  bool _allFetched = false;
  bool _isLoading = false;
  List<HomeWorkDetailModel> _data = [];
  final TextEditingController _searchController = TextEditingController();

  List<DocumentSnapshot> filteredSubRecords = [];
  List<DocumentSnapshot> allSubRecords = [];

  List<Map<String, dynamic>> allstatusRecords = [];
  List<Map<String, dynamic>> filteredstatusRecords = [];

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(days: 300));

  String _selectedDate = '';
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';

  // Filtered list for local search
  List<HomeWorkDetailModel> filteredData = [];
  final TextEditingController Search = TextEditingController();
  String searchText = '';

  @override
  void initState() {
    super.initState();
    _fetchFirebaseData();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      searchText = _searchController.text.toLowerCase();
    });
    _applySearchFilter();
  }

  void _applySearchFilter() {
    setState(() {
      filteredData = _data.where((homework) {
        final subject = homework.subject.toLowerCase();
        final title = homework.title.toLowerCase();
        final deadline = DateFormat('dd-MM-yyyy').format(homework.deadline);
        final status = homework.status.toLowerCase();

        return title.contains(searchText) ||
            subject.contains(searchText) ||
            deadline.contains(searchText) ||
            status.contains(searchText);
      }).toList();
    });
  }

  void _applyFilters() {
    setState(() {
      filteredData = _data.where((homeworks) {
        final subject = homeworks.subject.toLowerCase();
        final title = homeworks.title.toLowerCase();
        final deadline = DateFormat('dd-MM-yyyy').format(homeworks.deadline);
        final status = homeworks.status.toLowerCase();

        final matchesSearch = searchText.isEmpty ||
            title.contains(searchText) ||
            subject.contains(searchText) ||
            deadline.contains(searchText) ||
            status.contains(searchText);

        final matchesSubject =
            _filterSubject == 'All' || subject == _filterSubject.toLowerCase();
        final matchesStatus =
            selectedStatus == 'All' || status == selectedStatus.toLowerCase();

        return matchesSearch && matchesSubject && matchesStatus;
      }).toList();
    });
  }

  void _applySubjectFilter() {
    setState(() {
      if (_filterSubject == 'All') {
        filteredSubRecords = allSubRecords;
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

  void fetchclearquery(DateTime start, DateTime end) async {
    setState(() {
      query = FirebaseFirestore.instance
          .collection('homeworks')
          .where('deadline', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('deadline', isLessThanOrEqualTo: Timestamp.fromDate(end));
      _data.clear();
      _allFetched = false;
      _lastDocument = null;
    });

    await _fetchFirebaseData();
  }

  void clearQuery() async {
    setState(() {
      _searchController.clear();
      searchText = '';
      _filterSubject = 'All';
      selectedStatus = 'All';

      query = FirebaseFirestore.instance
          .collection('homeworks')
          .orderBy('deadline')
          .limit(PAGE_SIZE);

      _data.clear();
      _allFetched = false;
      _lastDocument = null;
      _isLoading = false;
    });

    await _fetchFirebaseData();
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

  Future<void> _fetchFirebaseData() async {
    if (_allFetched || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot snapshot;
      if (_lastDocument == null) {
        snapshot = await query.get();
      } else {
        snapshot =
            await query.startAfterDocument(_lastDocument!).limit(2).get();
      }

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _lastDocument = snapshot.docs.last;
          _data.addAll(snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return HomeWorkDetailModel.fromMap(data);
          }).toList());
          _applySearchFilter();
          if (snapshot.docs.length < 2) {
            _allFetched = true;
          }
        });
      } else {
        setState(() {
          _allFetched = true;
        });
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchText = _searchController.text.toLowerCase();
    final filteredRecords = _data.where((homeworks) {
      final subject = homeworks.subject.toLowerCase();
      final title = homeworks.title.toLowerCase();
      final deadline = DateFormat('dd-MM-yyyy').format(homeworks.deadline);
      final status = homeworks.status.toLowerCase();

      final matchesSearch = searchText.isEmpty ||
          subject.contains(searchText) ||
          title.contains(searchText) ||
          deadline.contains(searchText);

      final matchesSubject =
          _filterSubject == 'All' || subject == _filterSubject.toLowerCase();
      final matchesStatus =
          selectedStatus == 'All' || status == selectedStatus.toLowerCase();

      return matchesSearch && matchesSubject && matchesStatus;
    }).toList();

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
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollEnd) {
          if (scrollEnd.metrics.atEdge &&
              scrollEnd.metrics.pixels > 0 &&
              !_isLoading &&
              !_allFetched) {
            _fetchFirebaseData();
          }
          return true;
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search homeworks',
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
            Expanded(child: _buildHomeworkList(filteredRecords)),
            Container(
              height: 44,
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHomeworkList(List<HomeWorkDetailModel> records) {
    if (records.isEmpty && _isLoading) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.all(12.0),
        child: CircularProgressIndicator(),
      ));
    }

    if (records.isEmpty) {
      return const Center(
        child: Text(
          'No records found.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }
    return Expanded(
      child: ListView.builder(
        itemCount: records.length + (_allFetched ? 0 : 1),
        itemBuilder: (context, index) {
          if (index == records.length) {
            return const Center(
                child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ));
          }
          final homework = records[index];
          return CustomStudentTile(
              homework.subject,
              homework.title,
              DateFormat('dd-MM-yyyy').format(homework.deadline),
              homework.status, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeworkDetails(docId: homework.docid),
              ),
            );
          });
        },
      ),
    );
  }
}

class HomeWorkDetailModel {
  final String subject;
  final String title;
  final DateTime deadline;
  final String status;
  final String docid;

  HomeWorkDetailModel(
      {required this.subject,
      required this.title,
      required this.deadline,
      required this.status,
      required this.docid});

  factory HomeWorkDetailModel.fromMap(Map<String, dynamic> data) {
    return HomeWorkDetailModel(
      subject: data['subject'] ?? 'N/A',
      title: data['title'] ?? 'No title',
      deadline: (data['deadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'No status',
      docid: data['docid'] ?? 'No data',
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
    final documentid = Uuid().v4();
    final docid = documentid;

    if (status.isEmpty ||
        deadline.isEmpty ||
        title.isEmpty ||
        subject.isEmpty ||
        description.isEmpty ||
        estimatedtime.isEmpty ||
        assignedby.isEmpty) {
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final deadlines = DateFormat('dd-MM-yyyy').parse(deadline);
        final deadlineTimestamp = Timestamp.fromDate(deadlines);
        await FirebaseFirestore.instance
            .collection('homeworks')
            .doc(docid)
            .set({
          'status': status,
          'subject': subject,
          'title': title,
          'deadline': deadlineTimestamp,
          'assignedby': assignedby,
          'description': description,
          'estimatedtime': estimatedtime,
          'docid': docid,
        });
        print('Generated docid: $docid');

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

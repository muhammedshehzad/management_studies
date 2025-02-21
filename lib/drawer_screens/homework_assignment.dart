import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:side_sheet/side_sheet.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:uuid/uuid.dart';
import '../isar_storage/homework_records_model.dart';
import '../main.dart';
import '../sliding_transition.dart';
import 'homework_details.dart';

class HomeWorkScreen extends StatefulWidget {
  late final String docId;

  @override
  _HomeWorkScreenState createState() => _HomeWorkScreenState();
}

class _HomeWorkScreenState extends State<HomeWorkScreen> {
  static const PAGE_SIZE = 50;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String _filterSubject = 'All';
  String selectedStatus = 'All';
  List<QueryDocumentSnapshot<Map<String, dynamic>>> allRecords = [];
  String? globalSelectedSubjectFilter = 'All';

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

  List<Map<String, dynamic>> filteredstatusRecords = [];

  DateTime startDate = DateTime(2000, 1, 1);
  DateTime endDate = DateTime.now().add(Duration(days: 300));

  String _selectedDate = '';
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';
  List<QueryDocumentSnapshot>? searchResult;
  List<HomeWorkDetailModel> filteredData = [];
  final TextEditingController Search = TextEditingController();
  String searchText = '';
  Query newquery = FirebaseFirestore.instance.collection('homeworks');
  List<HomeWorkDetailModel> filteredRecords = [];

  List<HomeWorkDetailModel> _originalData = [];
  List<HomeWorkDetailModel> _filteredData = [];
  String _searchText = '';
  String? role;
  int _pageSize = 50;

  @override
  void initState() {
    super.initState();
    _fetchFirebaseData();
    loadRole();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> refreshHomeworkData() async {
    setState(() {
      _originalData.clear();
      _filteredData.clear();
      _lastDocument = null;
      _allFetched = false;
    });
    await _fetchFirebaseData();
  }

  void _applyFilters() {
    setState(() {
      _filteredData = _originalData.where((homework) {
        final matchesSubject = _filterSubject == 'All' ||
            homework.subject.toLowerCase() == _filterSubject.toLowerCase();

        final matchesSearch = _searchText.isEmpty ||
            homework.title.toLowerCase().contains(_searchText) ||
            homework.subject.toLowerCase().contains(_searchText) ||
            homework.status.toLowerCase().contains(_searchText);

        final matchesStatus = selectedStatus == 'All' ||
            homework.status.toLowerCase() == selectedStatus.toLowerCase();

        final matchesDate = (startDate == null || endDate == null) ||
            (homework.deadline.isAfter(startDate) &&
                homework.deadline.isBefore(endDate));

        return matchesSubject && matchesSearch && matchesStatus && matchesDate;
      }).toList();
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchText = value.toLowerCase();
    });
    _applyFilters();
  }

  void _onFilterChanged(String newSubject) {
    setState(() {
      _filterSubject = newSubject;
    });
    _applyFilters();
  }

  void _applystatusFilter() {
    setState(() {
      if (selectedStatus == 'All') {
        filteredRecords = allRecords.cast<HomeWorkDetailModel>();
      } else {
        filteredstatusRecords = allRecords
            .where((doc) => doc['status'] == selectedStatus)
            .cast<Map<String, dynamic>>()
            .toList();
      }
      _applyFilters();
    });
  }

  void clearQuery() async {
    setState(() {
      _filterSubject = 'All';
      selectedStatus = 'All';
      startDate = DateTime(2000, 1, 1);
      endDate = DateTime.now().add(Duration(days: 300));
      _data.clear();
      _originalData.clear();
      _filteredData.clear();
      _allFetched = false;
      _lastDocument = null;
      _isLoading = false;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('selectedSubjectFilter');

    await _fetchFirebaseData();
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is PickerDateRange) {
        startDate = args.value.startDate;
        endDate = args.value.endDate ?? args.value.startDate;
      } else if (args.value is DateTime) {
        _selectedDate = args.value.toString();
      } else if (args.value is List<DateTime>) {
        _dateCount = args.value.length.toString();
      } else {
        _rangeCount = args.value.length.toString();
      }

      _applyFilters();
    });
  }

  Future<String> _getUserRole() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return 'guest';

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();

      return userDoc.data()?['role'] ?? 'guest';
    } catch (e) {
      print('Error getting user role: $e');
      return 'guest';
    }
  }

  Future<void> _fetchFirebaseData() async {
    if (_isLoading || _allFetched) {
      print("loading: $_isLoading, allFetched: $_allFetched");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final String userRole = await _getUserRole();

    try {
      await Future.delayed(Duration(milliseconds: 100));

      Query<Map<String, dynamic>> query;

      if (userRole == 'Admin') {
        query = FirebaseFirestore.instance
            .collection('homeworks')
            .orderBy('deadline');
      } else if (userRole == 'Teacher' || userRole == 'Student') {
        final userDocSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .get();

        if (!userDocSnapshot.exists) {
          print(" User document doesn't exist");
          return;
        }

        final userDepartment = userDocSnapshot.data()?['department'];

        if (userDepartment == null) {
          print(" No department found for user");
          return;
        }

        query = FirebaseFirestore.instance
            .collection('homeworks')
            .where('subject', isEqualTo: userDepartment)
            .orderBy('deadline');
      } else {
        return;
      }

      if (_originalData.isEmpty) {
        final querySnapshot = await query.get();

        setState(() {
          _originalData = querySnapshot.docs.map((doc) {
            return HomeWorkDetailModel.fromMap(doc.data());
          }).toList();
          _applyFilters();
          if (querySnapshot.docs.isNotEmpty) {
            _lastDocument = querySnapshot.docs.last;
          }
        });
      } else {
        if (_lastDocument != null) {
          query = query.startAfterDocument(_lastDocument!);
        }

        final querySnapshot = await query.get();

        if (querySnapshot.docs.isEmpty) {
          setState(() {
            _allFetched = true;
          });
        } else {
          setState(() {
            _originalData.addAll(querySnapshot.docs.map((doc) {
              return HomeWorkDetailModel.fromMap(doc.data());
            }).toList());
            _lastDocument = querySnapshot.docs.last;
            _applyFilters();
          });
        }
      }
    } catch (e) {
      print("$e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> loadRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role');
    });
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
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Select a Subject: ",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          SubjectFilterButton(
                                            onSelected: (newValue) {
                                              _onFilterChanged(newValue);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
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
                                                DateTime.now(),
                                                DateTime.now()
                                                    .add(Duration(days: 1)),
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
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollEndNotification &&
              scrollNotification.metrics.pixels >=
                  scrollNotification.metrics.maxScrollExtent - 100) {
            if (!_isLoading && !_allFetched) {
              _fetchFirebaseData();
            }
          }
          return false;
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search homeworks',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Expanded(child: _buildHomeworkList(_filteredData)),
            if (role == 'Teacher')
              Container(
                height: 44,
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xff3e948e),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      SlidingPageTransitionRL(page: HomeWorkDetails()),
                    ).then((_) {
                      refreshHomeworkData();
                    });
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
    // );
  }

  Widget _buildHomeworkList(List<HomeWorkDetailModel> records) {
    if (records.isEmpty && _allFetched) {
      return const SizedBox();
    }

    if (_isLoading && records.isEmpty) {
      return Center(
          child: Center(
        child: Material(
          child: Shimmer.fromColors(
            baseColor: Colors.grey[400]!,
            highlightColor: Colors.grey[100]!,
            child: ListView.builder(
              itemCount: 7,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 15),
                    leading: Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                    title: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: double.infinity,
                        height: 20.0,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 100.0,
                        height: 15.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
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

    return ListView.builder(
      itemCount: records.length + (_allFetched || records.length < 8 ? 0 : 1),
      itemBuilder: (context, index) {
        if (index == records.length && !_allFetched) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final homework = records[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: CustomStudentTile(
            homework.subject,
            homework.title,
            DateFormat('dd-MM-yyyy').format(homework.deadline),
            homework.status,
            () {
              Navigator.push(
                context,
                SlidingPageTransitionRL(
                    page: HomeworkDetailsPage(docId: homework.docid)),
              );
            },
          ),
        );
      },
    );
  }
}

class HomeWorkDetailModel {
  final String subject;
  final String title;
  final DateTime deadline;
  final String status;
  final String description;
  final String estimatedTime;
  final String assignedBy;
  final String docid;

  HomeWorkDetailModel({
    required this.subject,
    required this.title,
    required this.deadline,
    required this.status,
    required this.docid,
    required this.description,
    required this.estimatedTime,
    required this.assignedBy,
  });

  factory HomeWorkDetailModel.fromMap(Map<String, dynamic> map) {
    return HomeWorkDetailModel(
      subject: map['subject'] ?? 'N/A',
      title: map['title'] ?? 'No title',
      deadline: (map['deadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'No status',
      docid: map['docid'] ?? 'No data',
      description: map['description'] ?? 'No Data',
      estimatedTime: map['estimatedtime'] ?? 'No Data',
      assignedBy: map['assignedby'] ?? 'No Data',
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
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _departmentController = TextEditingController();

  String? _selectedDepartment;
  String? _selectedTeacherName;
  String? _selectedTeacher;
  List<String> _departments = [];
  List<Map<String, String>> _teachers = [];
  bool _isLoading = true;

  Future<void> addHomeworkToFirestore(
      String title, String subject, DateTime deadline, String status) async {
    final firestore = FirebaseFirestore.instance;

    await firestore.collection('homeworks').add({
      'title': title,
      'subject': subject,
      'deadline': Timestamp.fromDate(deadline),
      'status': status,
    });
  }

  Future<bool> isConnected() async {
    var result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> _submitnewData() async {
    if (!_formKey.currentState!.validate()) return;
    final subject = _selectedDepartment ?? '';
    final title = _title.text.trim();
    final deadlineText = _deadlines.text.trim();
    final status = _status.text.trim();
    final assignedby = _selectedTeacherName;
    final description = _description.text.trim();
    final estimatedtime = _estimatedtime.text.trim();
    final documentid = Uuid().v4();

    if (assignedby == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a teacher')),
      );
      return;
    }

    if (subject.isEmpty ||
        title.isEmpty ||
        deadlineText.isEmpty ||
        status.isEmpty ||
        assignedby.isEmpty ||
        description.isEmpty ||
        estimatedtime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final deadline = DateFormat('dd-MM-yyyy').parse(deadlineText);
    final deadlineTimestamp = Timestamp.fromDate(deadline);

    final homework = HomeworkRecordModel()
      ..docid = documentid
      ..subject = subject
      ..title = title
      ..deadline = deadline
      ..status = status
      ..assignedBy = assignedby
      ..description = description
      ..estimatedTime = estimatedtime;

    await saveHomeworkToIsar(homework);
    print('data saved to isar locally');
    Navigator.pop(context);

    bool online = await isConnected();

    if (online) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('homeworks')
              .doc(documentid)
              .set({
            'status': status,
            'subject': subject,
            'title': title,
            'deadline': deadlineTimestamp,
            'assignedby': assignedby,
            'description': description,
            'estimatedtime': estimatedtime,
            'docid': documentid,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Homework added successfully')),
          );
          print('data saved to firestore');
          Navigator.pop(context);
        }
      } catch (error) {
        print('Error adding data: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding data: $error')),
        );
      }
    }
  }

  Future<void> saveHomeworkToIsar(HomeworkRecordModel homework) async {
    await isar.writeTxn(() async {
      await isar.homeworkRecordModels.put(homework);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchTeacherData();

    _departmentController.text =
        _selectedDepartment ?? 'No department selected';
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

  Future<String> _getUserRole() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return 'guest';

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();

      return userDoc.data()?['role'] ?? 'guest';
    } catch (e) {
      print('Error getting user role: $e');
      return 'guest';
    }
  }

  void _updateDepartment(String? dept) {
    setState(() {
      _selectedDepartment = dept;
    });
  }

  void _updateTeacher(String? teacher) {
    setState(() {
      _selectedTeacherName = teacher;
    });
  }

  Future<void> _fetchTeacherData() async {
    final userRole = await _getUserRole();
    QuerySnapshot teacherSnapshot;

    if (userRole == 'Admin') {
      teacherSnapshot =
          await FirebaseFirestore.instance.collection('Users').get();
    } else if (userRole == 'Teacher') {
      teacherSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get();
    } else {
      teacherSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('role', isEqualTo: 'Teacher')
          .get();
    }

    setState(() {
      _teachers = teacherSnapshot.docs
          .map((doc) => doc.data() as Map<String, String>)
          .toList();
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _deadlines.dispose();
    _status.dispose();
    _estimatedtime.dispose();
    super.dispose();
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TeacherInfoWidget(
                  onTeacherSelected: _updateTeacher,
                  onDept: _updateDepartment,
                ),
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    if (value.length < 3) {
                      return 'Title must be at least 3 characters long';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    if (value.length < 10) {
                      return 'Description must be at least 10 characters long';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _deadlines,
                  decoration: const InputDecoration(labelText: 'Deadline'),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a deadline';
                    }
                    return null;
                  },
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a status';
                    }
                    return null;
                  },
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      _status.text = newValue;
                    }
                  },
                ),
                TextFormField(
                  controller: _estimatedtime,
                  decoration: const InputDecoration(
                      labelText: 'Estimated Time', helperText: 'In Days'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter estimated time';
                    }
                    if (!RegExp(r'^\d+$').hasMatch(value)) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: SizedBox(
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xff3e948e),
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
      ),
    );
  }
}

class TeacherInfoWidget extends StatefulWidget {
  final Function(String?) onTeacherSelected;
  final Function(String?) onDept;

  const TeacherInfoWidget({
    Key? key,
    required this.onTeacherSelected,
    required this.onDept,
  }) : super(key: key);

  @override
  _TeacherInfoWidgetState createState() => _TeacherInfoWidgetState();
}

class _TeacherInfoWidgetState extends State<TeacherInfoWidget> {
  final TextEditingController _teacherNameController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  String? _selectedTeacher;
  String? _selectedTeacherName;
  String? _selectedDepartment;
  List<Map<String, String>> _teachers = [];

  @override
  void initState() {
    super.initState();
    _fetchTeacherData();
  }

  Future<String> _getUserRole() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return 'guest';
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();
      return userDoc.data()?['role'] ?? 'guest';
    } catch (e) {
      return 'guest';
    }
  }

  Future<void> _fetchTeacherData() async {
    final userRole = await _getUserRole();

    QuerySnapshot teacherSnapshot;
    try {
      if (userRole == 'Admin') {
        teacherSnapshot =
            await FirebaseFirestore.instance.collection('Users').get();
      } else if (userRole == 'Teacher') {
        teacherSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where(FieldPath.documentId,
                isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .get();
      } else {
        teacherSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('role', isEqualTo: 'Teacher')
            .get();
      }

      final teachersData = teacherSnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).map((data) {
        return data.map((key, value) => MapEntry(key, value.toString()));
      }).toList();

      setState(() {
        _teachers = teachersData;
        if (_teachers.isNotEmpty) {
          final teacher = _teachers.first;
          _selectedTeacher = teacher['username'];
          _selectedTeacherName = teacher['username'];
          _selectedDepartment = teacher['department'];

          _teacherNameController.text = _selectedTeacherName ?? '';
          _departmentController.text =
              _selectedDepartment ?? 'No department selected';
          widget.onTeacherSelected(_selectedTeacherName);
          widget.onDept(_selectedDepartment);
        } else {
          print("No teacher data found.");
        }
      });
    } catch (e) {
      print("Error fetching teacher data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _teacherNameController,
          decoration: InputDecoration(
            labelText: 'Assigned By',
            // helperText: 'Teacher ID: ${_selectedTeacher ?? "N/A"}',
          ),
          readOnly: true,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _departmentController,
          decoration: const InputDecoration(
            labelText: 'Department',
          ),
          readOnly: true,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _teacherNameController.dispose();
    _departmentController.dispose();
    super.dispose();
  }
}

class SubjectFilterButton extends StatefulWidget {
  final Function(String) onSelected;

  const SubjectFilterButton({super.key, required this.onSelected});

  @override
  _SubjectFilterButtonState createState() => _SubjectFilterButtonState();
}

class _SubjectFilterButtonState extends State<SubjectFilterButton> {
  List<String> subjects = [];
  String? selectedSubject;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final fetchedSubjects = await _fetchSubjects();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedSubject = prefs.getString('selectedSubjectFilter') ?? 'All';

    if (!fetchedSubjects.contains('All')) {
      fetchedSubjects.insert(0, 'All');
    }

    setState(() {
      subjects = fetchedSubjects
          .where((subject) => subject != null)
          .cast<String>()
          .toList();
      selectedSubject = subjects.contains(savedSubject) ? savedSubject : 'All';
    });
  }

  Future<List<String?>> _fetchSubjects() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('homeworks').get();
      return querySnapshot.docs
          .map((doc) => doc.data()['subject'] as String?)
          .where((subject) => subject != null)
          .toSet()
          .toList()
        ..sort();
    } catch (e) {
      print('Error fetching subjects: $e');
      return [];
    }
  }

  Future<void> handleSubjectChange(String? newValue) async {
    if (newValue != null) {
      setState(() {
        selectedSubject = newValue;
        widget.onSelected(newValue);
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('selectedSubjectFilter', newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: DropdownButton<String>(
          value: selectedSubject,
          items: subjects.map((subject) {
            return DropdownMenuItem<String>(
              value: subject,
              child: Text(
                subject == 'All' ? 'All Subjects' : " ${subject}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            handleSubjectChange(newValue);
          },
          icon: const Icon(Icons.arrow_drop_down, color: Colors.transparent),
          dropdownColor: Colors.white,
        ),
      ),
    );
  }
}

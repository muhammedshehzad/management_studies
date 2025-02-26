import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart' as isar;
import 'package:new_school/drawer_screens/student_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:side_sheet/side_sheet.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../isar_storage/academic_records_model.dart';
import '../isar_storage/isar_user_service.dart';
import '../sliding_transition.dart';

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
  List<DocumentSnapshot> allRecords = [];
  List<DocumentSnapshot> filteredRecords = [];
  String currentfilter = 'None';
  String _selectedDate = '';
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';
  String? selectedname;
  Query? query;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(days: 300));
  String _filterDepartment = '';
  List<String> department = ['All'];
  String? selectedFilter;
  List<DocumentSnapshot> filteredDeptRecords = [];
  List<DocumentSnapshot> allDptRecords = [];
  List<StudentDetailModel> localRecords = [];
  bool isOnline = false;
  StreamSubscription? _connectivitySubscription;
  String? role;

  Stream<QuerySnapshot<Map<String, dynamic>>> records() {
    return firestore.collection('records').orderBy('name').snapshots();
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
          .where('admdate', isGreaterThanOrEqualTo: start)
          .where('admdate', isLessThanOrEqualTo: end)
          .orderBy('admdate', descending: true);
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

  void clearQuery() {
    setState(() {
      _filterGrade = 'All';
      _filterDepartment = 'All';
      _initializeData();
    });
  }

  void SeachName(String query) {
    setState(() {
      searchtext = query.toLowerCase();
    });
  }

  Future<bool> isConnected() async {
    var result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
    checkInternet();
    loadRole();
    _initializeData();
    setState(() {
      _filterGrade = 'All';
      _filterDepartment = 'All';
      _fetchDepartments();
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

  Future<void> _initializeData() async {
    Query<Map<String, dynamic>>? fetchedQuery;

    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String currentUserId = currentUser?.uid ?? "";
    final userRole = await _getUserRole();
    await fetchDepartments();

    if (userRole == 'Student' && currentUser != null) {
      fetchedQuery = FirebaseFirestore.instance
          .collection('records')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('admdate', descending: true);
      print('student list');
    } else if (userRole == 'Teacher' && currentUser != null) {
      final userDocSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();

      if (!userDocSnapshot.exists) return;
      final userDepartment = userDocSnapshot.data()?['department'];

      if (userDepartment == null) return;
      fetchedQuery = FirebaseFirestore.instance
          .collection('records')
          .where('department', isEqualTo: userDepartment)
          .orderBy('admdate', descending: true);
      print('teacher list');
    } else {
      fetchedQuery = FirebaseFirestore.instance
          .collection('records')
          .orderBy('admdate', descending: true);
      print('admin list');
    }

    if (mounted) {
      setState(() {
        _filterGrade = 'All';
        _filterDepartment = 'All';
        query = fetchedQuery;
      });
    }
  }

  Future<void> checkInternet() async {
    bool connected = await hasInternet();
    setState(() {
      isOnline = connected;
    });

    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) async {
      bool connected =
          results.any((result) => result != ConnectivityResult.none) &&
              await hasInternet();
      setState(() {
        isOnline = connected;
      });
    });
  }

  Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> _fetchLocalData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userRole = await _getUserRole();

    if (userRole == 'Student' && currentUser != null) {
      final localRecords = await IsarUserService.isar!.studentDetailModels
          .filter()
          .uidEqualTo(currentUser.uid)
          .findAll();

      setState(() {});
    } else {
      await IsarUserService.isar!.studentDetailModels.where().findAll();
    }
  }

  Future<void> _initializeConnectivity() async {
    final connectivity = Connectivity();
    final List<ConnectivityResult> results =
        await connectivity.checkConnectivity();

    results.any((result) => result != ConnectivityResult.none);

    _connectivitySubscription = connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      results.any((result) => result != ConnectivityResult.none);
    });
  }

  Future<void> _fetchDepartments() async {
    final fetchedDepartments = await fetchDepartments();
    setState(() {
      department = ['All'] + fetchedDepartments;
      selectedFilter = department.first;
    });
  }

  Future<List<String>> fetchDepartments() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('records').get();

      final departments = querySnapshot.docs
          .map((doc) => doc.data())
          .map((data) => data['department'] as String?)
          .where((department) => department != null)
          .cast<String>()
          .toSet()
          .toList();

      departments.sort();
      return departments;
    } catch (e) {
      print('Error fetching departments: $e');
      return [];
    }
  }

  Future<void> refreshPageData() async {
    {
      setState(() {
        _initializeData();
        _filterGrade = 'All';
        _filterDepartment = 'All';
        SearchBar.text = "";
        searchtext = "";
      });
      return _fetchRecords();
    }
  }

  Future<void> _fetchRecords() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('records')
          .orderBy('admdate', descending: true)
          .get();
      setState(() {
        allRecords = querySnapshot.docs;
        _applyGradeFilter();
        _applyDeptFilter();
      });
    } catch (e) {
      print('Error fetching records: $e');
    }
  }

  void _applyGradeFilter() {
    setState(() {
      if (_filterGrade == 'All') {
        filteredRecords = allRecords;
      } else {
        filteredRecords =
            allRecords.where((doc) => doc['grade'] == _filterGrade).toList();
      }
    });
  }

  Future<void> loadRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role');
    });
    print(role);
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void _applyDeptFilter() {
    setState(() {
      if (_filterDepartment == 'All') {
        filteredDeptRecords = allDptRecords;
      } else {
        filteredDeptRecords = allRecords
            .where((doc) => doc['department'] == _filterDepartment)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                {
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
                                TabBar(
                                  indicatorColor: Color(0xff3e948e),
                                  labelColor: Colors.black87,
                                  unselectedLabelColor: Colors.grey,
                                  tabs: [
                                    Tab(text: "Grade"),
                                    Tab(text: "Department"),
                                    Tab(text: "Date"),
                                  ],
                                ),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Select a Grade",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 12),
                                            GradeFilterButton(
                                              onSelected: (selectedGrade) {
                                                setState(() {
                                                  _filterGrade = selectedGrade;
                                                  _applyGradeFilter();
                                                });
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
                                              "Select a Department",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 12),
                                            DepartmentFilterButton(
                                              onSelected: (selectedDepartment) {
                                                setState(() {
                                                  _filterDepartment =
                                                      selectedDepartment;
                                                  _applyGradeFilter();
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
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
                                              DateTime.now()
                                                  .subtract(Duration(days: 6)),
                                              DateTime.now(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Apply Filter Button
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * .9,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Color(0xff3e948e),
                                        elevation: 3,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
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
                }
              },
              icon: Icon(Icons.filter_list_sharp)),
        ],
        title: const Text('Academic Records'),
      ),
      body: Stack(
        children: [
          Column(
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

              // if (role == 'Admin' || role == 'Teacher')
              isOnline
                  ? Expanded(
                      child: StreamBuilder(
                        stream: query?.snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: ListView.builder(
                                  itemCount: 7,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0),
                                      child: ListTile(
                                        title: Container(
                                          width: 150.0,
                                          height: 20.0,
                                          color: Colors.white,
                                        ),
                                        subtitle: Container(
                                          width: 100.0,
                                          height: 15.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                                child: Text("Error: ${snapshot.error}"));
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text(
                                'No records found.',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            );
                          }

                          final allRecords = snapshot.data!.docs;
                          final filteredRecords = allRecords.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final name = (data['name'] ?? '').toLowerCase();
                            final email = (data['email'] ?? '').toLowerCase();
                            final grade = (data['grade'] ?? '').toLowerCase();
                            final admno = (data['admno'] ?? '');
                            final department =
                                (data['department'] ?? '').toLowerCase();

                            final matchesSearch = searchtext.isEmpty ||
                                name.contains(searchtext.toLowerCase()) ||
                                email.contains(searchtext.toLowerCase()) ||
                                grade.contains(searchtext.toLowerCase()) ||
                                department.contains(searchtext.toLowerCase()) ||
                                admno.contains(searchtext);
                            final matchesGrade =
                                _filterGrade.toLowerCase() == 'all' ||
                                    grade.trim().toLowerCase() ==
                                        _filterGrade.trim().toLowerCase();
                            final matchesDepartment =
                                _filterDepartment.toLowerCase() == 'all' ||
                                    department.trim().toLowerCase() ==
                                        _filterDepartment.trim().toLowerCase();

                            return matchesSearch &&
                                matchesGrade &&
                                matchesDepartment;
                          }).toList();

                          if (filteredRecords.isEmpty) {
                            return const Center(
                              child: Text(
                                'No matching records found.',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            );
                          }

                          print('online: firestore data is used');
                          return RefreshIndicator(
                            onRefresh: () {
                              setState(() {
                                _initializeData();
                                _filterGrade = 'All';
                                _filterDepartment = 'All';
                                SearchBar.text = "";
                                searchtext = "";
                              });
                              return _fetchRecords();
                            },
                            child: Container(
                              height: MediaQuery.of(context).size.height * .72,
                              child: ListView.builder(
                                itemCount: filteredRecords.length,
                                itemBuilder: (context, index) {
                                  final record = filteredRecords[index];
                                  final data =
                                      record.data() as Map<String, dynamic>;
                                  final status = data['status'] ?? 'N/A';
                                  final name = data['name'] ?? 'No name';
                                  final email = data['email'] ?? 'No email';
                                  final score =
                                      num.tryParse(data['score'].toString()) ??
                                          0;
                                  final percentage = num.tryParse(
                                          data['percentage'].toString()) ??
                                      0;
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
                                        SlidingPageTransitionRL(
                                          page:
                                              StudentDetails(docId: record.id),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : FutureBuilder<List<StudentDetailModel>>(
                      future: IsarUserService.isar!.studentDetailModels
                          .where()
                          .findAll(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(child: SizedBox());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text("Error: ${snapshot.error}"));
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Container(
                              height: MediaQuery.of(context).size.height * .75,
                              child: ListView.builder(
                                itemCount: 10,
                                itemBuilder: (context, index) {
                                  return CustomStudentTile(
                                    'Status',
                                    'Student Name',
                                    'student@gmail.com',
                                    0,
                                    0,
                                    'Nil',
                                    () {},
                                  );
                                },
                              ),
                            ),
                          );
                        }

                        final localRecords = snapshot.data!;
                        final filteredRecords = localRecords.where((record) {
                          final name = record.name.toLowerCase();
                          final email = record.email.toLowerCase();
                          final grade = record.grade.toLowerCase();
                          final admno = record.admissionNumber;
                          final department = record.department.toLowerCase();

                          final matchesSearch = searchtext.isEmpty ||
                              name.contains(searchtext.toLowerCase()) ||
                              email.contains(searchtext.toLowerCase()) ||
                              grade.contains(searchtext.toLowerCase()) ||
                              department.contains(searchtext.toLowerCase()) ||
                              admno.contains(searchtext);
                          final matchesGrade = _filterGrade.toLowerCase() ==
                                  'all' ||
                              grade.trim() == _filterGrade.trim().toLowerCase();
                          final matchesDepartment =
                              _filterDepartment.toLowerCase() == 'all' ||
                                  department.trim() ==
                                      _filterDepartment.trim().toLowerCase();

                          return matchesSearch &&
                              matchesGrade &&
                              matchesDepartment;
                        }).toList();
                        filteredRecords.sort((a, b) => a.name
                            .toLowerCase()
                            .compareTo(b.name.toLowerCase()));

                        if (filteredRecords.isEmpty) {
                          return const Center(
                            child: Text(
                              'No matching records found.',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          );
                        }

                        print('offline: isar data is used');
                        return RefreshIndicator(
                          onRefresh: () async {
                            setState(() {});
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height * .72,
                            child: ListView.builder(
                              itemCount: filteredRecords.length,
                              itemBuilder: (context, index) {
                                final record = filteredRecords[index];
                                return CustomStudentTile(
                                  record.status,
                                  record.name,
                                  record.email,
                                  record.score,
                                  record.percentage,
                                  record.grade,
                                  () {
                                    if (record.uid == null ||
                                        record.uid.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text('no id is passed'),
                                          backgroundColor: Colors.red.shade500,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          margin: const EdgeInsets.all(10),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                      print('no passed ${record.uid}');
                                    } else {
                                      print(record.uid);

                                      Navigator.push(
                                        context,
                                        SlidingPageTransitionRL(
                                          page: StudentDetails(
                                            docId: record.uid,
                                            isOffline: !isOnline,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
          if (role == 'Admin' || role == 'Teacher')
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
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
                              SlidingPageTransitionRL(
                                  page: FormViewStudentsMark()))
                          .then((_) {
                        refreshPageData();
                      });
                    },
                    child: const Text(
                      'Add data',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            )
        ],
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
  final TextEditingController _userIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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

  Future<bool> isConnected() async {
    var result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> _submitData() async {
    final status = _statusController.text.trim();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final scoreStr = _scoreController.text.trim();
    final percentageStr = _percentageController.text.trim();
    final grade = _gradeController.text.trim();
    final academicyear = _academicyear.text.trim();
    final department = _department.text.trim();
    final fatherjob = _fatherjob.text.trim();
    final fathername = _fathername.text.trim();
    final fatherphone = _fatherphone.text.trim();
    final hod = _hod.text.trim();
    final motherjob = _motherjob.text.trim();
    final mothername = _mothername.text.trim();
    final motherphone = _motherphone.text.trim();
    final regno = _regno.text.trim();
    final admno = _admno.text.trim();
    final admdateStr = _admdate.text.trim();
    final userid = _userIdController.text.trim();
    final score = double.tryParse(scoreStr) ?? 0.0;
    final percentage = double.tryParse(percentageStr) ?? 0.0;
    final admDateTime = DateFormat('dd-MM-yyyy').parse(admdateStr);

    String localUid = DateTime.now().millisecondsSinceEpoch.toString();

    final recordData = {
      'userId': userid,
      'id': localUid,
      'name': name,
      'email': email,
      'score': score,
      'percentage': percentage,
      'grade': grade,
      'status': status,
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
      'admdate': admDateTime,
      'synced': false,
    };
    await addRecordOffline(recordData);
    print('1');
    bool online = await isConnected();

    if (online) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final admTimestamp = Timestamp.fromDate(admDateTime);

          final docRef =
              await FirebaseFirestore.instance.collection('records').add({
            'userId': userid,
            'name': name,
            'email': email,
            'score': score,
            'percentage': percentage,
            'grade': grade,
            'status': status,
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

          final uid = docRef.id;
          print('3');
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Record added successfully online!"),
            backgroundColor: Colors.green.shade500,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(10),
            duration: const Duration(seconds: 2),
          ));
        }
      } catch (error) {
        print('Firestore Error: $error');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red.shade500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 2),
        ));
      }
    } else {}
  }

  Future<void> addRecordOffline(Map<String, dynamic> recordData) async {
    final studentRecord = StudentDetailModel()
      ..uid =
          recordData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString()
      ..name = recordData['name']
      ..email = recordData['email']
      ..score = recordData['score']
      ..percentage = recordData['percentage']
      ..grade = recordData['grade']
      ..status = recordData['status']
      ..academicYear = recordData['academicyear']
      ..registerNumber = recordData['regno']
      ..admissionNumber = recordData['admno']
      ..admissionDate = recordData['admdate']
      ..department = recordData['department']
      ..hod = recordData['hod']
      ..fatherName = recordData['fathername']
      ..fatherOccupation = recordData['fatherjob']
      ..fatherPhone = recordData['fatherphone']
      ..motherName = recordData['mothername']
      ..motherOccupation = recordData['motherjob']
      ..motherPhone = recordData['motherphone'];

    await IsarUserService.isar!.writeTxn(() async {
      await IsarUserService.isar!.studentDetailModels.put(studentRecord);
      print('Record added locally with UID: ${studentRecord.uid}');
      Navigator.pop(context);
    });
  }

  @override
  void initState() {
    super.initState();
    _scoreController.addListener(_updatePercentageAndGrade);
  }

  void _updatePercentageAndGrade() {
    final scoreText = _scoreController.text.trim();
    if (scoreText.isEmpty) {
      _percentageController.text = '';
      _gradeController.text = '';
      return;
    }

    final score = double.tryParse(scoreText);
    if (score == null || score > 1200) {
      _percentageController.text = '';
      _gradeController.text = '';
      return;
    }

    double percentage = (score / 1200) * 100;
    _percentageController.text = percentage.toStringAsFixed(2);

    String grade;
    if (percentage >= 91) {
      grade = 'A+';
    } else if (percentage >= 81) {
      grade = 'A';
    } else if (percentage >= 71) {
      grade = 'B+';
    } else if (percentage >= 61) {
      grade = 'B';
    } else if (percentage >= 51) {
      grade = 'C+';
    } else if (percentage >= 41) {
      grade = 'C';
    } else if (percentage >= 35) {
      grade = 'D';
    } else {
      grade = 'E';
    }
    _statusController.text = (percentage >= 35) ? 'Passed' : 'Failed';
    _gradeController.text = grade;
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _percentageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Student Data')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    StudentDropdown(
                      emailController: _emailController,
                      nameController: _nameController,
                      userIdController: _userIdController,
                      departmentController: _department,
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      readOnly: true,
                    ),
                    TextFormField(
                      controller: _scoreController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Score'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a score';
                        }
                        final score = double.tryParse(value);
                        if (score == null) {
                          return 'Score must be a number';
                        }
                        if (score > 1200) {
                          return 'Maximum score is 1200';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _percentageController,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Percentage'),
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Percentage cannot be empty';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _gradeController,
                      decoration: const InputDecoration(labelText: 'Grade'),
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a grade';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _statusController,
                      decoration: const InputDecoration(labelText: 'Status'),
                      readOnly: true,
                    ),
                    AcademicYearDropdown(
                      controller: _academicyear,
                    ),
                    TextFormField(
                      controller: _regno,
                      decoration:
                          const InputDecoration(labelText: 'Register Number'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a Register Number';
                        }
                        if (value.length > 6) {
                          return 'Register Number must be only 6 digits';
                        }
                        if (!RegExp(r'^\d+$').hasMatch(value)) {
                          return 'Register Number must contain only digits';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _admno,
                      decoration:
                          const InputDecoration(labelText: "Admission Number"),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter the Admission Number';
                        }
                        if (value.length > 6) {
                          return 'Register Number must be only 6 digits';
                        }
                        if (!RegExp(r'^\d+$').hasMatch(value)) {
                          return 'Register Number must contain only digits';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _admdate,
                      decoration:
                          const InputDecoration(labelText: "Admission Date"),
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please select an admission date';
                        }
                        return null;
                      },
                    ),
                    TextField(
                      controller: _department,
                      decoration: InputDecoration(
                        labelText: 'Department',
                      ),
                      readOnly: true,
                    ),
                    HODDropdown(
                      controller: _hod,
                    ),
                    TextFormField(
                      controller: _fathername,
                      decoration:
                          const InputDecoration(labelText: 'Name of Father'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter father\'s name';
                        }
                        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                          return 'Name should only contain letters';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _fatherphone,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                          labelText: "Father's Phone Number"),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter father\'s phone number';
                        }
                        if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                          return 'Phone number must be 10 digits';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _fatherjob,
                      decoration: const InputDecoration(
                          labelText: "Father's Occupation"),
                    ),
                    TextFormField(
                      controller: _mothername,
                      decoration:
                          const InputDecoration(labelText: 'Name of Mother'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter mother\'s name';
                        }
                        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                          return 'Name should only contain letters';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _motherphone,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                          labelText: "Mother's Phone Number"),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter mother\'s phone number';
                        }
                        if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                          return 'Phone number must be 10 digits';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _motherjob,
                      decoration: const InputDecoration(
                          labelText: "Mother's Occupation"),
                    ),
                    const SizedBox(height: 70),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Container(
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _submitData();
                      }
                    },
                    child: const Text(
                      'Submit',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class HODDropdown extends StatefulWidget {
  final TextEditingController controller;

  HODDropdown({required this.controller});

  @override
  _HODDropdownState createState() => _HODDropdownState();
}

class _HODDropdownState extends State<HODDropdown> {
  List<Map<String, dynamic>> _teachers = [];
  String? _selectedHOD;

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  Future<List<Map<String, dynamic>>> fetchTeachers() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("No logged in user found.");
      return [];
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.uid)
        .get();
    final currentUserData = userDoc.data() ?? {};
    final currentUserRole = currentUserData['role'] ?? '';
    final teacherDepartment = currentUserData['department'] ?? '';

    if (currentUserRole == 'Admin') {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('role', isEqualTo: 'Teacher')
          .orderBy('username')
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'username': doc['username'],
              })
          .toList();
    } else {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('role', isEqualTo: 'Teacher')
          .where('department', isEqualTo: teacherDepartment)
          .orderBy('username')
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'username': doc['username'],
              })
          .toList();
    }
  }

  Future<void> _loadTeachers() async {
    List<Map<String, dynamic>> teachers = await fetchTeachers();
    setState(() {
      _teachers = teachers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _selectedHOD,
      decoration: const InputDecoration(labelText: 'Class Tutor'),
      items: _teachers.map((teacher) {
        return DropdownMenuItem<String>(
          value: teacher['username'],
          child: Text(teacher['username']),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedHOD = value;
          widget.controller.text = value ?? '';
        });
      },
      validator: (value) => value == null ? 'Please select an HOD' : null,
    );
  }
}

class AcademicYearDropdown extends StatefulWidget {
  final TextEditingController controller;

  const AcademicYearDropdown({Key? key, required this.controller})
      : super(key: key);

  @override
  State<AcademicYearDropdown> createState() => _AcademicYearDropdownState();
}

class _AcademicYearDropdownState extends State<AcademicYearDropdown> {
  late String selectedYear;
  late List<String> academicYears;

  @override
  void initState() {
    super.initState();
    academicYears = generateAcademicYears();
    selectedYear = widget.controller.text.isNotEmpty
        ? widget.controller.text
        : academicYears.first;
    widget.controller.text = selectedYear;
  }

  List<String> generateAcademicYears() {
    final currentYear = DateTime.now().year;
    return List<String>.generate(
      12,
      (index) => '${currentYear - index}-${currentYear - index + 1}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedYear,
      decoration: const InputDecoration(labelText: 'Academic Year'),
      items: academicYears.map((year) {
        return DropdownMenuItem<String>(
          value: year,
          child: Text(year),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedYear = value!;
          widget.controller.text = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select an academic year';
        }
        return null;
      },
    );
  }
}

class StudentDropdown extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController nameController;
  final TextEditingController userIdController;
  final TextEditingController departmentController;

  const StudentDropdown({
    Key? key,
    required this.emailController,
    required this.nameController,
    required this.userIdController,
    required this.departmentController,
  }) : super(key: key);

  @override
  _StudentDropdownState createState() => _StudentDropdownState();
}

class _StudentDropdownState extends State<StudentDropdown> {
  List<Map<String, dynamic>> _students = [];
  String? _selectedStudent;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<List<Map<String, dynamic>>> fetchStudents() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("No logged in user found.");
      return [];
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.uid)
        .get();
    final currentUserData = userDoc.data() ?? {};
    final currentUserRole = currentUserData['role'] ?? '';

    Query query = FirebaseFirestore.instance
        .collection('Users')
        .where('role', isEqualTo: 'Student');

    if (currentUserRole != 'Admin') {
      final teacherDepartment = currentUserData['department'] ?? '';
      query = query.where('department', isEqualTo: teacherDepartment);
    }

    QuerySnapshot querySnapshot = await query.get();

    List<Map<String, dynamic>> students = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'username': data['username'],
        'email': data['email'] ?? '',
        'department': data['department'] ?? '',
      };
    }).toList();

    students.sort(
        (a, b) => a['username'].toString().compareTo(b['username'].toString()));
    return students;
  }

  Future<void> _loadStudents() async {
    List<Map<String, dynamic>> students = await fetchStudents();
    setState(() {
      _students = students;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _selectedStudent,
      decoration: const InputDecoration(labelText: 'Select Student'),
      items: _students.map((student) {
        return DropdownMenuItem<String>(
          value: student['id'],
          child: Text(student['username']),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedStudent = value;
          final selectedStudent =
              _students.firstWhere((student) => student['id'] == value);
          widget.emailController.text = selectedStudent['email'] ?? '';
          widget.nameController.text = selectedStudent['username'] ?? '';
          widget.userIdController.text = selectedStudent['id'];
          widget.departmentController.text =
              selectedStudent['department'] ?? '';
          // print("Selected student: $selectedStudent");
        });
      },
      validator: (value) => value == null ? 'Please select a student' : null,
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${score}/1200',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5)),
              SizedBox(
                height: 1,
              ),
              Text("${percentage}%",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5)),
              SizedBox(
                height: 1,
              ),
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

class GradeFilterButton extends StatefulWidget {
  final Function(String) onSelected;

  const GradeFilterButton({Key? key, required this.onSelected})
      : super(key: key);

  @override
  _GradeFilterButtonState createState() => _GradeFilterButtonState();
}

class _GradeFilterButtonState extends State<GradeFilterButton> {
  List<String> grades = ['All'];
  String? currentFilter; // Selected value

  Future<List<String>> fetchGrades() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('records').get();

      final grades = querySnapshot.docs
          .map((doc) => doc.data())
          .map((data) => data['grade'] as String?)
          .where((grade) => grade != null)
          .cast<String>()
          .toSet()
          .toList();

      grades.sort();
      return grades;
    } catch (e) {
      print('Error fetching grades: $e');
      return [];
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
      grades = ['All'] + fetchedGrades;
      currentFilter = grades.first; // Set the default selected value
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: currentFilter,
      // Currently selected value
      items: grades.map((grade) {
        return DropdownMenuItem<String>(
          value: grade,
          child: Text(
            grade == 'All' ? 'All Grades' : 'Grade $grade',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        );
      }).toList(),
      onChanged: (String? value) {
        setState(() {
          currentFilter = value!;
          widget.onSelected(value); // Notify the parent widget
          print(currentFilter); // Debugging print statement
        });
      },
      hint: Text(
        'Select Grade',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.blueGrey),
      dropdownColor: Colors.white,
      underline: Container(height: 0), // Optional: Remove underline
    );
  }
}

class DepartmentFilterButton extends StatefulWidget {
  final Function(String) onSelected;

  const DepartmentFilterButton({Key? key, required this.onSelected})
      : super(key: key);

  @override
  _DepartmentFilterButtonState createState() => _DepartmentFilterButtonState();
}

class _DepartmentFilterButtonState extends State<DepartmentFilterButton> {
  List<String> department = ['All'];
  String? selectedFilter; // Selected value
  String _filterDepartment = '';
  List<DocumentSnapshot> filteredDeptRecords = [];
  List<DocumentSnapshot> allDptRecords = []; // All fetched records

  void _applyDeptFilter() {
    setState(() {
      if (_filterDepartment == 'All') {
        filteredDeptRecords = allDptRecords;
      } else {
        filteredDeptRecords = allDptRecords
            .where((doc) => doc['department'] == _filterDepartment)
            .toList();
      }
    });
  }

  Future<List<String>> fetchDepartments() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('records').get();

      final departments = querySnapshot.docs
          .map((doc) => doc.data())
          .map((data) => data['department'] as String?)
          .where((department) => department != null)
          .cast<String>()
          .toSet()
          .toList();

      departments.sort();
      return departments;
    } catch (e) {
      print('Error fetching departments: $e');
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _fetchDepartments();
    });
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
    final fetchedDepartments = await fetchDepartments();
    setState(() {
      department = ['All'] + fetchedDepartments;
      selectedFilter = department.first; // Set the default selected value
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedFilter,
      items: department.map((String department) {
        return DropdownMenuItem<String>(
          value: department,
          child: Text(
            department == 'All' ? 'All Dept' : department, // Use $grade here
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          selectedFilter = newValue!;
          _filterDepartment = newValue;
          widget.onSelected(newValue!);
          print(selectedFilter); // Debugging print statement
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
      underline: Container(height: 0), // Optional: Remove underline
    );
  }
}

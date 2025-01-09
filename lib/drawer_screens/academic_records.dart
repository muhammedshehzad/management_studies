import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_school/drawer_screens/student_details.dart';
import 'package:side_sheet/side_sheet.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'gradefilter.dart';

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
  List<DocumentSnapshot> allRecords = []; // All fetched records
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
  List<DocumentSnapshot> allDptRecords = []; // All fetched
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
      query = FirebaseFirestore.instance.collection('records');
    });
  }

  void SeachName(String query) {
    setState(() {
      searchtext = query.toLowerCase();
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _filterGrade = 'All';
      _filterDepartment = 'All';
      _fetchDepartments();
      query = FirebaseFirestore.instance.collection('records');
    });
    _fetchRecords();
  }

  Future<void> _fetchDepartments() async {
    final fetchedDepartments = await fetchDepartments();
    setState(() {
      department = ['All'] + fetchedDepartments;
      selectedFilter = department.first; // Set the default selected value
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

  Future<void> _fetchRecords() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('records').get();
      setState(() {
        allRecords = querySnapshot.docs;
        _applyFilter();
        _applyDeptFilter();
      });
    } catch (e) {
      print('Error fetching records: $e');
    }
  }

  void _applyFilter() {
    setState(() {
      if (_filterGrade == 'All') {
        filteredRecords = allRecords;
      } else {
        filteredRecords =
            allRecords.where((doc) => doc['grade'] == _filterGrade).toList();
      }
    });
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

  // void _updateQueryForGrade() {
  //   query = FirebaseFirestore.instance
  //       .collection('records')
  //       .where('grade', isEqualTo: _filterGrade);
  // }

  @override
  Widget build(BuildContext context) {
    final recordStream = records();

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
                                      ElevatedButton(
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
                                    ],
                                  ),
                                ),
                                // Tab Bar
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
                                                  _applyFilter();
                                                });
                                              },
                                            ),
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
                                                  _applyFilter();
                                                });
                                              },
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
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Color(0xff3e948e),
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "Apply Filters",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
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
              icon: Icon(Icons.tune)),
        ],
        title: const Text('Academic Records'),
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
              stream: query?.snapshots(),
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
                  final grade = (data['grade'] ?? '').toLowerCase();
                  final admno = (data['admno'] ?? '');
                  final department = (data['department'] ?? '').toLowerCase();

                  final matchesSearch = searchtext.isEmpty ||
                      name.contains(searchtext.toLowerCase()) ||
                      email.contains(searchtext.toLowerCase()) ||
                      grade.contains(searchtext.toLowerCase()) ||
                      department.contains(searchtext.toLowerCase()) ||
                      admno.contains(searchtext);
                  final matchesGrade = _filterGrade.toLowerCase() == 'all' ||
                      grade.trim().toLowerCase() ==
                          _filterGrade.trim().toLowerCase();
                  final matchesDepartment =
                      _filterDepartment.toLowerCase() == 'all' ||
                          department.trim().toLowerCase() ==
                              _filterDepartment.trim().toLowerCase();

                  return matchesSearch && matchesGrade && matchesDepartment;
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

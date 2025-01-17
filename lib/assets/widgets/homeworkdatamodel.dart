// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:new_school/drawer_screens/homework_assignment.dart';
// import 'package:side_sheet/side_sheet.dart';
// import 'package:syncfusion_flutter_datepicker/datepicker.dart';
//
// import '../../drawer_screens/homework_details.dart';
//
// class HomeWorkScreen extends StatefulWidget {
//   late final String docId;
//
//   @override
//   _HomeWorkScreenState createState() => _HomeWorkScreenState();
// }
//
// class _HomeWorkScreenState extends State<HomeWorkScreen> {
//   static const PAGE_SIZE = 9;
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;
//   String _filterSubject = 'All';
//   String selectedStatus = 'All';
//   List<QueryDocumentSnapshot<Map<String, dynamic>>> allRecords = [];
//   Future<DocumentSnapshot<Map<String, dynamic>>> fetchDetails() async {
//     return firestore.collection('homeworks').doc(widget.docId).get();
//   }
//   Query _query = FirebaseFirestore.instance
//       .collection('homeworks')
//       .orderBy('deadline')
//       .limit(PAGE_SIZE);
//
//   DocumentSnapshot? _lastDocument;
//   bool _allFetched = false;
//   bool _isLoading = false;
//   List<HomeWorkDetailModel> _data = [];
//   final TextEditingController _searchController = TextEditingController();
//
//   List<DocumentSnapshot> filteredSubRecords = [];
//   List<DocumentSnapshot> allSubRecords = [];
//
//   List<Map<String, dynamic>> allstatusRecords = [];
//   List<Map<String, dynamic>> filteredstatusRecords = [];
//
//   DateTime startDate = DateTime.now();
//   DateTime endDate = DateTime.now().add(Duration(days: 300));
//
//   String _selectedDate = '';
//   String _dateCount = '';
//   String _range = '';
//   String _rangeCount = '';
//
//   // Filtered list for local search
//   List<HomeWorkDetailModel> filteredData = [];
//   final TextEditingController Search = TextEditingController();
//   String searchText = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchFirebaseData();
//     _searchController.addListener(_onSearchChanged);
//   }
//   void _onSearchChanged() {
//     setState(() {
//       searchText = _searchController.text.toLowerCase();
//     });
//     _applySearchFilter();  }
//
//   void _applySearchFilter() {
//     setState(() {
//       filteredData = _data.where((homework) {
//         final subject = homework.subject.toLowerCase();
//         final title = homework.title.toLowerCase();
//         final deadline = DateFormat('dd-MM-yyyy').format(homework.deadline);
//         final status = homework.status.toLowerCase();
//
//         // Check if the search text matches any of the fields
//         return title.contains(searchText) ||
//             subject.contains(searchText) ||
//             deadline.contains(searchText) ||
//             status.contains(searchText);
//       }).toList();
//     });
//   }
//
//   void _applyFilters() {
//     setState(() {
//       filteredData = _data.where((homework) {
//         final subject = homework.subject.toLowerCase();
//         final title = homework.title.toLowerCase();
//         final deadline = DateFormat('dd-MM-yyyy').format(homework.deadline);
//         final status = homework.status.toLowerCase();
//
//         final matchesSearch = searchText.isEmpty ||
//             title.contains(searchText) ||
//             subject.contains(searchText) ||
//             deadline.contains(searchText) ||
//             status.contains(searchText);
//
//         final matchesSubject = _filterSubject == 'All' || subject == _filterSubject.toLowerCase();
//         final matchesStatus = selectedStatus == 'All' || status == selectedStatus.toLowerCase();
//
//         return matchesSearch && matchesSubject && matchesStatus;
//       }).toList();
//     });
//   }
//   // void _applyFilters() {
//   //   setState(() {
//   //     _query = FirebaseFirestore.instance
//   //         .collection('homeworks')
//   //         .where('deadline', isGreaterThanOrEqualTo: startDate)
//   //         .where('deadline', isLessThanOrEqualTo: endDate);
//   //
//   //     if (_filterSubject != 'All') {
//   //       _query = _query.where('subject', isEqualTo: _filterSubject);
//   //     }
//   //
//   //     if (selectedStatus != 'All') {
//   //       _query = _query.where('status', isEqualTo: selectedStatus);
//   //     }
//   //
//   //     if (searchText.isNotEmpty) {
//   //       _query = _query.where('title', isGreaterThanOrEqualTo: searchText)
//   //           .where('title', isLessThanOrEqualTo: searchText + '\uf8ff');
//   //     }
//   //   });
//   //
//   //   _data.clear();
//   //   _lastDocument = null;
//   //   _allFetched = false;
//   //   _fetchFirebaseData();
//   // }
//   void _applySubjectFilter() {
//     setState(() {
//       if (_filterSubject == 'All') {
//         filteredSubRecords = allSubRecords; // Show all records
//       } else {
//         filteredSubRecords = allSubRecords
//             .where((doc) => doc['subject'] == _filterSubject)
//             .toList();
//       }
//     });
//   }
//
//
//   void _applystatusFilter() {
//     setState(() {
//       if (selectedStatus == 'All') {
//         filteredstatusRecords = List.from(allstatusRecords);
//       } else {
//         filteredstatusRecords = allstatusRecords
//             .where((doc) => doc['status'] == selectedStatus)
//             .toList();
//       }
//     });
//   }
//
//   void fetchclearquery(DateTime start, DateTime end) {
//     setState(() {
//       _query = FirebaseFirestore.instance
//           .collection('homeworks')
//           .where('deadline', isGreaterThanOrEqualTo: startDate)
//           .where('deadline', isLessThanOrEqualTo: endDate);
//     });
//   }
//
//
//   void clearQuery() {
//     setState(() {
//       _searchController.clear();
//       searchText = '';
//       _filterSubject = 'All';
//       selectedStatus = 'All';
//       _applyFilters();
//     });
//   }
//
//   void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
//     setState(() {
//       if (args.value is PickerDateRange) {
//         startDate = args.value.startDate;
//         endDate = args.value.endDate ?? args.value.startDate;
//         fetchclearquery(startDate, endDate);
//         print('$startDate - $endDate ');
//       } else if (args.value is DateTime) {
//         _selectedDate = args.value.toString();
//       } else if (args.value is List<DateTime>) {
//         _dateCount = args.value.length.toString();
//       } else {
//         _rangeCount = args.value.length.toString();
//       }
//     });
//   }
//
//
//   Future<void> _fetchFirebaseData() async {
//     if (_allFetched || _isLoading) return;
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       QuerySnapshot snapshot;
//       if (_lastDocument == null) {
//         snapshot = await _query.get();
//       } else {
//         snapshot = await _query.startAfterDocument(_lastDocument!).get();
//       }
//
//       if (snapshot.docs.isNotEmpty) {
//         setState(() {
//           _lastDocument = snapshot.docs.last;
//           _data.addAll(snapshot.docs.map((doc) {
//             final data = doc.data() as Map<String, dynamic>;
//             return HomeWorkDetailModel.fromMap(data);
//           }).toList());
//           _applySearchFilter();
//           if (snapshot.docs.length < PAGE_SIZE) {
//             _allFetched = true;
//           }
//         });
//       } else {
//         setState(() {
//           _allFetched = true;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error fetching data: $e');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final searchText = _searchController.text.toLowerCase();
//     final filteredRecords = _data.where((homework) {
//       final subject = homework.subject.toLowerCase();
//       final title = homework.title.toLowerCase();
//       final deadline = DateFormat('dd-MM-yyyy').format(homework.deadline);
//       final status = homework.status.toLowerCase();
//
//       final matchesSearch = searchText.isEmpty ||
//           subject.contains(searchText) ||
//           title.contains(searchText) ||
//           deadline.contains(searchText) ||
//           status.contains(searchText);
//
//       final matchesSubject = _filterSubject == 'All' || subject == _filterSubject.toLowerCase();
//       final matchesStatus = selectedStatus == 'All' || status == selectedStatus.toLowerCase();
//
//       return matchesSearch && matchesSubject && matchesStatus;
//     }).toList();
//
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Homework and Assignments'),
//         centerTitle: true,
//         actions: [
//           IconButton(
//               onPressed: () {
//                 SideSheet.right(
//                   sheetBorderRadius: 6,
//                   body: DefaultTabController(
//                     animationDuration: Duration(milliseconds: 300),
//                     length: 3,
//                     child: StatefulBuilder(
//                       builder: (BuildContext context, StateSetter setState) {
//                         return SizedBox(
//                           height: 400,
//                           child: Column(
//                             children: [
//                               // Header Section
//                               Padding(
//                                 padding: const EdgeInsets.all(16.0),
//                                 child: Row(
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       "Filters",
//                                       style: TextStyle(
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.black87),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               // Tab Bar
//                               TabBar(
//                                 indicatorColor: Color(0xff3e948e),
//                                 labelColor: Colors.black87,
//                                 unselectedLabelColor: Colors.grey,
//                                 tabs: [
//                                   Tab(text: "Subject"),
//                                   Tab(text: "Status"),
//                                   Tab(text: "Date"),
//                                 ],
//                               ),
//                               // Tab Bar Views
//                               Expanded(
//                                 child: TabBarView(
//                                   children: [
//                                     // Grade Tab
//                                     Padding(
//                                       padding: const EdgeInsets.all(16.0),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             "Select a Subject",
//                                             style: TextStyle(
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.w500,
//                                               color: Colors.black87,
//                                             ),
//                                           ),
//                                           SizedBox(height: 12),
//                                           SubjectFilterButton(
//                                               onSelected: (selectedSubject) {
//                                                 setState(() {
//                                                   _filterSubject = selectedSubject;
//                                                   _applySubjectFilter();
//                                                 });
//                                               })
//                                         ],
//                                       ),
//                                     ),
//                                     // Department Tab
//                                     Padding(
//                                       padding: const EdgeInsets.all(16.0),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             "Select a Status",
//                                             style: TextStyle(
//                                               fontSize: 18,
//                                               fontWeight: FontWeight.w600,
//                                               color: Colors.black87,
//                                             ),
//                                           ),
//                                           SizedBox(
//                                             height: 16,
//                                           ),
//                                           Wrap(
//                                             spacing: 14,
//                                             alignment:
//                                             WrapAlignment.spaceEvenly,
//                                             children: [
//                                               ChoiceChip(
//                                                 label: Text("All"),
//                                                 labelStyle: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   color: selectedStatus == "All"
//                                                       ? Colors.white
//                                                       : Colors.black,
//                                                 ),
//                                                 selected:
//                                                 selectedStatus == "All",
//                                                 selectedColor:
//                                                 Colors.blueGrey.shade600,
//                                                 backgroundColor:
//                                                 Colors.blueGrey.shade200,
//                                                 onSelected: (bool selected) {
//                                                   setState(() {
//                                                     selectedStatus = selected
//                                                         ? "All"
//                                                         : selectedStatus;
//                                                     print(
//                                                         "Selected Status: $selectedStatus");
//                                                     _applystatusFilter();
//                                                   });
//                                                 },
//                                               ),
//                                               ChoiceChip(
//                                                 label: Text("Completed"),
//                                                 labelStyle: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   color: selectedStatus ==
//                                                       "Completed"
//                                                       ? Colors.white
//                                                       : Colors.black,
//                                                 ),
//                                                 selected: selectedStatus ==
//                                                     "Completed",
//                                                 selectedColor:
//                                                 Colors.green.shade600,
//                                                 backgroundColor:
//                                                 Colors.green.shade200,
//                                                 onSelected: (bool selected) {
//                                                   setState(() {
//                                                     selectedStatus = selected
//                                                         ? "Completed"
//                                                         : selectedStatus;
//                                                     print(
//                                                         "Selected Status: $selectedStatus");
//                                                     _applystatusFilter();
//                                                   });
//                                                 },
//                                               ),
//                                               ChoiceChip(
//                                                 label: Text("Pending"),
//                                                 labelStyle: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   color: selectedStatus ==
//                                                       "Pending"
//                                                       ? Colors.white
//                                                       : Colors.black,
//                                                 ),
//                                                 selected:
//                                                 selectedStatus == "Pending",
//                                                 selectedColor:
//                                                 Colors.red.shade600,
//                                                 backgroundColor:
//                                                 Colors.red.shade200,
//                                                 onSelected: (bool selected) {
//                                                   setState(() {
//                                                     selectedStatus = selected
//                                                         ? "Pending"
//                                                         : selectedStatus;
//                                                     print(
//                                                         "Selected Status: $selectedStatus");
//                                                     _applystatusFilter();
//                                                   });
//                                                 },
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     // Date Tab
//                                     Padding(
//                                       padding: const EdgeInsets.all(16.0),
//                                       child: Container(
//                                         decoration: BoxDecoration(
//                                           color: Colors.grey[100],
//                                           borderRadius:
//                                           BorderRadius.circular(8),
//                                         ),
//                                         child: Padding(
//                                           padding: const EdgeInsets.all(16.0),
//                                           child: Container(
//                                             decoration: BoxDecoration(
//                                               color: Colors.grey[100],
//                                               borderRadius:
//                                               BorderRadius.circular(8),
//                                             ),
//                                             child: SfDateRangePicker(
//                                               onSelectionChanged:
//                                               _onSelectionChanged,
//                                               selectionMode:
//                                               DateRangePickerSelectionMode
//                                                   .range,
//                                               initialSelectedRange:
//                                               PickerDateRange(
//                                                 DateTime.now().subtract(
//                                                     Duration(days: 6)),
//                                                 DateTime.now(),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.all(16.0),
//                                 child: Container(
//                                   width: MediaQuery.of(context).size.width * .9,
//                                   child: ElevatedButton(
//                                     style: ElevatedButton.styleFrom(
//                                       foregroundColor: Colors.white,
//                                       backgroundColor: Color(0xff3e948e),
//                                       elevation: 3,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(6),
//                                       ),
//                                     ),
//                                     onPressed: () {
//                                       setState(() {
//                                         clearQuery();
//                                       });
//                                       Navigator.pop(context);
//                                     },
//                                     child: Text(
//                                       'Clear Filters',
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   context: context,
//                 );
//               },
//               icon: Icon(Icons.filter_list_sharp))
//         ],
//       ),
//       body: NotificationListener<ScrollNotification>(
//         onNotification: (scrollEnd) {
//           if (scrollEnd.metrics.atEdge && scrollEnd.metrics.pixels > 0) {
//             _fetchFirebaseData();
//           }
//           return true;
//         },
//         child: Column(
//           children: [
//         Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: TextField(
//           controller: _searchController,
//           decoration: InputDecoration(
//             hintText: 'Search homeworks',
//             prefixIcon: const Icon(Icons.search),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//         ),
//       ),
//             SizedBox(
//               height: 12,
//             ),
//             Expanded(child: _buildHomeworkList(filteredRecords)),
//             Container(
//               height: 44,
//               width: MediaQuery.of(context).size.width,
//               margin: EdgeInsets.symmetric(horizontal: 12,vertical: 8),
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   foregroundColor: Colors.white,
//                   backgroundColor: Color(0xff3e948e),
//                   elevation: 5,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                 ),
//                 onPressed: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => HomeWorkDetails()));
//                 },
//                 child: const Text(
//                   'Add data',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHomeworkList(List<HomeWorkDetailModel> records) {
//     if (records.isEmpty && _isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     if (records.isEmpty) {
//       return const Center(
//         child: Text(
//           'No records found.',
//           style: TextStyle(color: Colors.grey, fontSize: 16),
//         ),
//       );
//     }
//     return Expanded(
//       child: ListView.builder(
//         itemCount: records.length + (_allFetched ? 0 : 1),
//         itemBuilder: (context, index) {
//           if (index == records.length) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           final homework = records[index];
//           return CustomStudentTile(
//               homework.subject,
//               homework.title,
//               DateFormat('dd-MM-yyyy').format(homework.deadline),
//               homework.status, () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => HomeworkDetails(docId: homework.docid),
//               ),
//             );
//           });
//         },
//       ),
//     );
//   }
// }
//
// class HomeWorkDetailModel {
//   final String subject;
//   final String title;
//   final DateTime deadline;
//   final String status;
//   final String docid;
//
//   HomeWorkDetailModel({
//     required this.subject,
//     required this.title,
//     required this.deadline,
//     required this.status,
//     required this.docid
//   });
//
//   factory HomeWorkDetailModel.fromMap(Map<String, dynamic> data) {
//     return HomeWorkDetailModel(
//       subject: data['subject'] ?? 'N/A',
//       title: data['title'] ?? 'No title',
//       deadline: (data['deadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
//       status: data['status'] ?? 'No status',
//       docid: data['docid'] ?? 'No data',
//     );
//   }
// }

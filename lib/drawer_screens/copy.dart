// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// import 'homework_assignment.dart';
// import 'homework_details.dart';
// class _HomeWorkScreensState extends State<HomeWorkScreens> {
//   Query? query;
//   String searchtext = '';
//   final TextEditingController Search = TextEditingController();
//   List<String> subject = ['All'];
//   String? selectedsubjectFilter;
//   String _filterSubject = '';
//   List<DocumentSnapshot> filteredSubRecords = [];
//   List<DocumentSnapshot> allSubRecords = [];
//   String selectedStatus = "All";
//   List<Map<String, dynamic>> allstatusRecords = [];
//   List<Map<String, dynamic>> filteredstatusRecords = [];
//   DateTime startDate = DateTime.now();
//   DateTime endDate = DateTime.now().add(Duration(days: 300));
//   String _selectedDate = '';
//   String _dateCount = '';
//   String _range = '';
//   String _rangeCount = '';
//   List<DocumentSnapshot> allRecords = [];
//   DocumentSnapshot? _lastDocument;
//   bool _isLoading = false;
//   bool _allFetched = false;
//   final List<HomeWorkDetailModel> _data = [];
//   ScrollController _scrollController = ScrollController();
//
//   @override
//   void initState() {
//     super.initState();
//     _filterSubject = 'All';
//     query = FirebaseFirestore.instance.collection('homeworks').orderBy('deadline').limit(7);
//     _fetchInitialData();
//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoading && !_allFetched) {
//         _fetchNextBatch(); // Trigger fetching next batch of data when scrolled to bottom
//       }
//     });
//   }
//
//   Future<void> _fetchInitialData() async {
//     final querySnapshot = await FirebaseFirestore.instance.collection('homeworks').limit(7).get();
//     if (querySnapshot.docs.isNotEmpty) {
//       _lastDocument = querySnapshot.docs.last;
//       setState(() {
//         allRecords.addAll(querySnapshot.docs);
//       });
//     }
//   }
//
//   Future<void> _fetchNextBatch() async {
//     if (_isLoading || _allFetched) return;
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     final querySnapshot = await FirebaseFirestore.instance
//         .collection('homeworks')
//         .startAfterDocument(_lastDocument!)
//         .limit(7)
//         .get();
//
//     if (querySnapshot.docs.isNotEmpty) {
//       setState(() {
//         _lastDocument = querySnapshot.docs.last;
//         allRecords.addAll(querySnapshot.docs);
//         _isLoading = false;
//       });
//     } else {
//       setState(() {
//         _allFetched = true; // No more records to fetch
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(6.0),
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),
//               child: TextField(
//                 controller: Search,
//                 onChanged: Seacrhh,
//                 decoration: InputDecoration(
//                   hintText: 'Search homeworks',
//                   filled: true,
//                   fillColor: Colors.blueGrey.shade50,
//                   prefixIcon: const Icon(Icons.search),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 12),
//             Expanded(child: _buildHomeworkList()),
//             // Add data button
//             Container(
//               height: 40,
//               width: MediaQuery.of(context).size.width,
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
//                     context,
//                     MaterialPageRoute(builder: (context) => HomeWorkDetails()),
//                   );
//                 },
//                 child: const Text(
//                   'Add data',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHomeworkList() {
//     return StreamBuilder(
//       stream: query?.snapshots() ??
//           FirebaseFirestore.instance.collection('homeworks').snapshots(),
//       builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         if (snapshot.hasError) {
//           return Center(child: Text("Error: ${snapshot.error}"));
//         }
//
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(
//             child: Text(
//               'No records found.',
//               style: TextStyle(color: Colors.grey, fontSize: 16),
//             ),
//           );
//         }
//
//         final allRecords = snapshot.data!.docs;
//         final filteredRecords = allRecords.map((doc) {
//           final data = doc.data() as Map<String, dynamic>;
//           return HomeWorkDetailModel.fromMap(data);
//         }).toList();
//
//         // Apply filters based on search text, subject, and status
//         final searchFilteredRecords = filteredRecords.where((homework) {
//           final subject = homework.subject.toLowerCase() ?? '';
//           final title = homework.title.toLowerCase() ?? '';
//           final status = homework.status.toLowerCase() ?? '';
//
//           final matchesSearch = searchtext.isEmpty ||
//               subject.contains(searchtext) ||
//               title.contains(searchtext) ||
//               status.contains(searchtext);
//
//           final matchesSubject = _filterSubject.toLowerCase() == 'all' ||
//               subject.trim().toLowerCase() ==
//                   _filterSubject.trim().toLowerCase();
//
//           final matchesStatus = selectedStatus.toLowerCase() == 'all' ||
//               status.trim().toLowerCase() ==
//                   selectedStatus.trim().toLowerCase();
//
//           return matchesSearch && matchesSubject && matchesStatus;
//         }).toList();
//
//         if (searchFilteredRecords.isEmpty) {
//           return const Center(
//             child: Text(
//               'No matching records found.',
//               style: TextStyle(color: Colors.grey, fontSize: 16),
//             ),
//           );
//         }
//
//         return ListView.builder(
//           controller: _scrollController, // Attach the ScrollController
//           itemCount: searchFilteredRecords.length + (_isLoading ? 1 : 0),
//           itemBuilder: (context, index) {
//             if (index == searchFilteredRecords.length && !_isLoading) {
//               return Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: CircularProgressIndicator(),
//               );
//             }
//
//             if (index >= searchFilteredRecords.length) {
//               return SizedBox(); // Avoid accessing out-of-bounds index.
//             }
//
//             final homework = searchFilteredRecords[index];
//
//             return CustomStudentTileHomework(
//               homework.subject,
//               homework.title,
//               DateFormat('dd-MM-yyyy').format(homework.deadline),
//               homework.status,
//                   () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         HomeworkDetails(docId: allRecords[index].id),
//                   ),
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }
// }

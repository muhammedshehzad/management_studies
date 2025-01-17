// List<HomeWorkDetailModel> filteredRecords = [];
// bool _isLoading = false;
// bool _allFetched = false;
// DocumentSnapshot? _lastDocument;
// Query _query = FirebaseFirestore.instance.collection('homeworks');
//
// void fetchFilteredData() async {
//   // Start loading state
//   setState(() {
//     _isLoading = true;
//   });
//
//   // Apply filters directly to Firestore query
//   var query = FirebaseFirestore.instance.collection('homeworks');
//
//   // Apply subject filter
//   if (_filterSubject != 'All') {
//     query = query.where('subject', isEqualTo: _filterSubject);
//   }
//
//   // Apply status filter
//   if (selectedStatus != 'All') {
//     query = query.where('status', isEqualTo: selectedStatus);
//   }
//
//   // Apply date range filter
//   if (_startDate != null && _endDate != null) {
//     query = query
//         .where('deadline', isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate!))
//         .where('deadline', isLessThanOrEqualTo: Timestamp.fromDate(_endDate!));
//   }
//
//   try {
//     // Fetch the filtered data from Firestore
//     final querySnapshot = await query.get();
//
//     // Map Firestore documents to HomeWorkDetailModel
//     filteredRecords = querySnapshot.docs
//         .map((doc) => HomeWorkDetailModel.fromMap(doc.data() as Map<String, dynamic>))
//         .toList();
//
//     setState(() {
//       _isLoading = false;
//     });
//   } catch (e) {
//     print("Error fetching filtered data: $e");
//     setState(() {
//       _isLoading = false;
//     });
//   }
// }
//
// void _applySubjectFilter() {
//   setState(() {
//     if (_filterSubject == 'All') {
//       filteredRecords = allRecords;  // Reset to all records if subject filter is 'All'
//     } else {
//       filteredRecords = allRecords
//           .where((doc) => doc['subject'] == _filterSubject)
//           .toList();
//     }
//   });
// }
//
// void _applyStatusFilter() {
//   setState(() {
//     if (selectedStatus == 'All') {
//       filteredRecords = allRecords;  // Reset to all records if status filter is 'All'
//     } else {
//       filteredRecords = allRecords
//           .where((doc) => doc['status'] == selectedStatus)
//           .toList();
//     }
//   });
// }
//
// void fetchClearQuery(DateTime start, DateTime end) async {
//   setState(() {
//     _query = FirebaseFirestore.instance
//         .collection('homeworks')
//         .where('deadline', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
//         .where('deadline', isLessThanOrEqualTo: Timestamp.fromDate(end));
//     filteredRecords.clear();
//     _allFetched = false;
//     _lastDocument = null;
//   });
//
//   await fetchFilteredData();  // Call to fetch the data based on date filter
// }
//
// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: AppBar(
//       title: Text('Homework and Assignments'),
//       centerTitle: true,
//       actions: [
//         IconButton(
//             onPressed: () {
//               SideSheet.right(
//                 sheetBorderRadius: 6,
//                 body: DefaultTabController(
//                   animationDuration: Duration(milliseconds: 300),
//                   length: 3,
//                   child: StatefulBuilder(
//                     builder: (BuildContext context, StateSetter setState) {
//                       return SizedBox(
//                         height: 400,
//                         child: Column(
//                           children: [
//                             // Filter UI for subject, status, and date range here...
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 context: context,
//               );
//             },
//             icon: Icon(Icons.filter_list_sharp))
//       ],
//     ),
//     body: NotificationListener<ScrollNotification>(
//       onNotification: (scrollEnd) {
//         if (scrollEnd.metrics.pixels >=
//             scrollEnd.metrics.maxScrollExtent * 0.1 &&
//             !_isLoading &&
//             !_allFetched) {
//           _fetchFirebaseData();  // Fetch more data if needed
//         }
//         if (scrollEnd.metrics.atEdge &&
//             scrollEnd.metrics.pixels >=
//                 scrollEnd.metrics.maxScrollExtent * 0.1 &&
//             !_isLoading &&
//             !_allFetched) {
//           _fetchFirebaseData();  // Fetch more data if needed
//         }
//         return true;
//       },
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search homeworks',
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               onChanged: (value) {
//                 setState(() {
//                   searchText = value.toLowerCase();
//                 });
//                 fetchFilteredData(); // Update filtered data when search text changes
//               },
//             ),
//           ),
//           SizedBox(
//             height: 12,
//           ),
//           Expanded(child: _buildHomeworkList(filteredRecords)),
//           Container(
//             height: 44,
//             width: MediaQuery.of(context).size.width,
//             margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 foregroundColor: Colors.white,
//                 backgroundColor: Color(0xff3e948e),
//                 elevation: 5,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//               ),
//               onPressed: () {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => HomeWorkDetails()));
//               },
//               child: const Text(
//                 'Add data',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//           )
//         ],
//       ),
//     ),
//   );
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:uuid/uuid.dart';
//
// import '../new.dart';
// import '../sliding_transition.dart';
//
// class LeavesPage extends StatefulWidget {
//   const LeavesPage({super.key});
//
//   @override
//   State<LeavesPage> createState() => _LeavesPageState();
// }
//
// class _LeavesPageState extends State<LeavesPage> {
//   User? user = FirebaseAuth.instance.currentUser;
//
//   final TextEditingController submitLeavetypeController =
//   TextEditingController();
//   final TextEditingController submitStartDateController =
//   TextEditingController();
//   final TextEditingController submitEndDateController = TextEditingController();
//   final TextEditingController submitLeaveReasonController =
//   TextEditingController();
//   String role = "";
//   String name = "";
//   List currentData = [];
//   final TextEditingController detailNameController = TextEditingController();
//   final TextEditingController detailLeavetypeController =
//   TextEditingController();
//   final TextEditingController detailStatusController = TextEditingController();
//   final TextEditingController detailStartDateController =
//   TextEditingController();
//   final TextEditingController detailEndDateController = TextEditingController();
//   final TextEditingController detailDurationController =
//   TextEditingController();
//   final TextEditingController detailDepartmentController =
//   TextEditingController();
//   String userName = '';
//   bool isLoading = false;
//   final TextEditingController _searchController = TextEditingController();
//   String _searchText = '';
//
//   Future<String> fetchUserName() async {
//     User? currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser != null) {
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('Users')
//           .doc(currentUser.uid)
//           .get();
//
//       if (userDoc.exists && userDoc.data() != null) {
//         var userData = userDoc.data() as Map<String, dynamic>;
//         return userData['username'] ?? 'Unknown User';
//       }
//     }
//     return 'Unknown User';
//   }
//
//   void _onSearchChanged(String value) {
//     setState(() {
//       _searchText = value.toLowerCase();
//     });
//   }
//
//   bool _matchesSearch(Map<String, dynamic> leave, String searchText) {
//     if (searchText.isEmpty) return true;
//
//     final username = leave['username']?.toString().toLowerCase() ?? '';
//     final status = leave['status']?.toString().toLowerCase() ?? '';
//     final duration = leave['durationDays']?.toString() ?? '';
//     final leaveType = leave['leaveType']?.toString().toLowerCase() ?? '';
//     final department = leave['userDepartment']?.toString().toLowerCase() ?? '';
//     final reason = leave['leaveReason']?.toString().toLowerCase() ?? '';
//
//     return username.contains(searchText) ||
//         status.contains(searchText) ||
//         duration.contains(searchText) ||
//         leaveType.contains(searchText) ||
//         department.contains(searchText) ||
//         reason.contains(searchText);
//   }
//
//   void getData() {
//     final User? currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) {
//       print("No user logged in.");
//       return;
//     }
//     final uid = currentUser.uid;
//
//     setState(() {
//       isLoading = true;
//     });
//
//     FirebaseFirestore.instance
//         .collection('Users')
//         .doc(uid)
//         .get()
//         .then((DocumentSnapshot docSnapshot) {
//       if (docSnapshot.exists) {
//         final data = docSnapshot.data() as Map<String, dynamic>?;
//         if (data != null && mounted) {
//           setState(() {
//             role = data['role'] ?? "";
//             name = data['username'] ?? "";
//           });
//
//           if (role.toLowerCase() == "student") {
//             StudentQuery(uid);
//           } else if (role.toLowerCase() == "teacher") {
//             TeacherQuery();
//           } else {
//             print("User role is not student or teacher.");
//             setState(() {
//               isLoading = false;
//             });
//           }
//         }
//       } else {
//         print('Document does not exist in database');
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }).catchError((error) {
//       print('Failed to fetch user data: $error');
//       setState(() {
//         isLoading = false;
//       });
//     });
//   }
//
//   void StudentQuery(String userId) {
//     FirebaseFirestore.instance
//         .collection('Leaves')
//         .where("creator_role", isEqualTo: "student")
//         .where("userId", isEqualTo: userId)
//         .orderBy("startDate")
//         .get()
//         .then((querySnapshot) {
//       setState(() {
//         currentData = querySnapshot.docs;
//         isLoading = false;
//       });
//     }).catchError((error) {
//       print('Failed to fetch leave records for the student: $error');
//       setState(() {
//         isLoading = false;
//       });
//     });
//   }
//
//   void TeacherQuery() {
//     FirebaseFirestore.instance
//         .collection('Leaves')
//         .where("creator_role", isEqualTo: "student")
//         .orderBy("startDate")
//         .get()
//         .then((querySnapshot) {
//       setState(() {
//         currentData = querySnapshot.docs;
//         isLoading = false;
//       });
//     }).catchError((error) {
//       print('Failed to fetch leave records for students: $error');
//       setState(() {
//         isLoading = false;
//       });
//     });
//   }
//
//   Stream<QuerySnapshot> fetchStudentLeavesStream() {
//     return FirebaseFirestore.instance
//         .collection('Leaves')
//         .where("creator_role", isEqualTo: "student")
//         .orderBy("createdAt", descending: true)
//         .snapshots();
//   }
//
//   Stream<List<Map<String, dynamic>>> streamTeacherLeaves() {
//     return FirebaseFirestore.instance
//         .collection('Leaves')
//         .where("creator_role", isEqualTo: "teacher")
//         .orderBy("startDate")
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//         .map((doc) =>
//     {"leavesid": doc.id, ...doc.data() as Map<String, dynamic>})
//         .toList());
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     fetchUserName().then((name) {
//       setState(() {
//         userName = name;
//       });
//     });
//     getData();
//   }
//
//   void showLeaveDetails(BuildContext context, Map<String, dynamic> leave) {
//     final DateFormat formatter = DateFormat('yyyy-MM-dd');
//     final startDate = leave["startDate"] is Timestamp
//         ? (leave["startDate"] as Timestamp).toDate()
//         : null;
//     final endDate = leave["endDate"] is Timestamp
//         ? (leave["endDate"] as Timestamp).toDate()
//         : null;
//     final duration = leave["durationDays"]?.toString() ?? "N/A";
//     final creatorRole = leave["creator_role"]?.toString() ?? "N/A";
//     final leaveStatus = leave["status"]?.toString() ?? "Pending";
//
//     final User? currentUser = FirebaseAuth.instance.currentUser;
//     final uid = currentUser?.uid;
//     if (uid == null) return;
//
//     FirebaseFirestore.instance
//         .collection('Users')
//         .doc(uid)
//         .get()
//         .then((userDoc) {
//       if (!userDoc.exists) return;
//       final userRole = userDoc.data()?["role"] ?? "N/A";
//
//       // Determine whether the leave details are editable.
//       final bool canEdit =
//           (userRole == 'Student' && leaveStatus == "Pending") ||
//               (userRole == 'Teacher' &&
//                   creatorRole == 'teacher' &&
//                   leaveStatus == "Pending");
//
//       showModalBottomSheet(
//         context: context,
//         isScrollControlled: true,
//         builder: (context) => Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Top row: title, edit (if allowed) and close buttons.
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Leave Details',
//                     style: Theme.of(context).textTheme.headlineSmall,
//                   ),
//                   Row(
//                     children: [
//                       if (canEdit)
//                         IconButton(
//                           icon: const Icon(Icons.edit),
//                           onPressed: () {
//                             Navigator.pop(context);
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) =>
//                                     SubmitLeavePage(leave: leave),
//                               ),
//                             );
//                           },
//                         ),
//                       IconButton(
//                         icon: const Icon(Icons.close),
//                         onPressed: () => Navigator.pop(context),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               const Divider(),
//               _buildDetailRow(
//                   'User Name:', leave["username"], detailNameController,
//                   readOnly: true),
//               _buildDetailRow(
//                   'Type:', leave["leaveType"], detailLeavetypeController,
//                   readOnly: true),
//               _buildDetailRow('Status:', leaveStatus, detailStatusController,
//                   readOnly: true),
//               _buildDetailRow(
//                   'Start Date:',
//                   startDate != null ? formatter.format(startDate) : "N/A",
//                   detailStartDateController,
//                   readOnly: true),
//               _buildDetailRow(
//                   'End Date:',
//                   endDate != null ? formatter.format(endDate) : "N/A",
//                   detailEndDateController,
//                   readOnly: true),
//               _buildDetailRow(
//                   'Duration:', '$duration days', detailDurationController,
//                   readOnly: true),
//               _buildDetailRow('Department:', leave["userDepartment"] ?? "N/A",
//                   detailDepartmentController,
//                   readOnly: true),
//               const SizedBox(height: 10),
//               const Text('Reason:',
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//               const SizedBox(height: 5),
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(leave["leaveReason"] ?? "No reason provided"),
//               ),
//               const SizedBox(height: 20),
//               // Approve/Reject buttons for teachers or admins.
//               if (userRole == 'Teacher' && creatorRole == 'student')
//                 ApproveRejectButtons(
//                   initialStatus: leave['status'] ?? 'Pending',
//                   leaveId: leave['leavesid'],
//                 ),
//
//               if (userRole == 'Admin' && creatorRole == 'teacher')
//                 ApproveRejectButtons(
//                   initialStatus: leave['status'] ?? 'Pending',
//                   leaveId: leave['leavesid'],
//                 ),
//             ],
//           ),
//         ),
//       );
//     });
//   }
//
//   // Future<List<Map<String, dynamic>>> fetchLeaves() async {
//   //   final currentUser = FirebaseAuth.instance.currentUser;
//   //   if (currentUser == null) return [];
//   //   QuerySnapshot snapshot = await FirebaseFirestore.instance
//   //       .collection('Leaves')
//   //       .where('userId', isEqualTo: currentUser.uid)
//   //       .orderBy('createdAt',descending: true)
//   //       .get();
//   //   return snapshot.docs
//   //       .map((doc) => doc.data() as Map<String, dynamic>)
//   //       .toList();
//   // }
//   Stream<QuerySnapshot> fetchLeaves() {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     return FirebaseFirestore.instance
//         .collection('Leaves')
//         .where("userId", isEqualTo: currentUser?.uid)
//         .orderBy("createdAt", descending: true)
//         .snapshots();
//   }
//
//   Future<Map<String, dynamic>> fetchUser() async {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) {
//       throw Exception("No user is currently logged in.");
//     }
//     final doc = await FirebaseFirestore.instance
//         .collection('Users')
//         .doc(currentUser.uid)
//         .get();
//     if (!doc.exists) {
//       throw Exception("User details not found in Firestore.");
//     }
//     return doc.data() as Map<String, dynamic>;
//   }
//
//   Stream<Map<String, dynamic>> fetchUserDetails() {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) {
//       return Stream.error("No user is currently logged in.");
//     }
//
//     return FirebaseFirestore.instance
//         .collection('Users').where('field')
//         .doc(currentUser.uid)
//         .snapshots()
//         .map((snapshot) {
//       if (!snapshot.exists) {
//         throw Exception("User details not found in Firestore.");
//       }
//       return snapshot.data() as Map<String, dynamic>;
//     });
//   }
//
//   Stream<QuerySnapshot> fetchTeacherLeaves() {
//     return FirebaseFirestore.instance
//         .collection('Leaves')
//         .where("creator_role", isEqualTo: "teacher")
//         .orderBy("createdAt", descending: true)
//         .snapshots();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Leave Requests'),
//         centerTitle: true,
//       ),
//       body: Stack(
//         children: [
//           CustomScrollView(
//             physics: const NeverScrollableScrollPhysics(),
//             slivers: [
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         flex: 10,
//                         child: TextField(
//                           controller: _searchController,
//                           decoration: InputDecoration(
//                             hintText: 'Search leaves...',
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide:
//                               BorderSide(color: Colors.black54, width: 1.5),
//                             ),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             prefixIcon: const Icon(Icons.search),
//                             contentPadding: const EdgeInsets.symmetric(
//                                 vertical: 0, horizontal: 10),
//                           ),
//                           onChanged: _onSearchChanged,
//                         ),
//                       ),
//                       Expanded(
//                         flex: 1,
//                         child: IconButton(
//                           onPressed: () {},
//                           icon: Icon(Icons.filter_list,
//                               color: Colors.grey.shade800),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SliverFillRemaining(
//                 child: FutureBuilder<Map<String, dynamic>>(
//                   future: fetchUser(),
//                   builder: (context, userSnapshot) {
//                     if (userSnapshot.connectionState ==
//                         ConnectionState.waiting) {
//                       return const Center(child: CircularProgressIndicator());
//                     }
//                     if (userSnapshot.hasError) {
//                       return Center(
//                           child: Text('Error: ${userSnapshot.error}'));
//                     }
//                     if (!userSnapshot.hasData) {
//                       return const Center(
//                           child: Text('No user details found.'));
//                     }
//
//                     final userData = userSnapshot.data!;
//                     final role = userData['role']?.toLowerCase() ?? '';
//                     final isTeacher = role == 'teacher';
//                     final isAdmin = role == 'admin';
//
//                     if (isTeacher) {
//                       return Stack(
//                         children: [
//                           DefaultTabController(
//                             length: 2,
//                             child: Column(
//                               children: [
//                                 const TabBar(
//                                   tabs: [
//                                     Tab(text: 'Leave Requests'),
//                                     Tab(text: 'Leave Approvals'),
//                                   ],
//                                   indicatorColor: Colors.blueGrey,
//                                 ),
//                                 Expanded(
//                                   child: TabBarView(
//                                     children: [
//                                       // First Tab: Leave Requests (For Teachers)
//                                       isLoading
//                                           ? const Center(
//                                           child:
//                                           CircularProgressIndicator())
//                                           : currentData.isEmpty
//                                           ? const Center(
//                                           child: Text(
//                                               'No student leave requests found.'))
//                                           : StreamBuilder<
//                                           Map<String, dynamic>>(
//                                         stream: fetchUserDetails(),
//                                         builder:
//                                             (context, userSnapshot) {
//                                           if (userSnapshot
//                                               .connectionState ==
//                                               ConnectionState
//                                                   .waiting) {
//                                             return const Center(
//                                                 child:
//                                                 CircularProgressIndicator());
//                                           }
//                                           if (userSnapshot.hasError) {
//                                             return Center(
//                                                 child: Text(
//                                                     'Error: ${userSnapshot.error}'));
//                                           }
//                                           if (!userSnapshot.hasData) {
//                                             return const Center(
//                                                 child: Text(
//                                                     'No user details found.'));
//                                           }
//
//                                           final userData =
//                                           userSnapshot.data!;
//                                           final role =
//                                           (userData['role'] ?? '')
//                                               .toString()
//                                               .toLowerCase();
//
//                                           // Adjust the role check if needed.
//                                           final isTeacher =
//                                               role == 'teacher';
//
//                                           if (isTeacher) {
//                                             if (isLoading) {
//                                               return const Center(
//                                                   child:
//                                                   CircularProgressIndicator());
//                                             }
//                                             if (currentData.isEmpty) {
//                                               return const Center(
//                                                   child: Text(
//                                                       'No student leave requests found.'));
//                                             }
//
//                                             return Expanded(
//                                               child: ListView.builder(
//                                                 itemCount: currentData
//                                                     .length,
//                                                 itemBuilder:
//                                                     (context, index) {
//                                                   final doc =
//                                                   currentData[
//                                                   index];
//                                                   final leave = Map<
//                                                       String,
//                                                       dynamic>.from(
//                                                       doc.data()
//                                                       as Map);
//
//                                                   if (!_matchesSearch(
//                                                       leave,
//                                                       _searchText)) {
//                                                     return const SizedBox
//                                                         .shrink();
//                                                   }
//                                                   final startDate =
//                                                   (leave["startDate"]
//                                                   as Timestamp)
//                                                       .toDate();
//                                                   final endDate =
//                                                   (leave["endDate"]
//                                                   as Timestamp)
//                                                       .toDate();
//                                                   final duration = endDate
//                                                       .difference(
//                                                       startDate)
//                                                       .inDays +
//                                                       1;
//
//                                                   return Padding(
//                                                     padding:
//                                                     const EdgeInsets
//                                                         .symmetric(
//                                                         horizontal:
//                                                         8.0),
//                                                     child: Card(
//                                                       margin: const EdgeInsets
//                                                           .symmetric(
//                                                           vertical:
//                                                           8),
//                                                       child: ListTile(
//                                                         contentPadding:
//                                                         const EdgeInsets
//                                                             .all(
//                                                             16),
//                                                         onTap: () =>
//                                                             showLeaveDetails(
//                                                                 context,
//                                                                 leave),
//                                                         subtitle:
//                                                         Text(
//                                                           'User: ${leave["username"]}\n'
//                                                               'Leave Type: ${leave["leaveType"]}\n'
//                                                               'Status: ${leave["status"] ?? "Pending"}\n'
//                                                               'From: ${startDate.toLocal().toString().split(' ')[0]}, '
//                                                               'To: ${endDate.toLocal().toString().split(' ')[0]}\n'
//                                                               'Duration: $duration days',
//                                                         ),
//                                                         trailing:
//                                                         const Icon(
//                                                             Icons
//                                                                 .arrow_forward_ios),
//                                                       ),
//                                                     ),
//                                                   );
//                                                 },
//                                               ),
//                                             );
//                                           } else {
//                                             return StreamBuilder<
//                                                 QuerySnapshot>(
//                                               stream: fetchLeaves(),
//                                               builder: (context,
//                                                   snapshot) {
//                                                 if (snapshot
//                                                     .connectionState ==
//                                                     ConnectionState
//                                                         .waiting) {
//                                                   return const Center(
//                                                       child:
//                                                       CircularProgressIndicator());
//                                                 }
//                                                 if (snapshot
//                                                     .hasError) {
//                                                   return Center(
//                                                       child: Text(
//                                                           'Error: ${snapshot.error}'));
//                                                 }
//                                                 if (!snapshot
//                                                     .hasData ||
//                                                     snapshot
//                                                         .data!
//                                                         .docs
//                                                         .isEmpty) {
//                                                   return const Center(
//                                                       child: Text(
//                                                           'No leave requests found.'));
//                                                 }
//
//                                                 final filteredDocs =
//                                                 snapshot
//                                                     .data!.docs
//                                                     .where((doc) {
//                                                   final data = Map<
//                                                       String,
//                                                       dynamic>.from(
//                                                       doc.data()
//                                                       as Map);
//                                                   return _matchesSearch(
//                                                       data,
//                                                       _searchText);
//                                                 }).toList();
//
//                                                 return ListView
//                                                     .builder(
//                                                   itemCount:
//                                                   filteredDocs
//                                                       .length,
//                                                   itemBuilder:
//                                                       (context,
//                                                       index) {
//                                                     final doc =
//                                                     filteredDocs[
//                                                     index];
//                                                     final leave = Map<
//                                                         String,
//                                                         dynamic>.from(doc
//                                                         .data()
//                                                     as Map);
//                                                     final startDate = leave[
//                                                     "startDate"]
//                                                     is Timestamp
//                                                         ? (leave["startDate"]
//                                                     as Timestamp)
//                                                         .toDate()
//                                                         : null;
//                                                     final endDate = leave[
//                                                     "endDate"]
//                                                     is Timestamp
//                                                         ? (leave["endDate"]
//                                                     as Timestamp)
//                                                         .toDate()
//                                                         : null;
//                                                     String duration =
//                                                         "Unknown";
//                                                     if (startDate !=
//                                                         null &&
//                                                         endDate !=
//                                                             null) {
//                                                       final diffDays = endDate
//                                                           .difference(
//                                                           startDate)
//                                                           .inDays;
//                                                       duration =
//                                                       diffDays ==
//                                                           0
//                                                           ? '1 day'
//                                                           : '$diffDays days';
//                                                     }
//
//                                                     return Padding(
//                                                       padding: const EdgeInsets
//                                                           .symmetric(
//                                                           horizontal:
//                                                           8.0),
//                                                       child: Card(
//                                                         margin: const EdgeInsets
//                                                             .symmetric(
//                                                             vertical:
//                                                             8),
//                                                         child:
//                                                         ListTile(
//                                                           contentPadding:
//                                                           const EdgeInsets
//                                                               .all(
//                                                               16),
//                                                           onTap: () =>
//                                                               showLeaveDetails(
//                                                                   context,
//                                                                   leave),
//                                                           subtitle:
//                                                           Text(
//                                                             'Leave Type: ${leave["leaveType"]}\n'
//                                                                 'Status: ${leave["status"] ?? "Pending"}\n'
//                                                                 'From: ${startDate?.toLocal().toString().split(' ')[0] ?? "Unknown"}, '
//                                                                 'To: ${endDate?.toLocal().toString().split(' ')[0] ?? "Unknown"}\n'
//                                                                 'Duration: $duration',
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     );
//                                                   },
//                                                 );
//                                               },
//                                             );
//                                           }
//                                         },
//                                       ),
//                                       StreamBuilder<QuerySnapshot>(
//                                         stream: fetchStudentLeavesStream(),
//                                         builder: (context, snapshot) {
//                                           if (snapshot.connectionState ==
//                                               ConnectionState.waiting) {
//                                             return const Center(
//                                                 child:
//                                                 CircularProgressIndicator());
//                                           }
//                                           if (snapshot.hasError) {
//                                             return Center(
//                                                 child: Text(
//                                                     'Error: ${snapshot.error}'));
//                                           }
//                                           if (!snapshot.hasData ||
//                                               snapshot.data!.docs.isEmpty) {
//                                             return const Center(
//                                                 child: Text(
//                                                     'No student leave requests found.'));
//                                           }
//                                           final filteredDocs =
//                                           snapshot.data!.docs.where((doc) {
//                                             final data =
//                                             Map<String, dynamic>.from(
//                                                 doc.data() as Map);
//                                             return _matchesSearch(
//                                                 data, _searchText);
//                                           }).toList();
//
//                                           final leaves =
//                                           snapshot.data!.docs.map((doc) {
//                                             return Map<String, dynamic>.from(
//                                                 doc.data() as Map);
//                                           }).toList();
//
//                                           return ListView.builder(
//                                             itemCount: filteredDocs.length,
//                                             itemBuilder: (context, index) {
//                                               final leave = leaves[index];
//                                               final startDate =
//                                               leave["startDate"]
//                                               is Timestamp
//                                                   ? (leave["startDate"]
//                                               as Timestamp)
//                                                   .toDate()
//                                                   : null;
//                                               final endDate =
//                                               leave["endDate"] is Timestamp
//                                                   ? (leave["endDate"]
//                                               as Timestamp)
//                                                   .toDate()
//                                                   : null;
//                                               String duration = "Unknown";
//                                               if (startDate != null &&
//                                                   endDate != null) {
//                                                 final diffDays = endDate
//                                                     .difference(startDate)
//                                                     .inDays;
//                                                 duration = diffDays == 0
//                                                     ? '1 day'
//                                                     : '$diffDays days';
//                                               }
//
//                                               return Padding(
//                                                 padding:
//                                                 const EdgeInsets.symmetric(
//                                                     horizontal: 8.0),
//                                                 child: Card(
//                                                   margin: const EdgeInsets
//                                                       .symmetric(vertical: 8),
//                                                   child: ListTile(
//                                                     contentPadding:
//                                                     const EdgeInsets.all(
//                                                         16),
//                                                     onTap: () =>
//                                                         showLeaveDetails(
//                                                             context, leave),
//                                                     subtitle: Column(
//                                                       crossAxisAlignment:
//                                                       CrossAxisAlignment
//                                                           .start,
//                                                       children: [
//                                                         Text(
//                                                           'Student Name: ${leave["username"]}\n'
//                                                               'Leave Type: ${leave["leaveType"]}\n'
//                                                               'Status: ${leave["status"] ?? "Pending"}\n'
//                                                               'From: ${startDate?.toLocal().toString().split(' ')[0] ?? "Unknown"}, '
//                                                               'To: ${endDate?.toLocal().toString().split(' ')[0] ?? "Unknown"}\n'
//                                                               'Duration: $duration',
//                                                         ),
//                                                         const SizedBox(
//                                                             height: 8),
//                                                         ApproveRejectButtons(
//                                                           initialStatus:
//                                                           leave['status'] ??
//                                                               'Pending',
//                                                           leaveId:
//                                                           leave['leavesid'],
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ),
//                                               );
//                                             },
//                                           );
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Align(
//                             alignment: Alignment.bottomRight,
//                             child: Padding(
//                               padding: const EdgeInsets.all(20.0),
//                               child: SizedBox(
//                                 child: ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     foregroundColor: Colors.white,
//                                     backgroundColor: const Color(0xff3e948e),
//                                     elevation: 3,
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(6)),
//                                   ),
//                                   onPressed: () async {
//                                     final bool? shouldRefresh =
//                                     await Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                             builder: (context) =>
//                                             const SubmitLeavePage()));
//                                     if (shouldRefresh == true) {
//                                       getData();
//                                     }
//                                   },
//                                   child: Text(
//                                     'Add Leave',
//                                     style:
//                                     TextStyle(fontWeight: FontWeight.bold),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           )
//                         ],
//                       );
//                     } else if (isAdmin) {
//                       return StreamBuilder<QuerySnapshot>(
//                         stream: fetchTeacherLeaves(),
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState ==
//                               ConnectionState.waiting) {
//                             return const Center(
//                                 child: CircularProgressIndicator());
//                           }
//                           if (snapshot.hasError) {
//                             return Center(
//                                 child: Text('Error: ${snapshot.error}'));
//                           }
//                           if (!snapshot.hasData ||
//                               snapshot.data!.docs.isEmpty) {
//                             return const Center(
//                                 child:
//                                 Text('No teacher leave requests found.'));
//                           }
//
//                           final filteredDocs = snapshot.data!.docs.where((doc) {
//                             final data = doc.data() as Map<String, dynamic>;
//                             return _matchesSearch(data, _searchText);
//                           }).toList();
//
//                           return ListView.builder(
//                             itemCount: filteredDocs.length,
//                             itemBuilder: (context, index) {
//                               final doc = filteredDocs[index];
//                               final data = doc.data() as Map<String,
//                                   dynamic>; // Explicit conversion
//
//                               final startDate = data["startDate"] is Timestamp
//                                   ? (data["startDate"] as Timestamp).toDate()
//                                   : null;
//                               final endDate = data["endDate"] is Timestamp
//                                   ? (data["endDate"] as Timestamp).toDate()
//                                   : null;
//                               String duration = "Unknown";
//
//                               if (startDate != null && endDate != null) {
//                                 final diffDays =
//                                     endDate.difference(startDate).inDays;
//                                 duration =
//                                 diffDays == 0 ? '1 day' : '$diffDays days';
//                               }
//
//                               return Padding(
//                                 padding:
//                                 const EdgeInsets.symmetric(horizontal: 8.0),
//                                 child: Card(
//                                   margin:
//                                   const EdgeInsets.symmetric(vertical: 8),
//                                   child: ListTile(
//                                     contentPadding: const EdgeInsets.all(16),
//                                     onTap: () =>
//                                         showLeaveDetails(context, data),
//                                     // Pass `data` instead of `doc`
//                                     subtitle: Column(
//                                       crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           'Teacher Name: ${data["username"] ?? "Unknown"}\n'
//                                               'Leave Type: ${data["leaveType"] ?? "Unknown"}\n'
//                                               'Status: ${data["status"] ?? "Pending"}\n'
//                                               'From: ${startDate?.toLocal().toString().split(' ')[0] ?? "Unknown"}, '
//                                               'To: ${endDate?.toLocal().toString().split(' ')[0] ?? "Unknown"}\n'
//                                               'Duration: $duration',
//                                         ),
//                                         const SizedBox(height: 8),
//                                         ApproveRejectButtons(
//                                           initialStatus:
//                                           data['status'] ?? 'Pending',
//                                           leaveId: data['leavesid'] ?? '',
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             },
//                           );
//                         },
//                       );
//                     } else {
//                       return Stack(
//                         children: [
//                           StreamBuilder(
//                             stream: fetchLeaves(),
//                             builder: (context, snapshot) {
//                               if (snapshot.connectionState ==
//                                   ConnectionState.waiting) {
//                                 return const Center(
//                                     child: CircularProgressIndicator());
//                               }
//                               if (snapshot.hasError) {
//                                 return Center(
//                                     child: Text('Error: ${snapshot.error}'));
//                               }
//                               if (!snapshot.hasData ||
//                                   snapshot.data!.docs.isEmpty) {
//                                 return const Center(
//                                     child: Text('No leave requests found.'));
//                               }
//                               final filteredDocs =
//                               snapshot.data!.docs.where((doc) {
//                                 final data = doc.data() as Map<String, dynamic>;
//                                 return _matchesSearch(data, _searchText);
//                               }).toList();
//                               final leaves = snapshot.data!.docs
//                                   .map((doc) =>
//                               doc.data() as Map<String, dynamic>)
//                                   .toList();
//                               return ListView.builder(
//                                 itemCount: filteredDocs.length,
//                                 itemBuilder: (context, index) {
//                                   final leave = leaves[index];
//                                   final doc = filteredDocs[index];
//                                   final data =
//                                   doc.data() as Map<String, dynamic>;
//                                   final startDate = doc["startDate"]
//                                   is Timestamp
//                                       ? (doc["startDate"] as Timestamp).toDate()
//                                       : null;
//                                   final endDate = doc["endDate"] is Timestamp
//                                       ? (doc["endDate"] as Timestamp).toDate()
//                                       : null;
//                                   String duration = "Unknown";
//                                   if (startDate != null && endDate != null) {
//                                     final diffDays =
//                                         endDate.difference(startDate).inDays;
//                                     duration = diffDays == 0
//                                         ? '1 day'
//                                         : '$diffDays days';
//                                   }
//
//                                   return Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 8.0),
//                                     child: Card(
//                                       margin: const EdgeInsets.symmetric(
//                                           vertical: 8),
//                                       child: ListTile(
//                                         contentPadding:
//                                         const EdgeInsets.all(16),
//                                         onTap: () =>
//                                             showLeaveDetails(context, data),
//                                         subtitle: Text(
//                                           'Leave Type: ${doc["leaveType"]}\n'
//                                               'Status: ${doc["status"] ?? "Pending"}\n'
//                                               'From: ${startDate?.toLocal().toString().split(' ')[0] ?? "Unknown"}, '
//                                               'To: ${endDate?.toLocal().toString().split(' ')[0] ?? "Unknown"}\n'
//                                               'Duration: $duration',
//                                         ),
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               );
//                             },
//                           ),
//                           Align(
//                             alignment: Alignment.bottomRight,
//                             child: Padding(
//                               padding: const EdgeInsets.all(20.0),
//                               child: SizedBox(
//                                 child: ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     foregroundColor: Colors.white,
//                                     backgroundColor: const Color(0xff3e948e),
//                                     elevation: 3,
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(6)),
//                                   ),
//                                   onPressed: () async {
//                                     final bool? shouldRefresh =
//                                     await Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                             builder: (context) =>
//                                             const SubmitLeavePage()));
//                                     if (shouldRefresh == true) {
//                                       getData();
//                                     }
//                                   },
//                                   child: Text(
//                                     'Add Leave',
//                                     style:
//                                     TextStyle(fontWeight: FontWeight.bold),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           )
//                         ],
//                       );
//                     }
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// Widget _buildDetailRow(
//     String label, String value, TextEditingController controller,
//     {bool readOnly = false}) {
//   controller.text = value;
//
//   Color statusColor;
//   Color statusText;
//
//   switch (value) {
//     case 'Pending':
//       statusColor = Colors.orange.shade400;
//       statusText = Colors.white;
//       break;
//     case 'Rejected':
//       statusColor = Colors.red.shade400;
//       statusText = Colors.white;
//
//       break;
//     case 'Approved':
//       statusColor = Colors.green.shade400;
//       statusText = Colors.white;
//
//       break;
//     default:
//       statusColor = Colors.transparent;
//       statusText = Colors.black;
//   }
//
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 4),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         SizedBox(
//           width: 100,
//           child: Text(
//             label,
//             style: const TextStyle(fontSize: 13),
//           ),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Container(
//             color: statusColor,
//             child: TextField(
//               controller: controller,
//               readOnly: readOnly,
//               style: TextStyle(color: statusText, fontWeight: FontWeight.w500),
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.black54, width: 1),
//                 ),
//                 contentPadding:
//                 EdgeInsets.symmetric(vertical: 8, horizontal: 10),
//               ),
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }
//
// class SubmitLeavePage extends StatefulWidget {
//   final Map<String, dynamic>? leave;
//
//   const SubmitLeavePage({Key? key, this.leave}) : super(key: key);
//
//   @override
//   _SubmitLeavePageState createState() => _SubmitLeavePageState();
// }
//
// class _SubmitLeavePageState extends State<SubmitLeavePage> {
//   final TextEditingController submitLeavetypeController =
//   TextEditingController();
//   final TextEditingController submitStartDateController =
//   TextEditingController();
//   final TextEditingController submitEndDateController = TextEditingController();
//   final TextEditingController submitLeaveReasonController =
//   TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//
//   String userName = '';
//   bool isLoading = false;
//   String role = "";
//   String name = "";
//   List currentData = [];
//   bool isEditing = false;
//   String? leaveDocId;
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.leave != null) {
//       isEditing = true;
//       submitLeavetypeController.text = widget.leave!['leaveType'] ?? "";
//       submitStartDateController.text = widget.leave!['startDate'] != null
//           ? (widget.leave!['startDate'] as Timestamp)
//           .toDate()
//           .toLocal()
//           .toString()
//           .split(' ')[0]
//           : "";
//       submitEndDateController.text = widget.leave!['endDate'] != null
//           ? (widget.leave!['endDate'] as Timestamp)
//           .toDate()
//           .toLocal()
//           .toString()
//           .split(' ')[0]
//           : "";
//       submitLeaveReasonController.text = widget.leave!['leaveReason'] ?? "";
//       leaveDocId = widget.leave!['leavesid'];
//       print("Edit mode: leaveDocId = $leaveDocId");
//     }
//     getData();
//   }
//
//   void getData() {
//     final User? currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) {
//       print("No user logged in.");
//       return;
//     }
//     final uid = currentUser.uid;
//
//     setState(() {
//       isLoading = true;
//     });
//
//     FirebaseFirestore.instance
//         .collection('Users')
//         .doc(uid)
//         .get()
//         .then((DocumentSnapshot docSnapshot) {
//       if (docSnapshot.exists) {
//         final data = docSnapshot.data() as Map<String, dynamic>?;
//         if (data != null && mounted) {
//           setState(() {
//             role = data['role'] ?? "";
//             name = data['username'] ?? "";
//           });
//
//           if (role.toLowerCase() == "student") {
//             StudentQuery(uid);
//           } else if (role.toLowerCase() == "teacher") {
//             TeacherQuery();
//           } else {
//             print("User role is not student or teacher.");
//             setState(() {
//               isLoading = false;
//             });
//           }
//         }
//       } else {
//         print('Document does not exist in database');
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }).catchError((error) {
//       print('Failed to fetch user data: $error');
//       setState(() {
//         isLoading = false;
//       });
//     });
//   }
//
//   void StudentQuery(String userId) {
//     FirebaseFirestore.instance
//         .collection('Leaves')
//         .where("creator_role", isEqualTo: "student")
//         .where("userId", isEqualTo: userId)
//         .orderBy("startDate")
//         .get()
//         .then((querySnapshot) {
//       setState(() {
//         currentData = querySnapshot.docs
//             .map((doc) => {
//           ...doc.data() as Map<String, dynamic>,
//           "leavesid": doc.id,
//         })
//             .toList();
//         isLoading = false;
//       });
//     }).catchError((error) {
//       print('Failed to fetch leave records for the student: $error');
//       setState(() {
//         isLoading = false;
//       });
//     });
//   }
//
//   void TeacherQuery() {
//     FirebaseFirestore.instance
//         .collection('Leaves')
//         .where("creator_role", isEqualTo: "student")
//         .orderBy("startDate")
//         .get()
//         .then((querySnapshot) {
//       setState(() {
//         currentData = querySnapshot.docs
//             .map((doc) => {
//           ...doc.data() as Map<String, dynamic>,
//           "leavesid": doc.id,
//         })
//             .toList();
//         isLoading = false;
//       });
//     }).catchError((error) {
//       print('Failed to fetch leave records for students: $error');
//       setState(() {
//         isLoading = false;
//       });
//     });
//   }
//
//   Future<void> submitLeaveData() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         final currentUser = FirebaseAuth.instance.currentUser;
//         if (currentUser == null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("No user is currently logged in.")),
//           );
//           return;
//         }
//
//         final userDoc = await FirebaseFirestore.instance
//             .collection('Users')
//             .doc(currentUser.uid)
//             .get();
//         if (!userDoc.exists) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//                 content: Text("User details not found in Firestore.")),
//           );
//           return;
//         }
//
//         final userData = userDoc.data() as Map<String, dynamic>;
//         final userDepartment = userData["department"] ?? "";
//         final userName = userData["username"] ?? "";
//         final creatorRole = (userData["role"] ?? "").toString().toLowerCase();
//         DateTime startDate = DateTime.parse(submitStartDateController.text);
//         DateTime endDate = DateTime.parse(submitEndDateController.text);
//         int duration = endDate.difference(startDate).inDays + 1;
//         print('Leave Duration: $duration days');
//
//         CollectionReference leavesCollection =
//         FirebaseFirestore.instance.collection('Leaves');
//
//         if (isEditing && leaveDocId != null) {
//           await leavesCollection.doc(leaveDocId).update({
//             'leaveType': submitLeavetypeController.text,
//             'startDate': startDate,
//             'endDate': endDate,
//             'leaveReason': submitLeaveReasonController.text,
//             'durationDays': duration,
//             'updatedAt': FieldValue.serverTimestamp(),
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//                 content: Text("Leave request updated successfully.")),
//           );
//         } else {
//           var uuid = Uuid();
//           String generatedUUID = uuid.v4();
//           await leavesCollection.doc(generatedUUID).set({
//             'leavesid': generatedUUID,
//             'userId': currentUser.uid,
//             'username': userName,
//             'userDepartment': userDepartment,
//             'creator_role': creatorRole,
//             'leaveType': submitLeavetypeController.text,
//             'startDate': startDate,
//             'endDate': endDate,
//             'leaveReason': submitLeaveReasonController.text,
//             'createdAt': FieldValue.serverTimestamp(),
//             'durationDays': duration,
//             'status': 'Pending'
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//                 content: Text("Leave request submitted successfully.")),
//           );
//         }
//
//         if (!isEditing) {
//           submitLeavetypeController.clear();
//           submitLeaveReasonController.clear();
//           submitStartDateController.clear();
//           submitEndDateController.clear();
//         }
//         Navigator.pop(context, true);
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error submitting leave request: $e")),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(isEditing ? 'Edit Leave Request' : 'Submit Leave Request'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   isEditing
//                       ? 'Update your leave request:'
//                       : 'Create new leave request here:',
//                   style: const TextStyle(
//                       fontWeight: FontWeight.w500, fontSize: 18),
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: submitLeavetypeController,
//                   decoration: const InputDecoration(
//                     labelText: 'Leave Type',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter the leave type';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 10),
//                 GestureDetector(
//                   onTap: () async {
//                     DateTime? selectedDate = await showDatePicker(
//                       context: context,
//                       initialDate: DateTime.now().add(const Duration(days: 1)),
//                       firstDate: DateTime.now().add(const Duration(days: 1)),
//                       lastDate: DateTime(2100),
//                     );
//                     if (selectedDate != null) {
//                       submitStartDateController.text =
//                       "${selectedDate.toLocal()}".split(' ')[0];
//                     }
//                   },
//                   child: AbsorbPointer(
//                     child: TextFormField(
//                       controller: submitStartDateController,
//                       decoration: const InputDecoration(
//                         labelText: 'Start Date',
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please select a start date';
//                         }
//                         try {
//                           DateTime.parse(value);
//                         } catch (e) {
//                           return 'Invalid date format';
//                         }
//                         return null;
//                       },
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 GestureDetector(
//                   onTap: () async {
//                     DateTime? selectedDate = await showDatePicker(
//                       context: context,
//                       initialDate: DateTime.now().add(const Duration(days: 1)),
//                       firstDate: DateTime.now().add(const Duration(days: 1)),
//                       lastDate: DateTime(2100),
//                     );
//                     if (selectedDate != null) {
//                       submitEndDateController.text =
//                       "${selectedDate.toLocal()}".split(' ')[0];
//                     }
//                   },
//                   child: AbsorbPointer(
//                     child: TextFormField(
//                       controller: submitEndDateController,
//                       decoration: const InputDecoration(
//                         labelText: 'End Date',
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please select an end date';
//                         }
//                         try {
//                           DateTime.parse(value);
//                         } catch (e) {
//                           return 'Invalid date format';
//                         }
//                         return null;
//                       },
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 const Text(
//                   'Detailed Reason:',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                 ),
//                 const SizedBox(height: 8),
//                 TextField(
//                   controller: submitLeaveReasonController,
//                   maxLines: 4,
//                   decoration: const InputDecoration(
//                     border: OutlineInputBorder(),
//                     hintText: 'Enter your leave reason specifically here...',
//                     contentPadding:
//                     EdgeInsets.symmetric(vertical: 10, horizontal: 12),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 SizedBox(
//                   width: MediaQuery.of(context).size.width,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       foregroundColor: Colors.white,
//                       backgroundColor: const Color(0xff3e948e),
//                       elevation: 3,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(6)),
//                     ),
//                     onPressed: () {
//                       if (submitStartDateController.text.isNotEmpty &&
//                           submitEndDateController.text.isNotEmpty &&
//                           submitLeaveReasonController.text.isNotEmpty &&
//                           submitLeavetypeController.text.isNotEmpty) {
//                         submitLeaveData();
//                         getData();
//                       }
//                     },
//                     child: Text(
//                       isEditing ? 'Update Leave' : 'Submit Leave',
//                       style: const TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 14),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class ApproveRejectButtons extends StatefulWidget {
//   final String initialStatus;
//   final String leaveId;
//
//   const ApproveRejectButtons({
//     Key? key,
//     required this.initialStatus,
//     required this.leaveId,
//   }) : super(key: key);
//
//   @override
//   _ApproveRejectButtonsState createState() => _ApproveRejectButtonsState();
// }
//
// class _ApproveRejectButtonsState extends State<ApproveRejectButtons> {
//   late String _status;
//
//   @override
//   void initState() {
//     super.initState();
//     _status = widget.initialStatus;
//   }
//
//   Future<void> _updateLeaveStatus(String newStatus) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('Leaves')
//           .doc(widget.leaveId)
//           .update({'status': newStatus});
//
//       setState(() {
//         _status = newStatus;
//       });
//     } catch (e) {}
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         SizedBox(
//           height: 35,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildButton(
//                   text: 'Approve',
//                   color: Colors.green,
//                   onTap: () => _updateLeaveStatus('Approved')),
//               _buildButton(
//                   text: 'Reject',
//                   color: Colors.red,
//                   onTap: () => _updateLeaveStatus('Rejected')),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           'Status: $_status',
//           style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: _status == 'Approved'
//                   ? Colors.green
//                   : _status == 'Rejected'
//                   ? Colors.red
//                   : Colors.orange),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildButton({
//     required String text,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return Expanded(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 4.0),
//         child: ElevatedButton(
//           onPressed: onTap,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: color,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             elevation: 0.5,
//           ),
//           child: Center(
//             child: Text(
//               text,
//               style: const TextStyle(
//                   fontWeight: FontWeight.bold, color: Colors.white),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../screens/notifications_page.dart';


class LeavesPage extends StatefulWidget {
  const LeavesPage({super.key});

  @override
  State<LeavesPage> createState() => _LeavesPageState();
}

class _LeavesPageState extends State<LeavesPage> {
  User? user = FirebaseAuth.instance.currentUser;

  final TextEditingController submitLeavetypeController =
  TextEditingController();
  final TextEditingController submitStartDateController =
  TextEditingController();
  final TextEditingController submitEndDateController = TextEditingController();
  final TextEditingController submitLeaveReasonController =
  TextEditingController();
  String role = "";
  String name = "";
  List currentData = [];
  final TextEditingController detailNameController = TextEditingController();
  final TextEditingController detailLeavetypeController =
  TextEditingController();
  final TextEditingController detailStatusController = TextEditingController();
  final TextEditingController detailStartDateController =
  TextEditingController();
  final TextEditingController detailEndDateController = TextEditingController();
  final TextEditingController detailDurationController =
  TextEditingController();
  final TextEditingController detailDepartmentController =
  TextEditingController();
  String userName = '';
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  DateTime? startDate;
  DateTime? endDate;
  String? statusValue;

  Future<String> getUserName() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        var userData = userDoc.data() as Map<String, dynamic>;
        return userData['username'] ?? 'Unknown User';
      }
    }
    return 'Unknown User';
  }

  void filterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context,
            void Function(void Function()) setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Center(
              child: Text(
                'Filter Leaves',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.blueGrey.shade600,
                  fontSize: 18,
                ),
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      title: const Text('Start Date'),
                      trailing: IconButton(
                        icon: Icon(Icons.calendar_today,
                            color: Colors.blueGrey.shade700),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setState(() {
                              startDate = date;
                            });
                            setStateDialog(() {});
                          }
                        },
                      ),
                      subtitle: Text(
                        startDate != null
                            ? DateFormat('MMM dd, yyyy').format(startDate!)
                            : 'Not selected',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      title: const Text('End Date'),
                      trailing: IconButton(
                        icon: Icon(Icons.calendar_today,
                            color: Colors.blueGrey.shade700),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setState(() {
                              endDate = date;
                            });
                            setStateDialog(() {});
                          }
                        },
                      ),
                      subtitle: Text(
                        endDate != null
                            ? DateFormat('MMM dd, yyyy').format(endDate!)
                            : 'Not selected',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButtonFormField<String>(
                            value: statusValue,
                            decoration: InputDecoration(
                              labelText: 'status',
                              labelStyle:
                              TextStyle(color: Colors.blueGrey.shade700),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.transparent, width: 0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.transparent, width: 0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items: ['All', 'Pending', 'Approved', 'Rejected']
                                .map(
                                  (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ),
                            )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                statusValue = value;
                              });
                              setStateDialog(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Align(
                alignment: Alignment.bottomLeft,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black87,
                  ),
                  onPressed: () {
                    setState(() {
                      startDate = null;
                      endDate = null;
                      statusValue = null;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Clear Filters'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void onSearched(String value) {
    setState(() {
      _searchText = value.toLowerCase();
    });
  }

  bool searchFunctn(Map<String, dynamic> leave, String searchText) {
    final searchLower = searchText.toLowerCase();
    final username = leave['username']?.toString().toLowerCase() ?? '';
    final leaveType = leave['leaveType']?.toString().toLowerCase() ?? '';
    final status = leave['status']?.toString().toLowerCase() ?? 'pending';

    final startDates = leave['startDate'] is Timestamp
        ? (leave['startDate'] as Timestamp).toDate()
        : null;
    final endDates = leave['endDate'] is Timestamp
        ? (leave['endDate'] as Timestamp).toDate()
        : null;

    bool dateMatches = true;
    if (startDate != null && startDates != null) {
      dateMatches = startDates.isAfter(startDate!) ||
          startDates.isAtSameMomentAs(startDate!);
    }
    if (endDate != null && endDates != null) {
      dateMatches = dateMatches &&
          (endDates.isBefore(endDate!) || endDates.isAtSameMomentAs(endDate!));
    }

    bool statusMatches = true;
    if (statusValue != null && statusValue != 'All') {
      statusMatches = status == statusValue!.toLowerCase();
    }

    return (username.contains(searchLower) ||
        leaveType.contains(searchLower) ||
        status.contains(searchLower)) &&
        dateMatches &&
        statusMatches;
  }

  void getData() {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("No user logged in.");
      return;
    }
    final uid = currentUser.uid;
    setState(() {
      isLoading = true;
    });
    FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .get()
        .then((DocumentSnapshot docSnapshot) {
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>?;
        if (data != null && mounted) {
          setState(() {
            role = data['role'] ?? "";
            name = data['username'] ?? "";
          });
          if (role.toLowerCase() == "student") {
            StudentQuery(uid);
          } else if (role.toLowerCase() == "teacher") {
            TeacherQuery();
          } else {
            print("User role is not student or teacher.");
            setState(() {
              isLoading = false;
            });
          }
        }
      } else {
        print('Document does not exist in database');
        setState(() {
          isLoading = false;
        });
      }
    }).catchError((error) {
      print('Failed to fetch user data: $error');
      setState(() {
        isLoading = false;
      });
    });
  }

  void StudentQuery(String userId) {
    FirebaseFirestore.instance
        .collection('Leaves')
        .where("creator_role", isEqualTo: "student")
        .where("userId", isEqualTo: userId)
        .orderBy("startDate")
        .get()
        .then((querySnapshot) {
      setState(() {
        currentData = querySnapshot.docs;
        isLoading = false;
      });
    }).catchError((error) {
      print('Failed to fetch leave records for the student: $error');
      setState(() {
        isLoading = false;
      });
    });
  }

  void TeacherQuery() {
    FirebaseFirestore.instance
        .collection('Leaves')
        .where("creator_role", isEqualTo: "student")
        .orderBy("startDate")
        .get()
        .then((querySnapshot) {
      setState(() {
        currentData = querySnapshot.docs;
        isLoading = false;
      });
    }).catchError((error) {
      print('Failed to fetch leave records for students: $error');
      setState(() {
        isLoading = false;
      });
    });
  }

  Stream<QuerySnapshot> fetchStudentLeaves() {
    return FirebaseFirestore.instance
        .collection('Leaves')
        .where("creator_role", isEqualTo: "student")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  @override
  void initState() {
    super.initState();
    getUserName().then((name) {
      setState(() {
        userName = name;
      });
    });
    getData();
  }

  void bottomsheet(BuildContext context, Map<String, dynamic> leave) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final startDate = leave["startDate"] is Timestamp
        ? (leave["startDate"] as Timestamp).toDate()
        : null;
    final endDate = leave["endDate"] is Timestamp
        ? (leave["endDate"] as Timestamp).toDate()
        : null;
    final duration = leave["durationDays"]?.toString() ?? "N/A";
    final creatorRole = leave["creator_role"]?.toString() ?? "N/A";
    final leaveStatus = leave["status"]?.toString() ?? "Pending";

    final User? currentUser = FirebaseAuth.instance.currentUser;
    final uid = currentUser?.uid;
    if (uid == null) return;

    FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .get()
        .then((userDoc) {
      if (!userDoc.exists) return;
      final userRole = userDoc.data()?["role"] ?? "N/A";

      final bool canEdit =
          (userRole == 'Student' && leaveStatus == "Pending") ||
              (userRole == 'Teacher' &&
                  creatorRole == 'teacher' &&
                  leaveStatus == "Pending");

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Leave Details',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Row(
                    children: [
                      if (canEdit)
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SubmitLeavePage(leave: leave),
                              ),
                            );
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
              customRow('User Name:', leave["username"], detailNameController,
                  readOnly: true),
              customRow('Type:', leave["leaveType"], detailLeavetypeController,
                  readOnly: true),
              customRow('Status:', leaveStatus, detailStatusController,
                  readOnly: true),
              customRow(
                  'Start Date:',
                  startDate != null ? formatter.format(startDate) : "N/A",
                  detailStartDateController,
                  readOnly: true),
              customRow(
                  'End Date:',
                  endDate != null ? formatter.format(endDate) : "N/A",
                  detailEndDateController,
                  readOnly: true),
              customRow('Duration:', '$duration days', detailDurationController,
                  readOnly: true),
              customRow('Department:', leave["userDepartment"] ?? "N/A",
                  detailDepartmentController,
                  readOnly: true),
              const SizedBox(height: 10),
              const Text('Reason:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(leave["leaveReason"] ?? "No reason provided"),
              ),
              if (userRole == 'Teacher' && creatorRole == 'student')
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: customstatusButton(
                    initialStatus: leave['status'] ?? 'Pending',
                    leaveId: leave['leavesid'],
                    closesheet: true,
                  ),
                ),
              if (userRole == 'Admin' && creatorRole == 'teacher')
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: customstatusButton(
                    initialStatus: leave['status'] ?? 'Pending',
                    leaveId: leave['leavesid'],
                    closesheet: true,
                  ),
                ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    });
  }

  Stream<QuerySnapshot> fetchLeaves() {
    final currentUser = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('Leaves')
        .where("userId", isEqualTo: currentUser?.uid)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  Future<Map<String, dynamic>> fetchUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception("No user is currently logged in.");
    }
    final doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.uid)
        .get();
    if (!doc.exists) {
      throw Exception("User details not found in Firestore.");
    }
    return doc.data() as Map<String, dynamic>;
  }

  Stream<Map<String, dynamic>> fetchUserDetails() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Stream.error("No user is currently logged in.");
    }

    return FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        throw Exception("User details not found in Firestore.");
      }
      return snapshot.data() as Map<String, dynamic>;
    });
  }

  Stream<QuerySnapshot> fetchTeacherLeaves() {
    return FirebaseFirestore.instance
        .collection('Leaves')
        .where("creator_role", isEqualTo: "teacher")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Requests'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search leaves...',
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              BorderSide(color: Colors.black54, width: 1.5),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.search),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 10),
                          ),
                          onChanged: onSearched,
                        ),
                      ),
                      IconButton(
                        onPressed: () => filterDialog(context),
                        icon: Icon(Icons.filter_list,
                            color: Colors.grey.shade800),
                      ),
                    ],
                  ),
                ),
              ),
              SliverFillRemaining(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: fetchUser(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (userSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${userSnapshot.error}'));
                    }
                    if (!userSnapshot.hasData) {
                      return const Center(
                          child: Text('No user details found.'));
                    }

                    final userData = userSnapshot.data!;
                    final role = userData['role']?.toLowerCase() ?? '';
                    final isTeacher = role == 'teacher';
                    final isAdmin = role == 'admin';

                    if (isTeacher) {
                      return Stack(
                        children: [
                          DefaultTabController(
                            length: 2,
                            child: Column(
                              children: [
                                const TabBar(
                                  tabs: [
                                    Tab(text: 'Leave Requests'),
                                    Tab(text: 'Leave Approvals'),
                                  ],
                                  indicatorColor: Colors.blueGrey,
                                  labelColor: Colors.black,
                                  unselectedLabelColor: Colors.black54,
                                ),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      isLoading
                                          ? const Center(
                                          child:
                                          CircularProgressIndicator())
                                          : currentData.isEmpty
                                          ? const Center(
                                          child: Text(
                                              'No student leave requests found.'))
                                          : StreamBuilder<
                                          Map<String, dynamic>>(
                                        stream: fetchUserDetails(),
                                        builder:
                                            (context, userSnapshot) {
                                          if (userSnapshot
                                              .connectionState ==
                                              ConnectionState
                                                  .waiting) {
                                            return const Center(
                                                child:
                                                CircularProgressIndicator());
                                          }
                                          if (userSnapshot.hasError) {
                                            return Center(
                                                child: Text(
                                                    'Error: ${userSnapshot.error}'));
                                          }
                                          if (!userSnapshot.hasData) {
                                            return const Center(
                                                child: Text(
                                                    'No user details found.'));
                                          }

                                          final userData =
                                          userSnapshot.data!;
                                          final role = userData[
                                          'role']
                                              ?.toLowerCase() ??
                                              '';

                                          final isTeacher =
                                              role == 'Teacher';

                                          if (isTeacher) {
                                            if (isLoading) {
                                              return const Center(
                                                  child:
                                                  CircularProgressIndicator());
                                            }
                                            if (currentData.isEmpty) {
                                              return const Center(
                                                  child: Text(
                                                      'No student leave requests found.'));
                                            }
                                            return ListView.builder(
                                              itemCount:
                                              currentData.length,
                                              itemBuilder:
                                                  (context, index) {
                                                var doc = currentData[
                                                index];
                                                Map<String, dynamic>
                                                leave = doc.data()
                                                as Map<String,
                                                    dynamic>;
                                                if (!searchFunctn(
                                                    leave,
                                                    _searchText)) {
                                                  return SizedBox
                                                      .shrink();
                                                }
                                                final startDate =
                                                (leave["startDate"]
                                                as Timestamp)
                                                    .toDate();
                                                final endDate = (leave[
                                                "endDate"]
                                                as Timestamp)
                                                    .toDate();
                                                final duration = endDate
                                                    .difference(
                                                    startDate)
                                                    .inDays +
                                                    1;

                                                return Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .symmetric(
                                                      horizontal:
                                                      8.0),
                                                  child: Card(
                                                    margin:
                                                    const EdgeInsets
                                                        .symmetric(
                                                        vertical:
                                                        8),
                                                    child: ListTile(
                                                      contentPadding:
                                                      const EdgeInsets
                                                          .all(
                                                          16),
                                                      onTap: () =>
                                                          bottomsheet(
                                                              context,
                                                              leave),
                                                      subtitle: Text(
                                                        'User: ${leave["username"]}\n'
                                                            'Leave Type: ${leave["leaveType"]}\n'
                                                            'Status: ${leave["status"] ?? "Pending"}\n'
                                                            'From: ${startDate.toLocal().toString().split(' ')[0]}, '
                                                            'To: ${endDate.toLocal().toString().split(' ')[0]}\n'
                                                            'Duration: $duration days',
                                                      ),
                                                      trailing:
                                                      const Icon(Icons
                                                          .arrow_forward_ios),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          } else {
                                            return StreamBuilder<
                                                QuerySnapshot>(
                                              stream: fetchLeaves(),
                                              builder: (context,
                                                  snapshot) {
                                                if (snapshot
                                                    .connectionState ==
                                                    ConnectionState
                                                        .waiting) {
                                                  return const Center(
                                                      child:
                                                      CircularProgressIndicator());
                                                }
                                                if (snapshot
                                                    .hasError) {
                                                  return Center(
                                                      child: Text(
                                                          'Error: ${snapshot.error}'));
                                                }
                                                if (!snapshot
                                                    .hasData ||
                                                    snapshot
                                                        .data!
                                                        .docs
                                                        .isEmpty) {
                                                  return const Center(
                                                      child: Text(
                                                          'No leave requests found.'));
                                                }
                                                final filteredDocs =
                                                snapshot
                                                    .data!.docs
                                                    .where((doc) {
                                                  final data = doc
                                                      .data()
                                                  as Map<String,
                                                      dynamic>;
                                                  return searchFunctn(
                                                      data,
                                                      _searchText);
                                                }).toList();
                                                snapshot.data!.docs
                                                    .map((doc) => doc
                                                    .data()
                                                as Map<String,
                                                    dynamic>)
                                                    .toList();
                                                if (filteredDocs
                                                    .isEmpty) {
                                                  return const Center(
                                                      child: Text(
                                                          'No leave requests found.'));
                                                }
                                                return ListView
                                                    .builder(
                                                  itemCount:
                                                  filteredDocs
                                                      .length,
                                                  itemBuilder:
                                                      (context,
                                                      index) {
                                                    final doc =
                                                    filteredDocs[
                                                    index];
                                                    final data = doc
                                                        .data()
                                                    as Map<String,
                                                        dynamic>;

                                                    final startDate = doc[
                                                    "startDate"]
                                                    is Timestamp
                                                        ? (doc["startDate"]
                                                    as Timestamp)
                                                        .toDate()
                                                        : null;
                                                    final endDate = doc[
                                                    "endDate"]
                                                    is Timestamp
                                                        ? (doc["endDate"]
                                                    as Timestamp)
                                                        .toDate()
                                                        : null;
                                                    String duration =
                                                        "Unknown";
                                                    if (startDate !=
                                                        null &&
                                                        endDate !=
                                                            null) {
                                                      final diffDays = endDate
                                                          .difference(
                                                          startDate)
                                                          .inDays;
                                                      duration =
                                                      diffDays ==
                                                          0
                                                          ? '1 day'
                                                          : '$diffDays days';
                                                    }
                                                    if (filteredDocs
                                                        .isEmpty) {
                                                      return const Center(
                                                          child: Text(
                                                              'No leave requests found.'));
                                                    }
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal:
                                                          8.0),
                                                      child: Card(
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                            vertical:
                                                            8),
                                                        child:
                                                        ListTile(
                                                          contentPadding:
                                                          const EdgeInsets
                                                              .all(
                                                              16),
                                                          onTap: () =>
                                                              bottomsheet(
                                                                  context,
                                                                  data),
                                                          subtitle:
                                                          Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: [
                                                              Text(
                                                                'Leave Type: ${doc["leaveType"]}\n'
                                                                    'From: ${startDate?.toLocal().toString().split(' ')[0] ?? "Unknown"},  '
                                                                    'To: ${endDate?.toLocal().toString().split(' ')[0] ?? "Unknown"}\n'
                                                                    'Duration: $duration',
                                                                style:
                                                                TextStyle(
                                                                  fontFamily:
                                                                  GoogleFonts.montserrat().fontFamily,
                                                                ),
                                                              ),
                                                              Row(
                                                                mainAxisSize:
                                                                MainAxisSize.min,
                                                                children: [
                                                                  Text(
                                                                    'Status: ',
                                                                    style: TextStyle(
                                                                      fontFamily: GoogleFonts.montserrat().fontFamily,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    '${doc["status"] ?? "Pending"}',
                                                                    style: TextStyle(
                                                                      fontWeight: FontWeight.bold,
                                                                      color: (doc["status"] == "Approved")
                                                                          ? Colors.green
                                                                          : (doc["status"] == "Rejected")
                                                                          ? Colors.red
                                                                          : Colors.orange,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            );
                                          }
                                        },
                                      ),
                                      StreamBuilder<QuerySnapshot>(
                                        stream: fetchStudentLeaves(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                                child:
                                                CircularProgressIndicator());
                                          }
                                          if (snapshot.hasError) {
                                            return Center(
                                                child: Text(
                                                    'Error: ${snapshot.error}'));
                                          }
                                          if (!snapshot.hasData ||
                                              snapshot.data!.docs.isEmpty) {
                                            return const Center(
                                                child: Text(
                                                    'No student leave requests found.'));
                                          }

                                          final filteredDocs =
                                          snapshot.data!.docs.where((doc) {
                                            final data = doc.data()
                                            as Map<String, dynamic>;
                                            return searchFunctn(
                                                data, _searchText);
                                          }).toList();

                                          if (filteredDocs.isEmpty) {
                                            return const Center(
                                                child: Text(
                                                    'No leave requests found.'));
                                          }

                                          return ListView.builder(
                                            itemCount: filteredDocs.length,
                                            itemBuilder: (context, index) {
                                              final doc = filteredDocs[index];
                                              final leave =
                                              Map<String, dynamic>.from(
                                                  doc.data() as Map);

                                              final startDate =
                                              leave["startDate"]
                                              is Timestamp
                                                  ? (leave["startDate"]
                                              as Timestamp)
                                                  .toDate()
                                                  : null;
                                              final endDate =
                                              leave["endDate"] is Timestamp
                                                  ? (leave["endDate"]
                                              as Timestamp)
                                                  .toDate()
                                                  : null;

                                              String duration = "Unknown";
                                              if (startDate != null &&
                                                  endDate != null) {
                                                final diffDays = endDate
                                                    .difference(startDate)
                                                    .inDays;
                                                duration = diffDays == 0
                                                    ? '1 day'
                                                    : '$diffDays days';
                                              }

                                              return Padding(
                                                padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 8.0),
                                                child: Card(
                                                  margin: const EdgeInsets
                                                      .symmetric(vertical: 8),
                                                  child: ListTile(
                                                    contentPadding:
                                                    const EdgeInsets.all(
                                                        16),
                                                    onTap: () => bottomsheet(
                                                        context, leave),
                                                    subtitle: Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        Text(
                                                          'Student Name: ${leave["username"]}\n'
                                                              'Leave Type: ${leave["leaveType"]}\n'
                                                              'From: ${startDate?.toLocal().toString().split(' ')[0] ?? "Unknown"}, '
                                                              'To: ${endDate?.toLocal().toString().split(' ')[0] ?? "Unknown"}\n'
                                                              'Duration: $duration',
                                                        ),
                                                        customstatusButton(
                                                          initialStatus:
                                                          leave['status'] ??
                                                              'Pending',
                                                          leaveId:
                                                          leave['leavesid'],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: SizedBox(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: const Color(0xff3e948e),
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6)),
                                  ),
                                  onPressed: () async {
                                    final bool? shouldRefresh =
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                            const SubmitLeavePage()));
                                    if (shouldRefresh == true) {
                                      getData();
                                    }
                                  },
                                  child: Text(
                                    'Add Leave',
                                    style:
                                    TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      );
                    } else if (isAdmin) {
                      return StreamBuilder<QuerySnapshot>(
                        stream: fetchTeacherLeaves(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                                child:
                                Text('No teacher leave requests found.'));
                          }

                          final filteredDocs = snapshot.data!.docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return searchFunctn(data, _searchText);
                          }).toList();

                          return ListView.builder(
                            itemCount: filteredDocs.length,
                            itemBuilder: (context, index) {
                              final doc = filteredDocs[index];
                              final data = doc.data() as Map<String, dynamic>;
                              final startDate = data["startDate"] is Timestamp
                                  ? (data["startDate"] as Timestamp).toDate()
                                  : null;
                              final endDate = data["endDate"] is Timestamp
                                  ? (data["endDate"] as Timestamp).toDate()
                                  : null;
                              String duration = "Unknown";
                              if (startDate != null && endDate != null) {
                                final diffDays =
                                    endDate.difference(startDate).inDays;
                                duration =
                                diffDays == 0 ? '1 day' : '$diffDays days';
                              }
                              return Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Card(
                                  margin:
                                  const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    onTap: () => bottomsheet(context, data),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Teacher Name: ${data["username"] ?? "Unknown"}\n'
                                              'Leave Type: ${data["leaveType"] ?? "Unknown"}\n'
                                              'From: ${startDate?.toLocal().toString().split(' ')[0] ?? "Unknown"}, '
                                              'To: ${endDate?.toLocal().toString().split(' ')[0] ?? "Unknown"}\n'
                                              'Duration: $duration',
                                        ),
                                        customstatusButton(
                                          initialStatus:
                                          data['status'] ?? 'Pending',
                                          leaveId: data['leavesid'] ?? '',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    } else {
                      return Stack(
                        children: [
                          StreamBuilder(
                            stream: fetchLeaves(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              }
                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const Center(
                                    child: Text('No leave requests found.'));
                              }
                              final filteredDocs =
                              snapshot.data!.docs.where((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                return searchFunctn(data, _searchText);
                              }).toList();
                              snapshot.data!.docs
                                  .map((doc) =>
                              doc.data() as Map<String, dynamic>)
                                  .toList();
                              return ListView.builder(
                                itemCount: filteredDocs.length,
                                itemBuilder: (context, index) {
                                  final doc = filteredDocs[index];
                                  final data =
                                  doc.data() as Map<String, dynamic>;
                                  final startDate = doc["startDate"]
                                  is Timestamp
                                      ? (doc["startDate"] as Timestamp).toDate()
                                      : null;
                                  final endDate = doc["endDate"] is Timestamp
                                      ? (doc["endDate"] as Timestamp).toDate()
                                      : null;
                                  String duration = "Unknown";
                                  if (startDate != null && endDate != null) {
                                    final diffDays =
                                        endDate.difference(startDate).inDays;
                                    duration = diffDays == 0
                                        ? '1 day'
                                        : '$diffDays days';
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Card(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: ListTile(
                                        contentPadding:
                                        const EdgeInsets.all(16),
                                        onTap: () => bottomsheet(context, data),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Leave Type: ${doc["leaveType"]}\n'
                                                  'From: ${startDate?.toLocal().toString().split(' ')[0] ?? "Unknown"},  '
                                                  'To: ${endDate?.toLocal().toString().split(' ')[0] ?? "Unknown"}\n'
                                                  'Duration: $duration',
                                              style: TextStyle(
                                                fontFamily:
                                                GoogleFonts.montserrat()
                                                    .fontFamily,
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'Status: ',
                                                  style: TextStyle(
                                                    fontFamily:
                                                    GoogleFonts.montserrat()
                                                        .fontFamily,
                                                  ),
                                                ),
                                                Text(
                                                  '${doc["status"] ?? "Pending"}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: (doc["status"] ==
                                                        "Approved")
                                                        ? Colors.green
                                                        : (doc["status"] ==
                                                        "Rejected")
                                                        ? Colors.red
                                                        : Colors.orange,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: SizedBox(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: const Color(0xff3e948e),
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6)),
                                  ),
                                  onPressed: () async {
                                    final bool? shouldRefresh =
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                            const SubmitLeavePage()));
                                    if (shouldRefresh == true) {
                                      getData();
                                    }
                                  },
                                  child: Text(
                                    'Add Leave',
                                    style:
                                    TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget customRow(String label, String value, TextEditingController controller,
    {bool readOnly = false}) {
  controller.text = value;

  Color statusColor;
  Color statusText;

  switch (value) {
    case 'Pending':
      statusColor = Colors.orange.shade400;
      statusText = Colors.white;
      break;
    case 'Rejected':
      statusColor = Colors.red.shade400;
      statusText = Colors.white;

      break;
    case 'Approved':
      statusColor = Colors.green.shade400;
      statusText = Colors.white;

      break;
    default:
      statusColor = Colors.transparent;
      statusText = Colors.black;
  }
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            color: statusColor,
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              style: TextStyle(color: statusText, fontWeight: FontWeight.w500),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black54, width: 1),
                ),
                contentPadding:
                EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class SubmitLeavePage extends StatefulWidget {
  final Map<String, dynamic>? leave;

  const SubmitLeavePage({Key? key, this.leave}) : super(key: key);

  @override
  _SubmitLeavePageState createState() => _SubmitLeavePageState();
}

class _SubmitLeavePageState extends State<SubmitLeavePage> {
  final TextEditingController leavetypeController = TextEditingController();
  final TextEditingController startdateController = TextEditingController();
  final TextEditingController enddateController = TextEditingController();
  final TextEditingController leavereasonController = TextEditingController();
  final key = GlobalKey<FormState>();
  final FocusNode _dropdownFocusNode = FocusNode();
  DateTime? startDate;
  DateTime? endDate;
  String userName = '';
  bool isLoading = false;
  String role = "";
  String name = "";
  List currentData = [];
  bool isEditing = false;
  String? leaveDocId;
  bool _autoValidate = false;

  @override
  void initState() {
    super.initState();
    if (widget.leave != null) {
      isEditing = true;
      leavetypeController.text = widget.leave!['leaveType'] ?? "";
      startdateController.text = widget.leave!['startDate'] != null
          ? (widget.leave!['startDate'] as Timestamp)
          .toDate()
          .toLocal()
          .toString()
          .split(' ')[0]
          : "";
      enddateController.text = widget.leave!['endDate'] != null
          ? (widget.leave!['endDate'] as Timestamp)
          .toDate()
          .toLocal()
          .toString()
          .split(' ')[0]
          : "";
      leavereasonController.text = widget.leave!['leaveReason'] ?? "";
      leaveDocId = widget.leave!['leavesid'];
      print("Edit mode: leaveDocId = $leaveDocId");
    }
    getdata();
  }

  void getdata() {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("No user logged in.");
      return;
    }
    final uid = currentUser.uid;

    setState(() {
      isLoading = true;
    });

    FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .get()
        .then((DocumentSnapshot docSnapshot) {
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>?;
        if (data != null && mounted) {
          setState(() {
            role = data['role'] ?? "";
            name = data['username'] ?? "";
          });

          if (role.toLowerCase() == "student") {
            StudentsQuery(uid);
          } else if (role.toLowerCase() == "teacher") {
            TeachersQuery();
          } else {
            print("user role is not student/teacher.");
            setState(() {
              isLoading = false;
            });
          }
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }).catchError((error) {
      print('failed to fetch user data: $error');
      setState(() {
        isLoading = false;
      });
    });
  }

  void StudentsQuery(String userId) {
    FirebaseFirestore.instance
        .collection('Leaves')
        .where("creator_role", isEqualTo: "student")
        .where("userId", isEqualTo: userId)
        .orderBy("startDate")
        .get()
        .then((querySnapshot) {
      setState(() {
        currentData = querySnapshot.docs
            .map((doc) => {
          ...doc.data(),
          "leavesid": doc.id,
        })
            .toList();
        isLoading = false;
      });
    }).catchError((error) {
      print('failed to fetch leave records for the student: $error');
      setState(() {
        isLoading = false;
      });
    });
  }

  void TeachersQuery() {
    FirebaseFirestore.instance
        .collection('Leaves')
        .where("creator_role", isEqualTo: "student")
        .orderBy("startDate")
        .get()
        .then((querySnapshot) {
      setState(() {
        currentData = querySnapshot.docs
            .map((doc) => {
          ...doc.data(),
          "leavesid": doc.id,
        })
            .toList();
        isLoading = false;
      });
    }).catchError((error) {
      print('Failed to fetch leave records for students: $error');
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> submitLeaveData() async {
    if (key.currentState!.validate()) {
      try {
        setState(() {
          isLoading = true;
        });
        setState(() {
          _autoValidate = true;
        });
        final currentUser = FirebaseAuth.instance.currentUser;

        final userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser?.uid)
            .get();
        if (!userDoc.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("user details not found in Firestore")),
          );
          return;
        }

        final userData = userDoc.data() as Map<String, dynamic>;
        final userDepartment = userData["department"] ?? "";
        final userName = userData["username"] ?? "";
        final creatorRole = (userData["role"] ?? "").toString().toLowerCase();
        DateTime startDate = DateTime.parse(startdateController.text);
        DateTime endDate = DateTime.parse(enddateController.text);
        int duration = endDate.difference(startDate).inDays + 1;
        print('Leave Duration: $duration days');

        CollectionReference leavesCollection =
        FirebaseFirestore.instance.collection('Leaves');

        if (isEditing && leaveDocId != null) {
          await leavesCollection.doc(leaveDocId).update({
            'leaveType': leavetypeController.text,
            'startDate': startDate,
            'endDate': endDate,
            'leaveReason': leavereasonController.text,
            'durationDays': duration,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("leave request updated successfully")),
          );
        } else {
          var uuid = Uuid();
          String generatedUUID = uuid.v4();
          await leavesCollection.doc(generatedUUID).set({
            'leavesid': generatedUUID,
            'userId': currentUser?.uid,
            'username': userName,
            'userDepartment': userDepartment,
            'creator_role': creatorRole,
            'leaveType': leavetypeController.text,
            'startDate': startDate,
            'endDate': endDate,
            'leaveReason': leavereasonController.text,
            'createdAt': FieldValue.serverTimestamp(),
            'durationDays': duration,
            'status': 'Pending'
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("leave request submitted successfully")),
          );
        }

        if (!isEditing) {
          leavetypeController.clear();
          leavereasonController.clear();
          startdateController.clear();
          enddateController.clear();
        }
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("error submitting leave request: $e")),
        );
      }
    }
  }

  @override
  void dispose() {
    _dropdownFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Leave Request' : 'Submit Leave Request'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: key,
          autovalidateMode: _autoValidate
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  focusNode: _dropdownFocusNode,
                  value: leavetypeController.text.isNotEmpty
                      ? leavetypeController.text
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Leave Type',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    'Academic',
                    'Casual',
                    'Family',
                    'Medical',
                    'Personal',
                    'Other'
                  ].map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    _dropdownFocusNode.unfocus();

                    setState(() {
                      leavetypeController.text = newValue ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a leave type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    final DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate:
                      startDate ?? DateTime.now().add(Duration(days: 1)),
                      firstDate: DateTime.now().add(Duration(days: 1)),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        startDate = selectedDate;
                        startdateController.text =
                            DateFormat('yyyy-MM-dd').format(startDate!);
                        if (endDate == null || endDate!.isBefore(startDate!)) {
                          endDate = startDate!.add(Duration(days: 1));
                          enddateController.text =
                              DateFormat('yyyy-MM-dd').format(endDate!);
                        }
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: startdateController,
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a start date';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    final DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? startDate!.add(Duration(days: 1)),
                      firstDate: startDate!.add(Duration(days: 1)),
                      lastDate: DateTime(2100),
                    );

                    if (selectedDate != null) {
                      setState(() {
                        endDate = selectedDate;
                        enddateController.text =
                            DateFormat('yyyy-MM-dd').format(endDate!);
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: enddateController,
                      decoration: const InputDecoration(
                        labelText: 'End Date',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an end date';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Detailed Reason:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: leavereasonController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your leave reason here...',
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please provide a reason for the leave';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xff3e948e),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: submitLeaveData,
                    child: isLoading
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      isEditing ? 'Update Leave' : 'Submit Leave',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
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

class customstatusButton extends StatefulWidget {
  final String initialStatus;
  final String leaveId;
  final bool closesheet;

  const customstatusButton({
    Key? key,
    required this.initialStatus,
    required this.leaveId,
    this.closesheet = false,
  }) : super(key: key);

  @override
  _customstatusButtonState createState() => _customstatusButtonState();
}

class _customstatusButtonState extends State<customstatusButton> {
  late String _status;
  bool showstatusButtons = true;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    showstatusButtons = (_status == 'Pending');
  }

  @override
  void didUpdateWidget(covariant customstatusButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialStatus != widget.initialStatus) {
      setState(() {
        _status = widget.initialStatus;
        showstatusButtons = (_status == 'Pending');
      });
    }
  }

  Future<void> _updateLeaveStatus(String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('Leaves')
          .doc(widget.leaveId)
          .update({'status': newStatus});

      setState(() {
        _status = newStatus;
        showstatusButtons = false;
      });

      DocumentSnapshot leaveDoc = await FirebaseFirestore.instance
          .collection('Leaves')
          .doc(widget.leaveId)
          .get();

      if (leaveDoc.exists) {
        Map<String, dynamic> leaveData =
        leaveDoc.data() as Map<String, dynamic>;
        String userId = leaveData['userId'] ?? "Unknown";
        String username = leaveData['username'] ?? "Unknown";
        String role = leaveData['creator_role'] ?? "Unknown";
        String leaveType = leaveData['leaveType'] ?? "Unknown";
        String reason = leaveData['leaveReason'] ?? "No reason provided";
        String startDate = leaveData['startDate'] != null
            ? (leaveData['startDate'] as Timestamp)
            .toDate()
            .toLocal()
            .toString()
            .split(' ')[0]
            : "Unknown";
        String endDate = leaveData['endDate'] != null
            ? (leaveData['endDate'] as Timestamp)
            .toDate()
            .toLocal()
            .toString()
            .split(' ')[0]
            : "Unknown";

        await sendNotification(
          userId: userId,
          title: "Leave Status Updated",
          message:
          "Your leave request for $reason from $startDate to $endDate has been $newStatus.",
          type: "LeaveStatus",
          payload: {
            "User Name": username,
            "User Role": role,
            "Leave Type": leaveType,
            "Leave Status": newStatus,
            "Leave Reason": reason,
            "Start Date": startDate,
            "End Date": endDate,
            // "Leave Id": widget.leaveId,
          },
        );
      }

      if (widget.closesheet) {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error updating leave status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Text(
              'Status: ',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              '$_status',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _status == 'Approved'
                    ? Colors.green
                    : _status == 'Rejected'
                    ? Colors.red
                    : Colors.orange,
              ),
            )
          ],
        ),
        if (showstatusButtons)
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildButton(
                  text: 'Approve',
                  color: Colors.green,
                  onTap: () => _updateLeaveStatus('Approved'),
                ),
                _buildButton(
                  text: 'Reject',
                  color: Colors.red,
                  onTap: () => _updateLeaveStatus('Rejected'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0.5,
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
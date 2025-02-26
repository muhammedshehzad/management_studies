import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:new_school/isar_storage/leave_request_model.dart';
import 'package:uuid/uuid.dart';

import '../isar_storage/isar_user_service.dart';
import 'leavesBloc.dart';

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
  late LeavesBloc _bloc;
  bool isOnline = false;
  StreamSubscription? _connectivitySubscription;

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

  Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> syncPendingOperations() async {
    bool online = await hasInternet();
    if (!online) return;

    for (var update in FirestoreQueue.getQueuedUpdates()) {
      try {
        await FirebaseFirestore.instance
            .collection(update['collection'])
            .doc(update['docId'])
            .update(update['data']);
        FirestoreQueue.clearUpdate(0);
      } catch (e) {
        debugPrint("Error syncing Firestore update: $e");
      }
    }

    for (var notification in NotificationQueue.getQueuedNotifications()) {
      try {
        await sendNotification(
          userId: notification['userId'],
          title: notification['title'],
          message: notification['message'],
          type: notification['type'],
          payload: notification['payload'],
        );
        NotificationQueue.clearNotification(0);
      } catch (e) {
        debugPrint("Error syncing notification: $e");
      }
    }

    await IsarUserService.isar!.writeTxn(() async {
      final unsyncedLeaves = await IsarUserService.isar!.leaveRequests
          .where()
          .filter()
          .isSyncedEqualTo(false)
          .findAll();
      for (var leave in unsyncedLeaves) {
        leave.isSynced = true;
        await IsarUserService.isar!.leaveRequests.put(leave);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _bloc = LeavesBloc();
    syncPendingOperations();

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
                        Row(
                          children: [
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
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                bool? confirmDelete = await showDialog<bool>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 8,
                                    backgroundColor: Colors.white,
                                    title: Row(
                                      children: [
                                        Text(
                                          "Delete Leave Request",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                        ),
                                      ],
                                    ),
                                    content: const Text(
                                      "Are you sure you want to delete this leave request? This action cannot be undone.",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black54,
                                        height: 1.4,
                                      ),
                                    ),
                                    actionsPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.grey,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text(
                                          "Cancel",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          elevation: 2,
                                        ),
                                        child: const Text(
                                          "Delete",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmDelete == true) {
                                  try {
                                    bool online = await hasInternet();
                                    String leaveId = leave['leavesid'];

                                    if (online) {
                                      await FirebaseFirestore.instance
                                          .collection('Leaves')
                                          .doc(leaveId)
                                          .delete();
                                    } else {
                                      FirestoreQueue.queueUpdate(
                                        collection: 'Leaves',
                                        docId: leaveId,
                                        data: {
                                          'deleted': true,
                                          'timestamp':
                                              DateTime.now().toIso8601String(),
                                        },
                                      );
                                    }

                                    if (IsarUserService.isar != null) {
                                      await IsarUserService.isar!
                                          .writeTxn(() async {
                                        await IsarUserService
                                            .isar!.leaveRequests
                                            .where()
                                            .leavesIdEqualTo(leaveId)
                                            .deleteFirst();
                                      });
                                    }

                                    Navigator.pop(context);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            const Text("Leave request deleted"),
                                        backgroundColor: Colors.green,
                                        duration: const Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        margin: const EdgeInsets.all(10),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Failed to delete: $e"),
                                        backgroundColor: Colors.red,
                                        duration: const Duration(seconds: 3),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        margin: const EdgeInsets.all(10),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
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
  void dispose() {
    _bloc.dispose();
    super.dispose();
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
                                          : StreamBuilder<Map<String, dynamic>>(
                                              stream: fetchUserDetails(),
                                              builder: (context, userSnapshot) {
                                                if (userSnapshot
                                                        .connectionState ==
                                                    ConnectionState.waiting) {
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
                                                final role = userData['role']
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
                                                      var doc =
                                                          currentData[index];
                                                      Map<String, dynamic>
                                                          leave = doc.data()
                                                              as Map<String,
                                                                  dynamic>;
                                                      if (!searchFunctn(
                                                          leave, _searchText)) {
                                                        return SizedBox
                                                            .shrink();
                                                      }
                                                      final startDate =
                                                          (leave["startDate"]
                                                                  as Timestamp)
                                                              .toDate();
                                                      final endDate =
                                                          (leave["endDate"]
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
                                                                  vertical: 8),
                                                          child: ListTile(
                                                            contentPadding:
                                                                const EdgeInsets
                                                                    .all(16),
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
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
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
                                                          snapshot.data!.docs
                                                              .isEmpty) {
                                                        return const Center(
                                                            child: Text(
                                                                'No leave requests found.'));
                                                      }
                                                      final filteredDocs =
                                                          snapshot.data!.docs
                                                              .where((doc) {
                                                        final data = doc.data()
                                                            as Map<String,
                                                                dynamic>;
                                                        return searchFunctn(
                                                            data, _searchText);
                                                      }).toList();
                                                      snapshot.data!.docs
                                                          .map((doc) =>
                                                              doc.data() as Map<
                                                                  String,
                                                                  dynamic>)
                                                          .toList();
                                                      if (filteredDocs
                                                          .isEmpty) {
                                                        return const Center(
                                                            child: Text(
                                                                'No leave requests found.'));
                                                      }
                                                      return ListView.builder(
                                                        itemCount:
                                                            filteredDocs.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          final doc =
                                                              filteredDocs[
                                                                  index];
                                                          final data =
                                                              doc.data() as Map<
                                                                  String,
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
                                                              endDate != null) {
                                                            final diffDays =
                                                                endDate
                                                                    .difference(
                                                                        startDate)
                                                                    .inDays;
                                                            duration = diffDays ==
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
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        Text(
                                                                          'Status: ',
                                                                          style:
                                                                              TextStyle(
                                                                            fontFamily:
                                                                                GoogleFonts.montserrat().fontFamily,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          '${doc["status"] ?? "Pending"}',
                                                                          style:
                                                                              TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
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
                                        stream: _bloc.leavesStream,
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
                                            const SubmitLeavePage(),
                                      ),
                                    );
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
  bool isOnline = false;
  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;

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
    checkInternet().then((_) {
      if (isOnline) {
        syncFirestoreToLocal();
        syncUnsyncedLeaves();
      }
    });
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

  Future<bool> isConnected() async {
    var result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> syncUnsyncedLeaves() async {
    if (_isSyncing || !await hasInternet()) return;
    _isSyncing = true;

    try {
      final unsyncedLeaves = await IsarUserService.isar!.leaveRequests
          .where()
          .filter()
          .isSyncedEqualTo(false)
          .findAll();

      for (final leave in unsyncedLeaves) {
        leave.isSynced = true;
        await IsarUserService.isar!.writeTxn(() async {
          await IsarUserService.isar!.leaveRequests.put(leave);
        });

        final leaveData = {
          'userId': leave.userId,
          'username': leave.username,
          'userDepartment': leave.userDepartment,
          'creator_role': leave.creatorRole,
          'leaveType': leave.leaveType,
          'startDate': Timestamp.fromDate(leave.startDate),
          'endDate': Timestamp.fromDate(leave.endDate),
          'leaveReason': leave.leaveReason,
          'createdAt': leave.createdAt != null
              ? Timestamp.fromDate(leave.createdAt!)
              : FieldValue.serverTimestamp(),
          'durationDays': leave.durationDays,
          'status': leave.status,
          'leavesid': leave.leavesId,
        };

        final docRef =
            FirebaseFirestore.instance.collection('Leaves').doc(leave.leavesId);
        final docSnapshot = await docRef.get();

        try {
          if (docSnapshot.exists) {
            if (docSnapshot.data()!['status'] != leave.status) {
              await docRef.update({'status': leave.status});
            }
          } else {
            await docRef.set(leaveData);
          }

          if (!docSnapshot.exists ||
              docSnapshot.data()!['status'] != leave.status) {
            await sendNotification(
              userId: leave.userId,
              title: "Leave Status Updated",
              message:
                  "Your leave request for ${leave.leaveReason} from ${leave.startDate.toLocal().toString().split(' ')[0]} to ${leave.endDate.toLocal().toString().split(' ')[0]} has been ${leave.status}.",
              type: "LeaveStatus",
              payload: {
                "userName": leave.username,
                "userRole": leave.creatorRole,
                "leaveType": leave.leaveType,
                "leaveStatus": leave.status,
              },
            );
          }
        } catch (e) {
          leave.isSynced = false;
          await IsarUserService.isar!.writeTxn(() async {
            await IsarUserService.isar!.leaveRequests.put(leave);
          });
        }
      }
    } catch (e) {
      debugPrint("Error syncing leaves: $e");
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> checkInternet() async {
    bool connected = await hasInternet();
    setState(() => isOnline = connected);

    if (connected) {
      await syncFirestoreToLocal();
      await syncUnsyncedLeaves();
    }

    _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) async {
      bool newOnlineStatus =
          results.any((result) => result != ConnectivityResult.none) &&
              await hasInternet();

      if (newOnlineStatus != isOnline) {
        setState(() => isOnline = newOnlineStatus);
        if (newOnlineStatus) {
          await syncFirestoreToLocal();
          await syncUnsyncedLeaves();
        }
      }
    });
  }

  Future<void> syncFirestoreToLocal() async {
    if (!await hasInternet()) return;

    try {
      final leavesSnapshot =
          await FirebaseFirestore.instance.collection('Leaves').get();

      await IsarUserService.isar!.writeTxn(() async {
        for (final doc in leavesSnapshot.docs) {
          final leaveData = doc.data();
          final leaveId = doc.id;

          final existingLeave = await IsarUserService.isar!.leaveRequests
              .where()
              .leavesIdEqualTo(leaveId)
              .findFirst();

          if (existingLeave == null) {
            final leaveRequest = LeaveRequest()
              ..userId = leaveData['userId'] ?? ''
              ..leavesId = leaveId
              ..username = leaveData['username'] ?? ''
              ..userDepartment = leaveData['userDepartment'] ?? ''
              ..creatorRole = leaveData['creator_role'] ?? ''
              ..leaveType = leaveData['leaveType'] ?? ''
              ..startDate = (leaveData['startDate'] as Timestamp).toDate()
              ..endDate = (leaveData['endDate'] as Timestamp).toDate()
              ..leaveReason = leaveData['leaveReason'] ?? ''
              ..durationDays = leaveData['durationDays'] ?? 0
              ..status = leaveData['status'] ?? 'Pending'
              ..createdAt = (leaveData['createdAt'] as Timestamp).toDate()
              ..isSynced = true;

            await IsarUserService.isar!.leaveRequests.put(leaveRequest);
          }
        }
      });
    } catch (e) {
      debugPrint("Error syncing Firestore to local: $e");
    }
  }

  Future<void> submitLeaveData() async {
    if (!key.currentState!.validate()) return;

    try {
      setState(() {
        isLoading = true;
        _autoValidate = true;
      });

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("No authenticated user found");

      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();
      if (!userDoc.exists)
        throw Exception("User details not found in Firestore");

      final userData = userDoc.data() as Map<String, dynamic>;
      final userDepartment = userData["department"] ?? "";
      final userName = userData["username"] ?? "";
      final creatorRole = (userData["role"] ?? "").toString().toLowerCase();

      DateTime startDate = DateTime.parse(startdateController.text);
      DateTime endDate = DateTime.parse(enddateController.text);
      int duration = endDate.difference(startDate).inDays + 1;

      final existingLeaves = await IsarUserService.isar!.leaveRequests
          .where()
          .userIdEqualTo(currentUser.uid)
          .filter()
          .startDateLessThan(endDate.add(Duration(days: 1)))
          .and()
          .endDateGreaterThan(startDate.subtract(Duration(days: 1)))
          .findAll();

      final filteredLeaves = isEditing && leaveDocId != null
          ? existingLeaves
              .where((leave) => leave.leavesId != leaveDocId)
              .toList()
          : existingLeaves;

      if (filteredLeaves.isNotEmpty) {
        _showSnackBar(
            "You already have a leave request overlapping with these dates.");
        setState(() => isLoading = false);
        return;
      }

      final leaveId =
          isEditing && leaveDocId != null ? leaveDocId! : Uuid().v4();

      final leaveRequest = LeaveRequest()
        ..userId = currentUser.uid
        ..leavesId = leaveId
        ..username = userName
        ..userDepartment = userDepartment
        ..creatorRole = creatorRole
        ..leaveType = leavetypeController.text
        ..startDate = startDate
        ..endDate = endDate
        ..leaveReason = leavereasonController.text
        ..durationDays = duration
        ..status = 'Pending'
        ..createdAt = DateTime.now()
        ..isSynced = false;

      await IsarUserService.isar!.writeTxn(() async {
        await IsarUserService.isar!.leaveRequests.put(leaveRequest);
      });
      Navigator.pop(context);

      bool online = await isConnected();
      if (online) {
        final leaveData = {
          'userId': currentUser.uid,
          'username': userName,
          'userDepartment': userDepartment,
          'creator_role': creatorRole,
          'leaveType': leavetypeController.text,
          'startDate': Timestamp.fromDate(startDate),
          'endDate': Timestamp.fromDate(endDate),
          'leaveReason': leavereasonController.text,
          'createdAt': FieldValue.serverTimestamp(),
          'durationDays': duration,
          'status': 'Pending',
          'leavesid': leaveRequest.leavesId,
        };

        await FirebaseFirestore.instance
            .collection('Leaves')
            .doc(leaveRequest.leavesId)
            .set(leaveData, SetOptions(merge: true));

        await IsarUserService.isar!.writeTxn(() async {
          leaveRequest.isSynced = true;
          await IsarUserService.isar!.leaveRequests.put(leaveRequest);
        });
      } else {
        FirestoreQueue.queueUpdate(
          collection: 'Leaves',
          docId: leaveRequest.leavesId,
          data: {
            'userId': currentUser.uid,
            'username': userName,
            'userDepartment': userDepartment,
            'creator_role': creatorRole,
            'leaveType': leavetypeController.text,
            'startDate': Timestamp.fromDate(startDate),
            'endDate': Timestamp.fromDate(endDate),
            'leaveReason': leavereasonController.text,
            'createdAt': FieldValue.serverTimestamp(),
            'durationDays': duration,
            'status': 'Pending',
            'leavesid': leaveRequest.leavesId,
          },
        );
      }

      _showSnackBar(
          "Leave request submitted successfully", Colors.green.shade500);
      Navigator.pop(context);

      _clearForm();
    } catch (e) {
      _showSnackBar("Error submitting leave request: $e", Colors.red.shade500);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          isEditing = false;
        });
      }
    }
  }

  void _showSnackBar(String message, [Color? color]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 2),
        backgroundColor: color,
      ),
    );
  }

  void _clearForm() {
    leavetypeController.clear();
    leavereasonController.clear();
    startdateController.clear();
    enddateController.clear();
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

void initializeConnectivityListener() {
  Connectivity()
      .onConnectivityChanged
      .listen((ConnectivityResult result) async {
        if (result != ConnectivityResult.none) {
          final queuedNotifications =
              NotificationQueue.getQueuedNotifications();
          for (int i = queuedNotifications.length - 1; i >= 0; i--) {
            final notification = queuedNotifications[i];
            try {
              await sendNotification(
                userId: notification['userId'],
                title: notification['title'],
                message: notification['message'],
                type: notification['type'],
                payload: notification['payload'],
              );
              NotificationQueue.clearNotification(i);
            } catch (e) {
              debugPrint("Error sending queued notification: $e");
            }
          }
        }
      } as void Function(List<ConnectivityResult> event)?);
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
  bool isOnline = false;
  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    showstatusButtons = (_status == 'Pending');
    checkInternet();
    syncUnsyncedLeaves();
  }

  Future<void> syncUnsyncedLeaves() async {
    if (_isSyncing || !await hasInternet()) return;
    _isSyncing = true;

    try {
      final unsyncedLeaves = await IsarUserService.isar!.leaveRequests
          .where()
          .filter()
          .isSyncedEqualTo(false)
          .findAll();

      for (final leave in unsyncedLeaves) {
        leave.isSynced = true;
        await IsarUserService.isar!.writeTxn(() async {
          await IsarUserService.isar!.leaveRequests.put(leave);
        });

        final leaveData = {
          'userId': leave.userId,
          'username': leave.username,
          'userDepartment': leave.userDepartment,
          'creator_role': leave.creatorRole,
          'leaveType': leave.leaveType,
          'startDate': Timestamp.fromDate(leave.startDate),
          'endDate': Timestamp.fromDate(leave.endDate),
          'leaveReason': leave.leaveReason,
          'createdAt': leave.createdAt != null
              ? Timestamp.fromDate(leave.createdAt!)
              : FieldValue.serverTimestamp(),
          'durationDays': leave.durationDays,
          'status': leave.status,
          'leavesid': leave.leavesId,
        };
        print(leaveData);

        final docRef =
            FirebaseFirestore.instance.collection('Leaves').doc(leave.leavesId);
        final docSnapshot = await docRef.get();

        try {
          if (docSnapshot.exists) {
            if (docSnapshot.data()!['status'] != leave.status) {
              await docRef.update({'status': leave.status});
            }
          } else {
            await docRef.set(leaveData);
          }

          if (!docSnapshot.exists ||
              docSnapshot.data()!['status'] != leave.status) {
            await sendNotification(
              userId: leave.userId,
              title: "Leave Status Updated",
              message:
                  "Your leave request for ${leave.leaveReason} from ${leave.startDate.toLocal().toString().split(' ')[0]} to ${leave.endDate.toLocal().toString().split(' ')[0]} has been ${leave.status}.",
              type: "LeaveStatus",
              payload: {
                "userName": leave.username,
                "userRole": leave.creatorRole,
                "leaveType": leave.leaveType,
                "leaveStatus": leave.status,
              },
            );
          }
        } catch (e) {
          leave.isSynced = false;
          await IsarUserService.isar!.writeTxn(() async {
            await IsarUserService.isar!.leaveRequests.put(leave);
          });
        }
      }
    } catch (e) {
      debugPrint("Error syncing leaves: $e");
    } finally {
      _isSyncing = false;
    }
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

  Future<void> checkInternet() async {
    bool connected = await hasInternet();
    setState(() {
      isOnline = connected;
    });

    _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) async {
      bool newOnlineStatus =
          results.any((result) => result != ConnectivityResult.none) &&
              await hasInternet();
      if (newOnlineStatus != isOnline) {
        setState(() {
          isOnline = newOnlineStatus;
        });
        await Future.delayed(const Duration(seconds: 2));
        if (newOnlineStatus && !_isSyncing) {
          await syncUnsyncedLeaves();
        }
      }
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

  Future<void> updateLeaveStatus(String newStatus) async {
    try {
      bool online = await hasInternet();

      if (IsarUserService.isar == null) {
        throw Exception("Local database is not initialized");
      }

      // Fetch the leave request from local Isar storage first
      LeaveRequest? leaveRequest = await IsarUserService.isar!.leaveRequests
          .where()
          .leavesIdEqualTo(widget.leaveId)
          .findFirst();

      // If the leave request isn’t in local storage and we’re online, fetch it from Firestore
      if (leaveRequest == null && online) {
        DocumentSnapshot leaveDoc = await FirebaseFirestore.instance
            .collection('Leaves')
            .doc(widget.leaveId)
            .get();

        if (leaveDoc.exists) {
          final leaveData = leaveDoc.data() as Map<String, dynamic>;
          leaveRequest = LeaveRequest()
            ..userId = leaveData['userId'] ?? ''
            ..leavesId = widget.leaveId
            ..username = leaveData['username'] ?? ''
            ..userDepartment = leaveData['userDepartment'] ?? ''
            ..creatorRole = leaveData['creator_role'] ?? ''
            ..leaveType = leaveData['leaveType'] ?? ''
            ..startDate = (leaveData['startDate'] as Timestamp).toDate()
            ..endDate = (leaveData['endDate'] as Timestamp).toDate()
            ..leaveReason = leaveData['leaveReason'] ?? ''
            ..durationDays = leaveData['durationDays'] ?? 0
            ..status = leaveData['status'] ?? 'Pending'
            ..createdAt = leaveData['createdAt'] != null
                ? (leaveData['createdAt'] as Timestamp).toDate()
                : DateTime.now()
            ..isSynced = true;

          // Store the fetched leave request in the updater's local Isar storage
          await IsarUserService.isar!.writeTxn(() async {
            await IsarUserService.isar!.leaveRequests.put(leaveRequest!);
          });
        } else {
          throw Exception("Leave request does not exist in Firestore");
        }
      }

      if (leaveRequest == null) {
        throw Exception(
            "Leave request not found locally and device is offline");
      }

      // Update the status and sync flag
      await IsarUserService.isar!.writeTxn(() async {
        leaveRequest!.status = newStatus;
        leaveRequest.isSynced = online;
        await IsarUserService.isar!.leaveRequests.put(leaveRequest);
      });

      // If online, update Firestore and send notifications
      if (online) {
        await FirebaseFirestore.instance
            .collection('Leaves')
            .doc(widget.leaveId)
            .update({'status': newStatus});

        DocumentSnapshot leaveDoc = await FirebaseFirestore.instance
            .collection('Leaves')
            .doc(widget.leaveId)
            .get();

        if (leaveDoc.exists) {
          final leaveData = leaveDoc.data() as Map<String, dynamic>;
          String requesterId = leaveData['userId'] ?? "Unknown";
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

          final Map<String, dynamic> notificationParams = {
            'userId': requesterId,
            'title': "Leave Status Updated",
            'message':
                "Your leave request for $reason from $startDate to $endDate has been $newStatus.",
            'type': "LeaveStatus",
            'payload': <String, dynamic>{
              "userName": username,
              "userRole": role,
              "leaveType": leaveType,
              "leaveStatus": newStatus,
            },
          };

          await sendNotification(
            userId: notificationParams['userId'] as String,
            title: notificationParams['title'] as String,
            message: notificationParams['message'] as String,
            type: notificationParams['type'] as String,
            payload: notificationParams['payload'] as Map<String, dynamic>,
          );
        }
      } else {
        // Queue the update for Firestore if offline
        FirestoreQueue.queueUpdate(
          collection: 'Leaves',
          docId: widget.leaveId,
          data: {'status': newStatus},
        );

        // Queue the notification if offline
        NotificationQueue.queueNotification(
          userId: leaveRequest.userId,
          title: "Leave Status Updated",
          message:
              "Your leave request for ${leaveRequest.leaveReason} from ${leaveRequest.startDate.toLocal().toString().split(' ')[0]} to ${leaveRequest.endDate.toLocal().toString().split(' ')[0]} has been $newStatus.",
          type: "LeaveStatus",
          payload: {
            "userName": leaveRequest.username,
            "userRole": leaveRequest.creatorRole,
            "leaveType": leaveRequest.leaveType,
            "leaveStatus": newStatus,
          },
          leavesId: widget.leaveId,
        );
      }

      setState(() {
        _status = newStatus;
        showstatusButtons = false;
      });

      if (widget.closesheet) {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error updating leave status: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(10),
        ),
      );
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
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
                  onTap: () => updateLeaveStatus('Approved'),
                ),
                _buildButton(
                  text: 'Reject',
                  color: Colors.red,
                  onTap: () => updateLeaveStatus('Rejected'),
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

class NotificationQueue {
  static final List<Map<String, dynamic>> _queuedNotifications = [];

  static void queueNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    required Map<String, dynamic> payload,
    required String leavesId,
  }) {
    bool alreadyQueued = _queuedNotifications.any(
        (notification) => notification['payload']?['leavesId'] == leavesId);
    if (!alreadyQueued) {
      _queuedNotifications.add({
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'payload': {...payload, 'leavesId': leavesId},
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  static List<Map<String, dynamic>> getQueuedNotifications() =>
      _queuedNotifications;

  static void clearNotification(int index) {
    if (index >= 0 && index < _queuedNotifications.length) {
      _queuedNotifications.removeAt(index);
    }
  }

  static void clearNotificationByLeavesId(String leavesId) {
    _queuedNotifications.removeWhere(
        (notification) => notification['payload']?['leavesId'] == leavesId);
  }

  static Future<void> processQueue() async {
    if (_queuedNotifications.isEmpty) return;

    final notifications = List<Map<String, dynamic>>.from(_queuedNotifications);

    for (var notification in notifications) {
      try {
        await sendNotification(
          userId: notification['userId'] as String,
          title: notification['title'] as String,
          message: notification['message'] as String,
          type: notification['type'] as String,
          payload: notification['payload'] as Map<String, dynamic>,
        );

        clearNotificationByLeavesId(notification['payload']['leavesId']);
      } catch (e) {
        print("Error sending queued notification: $e");
      }
    }
  }
}

class FirestoreQueue {
  static final List<Map<String, dynamic>> _queuedUpdates = [];

  static void queueUpdate({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) {
    _queuedUpdates.add({
      'collection': collection,
      'docId': docId,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static List<Map<String, dynamic>> getQueuedUpdates() => _queuedUpdates;

  static void clearUpdate(int index) {
    if (index >= 0 && index < _queuedUpdates.length) {
      _queuedUpdates.removeAt(index);
    }
  }
}

Future<void> sendNotification({
  required String userId,
  required String title,
  required String message,
  required String type,
  Map<String, dynamic>? payload,
}) async {
  await FirebaseFirestore.instance.collection('notifications').add({
    'userId': userId,
    'title': title,
    'message': message,
    'type': type,
    'timestamp': DateTime.now().toUtc(),
    'isRead': false,
    'isNotified': false,
    'payload': payload,
  });
}

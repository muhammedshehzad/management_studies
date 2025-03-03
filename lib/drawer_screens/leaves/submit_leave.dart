import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:new_school/isar_storage/leave_request_model.dart';
import 'package:uuid/uuid.dart';

import '../../isar_storage/isar_user_service.dart';
import '../../notifications/notification_services.dart';

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
      } else {}

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

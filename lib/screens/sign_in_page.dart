import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isar/isar.dart' hide Query;
import 'package:new_school/isar_storage/academic_records_model.dart';
import 'package:new_school/isar_storage/homework_records_model.dart';
import 'package:new_school/isar_storage/leave_request_model.dart';
import 'package:new_school/isar_storage/transaction_model.dart';
import 'package:new_school/isar_storage/user_model.dart';
import 'package:new_school/screens/sign_up_page.dart';
import 'package:new_school/sliding_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Dashboard/dashboard.dart';
import '../firebase_auth_implementation/firebase_auth_services.dart';
import '../isar_storage/isar_user_service.dart';
import '../isar_storage/school_details_model.dart';

// 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  ---passkey---

Future<void> syncLeavesFirestoreToIsar() async {
  try {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("User not logged in.");
      return;
    }

    final String userRole = await _getUserRole();
    Query<Map<String, dynamic>> query;

    if (userRole == 'Student') {
      query = FirebaseFirestore.instance
          .collection('Leaves')
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true);
      print("Fetching leave records for Student...");
    } else if (userRole == 'Teacher') {
      final userDocSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();

      if (!userDocSnapshot.exists ||
          userDocSnapshot.data()?['department'] == null) {
        print("User department not found.");
        return;
      }

      final userDepartment = userDocSnapshot.data()!['department'];

      query = FirebaseFirestore.instance
          .collection('Leaves')
          .where(Filter.or(
            Filter('userId', isEqualTo: currentUser.uid),
            Filter.and(
              Filter('creator_role', isEqualTo: 'student'),
              Filter('userDepartment', isEqualTo: userDepartment),
            ),
          ))
          .orderBy('createdAt', descending: true);

      print(
          "Fetching leave records for $userRole in department: $userDepartment...");
    } else {
      query = FirebaseFirestore.instance
          .collection('Leaves')
          .orderBy('createdAt', descending: true);
      print("Fetching all leave records...");
    }

    final snapshot = await query.get();

    if (snapshot.docs.isEmpty) {
      print("No leave records found in Firestore.");
      return;
    }

    await IsarUserService.isar!.writeTxn(() async {
      await IsarUserService.isar!.leaveRequests.clear();
    });

    List<LeaveRequest> leaveRecords = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      DateTime startDate = (data['startDate'] as Timestamp).toDate();
      DateTime endDate = (data['endDate'] as Timestamp).toDate();

      leaveRecords.add(LeaveRequest()
        ..userId = data['userId'] ?? ''
        ..leavesId = data['leavesid'] ?? ''
        ..username = data['username'] ?? ''
        ..userDepartment = data['userDepartment'] ?? ''
        ..creatorRole = data['creator_role'] ?? ''
        ..leaveType = data['leaveType'] ?? ''
        ..startDate = startDate
        ..endDate = endDate
        ..createdAt =
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now()
        ..leaveReason = data['leaveReason'] ?? ''
        ..durationDays = data['durationDays'] ?? 0
        ..status = data['status'] ?? ''
        ..isSynced = true);
    }

    if (leaveRecords.isNotEmpty) {
      await IsarUserService.isar!.writeTxn(() async {
        await IsarUserService.isar!.leaveRequests.putAll(leaveRecords);
      });
      print(
          "Synced ${leaveRecords.length} leave records from Firestore to Isar.");
    } else {
      print("No new leave records to sync.");
    }
  } catch (e) {
    print("Error during leave records sync: $e");
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

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> with SingleTickerProviderStateMixin {
  bool isloading = false;
  final FirebaseAuthService _auth = FirebaseAuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  StreamSubscription<User?>? _userSubscription;
  final _db = FirebaseFirestore.instance;
  bool _isUpdatingEmail = false;
  final TextEditingController emailController = TextEditingController();
  String? userid;


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveProfileToIsar(Map<String, dynamic> data,
      {bool updateEmail = true}) async {
    await IsarUserService.isar!.writeTxn(() async {
      final existingUser = await IsarUserService.isar!.userModels
          .filter()
          .uidEqualTo(userid!)
          .findFirst();

      final user = existingUser ?? UserModel();
      user.uid = userid!;
      user.username = data['username'] ?? 'N/A';
      user.role = data['role'] ?? 'N/A';
      user.url = data['url'] ?? '';
      user.department = data['department'] ?? '';
      user.address = data['address'] ?? '';
      user.phone = data['phone'] ?? 'N/A';

      if (updateEmail) {
        user.email = data['email'] ?? 'N/A';
      } else {
        user.email = existingUser?.email ?? data['email'] ?? 'N/A';
      }

      await IsarUserService.isar!.userModels.put(user);
    });
  }

  Future<void> syncHomeworkRecordsFirestoreToIsar() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final String currentUserId = currentUser?.uid ?? "";
      final String userRole = await _getUserRole();

      Query<Map<String, dynamic>> query;

      if (userRole == 'Student' && currentUser != null) {
        query = FirebaseFirestore.instance
            .collection('homeworks')
            .where('userId', isEqualTo: currentUserId)
            .orderBy('deadline', descending: true);
        print('Fetching student homework list...');
      } else if (userRole == 'Teacher' && currentUser != null) {
        final userDocSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .get();
        if (!userDocSnapshot.exists) {
          print('Teacher document does not exist.');
          return;
        }
        final userDepartment = userDocSnapshot.data()?['department'];
        if (userDepartment == null) {
          print('Teacher department is null.');
          return;
        }
        query = FirebaseFirestore.instance
            .collection('homeworks')
            .where('subject', isEqualTo: userDepartment)
            .orderBy('deadline', descending: true);
        print('Fetching teacher homework list...');
      } else {
        query = FirebaseFirestore.instance
            .collection('homeworks')
            .orderBy('deadline', descending: true);
        print('Fetching admin homework list...');
      }
      await IsarUserService.isar!.writeTxn(() async {
        await IsarUserService.isar!.homeworkRecordModels.clear();
      });
      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        print("No homeworks found in Firestore/No connectivity");
        return;
      }

      final existingRecords =
          await IsarUserService.isar!.homeworkRecordModels.where().findAll();
      final existingDocIds =
          existingRecords.map((record) => record.docid).toSet();

      List<HomeworkRecordModel> homeworkRecords = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();

        if (existingDocIds.contains(doc.id)) {
          continue;
        }

        homeworkRecords.add(HomeworkRecordModel()
          ..docid = data['docid'] ?? ''
          ..subject = data['subject'] ?? ''
          ..title = data['title'] ?? ''
          ..deadline = (data['deadline'] is Timestamp)
              ? (data['deadline'] as Timestamp).toDate()
              : DateTime.now()
          ..assignedBy = data['assignedby'] ?? ''
          ..description = data['description'] ?? ''
          ..status = data['status'] ?? ''
          ..estimatedTime = data['estimatedtime'] ?? '');
      }

      if (homeworkRecords.isNotEmpty) {
        await IsarUserService.isar!.writeTxn(() async {
          await IsarUserService.isar!.homeworkRecordModels
              .putAll(homeworkRecords);
        });
        print(
            "Synced ${homeworkRecords.length} new homework record(s) from Firestore to Isar.");
      } else {
        print("No new homework records to sync.");
      }
    } catch (e) {
      print("1Error during sync: $e");
    }
  }

  Future<void> syncLeavesFirestoreToIsar() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print("User not logged in.");
        return;
      }

      final String userRole = await _getUserRole();
      Query<Map<String, dynamic>> query;

      if (userRole == 'Student') {
        query = FirebaseFirestore.instance
            .collection('Leaves')
            .where('userId', isEqualTo: currentUser.uid)
            .orderBy('createdAt', descending: true);
        print("Fetching leave records for Student...");
      } else if (userRole == 'Teacher') {
        final userDocSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .get();

        if (!userDocSnapshot.exists ||
            userDocSnapshot.data()?['department'] == null) {
          print("User department not found.");
          return;
        }

        final userDepartment = userDocSnapshot.data()!['department'];
        query = FirebaseFirestore.instance
            .collection('Leaves')
            .where(Filter.or(
              Filter('userId', isEqualTo: currentUser.uid),
              Filter.and(
                Filter('creator_role', isEqualTo: 'student'),
                Filter('userDepartment', isEqualTo: userDepartment),
              ),
            ))
            .orderBy('createdAt', descending: true);

        print(
            "Fetching leave records for $userRole in department: $userDepartment...");
      } else {
        query = FirebaseFirestore.instance
            .collection('Leaves')
            .orderBy('createdAt', descending: true);
        print("Fetching all leave records...");
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        print("No leave records found in Firestore.");
        return;
      }

      await IsarUserService.isar!.writeTxn(() async {
        await IsarUserService.isar!.leaveRequests.clear();
      });

      List<LeaveRequest> leaveRecords = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        DateTime startDate = (data['startDate'] as Timestamp).toDate();
        DateTime endDate = (data['endDate'] as Timestamp).toDate();

        leaveRecords.add(LeaveRequest()
          ..userId = data['userId'] ?? ''
          ..leavesId = data['leavesid'] ?? ''
          ..username = data['username'] ?? ''
          ..userDepartment = data['userDepartment'] ?? ''
          ..creatorRole = data['creator_role'] ?? ''
          ..leaveType = data['leaveType'] ?? ''
          ..startDate = startDate
          ..endDate = endDate
          ..createdAt =
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now()
          ..leaveReason = data['leaveReason'] ?? ''
          ..durationDays = data['durationDays'] ?? 0
          ..status = data['status'] ?? ''
          ..isSynced = true);
      }

      if (leaveRecords.isNotEmpty) {
        await IsarUserService.isar!.writeTxn(() async {
          await IsarUserService.isar!.leaveRequests.putAll(leaveRecords);
        });
        print(
            "Synced ${leaveRecords.length} leave records from Firestore to Isar.");
      } else {
        print("No new leave records to sync.");
      }
    } catch (e) {
      print("Error during leave records sync: $e");
    }
  }


  Future<void> syncRecordsFirestoreToIsar() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      final String currentUserId = currentUser?.uid ?? "";
      final String userRole = await _getUserRole();

      Query<Map<String, dynamic>> query;
      if (userRole == 'Student' && currentUser != null) {
        query = FirebaseFirestore.instance
            .collection('records')
            .where('userId', isEqualTo: currentUserId)
            .orderBy('admdate', descending: true);
        print('Fetching student list...');
      } else if (userRole == 'Teacher' && currentUser != null) {
        final userDocSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .get();
        if (!userDocSnapshot.exists) {
          print('Teacher document does not exist.');
          return;
        }
        final userDepartment = userDocSnapshot.data()?['department'];
        if (userDepartment == null) {
          print('Teacher department is null.');
          return;
        }
        query = FirebaseFirestore.instance
            .collection('records')
            .where('department', isEqualTo: userDepartment)
            .orderBy('admdate', descending: true);
        print('Fetching teacher list...');
      } else {
        query = FirebaseFirestore.instance
            .collection('records')
            .orderBy('admdate', descending: true);
        print('Fetching admin list...');
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        print("No records found in Firestore/No connectivity");
        return;
      }

      await IsarUserService.isar!.writeTxn(() async {
        await IsarUserService.isar!.studentDetailModels.clear();
      });

      List<StudentDetailModel> studentRecords = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final admissionNumber = data['admno'] ?? '';

        if (admissionNumber.isEmpty) {
          continue;
        }

        DateTime admissionDate = DateTime.now();
        if (data['admdate'] is Timestamp) {
          admissionDate = (data['admdate'] as Timestamp).toDate();
        }

        studentRecords.add(StudentDetailModel()
          ..uid = doc.id
          ..name = data['name'] ?? ''
          ..email = data['email'] ?? ''
          ..score =
              (data['score'] is num) ? (data['score'] as num).toDouble() : 0.0
          ..percentage = (data['percentage'] is num)
              ? (data['percentage'] as num).toDouble()
              : 0.0
          ..grade = data['grade'] ?? ''
          ..status = data['status'] ?? ''
          ..academicYear = data['academicyear'] ?? ''
          ..registerNumber = data['regno'] ?? ''
          ..admissionNumber = admissionNumber
          ..admissionDate = admissionDate
          ..department = data['department'] ?? ''
          ..hod = data['hod'] ?? ''
          ..fatherName = data['fathername'] ?? ''
          ..fatherOccupation = data['fatherjob'] ?? ''
          ..fatherPhone = data['fatherphone'] ?? ''
          ..motherName = data['mothername'] ?? ''
          ..motherOccupation = data['motherjob'] ?? ''
          ..motherPhone = data['motherphone'] ?? '');
      }

      if (studentRecords.isNotEmpty) {
        await IsarUserService.isar!.writeTxn(() async {
          await IsarUserService.isar!.studentDetailModels
              .putAll(studentRecords);
        });
        print(
            "Synced ${studentRecords.length} new record(s) from Firestore to Isar.");
      } else {
        print("No new records to sync.");
      }
    } catch (e) {
      print("2Error during sync: $e");
    }
  }

  Future<void> syncSchoolDetailsFromFirestore(String schoolId) async {
    if (schoolId.isEmpty) {
      print('Error: schoolId is empty');
      return;
    }

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection("School")
          .doc(schoolId)
          .get();

      if (!snapshot.exists) {
        print("No school details found for ID: $schoolId");
        return;
      }
      await IsarUserService.isar!.writeTxn(() async {
        await IsarUserService.isar!.schoolDetails.clear();
      });
      final data = snapshot.data() as Map<String, dynamic>;

      final schoolDetails = SchoolDetails()
        ..id = 1
        ..schoolName = data['schoolname'] ?? ''
        ..schoolType = data['schooltype'] ?? ''
        ..schoolLocation = data['schoollocation'] ?? ''
        ..schoolContact = data['schoolcontact'] ?? ''
        ..schoolWebsite = data['schoolwebsite'] ?? ''
        ..schoolImageUrl = data['url'] ?? '';

      await IsarUserService.isar!.writeTxn(() async {
        await IsarUserService.isar!.schoolDetails.put(schoolDetails);
      });

      print("School details synced - Firestore to Isar.");
    } catch (e) {
      print("Error syncing school details: $e");
    }
  }

  Future<void> syncUserProfileFromFirestore(String userId) async {
    if (userId.isEmpty) {
      print('userId is empty');
      return;
    }

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection("Users")
          .doc(userId)
          .get();

      if (!snapshot.exists) {
        print("No user profile found $userId");
        return;
      }
      await IsarUserService.isar!.writeTxn(() async {
        await IsarUserService.isar!.userModels.clear();
      });
      final data = snapshot.data() as Map<String, dynamic>;

      final user = UserModel()
        ..uid = userId
        ..username = data['username'] ?? 'N/A'
        ..email = data['email'] ?? 'N/A'
        ..role = data['role'] ?? 'N/A'
        ..url = data['url'] ?? ''
        ..department = data['department'] ?? ''
        ..address = data['address'] ?? ''
        ..phone = data['phone'] ?? 'N/A';

      await IsarUserService.isar!.writeTxn(() async {
        final existingUser = await IsarUserService.isar!.userModels
            .filter()
            .uidEqualTo(userId)
            .findFirst();
        if (existingUser != null) {
          user.id = existingUser.id;
        }
        await IsarUserService.isar!.userModels.put(user);
      });

      print("User synced from Firestore to Isar.");
    } catch (e) {
      print("Error syncing user profile: $e");
    }
  }

  Future<void> syncTransactionsFirestoreToIsar() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print("No logged-in user found.");
        return;
      }

      final String userRole = await _getUserRole();
      Query<Map<String, dynamic>> query;

      if (userRole == 'Student' || userRole == 'Teacher') {
        query = FirebaseFirestore.instance
            .collection('Transactions')
            .where('userId', isEqualTo: currentUser.uid)
            .orderBy('timestamp', descending: true);
        print('Student transactions...');
      } else {
        query = FirebaseFirestore.instance
            .collection('Transactions')
            .orderBy('timestamp', descending: true);
        print('All transactions...');
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        print("No transactions found in Firestore/No connectivity.");
        return;
      }

      await IsarUserService.isar!.writeTxn(() async {
        await IsarUserService.isar!.transactionModels.clear();
      });

      List<TransactionModel> transactions = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final String transactionId = doc.id;
        final String userId = data['userId'] ?? '';
        final String userName = data['userName'] ?? '';
        final double totalAmount = (data['totalAmount'] is num)
            ? (data['totalAmount'] as num).toDouble()
            : 0.0;
        DateTime timestamp = DateTime.now();
        if (data['timestamp'] != null && data['timestamp'] is Timestamp) {
          timestamp = (data['timestamp'] as Timestamp).toDate();
        }
        final String status = data['status'] ?? '';
        final String paymentId = data['paymentId'] ?? '';

        TransactionModel transaction = TransactionModel()
          ..transactionId = transactionId
          ..userId = userId
          ..userName = userName
          ..totalAmount = totalAmount
          ..timestamp = timestamp
          ..status = status
          ..paymentId = paymentId;

        final itemsSnapshot = await FirebaseFirestore.instance
            .collection('Transactions')
            .doc(transactionId)
            .collection('Items')
            .get();

        for (var itemDoc in itemsSnapshot.docs) {
          final itemData = itemDoc.data();

          TransactionItem item = TransactionItem()
            ..name = itemData['name'] ?? ''
            ..quantity = itemData['quantity'] ?? 0
            ..price = (itemData['price'] is num)
                ? (itemData['price'] as num).toDouble()
                : 0.0
            ..discountedPrice = (itemData['discountedPrice'] is num)
                ? (itemData['discountedPrice'] as num).toDouble()
                : 0.0
            ..total = (itemData['total'] is num)
                ? (itemData['total'] as num).toDouble()
                : 0.0;
          transaction.items.add(item);
        }

        transactions.add(transaction);
      }

      if (transactions.isNotEmpty) {
        await IsarUserService.isar!.writeTxn(() async {
          await IsarUserService.isar!.transactionModels.putAll(transactions);
        });
        print("Synced transactions from Firestore to Isar.");
      } else {
        print("No new transactions to sync.");
      }
    } catch (e) {
      print("Error during sync: $e");
    }
  }

  Future<void> _handleUserChange(User user) async {
    if (_isUpdatingEmail) return;

    final currentFirebaseEmail = user.email;
    if (currentFirebaseEmail == null) return;

    print("Updating Firestore email to: $currentFirebaseEmail");

    try {
      await _db.collection('Users').doc(userid).update({
        'email': currentFirebaseEmail,
      });
    } catch (e) {
      print("Error updating Firestore email: $e");
      return;
    }

    final snapshot = await _db.collection('Users').doc(userid).get();
    if (snapshot.exists) {
      final data = snapshot.data()!;

      await _saveProfileToIsar(data, updateEmail: true);
      if (mounted) {
        setState(() {
          emailController.text = currentFirebaseEmail;
        });
      }
    }
  }

  Future<void> _signIn() async {
    setState(() => isloading = true);

    if (!_formKey.currentState!.validate()) {
      setState(() => isloading = false);
      return;
    }

    try {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      User? userCredential =
          await _auth.signInWithEmailAndPassword(email, password);
      final User? user = FirebaseAuth.instance.currentUser;
      userid = user?.uid;
      if (userid != null) {
        _userSubscription =
            FirebaseAuth.instance.userChanges().listen((User? user) {
          if (user != null && mounted) {
            _handleUserChange(user);
          }
        });
      }
      if (userCredential != null) {
        var userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userCredential.uid)
            .get();
        final User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', user.uid);
        }
        if (!userDoc.exists) throw 'User role not found in Firestore.';

        final validRoles = ['Admin', 'Teacher', 'Student'];
        String role = userDoc.data()?['role'];
        if (!validRoles.contains(role)) throw 'Invalid role detected: $role';
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);
        await prefs.setString('role', role);

        if (!IsarUserService.isInitialized) {
          await IsarUserService.init();
        }
        syncRecordsFirestoreToIsar();

        syncSchoolDetailsFromFirestore('9NekuNXmyxdNxWekn282');

        syncUserProfileFromFirestore(user!.uid);

        syncHomeworkRecordsFirestoreToIsar();

        syncTransactionsFirestoreToIsar();

        syncLeavesFirestoreToIsar();

        Navigator.pushReplacement(
            context, SlidingPageTransitionRL(page: Dashboard(role: role)));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Sign-in successful'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green.shade500,
        ));
      } else {
        throw 'User not found.';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red.shade500,
      ));
    } finally {
      setState(() => isloading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Create animations
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Start animation
    _animationController.forward();
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _titleSlidePosition = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  height: 180,
                  child: Image.asset('lib/assets/access.png'),
                ),
                const SizedBox(height: 24),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Color(0xff3e948e), Color(0xff56c1ba)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Text(
                    "Welcome Back!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Sign in to continue",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black45,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 4),
    
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
              child: FadeTransition(
                opacity: _fadeInAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.8, end: 1.0),
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeInOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: SizedBox(
                              height: 120,
                              child: Hero(
                                tag: 'app_logo',
                                child: Image.asset('lib/assets/access.png'),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [Color(0xff3e948e), Color(0xff56c1ba)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: const Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Sign in to continue to your account",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                            BoxShadow(
                              color: Color(0xff3e948e).withOpacity(0.03),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Account Information",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff3e948e),
                                ),
                              ),
                              const SizedBox(height: 24),
                              AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return FadeTransition(
                                    opacity: Tween<double>(begin: 0.0, end: 1.0)
                                        .animate(
                                      CurvedAnimation(
                                        parent: _animationController,
                                        curve: Interval(0.4, 1.0,
                                            curve: Curves.easeOut),
                                      ),
                                    ),
                                    child: child,
                                  );
                                },
                                child: TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email Address',
                                    hintText: 'example@email.com',
                                    labelStyle: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Icon(Icons.email_outlined,
                                          color: Color(0xff3e948e)),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    contentPadding:
                                        const EdgeInsets.symmetric(vertical: 0),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.grey.withOpacity(0.15)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Color(0xff3e948e), width: 1.5),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.red.shade300),
                                    ),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty)
                                      return 'Please enter your email';
                                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                        .hasMatch(value))
                                      return 'Enter a valid email';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                              AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return FadeTransition(
                                    opacity: Tween<double>(begin: 0.0, end: 1.0)
                                        .animate(
                                      CurvedAnimation(
                                        parent: _animationController,
                                        curve: Interval(0.5, 1.0,
                                            curve: Curves.easeOut),
                                      ),
                                    ),
                                    child: child,
                                  );
                                },
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: _isObscure,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    hintText: '••••••••',
                                    labelStyle: TextStyle(
                                      // Username field - with animation
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Icon(Icons.lock_outline,
                                          color: Color(0xff3e948e)),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isObscure
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Colors.grey[600],
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isObscure = !_isObscure;
                                        });
                                      },
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    contentPadding:
                                        const EdgeInsets.symmetric(vertical: 0),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.grey.withOpacity(0.15)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Color(0xff3e948e), width: 1.5),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.red.shade300),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty)
                                      return 'Please enter your password';
                                    if (value.length < 6)
                                      return 'Password must be at least 6 characters';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 6),
                              const SizedBox(height: 30),
                              AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return FadeTransition(
                                    opacity: Tween<double>(begin: 0.0, end: 1.0)
                                        .animate(
                                      CurvedAnimation(
                                        parent: _animationController,
                                        curve: Interval(0.7, 1.0,
                                            curve: Curves.easeOut),
                                      ),
                                    ),
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                              begin: Offset(0, 0.3),
                                              end: Offset.zero)
                                          .animate(
                                        CurvedAnimation(
                                          parent: _animationController,
                                          curve: Interval(0.7, 1.0,
                                              curve: Curves.easeOutCubic),
                                        ),
                                      ),
                                      child: child,
                                    ),
                                  );
                                },
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 1.0, end: 1.0),
                                    duration: const Duration(milliseconds: 200),
                                    builder: (context, value, child) {
                                      return Transform.scale(
                                        scale: value,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xff3e948e),
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: isloading
                                              ? null
                                              : () {
                                                  // Button press animation
                                                  setState(() {
                                                    _signIn();
                                                  });
                                                },
                                          child: isloading
                                              ? SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2.0,
                                                  ),
                                                )
                                              : Text(
                                                  'Sign In',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return FadeTransition(
                                    opacity: Tween<double>(begin: 0.0, end: 1.0)
                                        .animate(
                                      CurvedAnimation(
                                        parent: _animationController,
                                        curve: const Interval(0.6, 1.0,
                                            curve: Curves.easeOut),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Flexible(
                                          flex: 4,
                                          child: Text(
                                            "Don't have an account?",
                                            style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 13),
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: false,
                                          ),
                                        ),
                                        Flexible(
                                          flex: 2,
                                          child: TextButton(
                                            onPressed: () =>
                                                Navigator.pushReplacement(
                                              context,
                                              SlidingPageTransitionRL(
                                                  page: SignUp()),
                                            ),
                                            child: const Text(
                                              'Sign Up',
                                              style: TextStyle(
                                                color: Color(0xff3e948e),
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: false,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:new_school/drawer_screens/academic_records.dart';
import 'package:new_school/drawer_screens/homework_assignment.dart';
import 'package:new_school/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:new_school/notifications/notification_services.dart';
import 'package:new_school/screens/profile_page.dart';
import 'package:new_school/screens/sign_in_page.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:badges/badges.dart' as badges;
import '../assets/widgets/admin_dashboard_charts.dart';
import '../assets/widgets/student_dashboard_charts.dart';
import '../assets/widgets/teacher_dashboard_chart.dart';
import '../drawer_screens/Canteen/canteen_page.dart';
import '../drawer_screens/leaves_page.dart';
import '../screens/notifications_page.dart';
import '../sliding_transition.dart';

class Dashboard extends StatefulWidget {
  final String role;

  const Dashboard({super.key, required this.role});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with WidgetsBindingObserver {
  File? selectedImage;
  bool isAuthenticating = false;

  Future<void> _checkAuthenticationOnStartup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFingerprintEnabled = prefs.getBool('fingerprint_enabled') ?? false;
    bool isAuthenticated = prefs.getBool('is_authenticated') ?? false;

    if (isFingerprintEnabled && !isAuthenticated && !isAuthenticating) {
      bool authResult = await _showBiometricAuth();
      if (!authResult) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication required.')),
        );
        await Future.delayed(const Duration(milliseconds: 100));
        SystemNavigator.pop();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAuthenticationOnResume();
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> _checkAuthenticationOnResume() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFingerprintEnabled = prefs.getBool('fingerprint_enabled') ?? false;
    bool isAuthenticated = prefs.getBool('is_authenticated') ?? false;

    if (isFingerprintEnabled && !isAuthenticated && !isAuthenticating) {
      bool authResult = await _showBiometricAuth();
      if (!authResult) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication required.')),
        );
        SystemNavigator.pop();
      }
    }
  }

  Future<bool> _showBiometricAuth() async {
    if (isAuthenticating) return false;

    setState(() {
      isAuthenticating = true;
    });

    final LocalAuthentication auth = LocalAuthentication();
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Biometric authentication not available.')),
        );
        return false;
      }

      final result = await auth.authenticate(
        localizedReason: 'Authenticate to access the dashboard',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (result) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('is_authenticated', true);
      }

      return result;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication error: $e')),
      );
      return false;
    } finally {
      setState(() {
        isAuthenticating = false;
      });
    }
  }

  Future<String?> getImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profileImagePath');
  }

  Future<void> saveImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImagePath', path);
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>>? profileBuild() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .snapshots();
    }
    return Stream.empty();
  }

  @override
  void initState() {
    super.initState();
    _loadImage();
    WidgetsBinding.instance.addObserver(this);
    _checkAuthenticationOnStartup();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadImage() async {
    final path = await getImagePath();
    if (path != null) {
      setState(() {
        selectedImage = File(path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profiles = profileBuild();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: profiles,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: Center(
              child: Material(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[400]!,
                  highlightColor: Colors.grey[100]!,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 70),
                          Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            height: 250,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            height: 250,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ));
          }

          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 50),
                  const SizedBox(height: 10),
                  Text(
                    'No data found for this user.',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => SignIn()));
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }
          print("Data: ${snapshot.data!.data()}");
          final data = snapshot.data!.data()!;
          final String role = data["role"] ?? 'N/A';
          var userData = snapshot.data!.data();
          String profileImageUrl = userData?['url'] ?? '';
          final String currentUserId =
              FirebaseAuth.instance.currentUser?.uid ?? "";

          return Scaffold(
            appBar: AppBar(
              actions: [
                StreamBuilder<QuerySnapshot>(
                  stream: firestore
                      .collection('notifications')
                      .where('userId', isEqualTo: currentUserId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              SlidingPageTransitionRL(
                                  page: NotificationsPage()));
                        },
                        icon: Image.asset(
                          'lib/assets/notification(1).png',
                          height: 25,
                          width: 25,
                        ),
                      ));
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                          child: Text('No notifications found'));
                    }

                    // Count unread notifications
                    final unreadCount = snapshot.data!.docs
                        .where((doc) => (doc['isRead'] == false))
                        .length;

                    return badges.Badge(
                      badgeAnimation: badges.BadgeAnimation.fade(),
                      showBadge: unreadCount > 0,
                      // Hide badge if there are no unread notifications
                      badgeContent: Text(
                        unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      position: badges.BadgePosition.topEnd(top: 5, end: 13),
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              SlidingPageTransitionRL(
                                  page: NotificationsPage()));
                        },
                        icon: Image.asset(
                          'lib/assets/notification(1).png',
                          height: 25,
                          width: 25,
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        SlidingPageTransitionRL(page: ProfilePage()),
                      );
                    },
                    icon: Container(
                      height: 33,
                      width: 33,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child:
                          profileImageUrl != null && profileImageUrl!.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    profileImageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.account_circle,
                                        size: 33,
                                        color: Colors.grey,
                                      );
                                    },
                                  ),
                                )
                              : Icon(
                                  Icons.account_circle,
                                  size: 33,
                                  color: Colors.grey,
                                ),
                    ),
                  ),
                ),
              ],
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                dragStartBehavior: DragStartBehavior.start,
                children: [
                  Container(
                    child: DrawerHeader(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(profileImageUrl),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.5),
                            BlendMode.darken,
                          ),
                        ),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(2),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            SlidingPageTransitionLR(page: ProfilePage()),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                data["username"] ?? 'N/A',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                data["email"] ?? 'N/A',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                role,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: Colors.yellowAccent,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      ListTile(
                        title: CustomTile(
                          label: 'Academic Records',
                          onPressed: () {
                            Navigator.push(
                              context,
                              SlidingPageTransitionLR(page: AcademicRecords()),
                            );
                          },
                          image: 'lib/assets/academicrecords.png',
                        ),
                      ),
                      ListTile(
                        title: CustomTile(
                          label: 'Homeworks',
                          onPressed: () {
                            Navigator.push(
                              context,
                              SlidingPageTransitionLR(page: HomeWorkScreen()),
                            );
                          },
                          image: 'lib/assets/homeworkandassignment.png',
                        ),
                      ),
                      ListTile(
                        title: CustomTile(
                          label: 'Canteen',
                          onPressed: () {
                            Navigator.push(
                              context,
                              SlidingPageTransitionLR(page: CanteenMenuPage()),
                            );
                          },
                          image: 'lib/assets/canteen.png',
                        ),
                      ),
                      ListTile(
                        title: CustomTile(
                          label: 'Leaves',
                          onPressed: () {
                            Navigator.push(
                              context,
                              SlidingPageTransitionLR(page: LeavesPage()),
                            );
                          },
                          image: 'lib/assets/leaves.png',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            body: SingleChildScrollView(
              child: Container(
                child: ContentArea(role: widget.role),
              ),
            ),
          );
        });
  }
}

class CustomTile extends StatelessWidget {
  const CustomTile({
    super.key,
    required this.label,
    required this.image,
    required this.onPressed,
  });

  final String label;
  final String image;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
        child: SizedBox(
          height: 60,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 3,
            color: Colors.blueGrey.shade100,
            shadowColor: Colors.black.withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    height: 25,
                    width: 25,
                    child: Image.asset(
                      image,
                      fit: BoxFit.cover,
                      color: Colors.blueGrey.shade700,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.blueGrey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ContentArea extends StatefulWidget {
  final String role;

  const ContentArea({super.key, required this.role});

  @override
  State<ContentArea> createState() => _ContentAreaState();
}

class _ContentAreaState extends State<ContentArea> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isStudent = widget.role == 'Student';
    bool isTeacher = widget.role == 'Teacher';
    bool isAdmin = widget.role == 'Admin';

    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                'Welcome to the ${widget.role} Dashboard!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            if (isStudent)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    child: FutureBuilder<double?>(
                      future: fetchAttendanceForCurrentUser(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                  ),
                                  width: double.infinity,
                                  height: 200,
                                  child: Center(
                                      child: CircularProgressIndicator())));
                        }
                        if (!snapshot.hasData) {
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            width: double.infinity,
                            height: 200,
                            child: Center(
                                child: Text("No attendance data available")),
                          );
                        }
                        double attendance = snapshot.data!;
                        return CircularIndicator(
                          attendance / 100,
                          "${attendance.toStringAsFixed(2)}%",
                          "Your Attendance Percentage",
                          attendance >= 75
                              ? Colors.green.shade500
                              : Colors.red.shade600,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  LeaderboardList(),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
            if (isTeacher)
              Column(
                children: [
                  SizedBox(
                    height: 12,
                  ),
                  AcademicPerformanceChart(),
                  DepartmentDistributionDonutChart(),
                  GradeDistributionChart(),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
            if (isAdmin)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    child: Text(
                      'Number of Teachers Per Department',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  TeachersChart(),
                  TeachersList(),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
          ],
        ),
      ],
    ));
  }

  Widget CircularIndicator(
      double percent, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.grey.shade300, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularPercentIndicator(
            radius: 55.0,
            lineWidth: 10.0,
            animation: true,
            animationDuration: 1200,
            percent: percent,
            center: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18.0,
                color: Colors.black87,
              ),
            ),
            footer: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16.0,
                  color: Colors.grey[700],
                ),
              ),
            ),
            circularStrokeCap: CircularStrokeCap.round,
            backgroundColor: Colors.grey[200]!,
            progressColor: color, // Single color for a flat look
          ),
        ],
      ),
    );
  }
}

class StudentData {
  final String year;
  final int boys;
  final int girls;

  StudentData({required this.year, required this.boys, required this.girls});
}

class Teacher {
  final String name;
  final String gender;
  final String department;

  Teacher({
    required this.name,
    required this.gender,
    required this.department,
  });
}

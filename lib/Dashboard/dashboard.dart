import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:new_school/drawer_screens/academic_records.dart';
import 'package:new_school/drawer_screens/canteen_page.dart';
import 'package:new_school/drawer_screens/homework_assignment.dart';
import 'package:new_school/screens/profile_page.dart';
import 'package:new_school/screens/sign_in_page.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../assets/widgets/homeworkdatamodel.dart';
import '../drawer_screens/leaves_page.dart';
import '../settings/two-factor_authentication.dart';
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
            return const Center(child: CircularProgressIndicator());
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
          return Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.notifications,
                      size: 33,
                    )),
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
                        image: DecorationImage(
                          image: NetworkImage(profileImageUrl),
                        ),
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
                          label: 'Homework and \nAssignments',
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
      child: SizedBox(
        height: 60,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
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
                    )),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.visible,
                ),
              ],
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              'Welcome to the ${widget.role} Dashboard!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Center(
          child: Column(
            children: [
              if (isStudent)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Attendance Indicators
                    CircularIndicator(0.82, "82.0%", "Average Attendance", Colors.yellowAccent.shade700),
                    SizedBox(height: 8),
                    CircularIndicator(0.18, "18.0%", "Average Leave Taken", Colors.purpleAccent.shade700),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Total Attendance = \nDays Present / \nTotal No. Of Working Days",
                                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                              ),
                              Text(
                                "109 / 120",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.green.shade600,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 12),
                        ],
                      ),
                    ),

                    // Linear Progress Indicator for Attendance
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * .7,
                        child: LinearPercentIndicator(
                          width: MediaQuery.of(context).size.width * .7,
                          lineHeight: 36.0,
                          percent: 0.82,
                          backgroundColor: Colors.grey.shade300,
                          progressColor: Colors.blue.shade500,
                          center: Text(
                            '82.0%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),

                    // Recent Activities/Assignments
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Text(
                    //         "Recent Activities/Assignments",
                    //         style: TextStyle(
                    //           fontSize: 18,
                    //           fontWeight: FontWeight.bold,
                    //           color: Colors.blue.shade700,
                    //         ),
                    //       ),
                    //       SizedBox(height: 10),
                    //       ListTile(
                    //         leading: Icon(Icons.assignment, color: Colors.blue),
                    //         title: Text("Math Homework - Due 3 days ago"),
                    //         subtitle: Text("Status: Completed"),
                    //       ),
                    //       ListTile(
                    //         leading: Icon(Icons.assignment_late, color: Colors.orange),
                    //         title: Text("Science Project - Due 1 week ago"),
                    //         subtitle: Text("Status: Pending"),
                    //       ),
                    //       ListTile(
                    //         leading: Icon(Icons.assignment_turned_in, color: Colors.green),
                    //         title: Text("English Essay - Due 5 days ago"),
                    //         subtitle: Text("Status: Completed"),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Performance Summary",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                          SizedBox(height: 10),
                          ListTile(
                            leading: Icon(Icons.trending_up, color: Colors.green),
                            title: Text("Overall Grade: A"),
                            subtitle: Text("You have consistently performed well in all subjects."),
                          ),
                          ListTile(
                            leading: Icon(Icons.trending_down, color: Colors.red),
                            title: Text("Math: C+ (Needs Improvement)"),
                            subtitle: Text("Focus on improving your Math scores."),
                          ),
                        ],
                      ),
                    ),
                    // Upcoming Exams
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Upcoming Exams",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 10),
                          ListTile(
                            leading: Icon(Icons.calendar_today, color: Colors.red),
                            title: Text("Math Exam - 25th Jan"),
                            subtitle: Text("Duration: 2 hours"),
                          ),
                          ListTile(
                            leading: Icon(Icons.calendar_today, color: Colors.red),
                            title: Text("Science Exam - 30th Jan"),
                            subtitle: Text("Duration: 3 hours"),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),

                    // Performance Summary

                  ],
                )
,
              if (isTeacher)
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: CircularIndicator(0.75, "75.0%",
                              "Average Attendance", Colors.green),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: CircularIndicator(0.25, "25.0%",
                              "Average Leave Taken", Colors.redAccent.shade700),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    BoysGirlsChart(),
                  ],
                ),
              SizedBox(height: 20),
              if (isAdmin)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Department-wise Teachers Details',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    TeachersChart(),
                    TeacherDashboard(),
                  ],
                ),
            ],
          ),
        ),
      ],
    ));
  }

  Widget CircularIndicator(
      double percent, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(1, 4),
          ),
        ],
      ),
      child: CircularPercentIndicator(
        radius: 75.0,
        lineWidth: 15.0,
        animation: true,
        animationDuration: 1200,
        percent: percent,
        center: AnimatedDefaultTextStyle(
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
            color: Colors.black,
          ),
          duration: Duration(milliseconds: 300),
          child: Text(value),
        ),
        footer: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16.0,
              color: Colors.grey[800],
            ),
          ),
        ),
        circularStrokeCap: CircularStrokeCap.round,
        backgroundColor: Colors.grey[200]!,
        linearGradient: LinearGradient(
          colors: [color.withOpacity(1), color.withOpacity(0.4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class BoysGirlsChart extends StatelessWidget {
  final List<StudentData> chartData = [
    StudentData(year: '2019', boys: 25, girls: 20),
    StudentData(year: '2020', boys: 22, girls: 23),
    StudentData(year: '2021', boys: 20, girls: 25),
    StudentData(year: '2022', boys: 24, girls: 21),
    StudentData(year: '2023', boys: 23, girls: 22),
    StudentData(year: '2024', boys: 23, girls: 22),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(1, 4),
          ),
        ],
      ),
      width: double.infinity,
      child: SfCartesianChart(
        title: ChartTitle(
          text: 'Students Over the Last Years',
          textStyle: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        legend: Legend(
          isVisible: true,
          position: LegendPosition.bottom,
          textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        tooltipBehavior:
            TooltipBehavior(enable: true, header: '', canShowMarker: false),
        primaryXAxis: CategoryAxis(
          title: AxisTitle(
            text: 'Year',
            textStyle: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
          ),
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(
            text: 'No. of Students',
            textStyle: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
          ),
        ),
        series: <CartesianSeries<dynamic, dynamic>>[
          ColumnSeries<StudentData, String>(
            dataSource: chartData,
            xValueMapper: (StudentData data, _) => data.year,
            yValueMapper: (StudentData data, _) => data.boys,
            name: 'Boys',
            color: Colors.blue.shade400,
            borderRadius: BorderRadius.circular(4),
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(color: Colors.white, fontSize: 12),
            ),
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade200],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          ColumnSeries<StudentData, String>(
            dataSource: chartData,
            xValueMapper: (StudentData data, _) => data.year,
            yValueMapper: (StudentData data, _) => data.girls,
            name: 'Girls',
            color: Colors.pink.shade400,
            borderRadius: BorderRadius.circular(4),
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(color: Colors.white, fontSize: 12),
            ),
            gradient: LinearGradient(
              colors: [Colors.pink.shade600, Colors.pink.shade200],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ), // Gradient effect on the bars
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

class TeacherDashboard extends StatelessWidget {
  final List<Teacher> teachers = [
    Teacher(name: " Doe", gender: "Male", department: "Mathematics"),
    Teacher(name: " Smith", gender: "Female", department: "Mathematics"),
    Teacher(name: " Davis", gender: "Female", department: "Science"),
    Teacher(name: " Johnson", gender: "Male", department: "Science"),
    Teacher(name: " Brown", gender: "Male", department: "History"),
    Teacher(name: " Wilson", gender: "Female", department: "History"),
    Teacher(name: "John ", gender: "Male", department: "Economics"),
    Teacher(name: "Jane ", gender: "Female", department: "Mathematics"),
    Teacher(name: "Emily ", gender: "Female", department: "Social Science"),
  ];

  Map<String, Map<String, int>> getGenderCountByDepartment(
      List<Teacher> teachers) {
    Map<String, Map<String, int>> departmentGenderCount = {};

    for (var teacher in teachers) {
      if (!departmentGenderCount.containsKey(teacher.department)) {
        departmentGenderCount[teacher.department] = {"Male": 0, "Female": 0};
      }

      if (teacher.gender == "Male") {
        departmentGenderCount[teacher.department]!["Male"] =
            departmentGenderCount[teacher.department]!["Male"]! + 1;
      } else if (teacher.gender == "Female") {
        departmentGenderCount[teacher.department]!["Female"] =
            departmentGenderCount[teacher.department]!["Female"]! + 1;
      }
    }

    return departmentGenderCount;
  }

  @override
  Widget build(BuildContext context) {
    var departmentGenderCount = getGenderCountByDepartment(teachers);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 350,
        child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          itemCount: departmentGenderCount.length,
          itemBuilder: (context, index) {
            String department = departmentGenderCount.keys.elementAt(index);
            int maleCount = departmentGenderCount[department]!["Male"]!;
            int femaleCount = departmentGenderCount[department]!["Female"]!;

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(department),
                subtitle: Text(
                    'Male Teachers: $maleCount | Female Teachers: $femaleCount'),
              ),
            );
          },
        ),
      ),
    );
  }
}

class TeachersChart extends StatelessWidget {
  const TeachersChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                    toY: 14,
                    color: Colors.blue,
                    borderSide: BorderSide(),
                    borderRadius: BorderRadius.circular(1)),
                BarChartRodData(
                    toY: 22,
                    color: Colors.pink,
                    borderSide: BorderSide(),
                    borderRadius: BorderRadius.circular(1)),
              ],
              barsSpace: 4,
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                    toY: 23,
                    color: Colors.blue,
                    borderSide: BorderSide(),
                    borderRadius: BorderRadius.circular(1)),
                BarChartRodData(
                    toY: 18,
                    color: Colors.pink,
                    borderSide: BorderSide(),
                    borderRadius: BorderRadius.circular(1)),
              ],
              barsSpace: 4,
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                    toY: 21,
                    color: Colors.blue,
                    borderSide: BorderSide(),
                    borderRadius: BorderRadius.circular(1)),
                BarChartRodData(
                    toY: 24,
                    color: Colors.pink,
                    borderSide: BorderSide(),
                    borderRadius: BorderRadius.circular(1)),
              ],
              barsSpace: 4,
            ),
            BarChartGroupData(
              x: 3,
              barRods: [
                BarChartRodData(
                    toY: 20,
                    color: Colors.blue,
                    borderSide: BorderSide(),
                    borderRadius: BorderRadius.circular(1)),
                BarChartRodData(
                    toY: 24,
                    color: Colors.pink,
                    borderSide: BorderSide(),
                    borderRadius: BorderRadius.circular(1)),
              ],
              barsSpace: 4,
            ),
            BarChartGroupData(
              x: 4,
              barRods: [
                BarChartRodData(
                    toY: 21,
                    color: Colors.blue,
                    borderSide: BorderSide(),
                    borderRadius: BorderRadius.circular(1)),
                BarChartRodData(
                    toY: 25,
                    color: Colors.pink,
                    borderSide: BorderSide(),
                    borderRadius: BorderRadius.circular(1)),
              ],
              barsSpace: 4,
            ),
            BarChartGroupData(
              x: 5,
              barRods: [
                BarChartRodData(
                    toY: 20,
                    color: Colors.blue,
                    borderSide: BorderSide(),
                    borderRadius: BorderRadius.circular(1)),
                BarChartRodData(
                    toY: 9,
                    color: Colors.pink,
                    borderSide: BorderSide(),
                    borderRadius: BorderRadius.circular(1)),
              ],
              barsSpace: 4,
            ),
            // Add more groups for other departments
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles:
                  SideTitles(showTitles: true, interval: 5, reservedSize: 35),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  switch (value.toInt()) {
                    case 0:
                      return const Text('Math');
                    case 1:
                      return const Text('Chem');
                    case 2:
                      return const Text('CS');
                    case 3:
                      return const Text('Bot');
                    case 4:
                      return const Text('BBA');
                    case 5:
                      return const Text('Bcom');
                    // Add more labels for other departments
                    default:
                      return const Text('');
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

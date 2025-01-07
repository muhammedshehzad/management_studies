import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:new_school/drawer_screens/academic_records.dart';
import 'package:new_school/screens/sign_in_page.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../settings/two-factor_authentication.dart';

class Dashboard extends StatefulWidget {
  final String role;

  const Dashboard({super.key, required this.role});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  File? selectedImage;
  bool isAuthenticating = false;

  Future<void> _checkAuthenticationOnStartup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFingerprintEnabled = prefs.getBool('fingerprint_enabled') ?? false;

    if (isFingerprintEnabled) {
      bool isAuthenticated = await _showBiometricAuth();
      if (!isAuthenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TwoFactorAuth()),
        );
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
              content: Text('Biometric authentication not available')),
        );
        return false;
      }

      final result = await auth.authenticate(
        localizedReason: 'Authenticate to access the dashboard',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      return result;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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
    _checkAuthenticationOnStartup();
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
                    onPressed: () async {
                      await Navigator.pushNamed(context, '/profile');
                      setState(() {
                        _loadImage();
                      });
                    },
                    icon: Container(
                        height: 33,
                        width: 33,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: (selectedImage != null)
                                  ? FileImage(selectedImage!)
                                  : (selectedImage == null)
                                      ? FileImage(File(data['url'] ?? ""))
                                          as ImageProvider
                                      : AssetImage('lib/assets/pandy.jpeg'),
                              fit: BoxFit.cover,
                            ))),
                  ),
                ),
                // IconButton(
                //     onPressed: () async {
                //       final SharedPreferences prefs =
                //           await SharedPreferences.getInstance();
                //       await prefs.remove('email');
                //       await prefs.remove('profileImagePath');
                //       await prefs.remove('role');
                //       await FirebaseAuth.instance.signOut();
                //       Navigator.pushReplacementNamed(context, '/signin');
                //     },
                //     icon: Icon(Icons.logout)),
              ],
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                dragStartBehavior: DragStartBehavior.start,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: selectedImage != null
                            ? FileImage(selectedImage!)
                            : FileImage(File(data!['url'] ?? "")) as ImageProvider,
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
                        await Navigator.pushNamed(context, '/profile');
                        setState(() {
                          _loadImage();
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                data["username"] ?? 'N/A',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                data["email"] ?? 'N/A',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
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

                  ListTile(
                    title: CustomTile(
                      label: 'Academic Records',
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AcademicRecords()));
                      },
                      image: 'lib/assets/academicrecords.png',
                    ),
                    onTap: () {
                      // Update the state of the app.
                      // ...
                    },
                  ),
                  Expanded(
                    child: ListTile(
                      title: CustomTile(
                        label: 'Homework and \nAssignments',
                        onPressed: () {},
                        image: 'lib/assets/homeworkandassignment.png',
                      ),
                      onTap: () {
                        // Update the state of the app.
                        // ...
                      },
                    ),
                  ),
                  ListTile(
                    title: CustomTile(
                      label: 'Canteen',
                      onPressed: () {},
                      image: 'lib/assets/canteen.png',
                    ),
                    onTap: () {
                      // Update the state of the app.
                      // ...
                    },
                  ),
                  ListTile(
                    title: CustomTile(
                      label: 'Leaves',
                      onPressed: () {},
                      image: 'lib/assets/leaves.png',
                    ),
                    onTap: () {
                      // Update the state of the app.
                      // ...
                    },
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
                  overflow: TextOverflow.visible  ,
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
                if (isStudent) SizedBox(height: 50),
                if (isStudent)
                  CircularIndicator(0.82, "82.0%", "Average Attendance",
                      Colors.yellowAccent.shade700),
                if (isStudent)
                  CircularIndicator(0.18, "18.0%", "Average Leave Taken",
                      Colors.purpleAccent.shade700),
                if (isStudent)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 38.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                                "Total Attendance = \nDays Present / Total No.Of Working Days"),
                            Text(
                              "109 / 120",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 24.0),
                        child: LinearPercentIndicator(
                          width: 350.0,
                          lineHeight: 24.0,
                          percent: 0.82,
                          backgroundColor: Colors.grey,
                          progressColor: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                if (isTeacher)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularIndicator(
                          0.75, "75.0%", "Average Attendance", Colors.green),
                      CircularIndicator(0.25, "25.0%", "Average Leave Taken",
                          Colors.redAccent.shade700),
                    ],
                  ),
                SizedBox(
                  height: 25,
                ),
                if (isTeacher) BoysGirlsChart(),
              ],
            ),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                TeachersChart(),
                TeacherDashboard(),
              ],
            ),
        ],
      ),
    );
  }

  Widget CircularIndicator(
      double percent, String value, String label, Color color) {
    return CircularPercentIndicator(
      radius: 75.0,
      lineWidth: 15.0,
      animation: true,
      percent: percent,
      center: Text(
        value,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      ),
      footer: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
        ),
      ),
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: color,
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
      width: 410,
      child: SfCartesianChart(
        title: ChartTitle(text: 'Students Over the Last Years'),
        legend: Legend(isVisible: true),
        tooltipBehavior: TooltipBehavior(enable: true),
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(
          title: AxisTitle(text: 'No.of Students'),
        ),
        series: <CartesianSeries<dynamic, dynamic>>[
          ColumnSeries<StudentData, String>(
            dataSource: chartData,
            xValueMapper: (StudentData data, _) => data.year,
            yValueMapper: (StudentData data, _) => data.boys,
            name: 'Boys',
            color: Colors.blue,
            dataLabelSettings: DataLabelSettings(isVisible: true),
          ),
          ColumnSeries<StudentData, String>(
            dataSource: chartData,
            xValueMapper: (StudentData data, _) => data.year,
            yValueMapper: (StudentData data, _) => data.girls,
            name: 'Girls',
            color: Colors.pink,
            dataLabelSettings: DataLabelSettings(isVisible: true),
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

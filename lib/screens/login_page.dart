
import 'package:flutter/material.dart';

import '../role_based_loginPage/admin_login.dart';
import '../role_based_loginPage/student_login.dart';
import '../role_based_loginPage/teacher_login.dart';

class Loginpage extends StatefulWidget {
  final String type;

  const Loginpage({super.key, required this.type});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  @override
  Widget build(BuildContext context) {
    Widget body;

    switch (widget.type) {
      case 'Student':
        body = const StudentLogin();
        break;
      case 'Teacher':
        body = const TeacherLogin();
        break;
      case 'Admin':
        body = const AdminLogin();
        break;
      default:
        body = const Center(
          child: Text('Unknown User Type'),
        );
    }

    return Scaffold(
      body: body,
    );
  }
}

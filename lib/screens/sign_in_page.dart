import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_school/screens/sign_up_page.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../Dashboard/dashboard.dart';
import '../firebase_auth_implementation/firebase_auth_services.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool isloading = false;

  final FirebaseAuthService _auth = FirebaseAuthService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _username = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  late AnimationController controller;

  @override
  void dispose() {
    _username.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      isloading = true;
    });

    if (!_formKey.currentState!.validate()) return;

    try {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      User? userCredential =
      await _auth.signInWithEmailAndPassword(email, password);

      if (userCredential != null) {
        var userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userCredential.uid)
            .get();

        if (!userDoc.exists) throw 'User role not found in Firestore.';
        final validRoles = ['Admin', 'Teacher', 'Student'];
        String role = userDoc.data()?['role'];

        if (!validRoles.contains(role)) throw 'Invalid role detected: $role';

        SharedPreferences prefs = await SharedPreferences.getInstance();

        await prefs.setString('email', email);
        await prefs.setString('role', role);
        final route =
        MaterialPageRoute(builder: (context) => Dashboard(role: role));
        Navigator.pushReplacement(context, route);

        print('Sign-in successful for role: $role');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign-in successful')),
        );
      } else {
        throw 'Sign-in failed. User not found.';
      }
      setState(() {
        isloading = false;
      });
    } catch (e) {
      print('Sign-in error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Sign In Page"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 400,
                  child: Image.asset(
                    'lib/assets/access.png',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30.0),
                isloading
                    ? Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    strokeAlign: .01,
                    color: Color(0xff3e948e),
                  ),
                )
                    : Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xff3e948e),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: _signIn,
                    child: const Text('Sign In'),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Don't have an account?"),
                    TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUp(),
                            ),
                          );
                        },
                        child: Text('SignUp')),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

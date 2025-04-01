import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_school/screens/sign_in_page.dart';
import 'package:new_school/sliding_transition.dart';
import '../firebase_auth_implementation/firebase_auth_services.dart';
import 'login_page.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with SingleTickerProviderStateMixin {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _username = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _department = TextEditingController();
  double _titleSlidePosition = 50.0;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isObscure = true;
  bool _rememberMe = false;
  final List<String> items = ['Student', 'Teacher'];
  String dropdownvalue = 'Student';
  String? selectedDepartment;
  bool _isObscureConfirm = true;

  @override
  void dispose() {
    _username.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPassword.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _checkIfAdmin(String userId) async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();
      if (userDoc.exists && userDoc.data()?['role'] == 'Admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Loginpage(
              type: 'Admin',
            ),
          ),
        );
      } else {
        print('User is not an admin');
      }
    } catch (e) {
      print('Error checking admin: $e');
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final user = usermodel(
      username: _username.text.trim(),
      email: _emailController.text.trim(),
      phone: _phone.text.trim(),
      address: _address.text.trim(),
      role: dropdownvalue,
      department: selectedDepartment!,
    );

    try {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      User? userCredential =
          await _auth.signUpWithEmailAndPassword(email, password);

      if (userCredential != null) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userCredential.uid)
            .set(user.toJson());

        print('User details added to Firestore.');


        await _checkIfAdmin(userCredential.uid);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signup successful'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(10),
            duration: const Duration(seconds: 2),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Loginpage(type: user.role),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signup failed'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(10),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Signup error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Color(0xff3e948e), Color(0xff56c1ba)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            "Sign Up",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -100,
              right: -100,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animationController.value * 1.0,
                    child: Opacity(
                      opacity: _animationController.value * 0.7,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xff56c1ba).withOpacity(0.2),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: -80,
              left: -50,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animationController.value * 1.0,
                    child: Opacity(
                      opacity: _animationController.value * 0.5,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xff3e948e).withOpacity(0.3),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 30.0, vertical: 20.0),
                child: FadeTransition(
                  opacity: _fadeInAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [Color(0xff3e948e), Color(0xff56c1ba)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: const Text(
                            "Create Account",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Sign up to start your journey",
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
                                      opacity:
                                          Tween<double>(begin: 0.0, end: 1.0)
                                              .animate(
                                        CurvedAnimation(
                                          parent: _animationController,
                                          curve: Interval(0.3, 0.9,
                                              curve: Curves.easeOut),
                                        ),
                                      ),
                                      child: child,
                                    );
                                  },
                                  child: DropdownButtonFormField<String>(
                                    value: dropdownvalue,
                                    items: items.map((String role) {
                                      return DropdownMenuItem<String>(
                                        value: role,
                                        child: Text(role),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        dropdownvalue = newValue!;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Select Role',
                                      labelStyle: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 14,
                                      ),
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Icon(Icons.person_outline,
                                            color: Color(0xff3e948e)),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 0),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color:
                                                Colors.grey.withOpacity(0.15)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Color(0xff3e948e),
                                            width: 1.5),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Colors.red.shade300),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),
                                AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    return FadeTransition(
                                      opacity:
                                          Tween<double>(begin: 0.0, end: 1.0)
                                              .animate(
                                        CurvedAnimation(
                                          parent: _animationController,
                                          curve: Interval(0.35, 0.95,
                                              curve: Curves.easeOut),
                                        ),
                                      ),
                                      child: child,
                                    );
                                  },
                                  child: TextFormField(
                                    controller: _username,
                                    decoration: InputDecoration(
                                      labelText: 'Username',
                                      hintText: 'Your username',
                                      labelStyle: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 14,
                                      ),
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Icon(Icons.person_outline,
                                            color: Color(0xff3e948e)),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 0),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color:
                                                Colors.grey.withOpacity(0.15)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Color(0xff3e948e),
                                            width: 1.5),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Colors.red.shade300),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your username';
                                      }
                                      return null;
                                    },
                                  ),
                                ),

                                const SizedBox(height: 20),
                                AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    return FadeTransition(
                                      opacity:
                                          Tween<double>(begin: 0.0, end: 1.0)
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
                                          const EdgeInsets.symmetric(
                                              vertical: 0),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color:
                                                Colors.grey.withOpacity(0.15)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Color(0xff3e948e),
                                            width: 1.5),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Colors.red.shade300),
                                      ),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                          .hasMatch(value)) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                ),

                                const SizedBox(height: 20),
                                AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    return FadeTransition(
                                      opacity:
                                          Tween<double>(begin: 0.0, end: 1.0)
                                              .animate(
                                        CurvedAnimation(
                                          parent: _animationController,
                                          curve: Interval(0.45, 1.0,
                                              curve: Curves.easeOut),
                                        ),
                                      ),
                                      child: child,
                                    );
                                  },
                                  child: TextFormField(
                                    controller: _phone,
                                    decoration: InputDecoration(
                                      labelText: 'Phone Number',
                                      hintText: 'Your phone number',
                                      labelStyle: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 14,
                                      ),
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Icon(Icons.phone_outlined,
                                            color: Color(0xff3e948e)),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 0),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color:
                                                Colors.grey.withOpacity(0.15)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Color(0xff3e948e),
                                            width: 1.5),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Colors.red.shade300),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your phone number';
                                      }
                                      return null;
                                    },
                                  ),
                                ),

                                const SizedBox(height: 20),
                                AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    return FadeTransition(
                                      opacity:
                                          Tween<double>(begin: 0.0, end: 1.0)
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
                                  child: DropdownButtonFormField<String>(
                                    value: selectedDepartment,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedDepartment = newValue;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Department',
                                      labelStyle: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 14,
                                      ),
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Icon(Icons.school_outlined,
                                            color: Color(0xff3e948e)),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 0),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color:
                                                Colors.grey.withOpacity(0.15)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Color(0xff3e948e),
                                            width: 1.5),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Colors.red.shade300),
                                      ),
                                    ),
                                    items: [
                                      'Maths',
                                      'Physics',
                                      'Chemistry',
                                      'Economics',
                                      'English',
                                      'Computer Science',
                                      'Data Science',
                                      'Advertising',
                                      'Management Studies',
                                      'Commerce'
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select your department';
                                      }
                                      return null;
                                    },
                                  ),
                                ),

                                const SizedBox(height: 20),
                                AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    return FadeTransition(
                                      opacity:
                                          Tween<double>(begin: 0.0, end: 1.0)
                                              .animate(
                                        CurvedAnimation(
                                          parent: _animationController,
                                          curve: Interval(0.55, 1.0,
                                              curve: Curves.easeOut),
                                        ),
                                      ),
                                      child: child,
                                    );
                                  },
                                  child: TextFormField(
                                    controller: _address,
                                    decoration: InputDecoration(
                                      labelText: 'Address',
                                      hintText: 'Your address',
                                      labelStyle: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 14,
                                      ),
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Icon(Icons.location_on_outlined,
                                            color: Color(0xff3e948e)),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 0),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color:
                                                Colors.grey.withOpacity(0.15)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Color(0xff3e948e),
                                            width: 1.5),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Colors.red.shade300),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your address';
                                      }
                                      return null;
                                    },
                                  ),
                                ),

                                const SizedBox(height: 20),
                                AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    return FadeTransition(
                                      opacity:
                                          Tween<double>(begin: 0.0, end: 1.0)
                                              .animate(
                                        CurvedAnimation(
                                          parent: _animationController,
                                          curve: Interval(0.6, 1.0,
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
                                          const EdgeInsets.symmetric(
                                              vertical: 0),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color:
                                                Colors.grey.withOpacity(0.15)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Color(0xff3e948e),
                                            width: 1.5),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Colors.red.shade300),
                                      ),
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
                                ),

                                const SizedBox(height: 20),
                                AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    return FadeTransition(
                                      opacity:
                                          Tween<double>(begin: 0.0, end: 1.0)
                                              .animate(
                                        CurvedAnimation(
                                          parent: _animationController,
                                          curve: Interval(0.65, 1.0,
                                              curve: Curves.easeOut),
                                        ),
                                      ),
                                      child: child,
                                    );
                                  },
                                  child: TextFormField(
                                    controller: _confirmPassword,
                                    obscureText: _isObscureConfirm,
                                    decoration: InputDecoration(
                                      labelText: 'Confirm Password',
                                      hintText: '••••••••',
                                      labelStyle: TextStyle(
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
                                          _isObscureConfirm
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: Colors.grey[600],
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isObscureConfirm =
                                                !_isObscureConfirm;
                                          });
                                        },
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 0),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color:
                                                Colors.grey.withOpacity(0.15)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Color(0xff3e948e),
                                            width: 1.5),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Colors.red.shade300),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please confirm your password';
                                      }
                                      if (value != _passwordController.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                  ),
                                ),

                                const SizedBox(height: 30),
                                AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    return FadeTransition(
                                      opacity:
                                          Tween<double>(begin: 0.0, end: 1.0)
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
                                      tween:
                                          Tween<double>(begin: 1.0, end: 1.0),
                                      duration:
                                          const Duration(milliseconds: 200),
                                      builder: (context, value, child) {
                                        return Transform.scale(
                                          scale: value,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Color(0xff3e948e),
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              shadowColor: Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _signUp();
                                              });
                                            },
                                            child: Text(
                                              'Sign Up',
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

                                const SizedBox(height: 20),
                                AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    return FadeTransition(
                                      opacity:
                                          Tween<double>(begin: 0.0, end: 1.0)
                                              .animate(
                                        CurvedAnimation(
                                          parent: _animationController,
                                          curve: Interval(0.75, 1.0,
                                              curve: Curves.easeOut),
                                        ),
                                      ),
                                      child: child,
                                    );
                                  },
                                  child: Flexible(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          flex:5,
                                          child: const Text(
                                            'Already have an account?',
                                            style: TextStyle(color: Colors.black54,
                                            fontSize: 13),
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: false,
                                          ),
                                        ),
                                        Flexible(
                                          flex:2,
                                          child: TextButton(
                                            onPressed: () {
                                              Navigator.pushReplacement(
                                                context,
                                                SlidingPageTransitionLR(page: SignIn()),
                                              );
                                            },
                                            child: const Text(
                                              'Sign In',
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
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class usermodel {
  final String username;
  final String email;
  final String phone;
  final String address;
  final String role;
  final String department;

  usermodel({
    required this.username,
    required this.email,
    required this.phone,
    required this.address,
    required this.role,
    required this.department,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'phone': phone,
      'address': address,
      'role': role,
      'department': department,
    };
  }
}

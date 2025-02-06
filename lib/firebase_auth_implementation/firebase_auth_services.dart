import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth;

  FirebaseAuthService() : _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Sign-up successful. User: ${credential.user}');
      return credential.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          print('Error: The email address is already in use.');
          break;
        case 'invalid-email':
          print('Error: The email address is invalid.');
          break;
        case 'weak-password':
          print('Error: The password is too weak.');
          break;
        default:
          print('FirebaseAuthException [${e.code}]: ${e.message}');
      }
      return null;
    } catch (e) {
      print('Unexpected error during signup: $e');
      return null;
    }
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Sign-in successful. User: ${credential.user}');
      return credential.user;
    } on FirebaseAuthException catch (e) {
      print('Sign-in error [${e.code}]: ${e.message}');
      return null;
    } catch (e) {
      print('Unexpected error during sign-in: $e');
      return null;
    }
  }
}

final FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<void> addUserDetails(
    String uid, String email, String username, String role) async {
  await firestore.collection('users').doc(uid).set({
    'email': email,
    'username': username,
    'role': role,
  });
}

class usermodel {
  final String? id;
  final String username;
  final String email;
  final String role;
  final String phone;
  final String address;
  final String department;
  final String profileImage; // New field added

  const usermodel({
    this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.phone,
    required this.address,
    required this.department,
    this.profileImage = '', // Default to empty string if not provided
  });

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "email": email,
      "role": role,
      "phone": phone,
      "address": address,
      "department": department,
      "profileImage": profileImage, // Include the image URL
    };
  }

  factory usermodel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return usermodel(
      id: document.id,
      username: data?["username"],
      email: data?["email"],
      role: data?["role"],
      phone: data?["phone"],
      address: data?["address"],
      department: data?["department"],
      profileImage:
      data?["profileImage"] ?? '', // Provide default value if null
    );
  }
}
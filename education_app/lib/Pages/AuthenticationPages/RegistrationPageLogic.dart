import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:education_app/Pages/LandingPage.dart';

class RegistrationPageLogic {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> register(BuildContext context, String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Perform any additional actions after registration if needed - ie database creation or something
        await _createDatabase();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LandingPage(user: user)),
        );
      }
    } catch (e) {
      print("Registration failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Registration failed. Please try again."),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _createDatabase() async {
    // Database creation logic...
  }
}

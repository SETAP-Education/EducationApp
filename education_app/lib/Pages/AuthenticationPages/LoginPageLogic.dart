import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:education_app/Pages/LandingPage.dart';

class LoginPageLogic {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> login(BuildContext context, String email, String password) async {
    try {
      // print("Email: $email, Password: $password");
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        print("Successfully logged in as ${user.displayName ?? user.email}");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LandingPage(user: user)),
        );
      }
    } catch (e) {
      print("Login failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login failed. Please try again."),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}

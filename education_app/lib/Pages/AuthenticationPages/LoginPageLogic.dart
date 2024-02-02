import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:education_app/Pages/LandingPage.dart';

class LoginPageLogic {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

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

  // Future<void> bypass(BuildContext context) async {
  //   try {
  //     if (user != null) {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => LandingPage(user: user!)),
  //       );
  //     }
  //   } catch (e) {
  //     print('Bypass failed: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Bypass failed. Please try again.'),
  //         duration: Duration(seconds: 3),
  //       ),
  //     );
  //   }
  // }

  Future<User?> test() async {
    try {
      // Delete existing admin account if it exists
      try {
        UserCredential existingUserCredential = await _auth.signInWithEmailAndPassword(
          email: 'test@admin.com',
          password: 'password',
        );
        await existingUserCredential.user?.delete();
        print('Existing test account deleted.');
      } catch (e) {
        // Ignore errors if the account doesn't exist
      }

      // Create the account
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: 'test@admin.com',
        password: 'password',
      );

      if (userCredential.user != null) {
        print('Test account created successfully.');
        return userCredential.user; // Return the created user
      }
    } catch (e) {
      print('Test Account failed: $e');
    }

    return null; // Return null if any error occurs
  }
}


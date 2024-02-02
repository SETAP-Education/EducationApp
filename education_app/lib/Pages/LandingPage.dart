import 'package:education_app/Quizzes/quiz.dart';
import 'package:education_app/Quizzes/quizManager.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:education_app/Pages/AuthenticationPages/LoginPageUI.dart';

class LandingPage extends StatelessWidget {
  final User user;

  QuizManager quizManager = QuizManager();

  LandingPage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Landing Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Sign out the user
              await FirebaseAuth.instance.signOut();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          LoginPageUI())); // Go back to the login page
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, ${user.displayName ?? user.email ?? user.uid}!',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add your landing page functionality here
              },
              child: Text(
                  'I was thinking this is how we do testing pages to begin with. Just have a button that leads to the page. Yes i know this is a button. I am going to go and write some notes on big data now.'),
            ),
          ],
        ),
      ),
    );
  }
}

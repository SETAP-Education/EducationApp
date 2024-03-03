import 'package:education_app/Pages/QuizBuilder.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:education_app/Pages/AuthenticationPages/LoginPage.dart';
import 'package:education_app/Pages/QuizPages/QuizPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  User? _user;
  List<String> recentQuizzes = [];

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  void _checkAuthState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _user = user; // Set the current user
        });
        _checkQuizHistory();
      }
    });
  }

  void _checkQuizHistory() async {
    if (_user != null) {
      try {
        final CollectionReference userCollection =
            FirebaseFirestore.instance.collection('users');
        final DocumentReference userDoc = userCollection.doc(_user!.uid);

        final CollectionReference quizHistoryCollection =
            userDoc.collection('quizHistory');

        final QuerySnapshot quizHistorySnapshot =
            await quizHistoryCollection.get();

        if (quizHistorySnapshot.docs.isNotEmpty) {
          // Quiz history exists, get the three most recent quiz IDs
          final recentQuizIds = quizHistorySnapshot.docs
              .map((doc) => doc.id)
              .toList()
              .reversed
              .take(3)
              .toList();

          setState(() {
            recentQuizzes = recentQuizIds;
          });
        } else {
          print('No quizzes have been attempted.');
        }
      } catch (e) {
        print('Error checking quiz history: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
                      builder: (context) => LoginPage())); // Go back to the login page
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, ${_user?.displayName ?? _user?.email ?? _user?.uid}!',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the quiz page when the button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => QuizPage()), // Replace QuizPage with your actual quiz page
                );
              },
              child: Text('Take Quiz'),
            ),
<<<<<<< HEAD

            ElevatedButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => QuizBuilder()));
            }, child: Text("Quiz Builder"))
=======
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Check quiz history when the button is pressed
                _checkQuizHistory();
              },
              child: Text('Check Quiz History'),
            ),
            SizedBox(height: 20),
            Container(
              height: 150,
              child: ListView.builder(
                itemCount: recentQuizzes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Recent Quiz ${index + 1}: ${recentQuizzes[index]}'),
                  );
                },
              ),
            ),
>>>>>>> 839762c5425717e95315a0deaa2803d086d0dd3f
          ],
        ),
      ),
    );
  }
}

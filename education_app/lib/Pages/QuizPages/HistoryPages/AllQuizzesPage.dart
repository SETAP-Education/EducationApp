import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education_app/Pages/AuthenticationPages/LoginPage.dart';
import 'package:education_app/Quizzes/quiz.dart';
import 'package:education_app/Quizzes/quizManager.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizHistoryPage extends StatefulWidget {
  @override
  _QuizHistoryPageState createState() => _QuizHistoryPageState();
}

class _QuizHistoryPageState extends State<QuizHistoryPage> {
  User? _user;
  late List<String> completedQuizIds = [];
  late Map<String, List<Map<String, dynamic>>> quizAttemptsMap = {};
  late QuizManager quizManager;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
    quizManager = QuizManager();
  }

  void _checkAuthState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _user = user; // Set the current user
        });
        if (user != null) {
          _loadQuizHistory();
        }
      }
    });
  }

  Future<void> _loadQuizHistory() async {
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
          Map<String, List<Map<String, dynamic>>> tempQuizAttemptsMap = {};

          quizHistorySnapshot.docs.forEach((doc) {
            final quizId = doc.id;
            final attemptsSnapshot =
                doc.reference.collection('attempts').orderBy('timestamp');

            attemptsSnapshot.get().then((attemptsQuerySnapshot) {
              if (attemptsQuerySnapshot.docs.isNotEmpty) {
                List<Map<String, dynamic>> attemptsData = [];
                attemptsQuerySnapshot.docs.forEach((attemptDoc) {
                  attemptsData.add(attemptDoc.data() as Map<String, dynamic>);
                });
                tempQuizAttemptsMap[quizId] = attemptsData;
              }
              setState(() {
                quizAttemptsMap = tempQuizAttemptsMap;
                completedQuizIds = quizAttemptsMap.keys.toList();
              });
            });
          });
        } else {
          print('No quizzes have been attempted.');
        }
      } catch (e) {
        print('Error loading quiz history: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: completedQuizIds.length,
        itemBuilder: (context, index) {
          final quizId = completedQuizIds[index];
          final attempts = quizAttemptsMap[quizId] ?? [];

          return ExpansionTile(
            title: Text('Quiz ID: $quizId'),
            children: [
              Column(
                children: [
                  for (final attempt in attempts)
                    ListTile(
                      title: Text(
                        'Timestamp: ${attempt['timestamp'].toString()}',
                      ),
                      subtitle: Text(
                        'Quiz Results: ${attempt['userResults'].toString()}',
                      ),
                      onTap: () {
                        // Handle onTap if needed
                      },
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

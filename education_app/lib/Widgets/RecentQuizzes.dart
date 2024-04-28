

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education_app/Pages/QuizPages/HistoryPages/QuizSummaryPage.dart';
import 'package:education_app/Quizzes/quiz.dart';
import 'package:education_app/Quizzes/quizManager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecentQuizzes extends StatefulWidget {

  const RecentQuizzes({ super.key });

  @override 
  State<RecentQuizzes> createState() => RecentQuizzesState();
}

class RecentQuizzesState extends State<RecentQuizzes> {

  QuizManager quizManager = QuizManager();
  User? _user;
  late List<QuizQuestion> loadedQuestions = [];
  Map<String, dynamic> quizAttemptData = {};
  Map<String, dynamic> userSummary = {};
  int earnedXp = 0; 
  late Quiz quiz; 

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  void _checkAuthState() async {
    User? user = await FirebaseAuth.instance.authStateChanges().first;
    if (user != null) {
      setState(() {
        _user = user; 
      });
    }
  }

  @override 
  Widget build(BuildContext context) {

    if (_user == null)
    {
      return Container();
    }

    return FutureBuilder<List<RecentQuiz>>(
        future: quizManager.getRecentQuizzesForUser(_user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading quiz names'));
          } else {
            if (snapshot.data == null) {
              return Center(child: CircularProgressIndicator());
            }
            List<RecentQuiz> quizzes = snapshot.data! ?? [];
            int numRecentQuizzes = quizzes.length;
            int numQuizzesPerRow = 1;
            int numRows = (numRecentQuizzes / numQuizzesPerRow).ceil();
            List<Widget> rows = List.generate(numRows, (rowIndex) {
              List<Widget> rowChildren = [];
              for (int i = 0; i < numQuizzesPerRow; i++) {
                int index = rowIndex * numQuizzesPerRow + i;
                const SizedBox(height: 10);
                if (index < numRecentQuizzes) {
                  rowChildren.add(
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).colorScheme.secondaryContainer,
                            
                          ),
                          child: InkWell(
                            onTap: () async {
                              await _getloadedQuestions(quizzes[index].id);
                              await _loadQuizAttemptData(quizzes[index].id);
                              earnedXp = quizzes[index].xpEarned;
                              _quizSummaryButton(loadedQuestions, quizAttemptData);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Row(
                                children: [ 
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(quizzes[index].name, 
                                        style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      Text(_nicifyDateTime(DateTime.fromMillisecondsSinceEpoch(quizzes[index].timestamp.millisecondsSinceEpoch)), 
                                        style: GoogleFonts.nunito(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic),
                                      )
                                    ],
                                  ),
                                  Spacer(), 

                                  Text("+ ${quizzes[index].xpEarned}xp",
                                    style: GoogleFonts.nunito(color: Theme.of(context).colorScheme.primary, fontSize: 18, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic),
                                  ),
                                ]
                              )
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              }
              return Row(
                children: rowChildren,
              );
            });
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rows,
            );
          }
        },
      );
  } 

  Future<void> _getloadedQuestions(String quizId) async {
    // int currentQuestionIndex = 0;

    if (mounted) {
      // print("Loading quiz with ID: $quizId");

      Quiz? loadedQuiz = await quizManager.getQuizWithId(quizId);

      if (loadedQuiz != null) {
        setState(() {
          quiz = loadedQuiz;
        });

        List<QuizQuestion> questions = [];
        for (String questionId in quiz.questionIds) {
          QuizQuestion? question = await QuizManager().getQuizQuestionById(questionId);

          if (question != null) {
            questions.add(question);
          } else {
            // Handle case where question doesn't exist
          }
        }

        if (mounted) {
          setState(() {
            loadedQuestions = questions;
          });
        }
      }
    } else {
      // Handle the case where the quiz is not found
      // may want to show an error message or navigate back
      print("Quiz not found with ID: $quizId");
    }
  }

  Future<void> _loadQuizAttemptData(String quizId) async {
    if (_user != null && mounted) {
      try {
        final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
        final DocumentReference userDoc = userCollection.doc(_user!.uid);

        final CollectionReference quizHistoryCollection = userDoc.collection('quizHistory').doc(quizId).collection('attempts');

        final QuerySnapshot attemptsSnapshot = await quizHistoryCollection.orderBy('timestamp', descending: true).limit(1).get();

        if (attemptsSnapshot.docs.isNotEmpty && mounted) {
          final attemptData = attemptsSnapshot.docs.first.data();
          setState(() {
            if (attemptData != null) {
              Map<String, dynamic> attemptDataMap = attemptData as Map<String, dynamic>;
              Map<String, dynamic> userResults = attemptDataMap['userResults'];
              Map<String, dynamic> userSummary = attemptDataMap['userSummary'];
              Timestamp? timestamp = attemptDataMap['timestamp'];

              if (userResults.isNotEmpty && userSummary.isNotEmpty && timestamp != null) {
                quizAttemptData = {
                  'timestamp': FieldValue.serverTimestamp(),
                  'userResults': {
                    'quizTotal': userResults['quizTotal'],
                    'userTotal': userResults['userTotal'],
                  },
                  'userSummary': userSummary,
                };
              }
            }
          });
        } else {
          print('No attempts found for quiz $quizId');
        }
      } catch (e) {
        print('Error loading quiz attempt data: $e');
      }
    }
  }

  void _quizSummaryButton(loadedQuestions, quizData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizSummaryPage(
          loadedQuestions: loadedQuestions,
          quizAttemptData: quizData,
          earnedXp: earnedXp,
        ),
      ),
    );
  }

  final List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

  String _nicifyDateTime(DateTime dateTime) {

    return "${dateTime.day} ${months[dateTime.month - 1]}";

  }
} 
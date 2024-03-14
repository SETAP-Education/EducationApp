import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:education_app/Pages/AuthenticationPages/LoginPage.dart';
import 'package:education_app/Pages/QuizPages/QuizPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education_app/Pages/QuizPages/QuizSummaryPage.dart';
import 'package:education_app/Quizzes/quiz.dart';
import 'package:education_app/Quizzes/quizManager.dart';


class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  User? _user;
  List<String> recentQuizzes = [];
  late List<QuizQuestion> loadedQuestions = [];
  Map<String, dynamic> quizAttemptData = {};
  Map<String, dynamic> userSummary = {};
  late QuizManager quizManager;
  String quizName = "";
  late Quiz quiz;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
    quizManager = QuizManager();
  }
  
  @override
  void dispose() {
    super.dispose();
  }

  void _checkAuthState() {
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (mounted) {
          setState(() {
            _user = user; // Set the current user
          });
          if (user != null) {
            _checkQuizHistory();
          }
        }
      }
    );
  }


  Future<List<String>> getQuizNames(List<String> quizIds) async {
    try {
      List<String> quizNames = [];

      for (String quizId in quizIds) {
        Quiz? loadedQuiz = await quizManager.getQuizWithId(quizId);
        quizNames.add(loadedQuiz?.name ?? 'Unnamed Quiz');
      }

      return quizNames;
    } catch (e) {
      print('Error fetching quiz names: $e');
      return [];
    }
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
            await quizHistoryCollection.orderBy('timestamp', descending: true).limit(3).get();

        if (quizHistorySnapshot.docs.isNotEmpty) {
          // Quiz history exists, get the three most recent quiz IDs
          final recentQuizIds = quizHistorySnapshot.docs
              .map((doc) => doc.id)
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


  Future<void> _getloadedQuestions(String quizId) async {
    // int currentQuestionIndex = 0;

    if (mounted) {
      // print("Loading quiz with ID: $quizId");

      Quiz? loadedQuiz = await quizManager.getQuizWithId(quizId);

      if (loadedQuiz != null) {
        setState(() {
          quiz = loadedQuiz;
        });

        // Print quiz details
        // print("Loaded quiz: ${quiz.name}");
        // print("Question IDs: ${quiz.questionIds}");

        List<QuizQuestion> questions = [];
        for (String questionId in quiz.questionIds) {

          // Fetch the question document directly from Firestore using QuizManager instead
          QuizQuestion? question =
              await QuizManager().getQuizQuestionById(questionId);

          if (question != null) {
            questions.add(question);

            // Print question type
            // print("Question Text: ${question.questionText}");
            // print("Question Type: ${question.type}");

          } else {
            // Handle case where question doesn't exist
          }
        }

        if (mounted) {
          setState(() {
            loadedQuestions = questions;
          });
        }

        // print("Current Question Index: $currentQuestionIndex...");
        // print("loadedQuestions: $loadedQuestions");
        // print("loadedQuestions: ${loadedQuestions[currentQuestionIndex].questionText}");

        // if (currentQuestionIndex < loadedQuestions.length) {
        //   print(
        //       "Current Question ID: ${loadedQuestions[currentQuestionIndex].questionText}");
        // } else {
        //   print(
        //       "Error: Index out of range - Current Question Index: $currentQuestionIndex");
        // }

        // displayQuestion(currentQuestionIndex, quiz.questionIds);
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
        final CollectionReference userCollection =
            FirebaseFirestore.instance.collection('users');
        final DocumentReference userDoc = userCollection.doc(_user!.uid);

        final CollectionReference quizHistoryCollection =
            userDoc.collection('quizHistory').doc(quizId).collection('attempts');

        final QuerySnapshot attemptsSnapshot =
            await quizHistoryCollection.orderBy('timestamp', descending: true).limit(1).get();

        if (attemptsSnapshot.docs.isNotEmpty && mounted) {
          final attemptData = attemptsSnapshot.docs.first.data();
          setState(() {
            // Check if attemptData is not null
            if (attemptData != null) {
              // Explicitly cast attemptData to Map<String, dynamic>
              Map<String, dynamic> attemptDataMap = attemptData as Map<String, dynamic>;

              // Extracting relevant data from the attemptData map
              Map<String, dynamic> userResults = attemptDataMap['userResults'];
              Map<String, dynamic> userSummary = attemptDataMap['userSummary'];
              Timestamp? timestamp = attemptDataMap['timestamp'];

              // print("67 LANDING PAGE USER SUMMARY: $userSummary");

              if (userResults.isNotEmpty && userSummary.isNotEmpty && timestamp != null) {
                // Formatting the quizAttemptData
                quizAttemptData = {
                  'timestamp': FieldValue.serverTimestamp(),
                  'userResults': {
                    'quizTotal': userResults['quizTotal'],
                    'userTotal': userResults['userTotal'],
                  },
                  'userSummary': userSummary,
                };
                // print("53 user summary: $userSummary");
                // print("54 quiz summary: $quizAttemptData");
              }
            }
          });

          // Print the retrieved attemptData for debugging
          // print("Attempt Data: $attemptData");
        } else {
          print('No attempts found for quiz $quizId');
        }
      } catch (e) {
        print('Error loading quiz attempt data: $e');
      }
    }
  }


  Map<String, dynamic> createQuizAttemptData(Map<String, dynamic> userSummary) {
    int quizTotal = loadedQuestions.length;

    return {
      'timestamp': FieldValue.serverTimestamp(),
      'userResults': {
        'quizTotal': quizTotal,  // Update this with the actual maximum points
        'userTotal': -1,
      },
      'userSummary': userSummary,
    };
  }

  @override
Widget build(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;

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
                builder: (context) => LoginPage(),
              ),
            ); // Go back to the login page
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
                  builder: (context) => QuizPage(),
                ),
              ); // Replace QuizPage with your actual quiz page
            },
            child: Text('Take Quiz'),
          ),
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
  height: 400,
  width: ((screenWidth / 2) * 5 / 6),
  decoration: BoxDecoration(
    color: Colors.transparent,
    border: Border.all(color: Colors.black),
    borderRadius: BorderRadius.circular(10),
  ),
  child: FutureBuilder<List<String>>(
    future: getQuizNames(recentQuizzes),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return Text('Error loading quiz names');
      } else {
        List<String> quizNames = snapshot.data ?? [];

        return SizedBox.expand(
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: List.generate(recentQuizzes.length, (index) {
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: InkWell(
                  onTap: () async {
                    await _getloadedQuestions(recentQuizzes[index]);
                    await _loadQuizAttemptData(recentQuizzes[index]);
                    _quizSummaryButton(loadedQuestions, quizAttemptData);
                  },
                  child: Container(
                    width: (((screenWidth / 2) * 5 / 6) / 3.2), // Adjust the width as needed
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      // border: Border.all(color: Colors.black),
                      // borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 60, // Adjust the size as needed
                          color: Colors.blue, // Highlight color
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Recent Quiz ${index + 1}: ${quizNames[index]}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }
    },
  ),
),
        ],
      ),
    ),
  );
}



  void _quizSummaryButton(loadedQuestions, quizData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizSummaryPage(
          loadedQuestions: loadedQuestions,
          quizAttemptData: quizData,
        ),
      ),
    );
  }
}

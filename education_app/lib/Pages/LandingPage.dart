import 'package:education_app/Pages/QuizBuilder.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:education_app/Pages/AuthenticationPages/LoginPage.dart';
import 'package:education_app/Pages/QuizPages/QuizPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education_app/Pages/QuizPages/QuizSummaryPage.dart';
import 'package:education_app/Quizzes/quiz.dart';
import 'package:education_app/Quizzes/quizManager.dart';
import 'package:google_fonts/google_fonts.dart';

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
    });
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
        final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
        final DocumentReference userDoc = userCollection.doc(_user!.uid);

        final CollectionReference quizHistoryCollection = userDoc.collection('quizHistory');

        final QuerySnapshot quizHistorySnapshot = await quizHistoryCollection.orderBy('timestamp', descending: true).limit(3).get();

        if (quizHistorySnapshot.docs.isNotEmpty) {
          // Quiz history exists, get the three most recent quiz IDs
          final recentQuizIds = quizHistorySnapshot.docs.map((doc) => doc.id).toList();

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

  Map<String, dynamic> createQuizAttemptData(Map<String, dynamic> userSummary) {
    int quizTotal = loadedQuestions.length;

    return {
      'timestamp': FieldValue.serverTimestamp(),
      'userResults': {
        'quizTotal': quizTotal,
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
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(30.0),
              width: MediaQuery.of(context).size.width * 0.4,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFf3edf6).withOpacity(1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.1,
                    margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
                    child: Text(
                      'Welcome, ${_user?.displayName ?? _user?.email ?? _user?.uid}!',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  Container(
                    alignment: Alignment.topCenter,
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFf3edf6).withOpacity(1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 10.0),
                          child: Text('Available', style: GoogleFonts.nunito(color: Colors.black, fontSize: 28)),
                        ),
                        Text('Test yourself!', style: GoogleFonts.nunito(color: Colors.black, fontSize: 20)),
                        Expanded(
                          child: QuizListView(), // quizListView widget to display quizzes
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(30.0),
              width: MediaQuery.of(context).size.width * 0.4,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.1,
                    margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFf3edf6).withOpacity(1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuizPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Take Quiz',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QuizBuilder(),
                              ),
                            );
                          },
                          child: const Text(
                            'Quiz Builder',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 20), // spacing
                        ElevatedButton(
                          onPressed: () {
                            _checkQuizHistory();
                          },
                          child: const Text(
                            'Check Quiz History',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: MediaQuery.of(context).size.height * 0.7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFf3edf6).withOpacity(1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 10.0),
                            child: Text(
                              'History',
                              style: GoogleFonts.nunito(color: Colors.black, fontSize: 28),
                            ),
                          ),
                          Text(
                            'View your recent efforts!',
                            style: GoogleFonts.nunito(color: Colors.black, fontSize: 20),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            alignment: Alignment.center,
                            height: 400,
                            width: ((screenWidth / 2) * 5 / 6),
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                            ),
                            child: FutureBuilder<List<String>>(
                              future: getQuizNames(recentQuizzes),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return const Text('Error loading quiz names');
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
                                                width: (((screenWidth / 2) * 5 / 6) / 3.2),
                                                padding: const EdgeInsets.all(20),
                                                margin: const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  color: Colors.white,
                                                  boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.2),
                                                       spreadRadius: 1,
                                                       blurRadius: 2,
                                                       offset: const Offset(0, 1),
                                                     ),
                                                   ],
                                                ),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.history,
                                                      size: 60,
                                                      color: Colors.blue,
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Text(
                                                      'Recent Quiz ${index + 1}: ${quizNames[index]}',
                                                      style: const TextStyle(fontSize: 16),
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
                  ),
                ],
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


class QuizListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('quizzes').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        // Extract quiz names from documents
        final List<String> quizNames = snapshot.data!.docs.map((doc) => doc['name'] as String).toList();

        return ListView.builder(
          itemCount: quizNames.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(quizNames[index]),
              onTap: () {
                print('Quiz ${quizNames[index]} tapped!');
                // where the quiz will load from
              },
            );
          },
        );
      },
    );
  }
}



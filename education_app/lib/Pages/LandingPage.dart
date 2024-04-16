import 'package:education_app/Pages/QuizPages/HistoryPages/AllQuizzes.dart';
import 'package:education_app/Pages/QuizBuilder.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:education_app/Pages/AuthenticationPages/LoginPage.dart';
import 'package:education_app/Pages/QuizPages/QuizPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education_app/Pages/QuizPages/HistoryPages/QuizSummaryPage.dart';
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
        title: Center(child: const Text('IntelliQuiz')),
        actions: [
          Center(
            child: IconButton(
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
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: MediaQuery.of(context).size.height * 0.1, // Controls the height of the top left container
                    margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
                    child: FutureBuilder<String?>(
                    future: getUserDisplayName(_user!.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text(
                          'Welcome, Loading...',
                          style: const TextStyle(fontSize: 20),
                        );
                      } else if (snapshot.hasError) {
                        return Text(
                          'Error loading display name',
                          style: const TextStyle(fontSize: 20),
                        );
                      } else {
                        String? displayName = snapshot.data;

                        return Text(
                          'Welcome, ${displayName ?? 'User'}!',
                          style: const TextStyle(fontSize: 20),
                        );
                      }
                    },
                  ),

                  ),
                  Container(
                    alignment: Alignment.topCenter,
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: MediaQuery.of(context).size.height * 0.75, // Controls the height of the bottom left container
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height * 0.1, // Controls the height of the top right container
                    margin: const EdgeInsets.only(bottom: 20.0),
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
                        const SizedBox(width: 20),
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
                        const SizedBox(width: 20),
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
                  Expanded(
                    child: Container(
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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              'History',
                              style: GoogleFonts.nunito(color: Colors.black, fontSize: 28),
                            ),
                            Text(
                              'View your recent efforts!',
                              style: GoogleFonts.nunito(color: Colors.black, fontSize: 20),
                            ),
                            const SizedBox(height: 20),
                            FutureBuilder<List<String>>(
                              future: getQuizNames(recentQuizzes),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(child: Text('Error loading quiz names'));
                                } else {
                                  List<String> quizNames = snapshot.data ?? [];
                                  int numRecentQuizzes = quizNames.length;
                                  int numQuizzesPerRow = 2;
                                  int numRows = (numRecentQuizzes / numQuizzesPerRow).ceil();
                                  List<Widget> rows = List.generate(numRows, (rowIndex) {
                                    List<Widget> rowChildren = [];
                                    for (int i = 0; i < numQuizzesPerRow; i++) {
                                      int index = rowIndex * numQuizzesPerRow + i;
                                      if (index < numRecentQuizzes) {
                                        rowChildren.add(
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                              child: Container(
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
                                                child: InkWell(
                                                  onTap: () async {
                                                    await _getloadedQuestions(recentQuizzes[index]);
                                                    await _loadQuizAttemptData(recentQuizzes[index]);
                                                    _quizSummaryButton(loadedQuestions, quizAttemptData);
                                                  },
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
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
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ],
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
                            ),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 0.0, right: 20.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => QuizHistoryPage(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'View All',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]
        )
      )
    );
  }

  Future<String?> getUserDisplayName(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userSnapshot.exists) {
        return userSnapshot.get('displayName');
      } else {
        print('User not found in Firestore');
        return null;
      }
    } catch (e) {
      print('Error retrieving user display name: $e');
      return null;
    }
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
    return GridView.builder(
      padding: const EdgeInsets.all(10.0), // Add padding to move tiles away from the container border
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: 8, // Maximum of 8 tiles (4 high, 2 wide)
      itemBuilder: (context, index) {
        return AvailableInterestTile(index: index);
      },
    );
  }
}

class AvailableInterestTile extends StatelessWidget {
  final int index;

  const AvailableInterestTile({required this.index});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Placeholder for button functionality
        print('Tile ${index + 1} tapped!');
        // Add code here to generate quiz based on user's interest
      },
      child: Container(
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
        // height: MediaQuery.of(context).size.height * 1, // Half the height of the screen
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.history,
              size: 40, // Reduce the icon size
              color: Colors.blue,
            ),
            const SizedBox(height: 5), // Add some space between the icon and the text
            Text(
              'Interest ${index + 1}', // Placeholder for tile name
              style: const TextStyle(fontSize: 14), // Reduce the font size
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}






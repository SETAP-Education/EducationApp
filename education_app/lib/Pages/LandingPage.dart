import 'package:education_app/Pages/AuthenticationPages/LoginPage.dart';
import 'package:education_app/Pages/QuizPages/QuizPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education_app/Pages/QuizBuilder.dart';
import 'package:education_app/Pages/QuizPages/HistoryPages/QuizSummaryPage.dart';
import 'package:education_app/Quizzes/quiz.dart';
import 'package:education_app/Quizzes/quizManager.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:education_app/Theme/AppTheme.dart';
import 'package:education_app/Pages/QuizPages/HistoryPages/AllQuizzesPage.dart';


class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  User? _user;
  List<String> userInterests = [];
  int xpLevel = 0; // Assuming XP level is an integer
  late String _displayName = "Placeholder";
  late List<String> otherTopics = [];

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

  void _checkAuthState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _user = user;
        });
        if (user != null) {
          _fetchOtherTopics();
          _getUserInterests(user.uid);
          _getUserXPLevel(user.uid);
          _getUserDisplayName(user.uid); // Call to get user display name
        }
      }
    });
  }

  void _getUserInterests(String uid) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        setState(() {
          userInterests = List<String>.from(userSnapshot.get('interests'));
        });
      }
    } catch (e) {
      print('Error fetching user interests: $e');
    }
  }

  void _fetchOtherTopics() async {
    try {
      if (_user != null) {
        // Get user's interests from Firestore
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();
        if (userSnapshot.exists) {
          List<String> userInterests = List<String>.from(userSnapshot.get('interests'));

          // Query Firestore to get all interests
          DocumentSnapshot interestsSnapshot = await FirebaseFirestore.instance.collection('interests').doc('interests').get();

          if (interestsSnapshot.exists) {
            List<String> allInterests = List<String>.from(interestsSnapshot.get('interests'));

            // Extract other topics that are not in the user's interests
            List<String> remainingInterests = allInterests.where((interest) => !userInterests.contains(interest)).toList();

            // Set the remaining interests as topics
            setState(() {
              otherTopics = remainingInterests.map((interest) => '$interest').toList();
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching other topics: $e');
    }
  }


  void _getUserXPLevel(String uid) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        setState(() {
          xpLevel = userSnapshot.get('xpLvl');
        });
      }
    } catch (e) {
      print('Error fetching user XP level: $e');
    }
  }

  void _getUserDisplayName(String uid) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        setState(() {
          _displayName = userSnapshot.get('displayName');
        });
      }
    } catch (e) {
      print('Error fetching user display name: $e');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTheme.buildAppBar(context, 'Quiz App', true, "Welcome to our quiz app", Text(
        'Hi there! This is the landing page for AMT. '
        )),
      body: _user != null
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    margin: const EdgeInsets.all(30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 2 / 3,
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Theme.of(context).colorScheme.primaryContainer,
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
                                    'Your Interests',
                                    style: GoogleFonts.nunito(fontSize: 28),
                                  ),
                                  const SizedBox(height: 20),
                                  FutureBuilder<List<String>>(
                                    future: Future.value(userInterests),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Center(child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(child: Text('Error loading interests'));
                                      } else {
                                        List<String> interests = snapshot.data ?? [];
                                        int numInterests = interests.length;
                                        int numInterestsPerRow = 4; // Adjust the number of interests per row as needed
                                        int numRows = (numInterests / numInterestsPerRow).ceil();
                                        List<Widget> rows = List.generate(numRows, (rowIndex) {
                                          List<Widget> rowChildren = [];
                                          for (int i = 0; i < numInterestsPerRow; i++) {
                                            int index = rowIndex * numInterestsPerRow + i;
                                            const SizedBox(height: 10);
                                            if (index < numInterests) {
                                              rowChildren.add(
                                                Flexible(
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                                                    child: Container(
                                                      height: 200,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(10),
                                                        color: Theme.of(context).colorScheme.primaryContainer,
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
                                                          print('Interest ${index + 1}: ${interests[index]} pressed');

                                                          // Generate a new quiz
                                                          String id = await quizManager.generateQuiz([ interests[index] ], 30, 20, 5);
                                                          
                                                          Navigator.push(context, MaterialPageRoute(builder:(context) {
                                                            return QuizPage(quizId: id);
                                                          },));
                                                        },
                                                        child: Center(
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              const Icon(
                                                                Icons.history,
                                                                size: 60,
                                                                color: Colors.blue,
                                                              ),
                                                              const SizedBox(height: 10),
                                                              Text(
                                                                interests[index],
                                                                style: const TextStyle(fontSize: 16),
                                                                textAlign: TextAlign.center,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              rowChildren.add(Flexible(child: SizedBox())); // Add an empty Flexible widget for even distribution
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
                                  Text(
                                    'Other Topics',
                                    style: GoogleFonts.nunito(fontSize: 28),
                                  ),
                                  const SizedBox(height: 20),
                                  FutureBuilder<List<String>>(
                                    future: Future.value(otherTopics), // Assuming otherTopics is a list of other topics
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Center(child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(child: Text('Error loading topics'));
                                      } else {
                                        
                                        List<String> topics = snapshot.data ?? [];
                                        // Filter out user's interests from the list of other topics
                                        List<String> remainingTopics = topics.where((topic) => !userInterests.contains(topic)).toList();
                                        print("All topics: $topics");
                                        print("Remaining topics: $remainingTopics");

                                        int numTopics = remainingTopics.length;
                                        int numTopicsPerRow = 4; // Adjust the number of topics per row as needed
                                        int numRows = (numTopics / numTopicsPerRow).ceil();
                                        List<Widget> rows = List.generate(numRows, (rowIndex) {
                                          List<Widget> rowChildren = [];
                                          for (int i = 0; i < numTopicsPerRow; i++) {
                                            int index = rowIndex * numTopicsPerRow + i;
                                            const SizedBox(height: 10);
                                            if (index < numTopics) {
                                              rowChildren.add(
                                                Flexible(
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                                                    child: Container(
                                                      height: 200,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(10),
                                                        color: Theme.of(context).colorScheme.primaryContainer,
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
                                                          print('${remainingTopics[index]} pressed');
                                                          // Add functionality here if needed

                                                          // Generate a new quiz
                                                          String id = await quizManager.generateQuiz([ remainingTopics[index] ], 30, 20, 5);
                                                          
                                                          Navigator.push(context, MaterialPageRoute(builder:(context) {
                                                            return QuizPage(quizId: id);
                                                          },));
                                                        },
                                                        child: Center(
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              const Icon(
                                                                Icons.topic, // Replace with appropriate icon
                                                                size: 60,
                                                                color: Colors.blue,
                                                              ),
                                                              const SizedBox(height: 10),
                                                              Text(
                                                                remainingTopics[index], // Use remainingTopics instead of topics
                                                                style: const TextStyle(fontSize: 16),
                                                                textAlign: TextAlign.center,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              rowChildren.add(Flexible(child: SizedBox())); // Add an empty Flexible widget for even distribution
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
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width * 1 / 3,
                    margin: const EdgeInsets.fromLTRB(0, 30, 30, 30),
                    child: Column(
                      children: [
                        Container(
                          height: 125,
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(context).colorScheme.primaryContainer,
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'XP Level',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              Container(
    width: double.infinity,
    height: 40,
    decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(20),
    ),
    child: Stack(
        children: [
            // Inner Container with FractionallySizedBox
            FractionallySizedBox(
                widthFactor: xpLevel / 100,
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                    ),
                ),
            ),
            // Text widget aligned in the center
            Center(
                child: Text(
                    '$xpLevel XP - ${_getXPLevelDescription(xpLevel)}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
            ),
        ],
    ),
),

                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        Expanded(
                          flex: 7,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 1 / 3,
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Theme.of(context).colorScheme.primaryContainer,
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
                                  Row(
                                    children: [
                                      Spacer(),
                                      Text(
                                        'Quiz History',
                                        style: GoogleFonts.nunito(fontSize: 28),
                                      ),
                                      SizedBox(width: MediaQuery.of(context).size.width * 1/12), // Adjust the width as needed
                                      ElevatedButton(
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
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  FutureBuilder<List<RecentQuiz>>(
                                    future: quizManager.getRecentQuizzesForUser(_user!.uid),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Center(child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(child: Text('Error loading quiz names'));
                                      } else {
                                        List<RecentQuiz> quizzes = snapshot.data! ?? [];
                                        int numRecentQuizzes = quizzes.length;
                                        int numQuizzesPerRow = 2;
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
                                                        color: Theme.of(context).colorScheme.primaryContainer,
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
                                                          await _getloadedQuestions(quizzes[index].id);
                                                          await _loadQuizAttemptData(quizzes[index].id);
                                                          _quizSummaryButton(loadedQuestions, quizAttemptData);
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 20),
                                                          child: Row(
                                                            children: [ 
                                                              Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(quizzes[index].name, 
                                                                    style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.bold),
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
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to login page
                },
                child: Text('Login'),
              ),
            ),
    );
  }


  String _getXPLevelDescription(int xp) {
    if (xp >= 0 && xp <= 20) {
      return 'Beginner';
    } else if (xp >= 21 && xp <= 40) {
      return 'Intermediate';
    } else if (xp >= 41 && xp <= 60) {
      return 'Advanced';
    } else if (xp >= 61 && xp <= 80) {
      return 'Expert';
    } else {
      return 'Master';
    }
  }

  String _nicifyDateTime(DateTime dateTime) {
    

    List<String> months = [
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

    return "${dateTime.day} ${months[dateTime.month - 1]}";

  }
}
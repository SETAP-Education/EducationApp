import 'package:education_app/Pages/AuthenticationPages/LoginPage.dart';
import 'package:education_app/Pages/QuizPages/QuizPage.dart';
import 'package:education_app/Widgets/UserInfo.dart';
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
import 'package:education_app/Pages/AuthenticationPages/DisplayNamePage.dart';


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
    return Scaffold(
      appBar: AppTheme.buildAppBar(context, '', true, false, "Welcome to our quiz app", Text(
        'Hi there! This is the landing page for quizzical. '
        )),
      body: _user != null
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Expanded(
                  flex: 2,
                  child: Container(
                    clipBehavior: Clip.none,
                    height: double.infinity,
                    padding: const EdgeInsets.all(30),
                    child:  SingleChildScrollView(
                      clipBehavior: Clip.none,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    borderRadius: BorderRadius.circular(24),
                                    onTap: () async {
                                      // We want to run a review quiz 

                                      // Since we use all questions from all difficulties just fluke user stuff
                                      String quizId = await quizManager.generateQuiz(userInterests, 50, 100, 8, name: "Review");
                                      // Reviews grant even less xp 
                                      Navigator.push(context, MaterialPageRoute(builder:(context) => QuizPage(quizId: quizId, multiplier: 0.15)));
                                    },
                                    child: Ink(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      padding: EdgeInsets.all(24.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              color: Theme.of(context).colorScheme.primary
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                                            child: Text("Review", style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800))
                                          ),
                                          SizedBox(height: 12.0),
                                          Text("Take a review of all topics and difficulties to see how much you've improved!", style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold)),
                                          SizedBox(height: 6.0),
                                          Text("8 Questions • ${userInterests.toString().substring(1, userInterests.toString().length - 1)}", style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary))
                                        ],
                                      )
                                    )
                                  ),  
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(), // Empty space on the left
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Your Interests',
                                            style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      // IconButton(
                                      //   icon: const Icon(Icons.remove),
                                      //   onPressed: () {
                                      //     // Navigate to DisplayUser page
                                      //     Navigator.push(
                                      //       context,
                                      //       MaterialPageRoute(
                                      //         builder: (context) => DisplayUser(),
                                      //       ),
                                      //     );
                                      //   },
                                      // ),
                                    ],
                                  ),

                                  Text(
                                    'Pick a topic to begin a quiz!',
                                    style: GoogleFonts.nunito(fontSize: 18),
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
                                                    child: InkWell(
                                                      onTap: () async {
                                                          print('Interest ${index + 1}: ${interests[index]} pressed');

                                                          // Generate a new quiz
                                                          String id = await quizManager.generateQuiz([ interests[index] ], xpLevel, 20, 5);
                                                          
                                                          Navigator.push(context, MaterialPageRoute(builder:(context) {
                                                            return QuizPage(quizId: id);
                                                          },));
                                                        },
                                                      
                                                      child: Ink(
                                                        height: 200,
                                                        decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(10),
                                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                                        
                                                      ),
                                                        child: Center(
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                               Container(

                                                                decoration: BoxDecoration(
                                                                  color: Theme.of(context).scaffoldBackgroundColor,
                                                                  borderRadius: BorderRadius.circular(20),
                                                                ),
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: Image.asset("assets/images/${interests[index].toLowerCase()}.png", color: Theme.of(context).colorScheme.primary, width: 48, height: 48)
                                                              ),
                                                              const SizedBox(height: 10),
                                                              Text(
                                                                interests[index],
                                                                style:  GoogleFonts.nunito(fontSize: 18,  fontWeight: FontWeight.bold),
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(), // Empty space on the left
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Other Topics',
                                            style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      // IconButton(
                                      //   icon: const Icon(Icons.add),
                                      //   onPressed: () {
                                      //     // Navigate to DisplayUser page
                                      //     Navigator.push(
                                      //       context,
                                      //       MaterialPageRoute(
                                      //         builder: (context) => DisplayUser(),
                                      //       ),
                                      //     );
                                      //   },
                                      // ),
                                    ],
                                  ),
                                  Text(
                                    'Other topics you can take quiz on that didn\'t interest you as much!',
                                    style: GoogleFonts.nunito(fontSize: 18),
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
                                                    child: InkWell(
                                                      onTap: () async {
                                                          print('Interest ${index + 1}: ${remainingTopics[index]} pressed');

                                                          // Generate a new quiz
                                                          String id = await quizManager.generateQuiz([ remainingTopics[index] ], xpLevel, 20, 5);
                                                          
                                                          Navigator.push(context, MaterialPageRoute(builder:(context) {
                                                            return QuizPage(quizId: id);
                                                          },));
                                                        },
                                                      
                                                      child: Ink(
                                                        height: 200,
                                                        decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(10),
                                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                                        
                                                      ),
                                                        child: Center(
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                               Container(

                                                                decoration: BoxDecoration(
                                                                  color: Theme.of(context).scaffoldBackgroundColor,
                                                                  borderRadius: BorderRadius.circular(20),
                                                                ),
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: Image.asset("assets/images/${remainingTopics[index].toLowerCase()}.png", color: Theme.of(context).colorScheme.primary, width: 48, height: 48)
                                                              ),
                                                              const SizedBox(height: 10),
                                                              Text(
                                                                remainingTopics[index],
                                                                style:  GoogleFonts.nunito(fontSize: 18,  fontWeight: FontWeight.bold),
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
                              ))),
                            ),
                          
                        
                
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 30.0, 30.0, 30.0),
                    child: UserInfoWidget(userId: _user!.uid)
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
}
import 'package:education_app/Pages/AuthenticationPages/RegistrationPage.dart';
import 'package:flutter/material.dart';
import 'package:education_app/Quizzes/quiz.dart';
import 'package:education_app/Quizzes/quizManager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:education_app/Pages/QuizPages/HistoryPages/QuizSummaryPage.dart';
import 'package:education_app/Theme/AppTheme.dart';
import 'package:education_app/Pages/LandingPage.dart';

class QuizPage extends StatefulWidget {
  QuizPage({ required this.quizId, this.multiplier = 0.5 });

  String quizId = ""; 
  double multiplier  = 0.0; 

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late TextEditingController fillInTheBlankController;
  late QuizManager quizManager;
  late Quiz quiz;
  late List<QuizQuestion> loadedQuestions = [];
  int currentQuestionIndex = 0;
  bool quizCompleted = false;
  Map<String, dynamic> userSummary = {};
  bool quizSubmitted = false;
  int earnedXp = 0; 
  Map<String, dynamic> quizAttemptData = {};

  @override
  void initState() {
    super.initState();
    quizManager = QuizManager();
    loadQuiz(widget.quizId);
    fillInTheBlankController = TextEditingController();
  }

  @override
  void dispose() {
    fillInTheBlankController.dispose();
    super.dispose();
  }

  Future<void> loadQuiz(String quizId) async {
    print("Loading quiz with ID: $quizId");
    Quiz? loadedQuiz = await quizManager.getQuizWithId(quizId);

    if (loadedQuiz != null) {
      setState(() { quiz = loadedQuiz; });

      // Print quiz details
      print("Loaded quiz: ${quiz.name}");
      print("Question IDs: ${quiz.questionIds}");

      List<QuizQuestion> questions = [];
      for (String questionId in quiz.questionIds) {
        print(
            "1 Fetching Question: $questionId, list length: ${questions.length}");

        QuizQuestion? question =
            await QuizManager().getQuizQuestionById(questionId);

        if (question != null) {
          questions.add(question);

          print("Question Text: ${question.questionText}");
          print("Question Type: ${question.type}");

          print("Added question, list length: ${questions.length}");
        } else {}

        print("2 Fetching Question: $questionId, list length: ${questions.length}");
      }

      setState(() {
        loadedQuestions = questions;
      });

      print("Current Question Index: $currentQuestionIndex...");
      print("loadedQuestions: $loadedQuestions");

      if (currentQuestionIndex < loadedQuestions.length) {
        print(
            "Current Question ID: ${loadedQuestions[currentQuestionIndex].questionText}");
      } else {
        print(
            "Error: Index out of range - Current Question Index: $currentQuestionIndex");
      }

      displayQuestion(currentQuestionIndex, quiz.questionIds);
    } else {
      print("Quiz not found with ID: $quizId");
    }
  }

  void moveToNextOrSubmit() async {
    if (currentQuestionIndex >= loadedQuestions.length) {
      // Prevents accessing an index that is out of bounds
      return;
    }

    QuizQuestion currentQuestion = loadedQuestions[currentQuestionIndex];
    String questionId = quiz.questionIds[currentQuestionIndex];

    Map<String, dynamic> questionSummary;

    if (currentQuestion.type == QuestionType.multipleChoice) {
      if (currentQuestion.answer is QuestionMultipleChoice) {
        questionSummary = checkUserAnswers(
          currentQuestion,
          questionId,
          currentQuestion.type,
          userSummary,
        );
      } else {
        print("Error: Incorrect question type for multiple-choice question.");
        return;
      }
    } else if (currentQuestion.type == QuestionType.fillInTheBlank) {
      if (currentQuestion.answer is QuestionFillInTheBlank) {
        questionSummary = checkUserAnswers(
          currentQuestion,
          questionId,
          currentQuestion.type,
          userSummary,
        );
      } else {
        print("Error: Incorrect question type for fill-in-the-blank question.");
        return;
      }
    } else { return; }

    userSummary = {
      ...userSummary,
      ...questionSummary,
    };

    // Move to the next question or submit the quiz
    if (currentQuestionIndex < loadedQuestions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        quizCompleted = false;
      });
      await displayQuestion(currentQuestionIndex, quiz.questionIds);
    } else {
      setState(() {
        quizCompleted = true;
      });

      await storeUserAnswersInFirebase(userSummary);
      Map<String, dynamic> quizAttemptData = createQuizAttemptData(userSummary);

      print("FINAL loadedQuestions: $loadedQuestions");
      print("LOADED QUESTIONS TEXTS: ${loadedQuestions[currentQuestionIndex].questionText}");
      print("FINAL attempt data: $quizAttemptData");

      // Navigate to QuizSummaryPage with quizSummary
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizSummaryPage(
            loadedQuestions: loadedQuestions,
            quizAttemptData: quizAttemptData,
            earnedXp: earnedXp,
          ),
        ),
      );
    }
  }

  Map<String, dynamic> createQuizAttemptData(Map<String, dynamic> userSummary) {
    int quizTotal = loadedQuestions.length;

    return {
      'timestamp': FieldValue.serverTimestamp(),
      'userResults': {
        'quizTotal': quizTotal,
        'userTotal': calculateUserTotal(userSummary),
      },
      'userSummary': userSummary,
    };
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width * 2 / 3;
    double containerHeight = MediaQuery.of(context).size.height * 2 / 3;

    Color primaryColour = Theme.of(context).colorScheme.primary;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar: AppTheme.buildAppBar(context, 'Quiz App', false, false, "Welcome to our quiz app", const Text('')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: containerWidth,
                height: containerHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: primaryColour.withOpacity(1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: loadedQuestions.isNotEmpty
                      ? buildQuizPage(loadedQuestions[currentQuestionIndex])
                      : Container(),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (currentQuestionIndex > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 550),
                        child: IconButton(
                          icon: Icon(Icons.arrow_left, color: Theme.of(context).colorScheme.primary,),
                          tooltip: 'Previous question',
                          onPressed: () {
                            if (currentQuestionIndex > 0) {
                              // If there is a previous question, move to it
                              currentQuestionIndex--;
                              displayQuestion(currentQuestionIndex, quiz.questionIds);
                              setState(() {
                                quizCompleted = false;
                              });
                            }
                          },
                        ),
                      )
                    else
                      const SizedBox(width: 48),
                    Padding(
                      padding: const EdgeInsets.only(right: 550),
                      child: IconButton(
                        icon: Icon(Icons.arrow_right, color: Theme.of(context).colorScheme.primary),
                        tooltip: currentQuestionIndex < loadedQuestions.length - 1
                            ? 'Next Question'
                            : 'Submit Quiz',
                        onPressed: () async {
                          if (currentQuestionIndex == loadedQuestions.length) {
                            // If there are more questions, store user answers in Firebase
                            print("Just before storing the userSummary: $userSummary");
                          }
                          moveToNextOrSubmit();
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          // Show the alert dialog
                          bool? userConfirmed = await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                title: Text(
                                  'Are you sure?',
                                  style: TextStyle(
                                    color: secondaryColour,
                                  ),
                                ),
                                content: Text(
                                  'Do you really want to quit?',
                                  style: TextStyle(
                                    color: secondaryColour,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      // User pressed 'Cancel'
                                      Navigator.pop(context, false);
                                    },
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: secondaryColour,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // User pressed 'Yes'
                                      Navigator.pop(context, true);
                                    },
                                    child: Text(
                                      'Yes',
                                      style: TextStyle(
                                        color: secondaryColour,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                          if (userConfirmed == true) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => LandingPage()),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColour,
                        ),
                        child: Text(
                          'Quit',
                          style: TextStyle(
                            color: secondaryColour,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(bottom: 50, right: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: loadedQuestions.map((id) {
                      int index = loadedQuestions.indexOf(id);
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == currentQuestionIndex
                              ? Colors.blue
                              : Theme.of(context).colorScheme.secondary,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildQuizPage(QuizQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Text(
          question.questionText,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 45),
        //This is where the question will be asked / written to the page. The question format for posing the question is universal for all question types thus doesn't need to be type specific.

        if (question.type == QuestionType.multipleChoice)
          buildMultipleChoiceQuestion(question.answer as QuestionMultipleChoice),
        if (question.type == QuestionType.fillInTheBlank)
          buildFillInTheBlankQuestion(question.answer as QuestionFillInTheBlank, question.key),
      ],
    );
  }

  Widget buildMultipleChoiceQuestion(QuestionMultipleChoice question) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: question.options.length,
      itemBuilder: (context, index) {
        String option = question.options[index];
        bool isSelected = question.selectedOptions.contains(index);

        return InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                question.selectedOptions.remove(index);
              } else {
                question.selectedOptions.add(index);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 100),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.blue,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                option,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildFillInTheBlankQuestion(QuestionFillInTheBlank question, GlobalKey key) {
    return Container(
      width: 500,
      child: TextField(
        controller: question.controller,
        key: key,
        onChanged: (text) {
          setState(() {
            question.userResponse = text;
          });
        },
        decoration: InputDecoration(
          hintText: "Enter your answer here",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          filled: true,
          fillColor: primaryColour,
          hintStyle: const TextStyle(
            color: Colors.black,
          ),
        ),
        style: const TextStyle(
          color: Colors.black,
        ),
      )
    );
  }

  Future<void> displayQuestion(int index, List<String> questionIds) async {
    if (loadedQuestions.isNotEmpty && index < loadedQuestions.length) {
      QuizQuestion currentQuestion = loadedQuestions[index];
      String questionId = questionIds[index]; // Use the correct questionId

      // Initialize user response in userSummary only if not already present
      if (!userSummary.containsKey(questionId)) {
        if (currentQuestion.type == QuestionType.multipleChoice) {
          QuestionMultipleChoice multipleChoiceAnswer =
              QuestionMultipleChoice.fromMap(currentQuestion.answer.toFirestore());

          // Get the correct answers for the question
          List<int> correctAnswers = multipleChoiceAnswer.correctAnswers;

          // Initialize user response in userSummary only if not already present
          if (!userSummary.containsKey(questionId)) {
            userSummary[questionId] = {
              'correctIncorrect': 'Not Answered',
              'userResponse': multipleChoiceAnswer.selectedOptions,
              'correctAnswers': correctAnswers,
            };
          }
        } else if (currentQuestion.type == QuestionType.fillInTheBlank) {
          QuestionFillInTheBlank fillInTheBlankAnswer =
              currentQuestion.answer as QuestionFillInTheBlank;
          setState(() {
            fillInTheBlankController.text = fillInTheBlankAnswer.userResponse;
          });

          String correctAnswer = fillInTheBlankAnswer.correctAnswer;

          // Initialize user response in userSummary only if not already present
          if (!userSummary.containsKey(questionId)) {
            userSummary[questionId] = {
              'correctIncorrect': 'Not Answered',
              'userResponse': fillInTheBlankAnswer.userResponse,
              'correctAnswers': correctAnswer,
            };
          }
        }
      }
    } else {
      print("Error: loadedQuestions is empty or index is out of range.");
    }
  }

  Future<void> storeUserAnswersInFirebase(Map<String, dynamic> userSummary) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print("User not logged in.");
        return;
      }

      String userId = user.uid;
      Quiz? loadedQuiz2 = await quizManager.getQuizWithId(widget.quizId);

      if (loadedQuiz2 == null) {
        print("Quiz not found with ID: ${widget.quizId}");
        return;
      }

      CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
      DocumentReference userDocument = usersCollection.doc(userId);
      CollectionReference quizHistoryCollection = userDocument.collection('quizHistory').doc(widget.quizId).collection('attempts');

      String quizAttemptId = DateTime.now().toUtc().toIso8601String();
      DocumentReference quizAttemptDocument = quizHistoryCollection.doc(quizAttemptId);

      int quizTotal = loadedQuestions.length;

      Map<String, dynamic> quizAttemptData = {
        'timestamp': FieldValue.serverTimestamp(),
        'userResults': {
          'quizTotal': quizTotal,
          'userTotal': calculateUserTotal(userSummary),
        },
        'userSummary': userSummary,
      };

      await quizAttemptDocument.set(quizAttemptData);
      int xpGain = calculateXpGain(userSummary, widget.multiplier);
      earnedXp = xpGain; 

      // Now, update the timestamp field in the quizId2 document
      await FirebaseFirestore.instance.collection('users').doc(userId).collection('quizHistory').doc(widget.quizId).set({
        'timestamp': FieldValue.serverTimestamp(),
        'xpGain': xpGain,
        'name': quiz.name,
      }, SetOptions(merge: true));

      var userDoc = await FirebaseFirestore.instance.collection("users").doc(userId).get();
      int currentXp = 0; 

      if (userDoc.data() != null) {
        if (userDoc.data()!.containsKey("xpLvl")) {
          currentXp = userDoc.data()!["xpLvl"];
        }
      }

      currentXp += xpGain;
      FirebaseFirestore.instance.collection("users").doc(userId).update({ "xpLvl": currentXp }, );

      print("User answers and summary stored successfully!");
    } catch (error) {
      print("Error storing user answers: $error");
    }
  }

  // Helper function to get correct answers from loaded questions
  Map<String, dynamic> getCorrectAnswers(List<QuizQuestion> questions) {
    Map<String, dynamic> correctAnswers = {};
    questions.forEach((question) {
      if (question.type == QuestionType.multipleChoice) {
        QuestionMultipleChoice mcQuestion = question.answer as QuestionMultipleChoice;
        correctAnswers[question.questionText] = mcQuestion.correctAnswers;
      } else if (question.type == QuestionType.fillInTheBlank) {
        QuestionFillInTheBlank fitbQuestion = question.answer as QuestionFillInTheBlank;
        correctAnswers[question.questionText] = fitbQuestion.correctAnswer;
      } else {}
    });
    return correctAnswers;
  }

  int calculateUserTotal(Map<String, dynamic> userSummary) {
    int userTotal = 0;

    userSummary.forEach((questionId, details) {
      if (details['correctIncorrect'] == 'Correct') {
        userTotal += 1;
      }
    });
    return userTotal;
  }

  int calculateXpGain(Map<String, dynamic> userSummary, double multiplier) {
    int xp = 0; 

    userSummary.forEach((questionId, details) {
      if (details['correctIncorrect'] == 'Correct') {
        var q = loadedQuestions.where((element)  { return element.questionId == questionId; });
        xp +=  q.first.difficulty;
      }
    });
    xp = xp ~/ loadedQuestions.length;
    xp = (xp.toDouble() * multiplier).toInt();
    return xp;
  }
}

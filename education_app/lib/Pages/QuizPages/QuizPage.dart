import 'package:flutter/material.dart';
import 'package:education_app/Quizzes/quiz.dart';
import 'package:education_app/Quizzes/quizManager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:education_app/Pages/QuizPages/HistoryPages/QuizSummaryPage.dart';

class QuizPage extends StatefulWidget {
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
  // Replace the quizId being passed in, it is static for testing purposes.
  String quizId = 'yKExulogYwk65MqHrFMN';
  Map<String, dynamic> quizAttemptData = {};

  @override
  void initState() {
    super.initState();
    quizManager = QuizManager();
    loadQuiz(quizId);
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
      setState(() {
        quiz = loadedQuiz;
      });

      // Print quiz details
      print("Loaded quiz: ${quiz.name}");
      print("Question IDs: ${quiz.questionIds}");

      List<QuizQuestion> questions = [];
      for (String questionId in quiz.questionIds) {
        print(
            "1 Fetching Question: $questionId, list length: ${questions.length}");

        // Fetch the question document directly from Firestore using QuizManager instead
        QuizQuestion? question =
            await QuizManager().getQuizQuestionById(questionId);

        if (question != null) {
          questions.add(question);

          // Print question type
          print("Question Text: ${question.questionText}");
          print("Question Type: ${question.type}");

          print("Added question, list length: ${questions.length}");
        } else {
          // Handle case where question doesn't exist
        }

        print(
            "2 Fetching Question: $questionId, list length: ${questions.length}");
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
      // Handle the case where the quiz is not found
      // may want to show an error message or navigate back
      print("Quiz not found with ID: $quizId");
    }
  }

  void moveToNextOrSubmit() async {
    if (currentQuestionIndex >= loadedQuestions.length) {
      // Prevents accessing an index that is out of bounds
      return;
    }

    QuizQuestion currentQuestion = loadedQuestions[currentQuestionIndex];
    String questionId = quiz.questionIds[currentQuestionIndex]; // Get the correct questionId

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
    } else {
      // Add other question types if needed
      return;
    }


    // Update userSummary with the new summary
    userSummary = {
      ...userSummary,
      ...questionSummary,
    };

    // Print the current question summary (you can remove this in the final version)
    print("User Summary: $userSummary");

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
          ),
        ),
      );
    }

    // Print the current question index (you can remove this in the final version)
    print("Question Index: $currentQuestionIndex");
  }


  Map<String, dynamic> createQuizAttemptData(Map<String, dynamic> userSummary) {
    int quizTotal = loadedQuestions.length;

    return {
      'timestamp': FieldValue.serverTimestamp(),
      'userResults': {
        'quizTotal': quizTotal,  // Update this with the actual maximum points
        'userTotal': calculateUserTotal(userSummary),
      },
      'userSummary': userSummary,
    };
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width * 2 / 3;
    double containerHeight = MediaQuery.of(context).size.height * 2 / 3;

    return Scaffold(
      appBar: AppBar(
      ),
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
                  color: Color(0xFFf3edf6).withOpacity(1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: Offset(0, 3),
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
            padding: const EdgeInsets.only(left: 250),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (currentQuestionIndex > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 350),
                        child: IconButton(
                          // color: tertiary,
                          // hoverColor: secondary,
                          icon: const Icon(Icons.arrow_left),
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
                      SizedBox(width: 48), // Add a placeholder SizedBox when the condition is false
                    Padding(
                      padding: const EdgeInsets.only(right: 550),
                      child: IconButton(
                        // color: tertiary,
                        // hoverColor: secondary,
                        icon: const Icon(Icons.arrow_right),
                        tooltip: currentQuestionIndex < loadedQuestions.length - 1
                            ? 'Next Question'
                            : 'Submit Quiz',
                        onPressed: () async {
                          if (currentQuestionIndex == loadedQuestions.length) {
                            // If there are more questions, store user answers in Firebase
                            print("Just before storing the userSummary: $userSummary");
                            // await storeUserAnswersInFirebase2(userSummary);
                          }
                          moveToNextOrSubmit();
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(bottom: 50, right: 190),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: loadedQuestions.map((id) {
                      int index = loadedQuestions.indexOf(id);
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == currentQuestionIndex
                              ? Colors.blue
                              : Colors.grey,
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
        SizedBox(height: 20),
        Text(
          question.questionText,
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 45),
        //This is where the question will be asked / written to the page. The question format for posing the question is universal for all question types thus doesn't need to be type specific.

        if (question.type == QuestionType.multipleChoice)
          buildMultipleChoiceQuestion(question.answer as QuestionMultipleChoice),
        if (question.type == QuestionType.fillInTheBlank)
          buildFillInTheBlankQuestion(question.answer as QuestionFillInTheBlank),
        // if (question.type == QuestionType.dragAndDrop) 
          // buildDragAndDropQuestion(question.answer as DragAndDropQuestion, context),
          // buildDragAndDropQuestion(question.answer as DragAndDropQuestion, context),
      ],
    );
  }

  Widget buildMultipleChoiceQuestion(QuestionMultipleChoice question) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
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
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 100),
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

  Widget buildFillInTheBlankQuestion(QuestionFillInTheBlank question) {
    return Container(
      width: 500,
      child: TextField(
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
          fillColor: Colors.white,
        ),
      )
    );
  }

// Widget buildDragAndDropQuestion(DragAndDropQuestion question, BuildContext context) {
//   List<Widget> droppedItems = [];

//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         question.optionsText.join('\n'),
//         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//       ),
//       SizedBox(height: 20),
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           // Drag Targets
//           for (int i = 0; i < question.options.length; i++)
//             Draggable<Widget>(
//               child: Container(
//                 width: 50,
//                 height: 50,
//                 color: Colors.blue,
//                 child: const Center(child: Text('Item 1'))
//               ),
//               feedback: Container(
//                 width: 100,
//                 height: 100,
//                 color: Colors.blue,
//                 child: const Center(child: Text('Item 1'))
//               ),
//               data: Container(
//                 width: 100,
//                 height: 100,
//                 color: Colors.blue,
//                 child: const Center(child: Text('Item 1'))
//               )
//             ),
//           for (int i = 0; i < question.options.length; i++)
//             DragTarget<Widget>(
//               builder: (context, accepted, rejected) {
//                 return Container(
//                   width: 300,
//                   height: 200,
//                   color: Colors.grey,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: droppedItems.isEmpty
//                       ? [const Text('Drop Items Here')]
//                       : droppedItems
//                   ),
//                 );
//               },
//               onWillAccept: (Widget? data) {
//                 return true;
//               },
//               onAccept: (Widget data) {
//                 setState(() {
//                   droppedItems.add(data);
//                 });
//               },
//             ),
//         ],
//       ),
//     ],
//   );
// }


// Widget buildTarget(
//   BuildContext context, {
//   required String text,
//   required List<String> options,
//   required DragTargetAccept<String> onAccept,
// }) =>
//     CircleAvatar(
//       radius: 50,
//       child: DragTarget<String>(
//         builder: (context, candidateData, rejectedData) => Stack(
//           children: [
//             // Draggable Options
//             for (int i = 0; i < options.length; i++)
//               Draggable<String>(
//               data: options[i],
//               feedback: Card(
//                 elevation: 5,
//                 child: Container(
//                   width: 100,
//                   height: 50,
//                   alignment: Alignment.center,
//                   child: Text(options[i]),
//                 ),
//               ),
//               child: Card(
//                 elevation: 3,
//                 child: Container(
//                   width: 100,
//                   height: 50,
//                   alignment: Alignment.center,
//                   child: Text(options[i]),
//                 ),
//               ),
//             ),
//             // IgnorePointer(child: Center(child: buildText(text))),
//           ],
//         ),
//         onWillAcceptWithDetails: (data) => true,
//         onAcceptWithDetails: (DragTargetDetails<String> details) {
//           String data = details.data;
//           onAccept(data);
//         },
//       ),
//     );


//     Widget buildText(String text) => Container(
//       decoration: BoxDecoration(boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.8),
//           blurRadius: 12,
//         )
//       ]),
//       child: Text(
//         text,
//         style: TextStyle(
//           color: Colors.white,
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );

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
      // int quizTotal = quizAttemptData['userResults']['quizTotal'];

      if (user == null) {
        print("User not logged in.");
        return;
      }

      String userId = user.uid;
      Quiz? loadedQuiz2 = await quizManager.getQuizWithId(quizId);

      if (loadedQuiz2 == null) {
        print("Quiz not found with ID: $quizId");
        return;
      }

      CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
      DocumentReference userDocument = usersCollection.doc(userId);
      CollectionReference quizHistoryCollection = userDocument.collection('quizHistory').doc(quizId).collection('attempts');

      String quizAttemptId = DateTime.now().toUtc().toIso8601String();
      DocumentReference quizAttemptDocument = quizHistoryCollection.doc(quizAttemptId);

      int quizTotal = loadedQuestions.length;

      // Include the timestamp field in the userSummary
      Map<String, dynamic> quizAttemptData = {
        'timestamp': FieldValue.serverTimestamp(),
        'userResults': {
          'quizTotal': quizTotal, // Update this with the actual number of questions
          'userTotal': calculateUserTotal(userSummary),
        },
        'userSummary': userSummary,
      };

      // Store data in Firebase
      await quizAttemptDocument.set(quizAttemptData);

      // Now, update the timestamp field in the quizId2 document
      await FirebaseFirestore.instance.collection('users').doc(userId).collection('quizHistory').doc(quizId).set({
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Print success message
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
      } else {
        // Handle other question types if needed
      }
    });
    return correctAnswers;
  }

  // Calculate user total based on the summary
  int calculateUserTotal(Map<String, dynamic> userSummary) {
    int userTotal = 0;

    userSummary.forEach((questionId, details) {
      if (details['correctIncorrect'] == 'Correct') {
        // Assign points based on your scoring logic
        // For example, you might have different point values for different question difficulties
        userTotal += 1;
      }
    });

    return userTotal;
  }
}

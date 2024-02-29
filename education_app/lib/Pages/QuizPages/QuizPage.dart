import 'package:flutter/material.dart';
import 'package:education_app/Quizzes/quiz.dart';
import 'package:education_app/Quizzes/quizManager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education_app/Pages/QuizPages/QuizSummaryPage.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      // Prevents accessing an index that out of bounds
      return;
    }

    QuizQuestion currentQuestion = loadedQuestions[currentQuestionIndex];
    String questionId = quiz.questionIds[currentQuestionIndex]; // Get the correct questionId

    if (currentQuestion.type == QuestionType.multipleChoice) {
      if (currentQuestion.answer is QuestionMultipleChoice) {
        Map<String, dynamic> questionSummary = checkUserAnswers(
          currentQuestion.answer as QuestionMultipleChoice,
          questionId,
          currentQuestion.type,
          userSummary,
        );
        print("71 User Summary: $questionSummary");

        // Update userSummary with the new summary
        userSummary = {
          ...userSummary,
          ...questionSummary,
        };

        await Future.delayed(Duration(milliseconds: 500));

        print("70 User Summary: $userSummary");
        // storeUserAnswersInFirebase2(userSummary);
      } else {
        print("Error: Incorrect question type for multiple-choice question.");
        return;
      }
    } else if (currentQuestion.type == QuestionType.fillInTheBlank) {
      if (currentQuestion.answer is QuestionFillInTheBlank) {
        checkFillInTheBlankAnswer(currentQuestion.answer as QuestionFillInTheBlank);
      } else {
        print("Error: Incorrect question type for fill-in-the-blank question.");
        return;
      }
    } else {
      // Add other question types if needed
    }

    // checkUserAnswers(quiz.questionIds, loadedQuestions);
    // storeUserAnswersInFirebase2(userSummary);
    print("43 User Summary: $userSummary");

    // print("Current Question Index: $currentQuestionIndex");

    if (currentQuestionIndex < loadedQuestions.length - 1) {
      // Move to the next question
      setState(() {
        currentQuestionIndex++;
        quizCompleted = false;
      });
      await displayQuestion(currentQuestionIndex, quiz.questionIds);
    } else {
      // Last question, submit the quiz
      setState(() {
        quizCompleted = true;
      });

      // Navigate to QuizSummaryPage with quizSummary
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizSummaryPage(quizSummary: userSummary),
        ),
      );
    }
    print("Question Index: $currentQuestionIndex");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz Page"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: 1600,
                height: 800,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 0,
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (currentQuestionIndex > 0)
                      ElevatedButton(
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
                        child: Text('Previous Question'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          moveToNextOrSubmit();
                          if (currentQuestionIndex < loadedQuestions.length - 2) {
                              // If there are more questions, store user answers in Firebase
                              print("Just before storing the userSummary: $userSummary");
                              // storeUserAnswersInFirebase2(userSummary);
                            }
                        },
                        child: Text(
                          currentQuestionIndex < loadedQuestions.length - 1
                              ? 'Next Question'
                              : 'Submit Quiz'
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
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
        SizedBox(height: 10),
        Text(
          question.questionText,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        //This is where the question will be asked / written to the page. The question format for posing the question is universal for all question types thus doesn't need to be type specific.

        //This is where the response format will change depending on the question type. Multiple Choice will have selectable thingys. Drag and Drop something else...
        // if (question.type == QuestionType.multipleChoice) {
        //   buildMultipleChoiceOptions(question.answer as QuestionMultipleChoice),
        // } else if (question.type == QuestionType.fillInTheBlank) {
        //   buildFillInTheBlankOptions(question.answer as QuestionFillInTheBlank),
        // } //FOR SOME REASON THIS IF STATEMENT WONT WORK SO I DECIDED TO USE A SWITCH STATEMENT...

        if (question.type == QuestionType.multipleChoice)
          buildMultipleChoiceQuestion(question.answer as QuestionMultipleChoice),
        if (question.type == QuestionType.fillInTheBlank)
          buildFillInTheBlankQuestion(question.answer as QuestionFillInTheBlank),
        // if (question.type == QuestionType.dragAndDrop) 
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
            // Handle user selection here
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
            margin: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue,
                width: 1,
              ),
            ),
            child: Text(
              option,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }

  // Function to check correctness of selected options for multiple-choice question
  // void checkMultipleChoiceAnswer(QuestionMultipleChoice question, String questionId) {
  //   // Get the correct answers for the question
  //   List<int> correctAnswers = question.correctAnswers;

  //   // Get the user's selected options
  //   List<int> selectedOptions = question.selectedOptions;

  //   // Sort both lists to compare them easily
  //   correctAnswers.sort();
  //   selectedOptions.sort();

  //   // Check if the selected options match the correct answers
  //   print("1 THESE ARE THE SELECTED OPTIONS: $selectedOptions, $correctAnswers");
  //   if (areListsEqual(correctAnswers, selectedOptions)) {
  //     // The user's answer is correct
  //     print("2 THESE ARE THE SELECTED OPTIONS: $selectedOptions");
  //     print("Correct! User selected the right options.");
  //     userSummary[questionId] = {
  //       'correctIncorrect': 'Correct',
  //       'userResponse': question.selectedOptions,
  //       'correctAnswers': correctAnswers,
  //     };
  //   } else {
  //     print("3 THESE ARE THE SELECTED OPTIONS: $selectedOptions, $correctAnswers");
  //     // The user's answer is incorrect
  //     print("Incorrect! User selected the wrong options.");
  //     userSummary[questionId] = {
  //       'correctIncorrect': 'Incorrect',
  //       'userResponse': question.selectedOptions,
  //       'correctAnswers': correctAnswers,
  //     };
  //   }
  // }



  bool areListsEqual(List<dynamic> list1, List<dynamic> list2) {
    if (list1.length != list2.length) {
      return false;
    }

    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) {
        return false;
      }
    }

    return true;
  }


  Widget buildFillInTheBlankQuestion(QuestionFillInTheBlank question) {
    return TextField(
      onChanged: (text) {
        // Handle user input here
        setState(() {
          question.userResponse = text;
        });
      },
      decoration: InputDecoration(
        hintText: "Type your answer here...",
        // You can customize the input decoration based on your design
      ),
    );
  }

  void checkFillInTheBlankAnswer(QuestionFillInTheBlank question) {
    // Get the correct answers for the question
    List<String> correctAnswers = question.correctAnswers.map((answer) => answer.toLowerCase()).toList();

    // Get the user's response
    String userResponse = question.userResponse.toLowerCase();

    // Check if the user's response matches any of the correct answers
    bool isCorrect = correctAnswers.contains(userResponse);

    // Update the user summary
    userSummary[loadedQuestions[currentQuestionIndex].questionText] = {
      'correctIncorrect': isCorrect ? 'Correct' : 'Incorrect',
      'userResponse': userResponse,
      'correctAnswers': correctAnswers,
    };

    // Print the result (you can remove this in the final version)
    print("Question: ${loadedQuestions[currentQuestionIndex].questionText}");
    print("Correct Answers: ${correctAnswers}");
    print("User Response: $userResponse");
    print("Result: ${isCorrect ? 'Correct' : 'Incorrect'}");
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
            'questionText': currentQuestion.questionText,
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

        List<String> correctAnswers = fillInTheBlankAnswer.correctAnswers;

        // Initialize user response in userSummary only if not already present
        if (!userSummary.containsKey(questionId)) {
          userSummary[questionId] = {
            'questionText': currentQuestion.questionText,
            'correctIncorrect': 'Not Answered',
            'userResponse': fillInTheBlankAnswer.userResponse,
            'correctAnswers': correctAnswers,
          };
        }
      }
    }
  } else {
    print("Error: loadedQuestions is empty or index is out of range.");
  }
}


  // Future<void> storeUserAnswersInFirebase(List<String> questionIds, loadedQuestions) async {
  //   try {
  //     Quiz? loadedQuiz = await quizManager.getQuizWithId(quizId);
  //     User? user = FirebaseAuth.instance.currentUser;
  //     if (user == null) {
  //       // Handle the case where the user is not logged in
  //       print("User not logged in.");
  //       return;
  //     }

  //     if (loadedQuiz != null) {
  //       setState(() {
  //         quiz = loadedQuiz;
  //       });

  //       // Print quiz details
  //       print("Loaded quiz: ${quiz.name}");
  //       print("Question IDs: ${quiz.questionIds}");

  //       String userId = user.uid;

  //       // Your existing code...
  //       // Create a reference to the users collection
  //       CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  //       // Create a reference to the user's document
  //       DocumentReference userDocument = usersCollection.doc(userId);

  //       // Create a reference to the quiz history subcollection for the current quiz
  //       CollectionReference quizHistoryCollection = userDocument.collection('quizHistory').doc(quizId).collection('attempts');

  //       // Generate a unique ID for this quiz attempt (using timestamp)
  //       String quizAttemptId = DateTime.now().toUtc().toIso8601String();

  //       // Create a reference to the quiz attempt document
  //       DocumentReference quizAttemptDocument = quizHistoryCollection.doc(quizAttemptId);

  //       List<QuizQuestion> questions = [];

  //       for (String questionId in questionIds) {
  //         // Fetch the question document directly from Firestore using QuizManager instead
  //         QuizQuestion? question = await QuizManager().getQuizQuestionById(questionId);

  //         if (question != null) {
  //           questions.add(question);
  //         } else {
  //           // Handle the case where the question doesn't exist
  //           print("Question not found with ID: $questionId");
  //         }
  //       }

  //       // print("84 User Summary: $userSummary");
  //       Map<String, dynamic> userSummary = checkUserAnswers(questionIds, loadedQuestions);
  //       print("85 User Summary: $userSummary");

  //       // Prepare data to store in Firebase
  //       Map<String, dynamic> quizAttemptData = {
  //         'timestamp': FieldValue.serverTimestamp(), // Store timestamp
  //         'userResults': {
  //           'quizTotal': 20, // Update this with the actual maximum points
  //           'userTotal': calculateUserTotal(userSummary),
  //         },
  //         'userSummary': userSummary,
  //       };

  //       // Store data in Firebase
  //       await quizAttemptDocument.set(quizAttemptData);

  //       // Print success message
  //       print("User answers and summary stored successfully!");
  //     }
  //   } catch (error) {
  //     // Handle errors, e.g., display an error message
  //     print("Error storing user answers: $error");
  //   }
  // }

  Future<void> storeUserAnswersInFirebase2(Map<String, dynamic> userSummary) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        // Handle the case where the user is not logged in
        print("User not logged in.");
        return;
      }

      // Fetch the quiz details
      Quiz? loadedQuiz2 = await quizManager.getQuizWithId(quizId);  // Rename variable to avoid conflict
      if (loadedQuiz2 == null) {
        print("Quiz not found with ID: $quizId");
        return;
      }

      // Get the user ID and quiz ID
      String userId = user.uid;
      String quizId2 = quizId;  // Rename variable to avoid conflict

      // Create a reference to the users collection
      CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

      // Create a reference to the user's document
      DocumentReference userDocument = usersCollection.doc(userId);

      // Create a reference to the quiz history subcollection for the current quiz
      CollectionReference quizHistoryCollection = userDocument.collection('quizHistory').doc(quizId2).collection('attempts');

      // Generate a unique ID for this quiz attempt (using timestamp)
      String quizAttemptId = DateTime.now().toUtc().toIso8601String();

      // Create a reference to the quiz attempt document
      DocumentReference quizAttemptDocument = quizHistoryCollection.doc(quizAttemptId);

      // Prepare data to store in Firebase
      Map<String, dynamic> quizAttemptData = {
        'timestamp': FieldValue.serverTimestamp(), // Store timestamp
        'userResults': {
          'quizTotal': 20, // Update this with the actual maximum points
          'userTotal': calculateUserTotal(userSummary),
        },
        'userSummary': userSummary,
      };

      // Store data in Firebase
      await quizAttemptDocument.set(quizAttemptData);

      // Print success message
      print("User answers and summary stored successfully!");
    } catch (error) {
      // Handle errors, e.g., display an error message
      print("Error storing user answers: $error");
    }
  }








  // Function to get correct answers for a specific question
  List<dynamic> getCorrectAnswersForQuestion(QuizQuestion question) {
    if (question.type == QuestionType.multipleChoice) {
      return (question.answer as QuestionMultipleChoice).correctAnswers;
    } else if (question.type == QuestionType.fillInTheBlank) {
      return (question.answer as QuestionFillInTheBlank).correctAnswers;
    } else {
      // Handle other question types if needed
      return [];
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
        correctAnswers[question.questionText] = fitbQuestion.correctAnswers;
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

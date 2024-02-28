import 'package:flutter/material.dart';
import 'package:education_app/Quizzes/quiz.dart';
import 'package:education_app/Quizzes/quizManager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education_app/Pages/QuizPages/QuizSummaryPage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizSummaryPage extends StatefulWidget {
  final Map<String, dynamic> quizSummary;

  QuizSummaryPage({required this.quizSummary});

  @override
  _QuizSummaryPageState createState() => _QuizSummaryPageState();
}

class _QuizSummaryPageState extends State<QuizSummaryPage> {
  // final Map<String, dynamic> quizSummary;
  late TextEditingController fillInTheBlankController;
  late QuizManager quizManager;
  late Quiz quiz;
  late List<QuizQuestion> loadedQuestions = [];
  int currentQuestionIndex = 0;
  Map<String, dynamic> userSummary = {};
  // Replace the quizId being passed in, it is static for testing purposes.
  String quizId = 'yKExulogYwk65MqHrFMN';
  
  // QuizSummaryPage({required this.quizSummary});

  @override
  void initState() {
    super.initState();
    quizManager = QuizManager();
    loadQuiz(quizId);
    fillInTheBlankController = TextEditingController();
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
        // print(
            // "1 Fetching Question: $questionId, list length: ${questions.length}");

        // Fetch the question document directly from Firestore using QuizManager instead
        QuizQuestion? question =
            await QuizManager().getQuizQuestionById(questionId);

        if (question != null) {
          questions.add(question);

          // Print question type
          // print("Question Text: ${question.questionText}");
          // print("Question Type: ${question.type}");

          // print("Added question, list length: ${questions.length}");
        } else {
          // Handle case where question doesn't exist
        }

        // print(
            // "2 Fetching Question: $questionId, list length: ${questions.length}");
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

      displayQuestion(currentQuestionIndex);
    } else {
      // Handle the case where the quiz is not found
      // may want to show an error message or navigate back
      print("Quiz not found with ID: $quizId");
    }
  }

  Future<void> displayQuestion(int index) async {
    if (loadedQuestions.isNotEmpty && index < loadedQuestions.length) {
      QuizQuestion currentQuestion = loadedQuestions[index];

      // Print question details
      print("Question ${index + 1}:");
      print("Text: ${currentQuestion.questionText}");
      print("Type: ${currentQuestion.type}");
      print("Difficulty: ${currentQuestion.difficulty}");
      print("Tags: ${currentQuestion.tags}");

      print("1");
      if (currentQuestion.type == QuestionType.multipleChoice) {
        print("Multiple Choice Start");
        QuestionMultipleChoice multipleChoiceAnswer = QuestionMultipleChoice.fromMap(currentQuestion.answer.toFirestore());
        print("Options: ${multipleChoiceAnswer.options}");
        print("Correct Answers: ${multipleChoiceAnswer.correctAnswers}");
        userSummary[loadedQuestions[currentQuestionIndex].questionText] = {
          'correctIncorrect': 'Not Answered',
          'userResponse': [],
        };
        print("Multiple Choice End");
      } else if (currentQuestion.type == QuestionType.fillInTheBlank) {
        QuestionFillInTheBlank fillInTheBlankAnswer =
            currentQuestion.answer as QuestionFillInTheBlank;
        setState(() {
          fillInTheBlankController.text = fillInTheBlankAnswer.userResponse;
        });
        print("fillInTheBlankAnswer: ${fillInTheBlankAnswer.userResponse}");
        print("Correct Answers: ${fillInTheBlankAnswer.correctAnswers}");
        userSummary[loadedQuestions[currentQuestionIndex].questionText] = {
          'correctIncorrect': 'Not Answered',
          'userResponse': fillInTheBlankAnswer.userResponse,
        };
      }
    } else {
      print("Error: loadedQuestions is empty or index is out of range.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Summary Page"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (int i = 0; i < loadedQuestions.length; i++)
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  width: 1600,
                  padding: EdgeInsets.all(16),
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
                  child: loadedQuestions.isNotEmpty
                      ? buildQuizPage(loadedQuestions[i])
                      : Container(),
                ),
            ],
          ),
        ),
      )
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
      // Other code for building the question...

      if (question.type == QuestionType.multipleChoice)
        buildMultipleChoiceQuestion(question.answer as QuestionMultipleChoice),
      // if (question.type == QuestionType.fillInTheBlank)
        // buildFillInTheBlankQuestion(question.answer as QuestionFillInTheBlank),
      // if (question.type == QuestionType.dragAndDrop) 
        // buildDragAndDropQuestion(question.answer as DragAndDropQuestion, context),
    ],
  );
}


Widget buildMultipleChoiceQuestion(QuestionMultipleChoice question) {
  String questionText = loadedQuestions[currentQuestionIndex].questionText;

  // Correctly cast the correctAnswers to a list of strings, provide default empty list if null
  List<String> correctAnswers = (widget.quizSummary[questionText]['correctAnswers'] as List?)?.map((e) => e.toString()).toList() ?? [];

  // Provide default empty list if userResponse is null
  List<dynamic> userResponses = widget.quizSummary[questionText]['userResponse'] ?? [];

  print("SUMMARY !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
  print("User Summary: $userSummary");
  print("Question: $question");
  print("Question Text: $questionText");
  print("User Responses: $userResponses");
  print("Correct Answers: $correctAnswers");

  return ListView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemCount: question.options.length,
    itemBuilder: (context, index) {
      String option = question.options[index];
      // Convert option to String to ensure proper comparison
      String stringOption = option.toString();

      print("userResponse and correctAnswers: ${userResponses[index]}, ${correctAnswers[index]}");
      bool isUserResponseCorrect = userResponses[index] == correctAnswers[index];

      Color highlightColor = Colors.white; // Default color

      print("isUserResponseCorrect: $isUserResponseCorrect");
      if (isUserResponseCorrect) {
        highlightColor = Colors.green; // Highlight in green if user response is correct
      } else {
        highlightColor = Colors.red; // Highlight in red if user response is incorrect
      }

      return InkWell(
        onTap: () {
          // Handle user selection here
          setState(() {
            // No need to modify selectedOptions, just handle highlighting
          });
        },
        child: Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: highlightColor, // Highlight based on correctness
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.blue, // Border color
              width: 1,
            ),
          ),
          child: Text(
            option,
            style: TextStyle(
              color: Colors.black, // Change the text color if needed
            ),
          ),
        ),
      );
    },
  );
}













}

// return ListView.builder(
//       shrinkWrap: true,
//       physics: NeverScrollableScrollPhysics(),
//       itemCount: question.options.length,
//       itemBuilder: (context, index) {
//         String option = question.options[index];
//         bool isSelected = question.selectedOptions.contains(index);
//         bool isUserResponse = widget.quizSummary[loadedQuestions[currentQuestionIndex].questionText]['userResponse'].contains(index);

//         return InkWell(
//           onTap: () {
//             // Handle user selection here
//             setState(() {
//               if (isSelected) {
//                 question.selectedOptions.remove(index);
//               } else {
//                 question.selectedOptions.add(index);
//               }
//             });
//           },
//           child: Container(
//             padding: EdgeInsets.all(10),
//             margin: EdgeInsets.symmetric(vertical: 5),
//             decoration: BoxDecoration(
//               color: isSelected
//                   ? Colors.blue
//                   : isUserResponse
//                       ? Colors.green // Highlight user's correct response
//                       : Colors.white,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(
//                 color: Colors.blue,
//                 width: 1,
//               ),
//             ),
//             child: Text(
//               option,
//               style: TextStyle(
//                 color: isSelected || isUserResponse ? Colors.white : Colors.black,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

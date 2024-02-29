import 'package:flutter/material.dart';
import 'package:education_app/Quizzes/quiz.dart';
import 'package:education_app/Quizzes/quizManager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizSummaryPage extends StatefulWidget {
  final Map<String, dynamic> quizSummary;

  QuizSummaryPage({required this.quizSummary});

  @override
  _QuizSummaryPageState createState() => _QuizSummaryPageState();
}

class _QuizSummaryPageState extends State<QuizSummaryPage> {
  late TextEditingController fillInTheBlankController;
  late QuizManager quizManager;
  late Quiz quiz;
  late List<QuizQuestion> loadedQuestions = [];
  int currentQuestionIndex = 0;
  Map<String, dynamic> userSummary = {};
  String quizId = 'yKExulogYwk65MqHrFMN';

  @override
  void initState() {
    super.initState();
    quizManager = QuizManager();
    loadQuiz(quizId);
    userSummary = widget.quizSummary;
    fillInTheBlankController = TextEditingController();
    print("USER SUMMARY SUPPOSEDLY $userSummary...");
  }

  Future<void> loadQuiz(String quizId) async {
    print("Loading quiz with ID: $quizId");

    Quiz? loadedQuiz = await quizManager.getQuizWithId(quizId);

    if (loadedQuiz != null) {
      setState(() {
        quiz = loadedQuiz;
      });

      List<QuizQuestion> questions = [];
      for (String questionId in quiz.questionIds) {
        QuizQuestion? question =
            await QuizManager().getQuizQuestionById(questionId);

        if (question != null) {
          questions.add(question);
        } else {
          // Handle case where question doesn't exist
        }
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
      print("Quiz not found with ID: $quizId");
    }
  }

  Future<void> displayQuestion(int index) async {
    if (loadedQuestions.isNotEmpty && index < loadedQuestions.length) {
      QuizQuestion currentQuestion = loadedQuestions[index];

      if (currentQuestion.type == QuestionType.multipleChoice) {
        QuestionMultipleChoice multipleChoiceAnswer =
            QuestionMultipleChoice.fromMap(
                currentQuestion.answer.toFirestore());

        List<int> correctAnswers = multipleChoiceAnswer.correctAnswers;

        userSummary[currentQuestion.questionText] = {
          'correctIncorrect': 'Not Answered',
          'userResponse': multipleChoiceAnswer.selectedOptions,
          'correctAnswers': correctAnswers,
        };
      } else if (currentQuestion.type == QuestionType.fillInTheBlank) {
        QuestionFillInTheBlank fillInTheBlankAnswer =
            currentQuestion.answer as QuestionFillInTheBlank;
        setState(() {
          fillInTheBlankController.text = fillInTheBlankAnswer.userResponse;
        });
        
        List<String> correctAnswers = fillInTheBlankAnswer.correctAnswers;

        userSummary[currentQuestion.questionText] = {
          'correctIncorrect': 'Not Answered',
          'userResponse': fillInTheBlankAnswer.userResponse,
          'correctAnswers': correctAnswers,
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
                      ? buildQuizSummaryPage(loadedQuestions[i])
                      : Container(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildQuizSummaryPage(QuizQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 10),
        Text(
          question.questionText,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        if (question.type == QuestionType.multipleChoice)
          buildMultipleChoiceQuestion(
              question.answer as QuestionMultipleChoice),
      ],
    );
  }

  Widget buildMultipleChoiceQuestion(QuestionMultipleChoice question) {
  // Create a local variable to store the current question and its selected options
  QuizQuestion currentQuestion = loadedQuestions[currentQuestionIndex];
  QuestionMultipleChoice currentQuestionAnswer =
      QuestionMultipleChoice.fromMap(currentQuestion.answer.toFirestore());

  return ListView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemCount: question.options.length,
    itemBuilder: (context, index) {
      String option = question.options[index];
      bool isSelected = currentQuestionAnswer.selectedOptions.contains(index);

      List<int> correctAnswers =
          List<int>.from(userSummary[currentQuestion.questionText]![
                  'correctAnswers'] ??
              []);
      List<int> userResponse =
          List<int>.from(userSummary[currentQuestion.questionText]![
                  'userResponse'] ??
              []);

      bool isCorrectAnswer = correctAnswers.contains(index);
      bool isUserResponse = userResponse.contains(index);

      return InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              currentQuestionAnswer.selectedOptions.remove(index);
            } else {
              currentQuestionAnswer.selectedOptions.add(index);
            }

            userSummary[currentQuestion.questionText]![
                'userResponse'] = List<int>.from(
                currentQuestionAnswer.selectedOptions);
          });
        },
        child: Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.blue
                : (isUserResponse
                    ? (isCorrectAnswer ? Colors.green : Colors.red)
                    : Colors.white),
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
}

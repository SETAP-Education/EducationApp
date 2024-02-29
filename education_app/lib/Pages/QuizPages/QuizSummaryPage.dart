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
  late Map<String, dynamic> userSummary;
  String quizId = 'yKExulogYwk65MqHrFMN';

  @override
  void initState() {
    super.initState();
    quizManager = QuizManager();
    loadQuiz(quizId);
    userSummary = widget.quizSummary;
    fillInTheBlankController = TextEditingController();
    print("QuizSummaryPage initialised userSummary $userSummary...");
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
        child: Column(
          children: [
            // Display general quiz statistics
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.blue.withOpacity(0.1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "User Results",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  // Display general quiz statistics using userSummary
                  Text("Total Questions: ${loadedQuestions.length}"),
                  Text("Correct Answers: ${calculateCorrectAnswers()}"),
                  Text("Incorrect Answers: ${calculateIncorrectAnswers()}"),
                  // You can add more statistics as needed
                ],
              ),
            ),
            // Display quiz questions
            for (int i = 0; i < loadedQuestions.length; i++)
              buildQuizSummaryPage(loadedQuestions[i], i),
          ],
        ),
      ),
    );
  }

  Widget buildQuizSummaryPage(QuizQuestion question, int questionIndex) {
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
              question.answer as QuestionMultipleChoice, questionIndex),
      ],
    );
  }

  Widget buildMultipleChoiceQuestion(QuestionMultipleChoice question, int questionIndex) {
    List<int> userResponse =
        List<int>.from(userSummary[questionIndex.toString()]?['userResponse'] ?? []);

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: question.options.length,
      itemBuilder: (context, index) {
        String option = question.options[index];
        bool isSelected = userResponse.contains(index);

        bool isCorrectAnswer = question.correctAnswers.contains(index);

        return InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                userResponse.remove(index);
              } else {
                userResponse.add(index);
              }

              userSummary[questionIndex.toString()] = {
                'correctIncorrect': 'Not Answered',
                'userResponse': List<int>.from(userResponse),
              };
            });
          },
          child: Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue
                  : (isCorrectAnswer ? Colors.green : Colors.white),
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

  int calculateCorrectAnswers() {
    int correctAnswers = 0;
    for (int i = 0; i < loadedQuestions.length; i++) {
      String key = i.toString();
      if (userSummary[key]?['correctIncorrect'] == 'Correct') {
        correctAnswers++;
      }
    }
    return correctAnswers;
  }

  int calculateIncorrectAnswers() {
    int incorrectAnswers = 0;
    for (int i = 0; i < loadedQuestions.length; i++) {
      String key = i.toString();
      if (userSummary[key]?['correctIncorrect'] == 'Incorrect') {
        incorrectAnswers++;
      }
    }
    return incorrectAnswers;
  }
}

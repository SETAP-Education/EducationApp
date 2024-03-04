import 'package:flutter/material.dart';
import 'package:education_app/Quizzes/quiz.dart';
import 'package:education_app/Pages/LandingPage.dart';

class QuizSummaryPage extends StatelessWidget {
  final List<QuizQuestion> loadedQuestions;
  final Map<String, dynamic> quizAttemptData;

  QuizSummaryPage({
    required this.loadedQuestions,
    required this.quizAttemptData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Center( // Center everything on the screen
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Quiz Summary',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              // Display overall quiz results
              buildQuizResults(quizAttemptData, context),
              // SizedBox(height: 8.0),
              // Display quizAttemptData using QuizSummaryItem
              for (int i = 0; i < loadedQuestions.length; i++)
                FractionallySizedBox(
                  widthFactor: 2 / 3,
                  child: Card(
                    margin: EdgeInsets.only(bottom: 16.0),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: loadedQuestions.isNotEmpty
                          ? QuizSummaryItem(
                              question: loadedQuestions[i],
                              questionIndex: i,
                              quizAttemptData: quizAttemptData,
                            )
                          : Container(),
                    ),
                  ),
                ),
              SizedBox(height: 16.0),
              Padding(
                padding: EdgeInsets.only(left: 390),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LandingPage(),
                      ),
                    );
                  },
                  child: Text('Home'),
              ),
      ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildQuizResults(Map<String, dynamic> quizAttemptData, BuildContext context) {
    // Extract relevant data
    int quizTotal = quizAttemptData['userResults']['quizTotal'];
    int userTotal = quizAttemptData['userResults']['userTotal'];

    return FractionallySizedBox(
      widthFactor: 2 / 3,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 5, // Set the elevation for the shadow
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Quiz overview',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5.0),
              Text(
                "                   ${(userTotal / quizTotal) * 100}% \n $userTotal / $quizTotal answered correctly ",
                style: TextStyle(fontSize: 17.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuizSummaryItem extends StatelessWidget {
  final QuizQuestion question;
  final int questionIndex;
  final Map<String, dynamic> quizAttemptData;

  QuizSummaryItem({
    required this.question,
    required this.questionIndex,
    required this.quizAttemptData,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize userResponse with an empty list if not present in quizAttemptData
    List<int> userResponse = List<int>.from(quizAttemptData['userSummary'][questionIndex.toString()]?['userResponse'] ?? []);

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
          buildMultipleChoiceQuestion(question.answer as QuestionMultipleChoice, userResponse),
        if (question.type == QuestionType.fillInTheBlank)
          buildFillInTheBlankQuestion(question.answer as QuestionFillInTheBlank),
      ],
    );
  }

  Widget buildMultipleChoiceQuestion(QuestionMultipleChoice question, List<int> userResponse) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: question.options.length,
      itemBuilder: (context, index) {
        String option = question.options[index];
        bool isSelected = question.selectedOptions.contains(index);
        bool isCorrect = question.correctAnswers.contains(index);

        Color backgroundColour = isSelected
            ? (isSelected && isCorrect ? Colors.green : Colors.red)
            : Colors.transparent;

        Color borderColour = isSelected
            ? (isSelected && isCorrect ? Colors.green : Colors.red)
            : (isCorrect ? Colors.green : Colors.blue);

        return Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: backgroundColour,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: borderColour,
              width: 1,
            ),
          ),
          child: Text(
            option,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        );
      },
    );
  }

  Widget buildFillInTheBlankQuestion(QuestionFillInTheBlank question) {
    print("The user response: ${question.userResponse}, The correct response: ${question.correctAnswer}");

    // Determine background and border colors
    Color backgroundColour = (question.userResponse.isEmpty)
        ? Colors.transparent // Not answered
        : (question.userResponse.toLowerCase() == question.correctAnswer.toLowerCase())
            ? Colors.green // Correct
            : Colors.red; // Incorrect

    Color borderColour = (question.userResponse.isEmpty)
        ? Colors.blue // Not answered
        : (question.userResponse.toLowerCase() == question.correctAnswer.toLowerCase())
            ? Colors.green // Correct
            : Colors.red; // Incorrect

    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColour,
        border: Border.all(
          color: borderColour,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          (question.userResponse.isEmpty) ? 'Not answered' : question.userResponse,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

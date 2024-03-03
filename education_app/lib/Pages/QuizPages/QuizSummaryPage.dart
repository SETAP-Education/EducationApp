import 'package:flutter/material.dart';
import 'package:education_app/Quizzes/quiz.dart';

class QuizSummaryPage extends StatelessWidget {
  final List<QuizQuestion> loadedQuestions;
  final Map<String, dynamic> quizAttemptData;

  QuizSummaryPage({
    required this.loadedQuestions,
    required this.quizAttemptData,
  });

  @override
  Widget build(BuildContext context) {
    print("THIS IS THE INITIAL QUIZ SUMMARY PAGE: $quizAttemptData");
    print("THIS IS THE INITIAL LoadedQuestions: $loadedQuestions");

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Summary'),
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
              ElevatedButton(
                onPressed: () {
                  // Navigate back to the quiz page or any other action
                  Navigator.pop(context);
                },
                child: Text('Back to Quiz'),
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
    print("3 Quiz Attempt Data: $quizAttemptData");

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
                'Quiz Results',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                "Quiz Total: $quizTotal",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                'Your Score: $userTotal',
                style: TextStyle(fontSize: 16.0),
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
    print("12 question: $question");
    print("13 question answer: ${question.answer}");

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
          buildMultipleChoiceQuestion(question.answer as QuestionMultipleChoice),
        if (question.type == QuestionType.fillInTheBlank)
          buildFillInTheBlankQuestion(question.answer as QuestionFillInTheBlank),
      ],
    );
  }

  Widget buildMultipleChoiceQuestion(QuestionMultipleChoice question) {
    print("23 quesiton: $question");
    print("24 The user response: ${question.selectedOptions}, The correct response: ${question.correctAnswers}");
    print("25 Quiz Data: ${quizAttemptData}");
    print("26 Question Index: ${questionIndex}}");
    int outputtedStatement = quizAttemptData['userSummary'][questionIndex]['userResponse'];
    print("27 The outputted statemtent: $outputtedStatement");

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
          (question.userResponse.isEmpty) ? 'Not answered - The correct Answer is: "${question.correctAnswer}"' : question.userResponse,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

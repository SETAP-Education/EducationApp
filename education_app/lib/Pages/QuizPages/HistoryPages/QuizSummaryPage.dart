import 'package:education_app/Pages/LandingPage.dart';
import 'package:education_app/Widgets/Button.dart';
import 'package:flutter/material.dart';
import 'package:education_app/Quizzes/quiz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education_app/Theme/AppTheme.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizSummaryPage extends StatelessWidget {
  final List<QuizQuestion> loadedQuestions;
  final Map<String, dynamic> quizAttemptData;
  final int earnedXp; 


  QuizSummaryPage({
    required this.loadedQuestions,
    required this.quizAttemptData,
    required this.earnedXp, 
  });

  @override
  Widget build(BuildContext context) {
    print("THIS IS THE INITIAL QUIZ SUMMARY PAGE: $quizAttemptData");
    print("THIS IS THE INITIAL LoadedQuestions: $loadedQuestions");
    List<String> questionIds = quizAttemptData['userSummary'].keys.toList();
    print("4 Question Ids: $questionIds");

    return Scaffold(
      appBar: AppTheme.buildAppBar(context, 'Quiz App', false, false, "Welcome to our quiz app", Text('')),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Quiz Summary',
                style: GoogleFonts.nunito(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              buildQuizResults(quizAttemptData, context),
              for (int i = 0; i < loadedQuestions.length; i++)
                FractionallySizedBox(
                  widthFactor: 2 / 3,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 16.0),
                   
                    decoration: BoxDecoration(
                       color: Theme.of(context).colorScheme.primaryContainer,
                       borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: loadedQuestions.isNotEmpty
                          ? buildQuizSummaryItem(loadedQuestions[i], i, quizAttemptData)
                          : Container(),
                    ),
                  ),
                ),
              const SizedBox(height: 16.0),

              FractionallySizedBox(
                widthFactor: 2 / 3,
                child: Button(
                  important: true,
                  onClick: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LandingPage(),
                      ),
                    );
                  },
                  child: Text(
                    'Back to Home',
                    style: GoogleFonts.nunito(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> getUserResponseForQuestion(QuizQuestion question, Map<String, dynamic> quizAttemptData, int questionIndex) async {
    dynamic userResponse; // Initialize the userResponse variable

    quizAttemptData['userSummary'].forEach((questionId, summary) {
      // Check if 'userResponse' exists for the current question
      if (summary.containsKey('userResponse')) {
        // Retrieve 'userResponse' based on question type
        var summaryUserResponse = summary['userResponse'];

        // Check question type (assuming multiple choice or fill in the blank)
        if (question.type == QuestionType.multipleChoice && summaryUserResponse is List<int>) {
          // Handle 'userResponse' as List<int> (multiple choice)
          print('Question ID: $questionId, User Response (Multiple Choice): $summaryUserResponse');
          userResponse = summaryUserResponse;
        } else if (question.type == QuestionType.fillInTheBlank && summaryUserResponse is String) {
          // Handle 'userResponse' as String (fill in the blank)
          print('Question ID: $questionId, User Response (Fill in the Blank): $summaryUserResponse');
          userResponse = summaryUserResponse;
        } else {
          print('Unknown question type for Question ID: $questionId');
        }
      } else {
        // Handle the case where 'userResponse' is not present in the summary
        print('No user response found for Question ID: $questionId');
      }
    });

    return userResponse;
  }


  // Future<int> getQuestionTypeFromFirestore(String questionId, FirebaseFirestore firestore) async {
  //   try {
  //     final questionDoc = await firestore.collection('questions').doc(questionId).get();
  //     if (questionDoc.exists) {
  //       final questionType = questionDoc.data()?['type'];
  //       return questionType;
  //     } else {
  //       print('Question not found in Firestore for ID: $questionId');
  //     }
  //   } catch (e) {
  //     print('Error fetching question type from Firestore: $e');
  //     return null;
  //   }
  // }

  Widget buildQuizResults(Map<String, dynamic> quizAttemptData, BuildContext context) {
    int quizTotal = quizAttemptData['userResults']['quizTotal'];
    int userTotal = quizAttemptData['userResults']['userTotal'];
    print("3 Quiz Attempt Data: $quizAttemptData");

    return FractionallySizedBox(
      widthFactor: 2 / 3,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(24.0),
        ),
       
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'How did you do?',
                style: GoogleFonts.nunito(fontSize: 28.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5.0),
              // Text(
              //   "                   ${(userTotal / quizTotal) * 100}% \n $userTotal / $quizTotal answered correctly ",
              //   style: GoogleFonts.nunito(fontSize: 17.0),
              // ),

              RichText(text: TextSpan(
                text: "$userTotal",
                style: GoogleFonts.nunito(fontSize: 22.0, color: Theme.of(context).textTheme.bodyMedium!.color),
                children: [
                  TextSpan(
                    text: " / $quizTotal",
                    style: GoogleFonts.nunito(fontSize: 16.0, color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.5))
                  ),
                  TextSpan(
                    text: " answered correctly",
                    style: GoogleFonts.nunito(fontSize: 20.0, color: Theme.of(context).textTheme.bodyMedium!.color)
                  )
                ]
              )),

              Text("${(userTotal / quizTotal) * 100}%", style: GoogleFonts.nunito(fontSize: 32.0, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("You earned:  ", style: GoogleFonts.nunito(fontSize: 22)),
                  Text("${earnedXp}xp" , style: GoogleFonts.nunito(fontSize: 28, color: Theme.of(context).colorScheme.primary, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold))
                ],
              )
             
            ],
          ),
        ),
      ),
    );
  }

  Widget buildQuizSummaryItem(QuizQuestion question, int questionIndex, Map<String, dynamic> quizAttemptData) {
    dynamic userResponse;

    for (var entry in quizAttemptData['userSummary'].entries) {
      var questionId = entry.key;
      var summary = entry.value;

      if (questionId == question.questionId) {
        // Found the user response for the current question
        if (summary.containsKey('userResponse')) {
          var summaryUserResponse = summary['userResponse'];

          if (question.type == QuestionType.multipleChoice) {
            print('Question ID: $questionId, User Response (Multiple Choice): $summaryUserResponse');
            // Convert userResponse to List<int>
            userResponse = (summaryUserResponse as List).cast<int>();
          } else if (question.type == QuestionType.fillInTheBlank) {
            print('Question ID: $questionId, User Response (Fill in the Blank): $summaryUserResponse');
            // Convert userResponse to List<int>
            userResponse = (summaryUserResponse as String);
          } else {
            print('Unknown question type for Question ID: $questionId');
            userResponse = "asdf";
          }
        } else {
          print('No user response found for Question ID: $questionId');
        }

        // Break the loop once we find the user response for the current question
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 10),
        Text(
          question.questionText,
          style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        if (question.type == QuestionType.multipleChoice)
          buildMultipleChoiceQuestion(question.answer as QuestionMultipleChoice, userResponse),
        if (question.type == QuestionType.fillInTheBlank)
          buildFillInTheBlankQuestion(question.answer as QuestionFillInTheBlank, userResponse),
      ],
    );
  }

  Widget buildMultipleChoiceQuestion(QuestionMultipleChoice question, List<int> userResponse) {
    // String questionId = question.questionId; // Use the appropriate key to get the question ID
    // List<dynamic> userResponseList = quizAttemptData['userSummary'][quizAttemptData.questionId]['userResponse'];
    print("MC USER RESPONSE: $userResponse");

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: question.options.length,
      itemBuilder: (context, index) {
        String option = question.options[index];
        bool isSelected = userResponse.contains(index);
        bool isCorrect = question.correctAnswers.contains(index);

        Color backgroundColour = isSelected
            ? (isSelected && isCorrect ? Colors.green : Colors.red)
            : Colors.transparent;

        Color borderColour = isSelected
            ? (isSelected && isCorrect ? Colors.green : Colors.red)
            : (isCorrect ? Colors.green : Colors.grey);

        return Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: backgroundColour,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColour,
              width: 2,
            ),
          ),
          child: Text(
            option,
            style: GoogleFonts.nunito(
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: isSelected || isCorrect ? FontWeight.bold : FontWeight.normal
            ),
          ),
        );
      },
    );
  }

  Widget buildFillInTheBlankQuestion(QuestionFillInTheBlank question, String userResponse) {
    print("The user response: ${userResponse}, The correct response: ${question.correctAnswer}");
    print("FITB USER RESPONSE: $userResponse");

    Color backgroundColour = userResponse.isEmpty
        ? Colors.transparent
        : (userResponse.toLowerCase() == question.correctAnswer.toLowerCase())
            ? Colors.green
            : Colors.red;

    Color borderColour = userResponse.isEmpty
        ? Colors.blue
        : (userResponse.toLowerCase() == question.correctAnswer.toLowerCase())
            ? Colors.green
            : Colors.red;

    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColour,
        border: Border.all(
          color: borderColour,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          userResponse.isEmpty
              ? 'Not answered - The correct Answer is: "${question.correctAnswer}"'
              : userResponse.toLowerCase() == question.correctAnswer.toLowerCase()
                  ? 'Correct! Your answer: ${userResponse} ✓'
                  : 'Incorrect. Your answer: ${userResponse} ✘ | The correct Answer is: "${question.correctAnswer}"',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
      ),
      ),
    );
  }
}

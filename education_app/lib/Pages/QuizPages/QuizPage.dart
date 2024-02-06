import 'package:flutter/material.dart';
import 'package:education_app/Quizzes/quiz.dart';
import 'package:education_app/Quizzes/quizManager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late QuizManager quizManager;
  late Quiz quiz;
  late List<QuizQuestion> loadedQuestions = [];
  int currentQuestionIndex = 0;
  bool quizCompleted = false;

  @override
  void initState() {
    super.initState();
    quizManager = QuizManager();
    // Replace 'your_quiz_id' with the actual ID of the quiz you want to load, it is static for testing purposes.
    loadQuiz('yKExulogYwk65MqHrFMN');
  }

  Future<void> loadQuiz(String quizId) async {
    print("Loading quiz with ID: $quizId");

    Quiz? loadedQuiz = await quizManager.getQuizWithId(quizId);

    if (loadedQuiz != null) {
      setState(() {
        quiz = loadedQuiz;
        loadedQuestions = quiz.loadedQuestions;
      });

      // Print quiz details
      print("Loaded quiz: ${quiz.name}");
      print("Question IDs: ${quiz.questionIds}");

      // Fetch questions and populate loadedQuestions
      await fetchQuestionsForQuiz(quiz.questionIds);

      print("Current Question Index: $currentQuestionIndex...");
      print("loadedQuestions: $loadedQuestions");

      if (currentQuestionIndex < loadedQuestions.length) {
        print("Current Question ID: ${loadedQuestions[currentQuestionIndex].questionText}");
      } else {
        print("Error: Index out of range - Current Question Index: $currentQuestionIndex");
      }

      displayQuestion(currentQuestionIndex);
    } else {
      // Handle the case where the quiz is not found
      // You may want to show an error message or navigate back
      print("Quiz not found with ID: $quizId");
    }
  }

  Future<void> fetchQuestionsForQuiz(List<String> questionIds) async {
    List<QuizQuestion> questions = [];

    for (String questionId in questionIds) {
      print("1 Fetching Question: $questionId, list length: ${questions.length}");

      // Fetch the question document directly from Firestore because im not sure how else to do it...if there is a better way to do it, feel free to do it.
      DocumentSnapshot<Map<String, dynamic>> questionSnapshot =
          await FirebaseFirestore.instance.collection('questions').doc(questionId).get();

      print("Middle of the fetch function...");

      if (questionSnapshot.exists) {
        QuizQuestion question = QuizQuestion.fromFirestore(questionSnapshot, null);
        questions.add(question);

        // Print question type
        print("Question Text: ${question.questionText}");
        print("Question Type: ${question.type}");
        
        print("Added question, list length: ${questions.length}");
      } else {
        // to handle case where question doesn't exist
      }

      print("2 Fetching Question: $questionId, list length: ${questions.length}");
    }

    setState(() {
      loadedQuestions = questions;
    });
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
                            currentQuestionIndex--;
                            displayQuestion(currentQuestionIndex);
                            setState(() {
                              quizCompleted = false;
                            });
                          }
                        },
                        child: Text('Previous Question'),
                      ),
                    if (!quizCompleted)
                      ElevatedButton(
                        onPressed: () async {
                          print("Options selected: ${(loadedQuestions[currentQuestionIndex].answer as QuestionMultipleChoice).selectedOptions}");
                          print("Current Question Index: $currentQuestionIndex");
                          currentQuestionIndex++;
                          if (currentQuestionIndex < loadedQuestions.length - 1) {
                            print("Question Index inside if: $currentQuestionIndex");
                            await displayQuestion(currentQuestionIndex);
                          } else {
                            print("Question Index inside else: $currentQuestionIndex");
                            setState(() {
                              quizCompleted = true;
                            });
                          }
                          print("Question Index: $currentQuestionIndex");
                        },
                        child: const Text('Next Question'),
                      ),
                    if (quizCompleted)
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to QuizSummary when the quiz is completed
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => QuizSummary(
                          //       questionIds: loadedQuestions.map((question) => question.questionText).toList(),
                          //       userAnswers: userAnswers,
                          //     ),
                          //   ),
                          // );
                          // WILL PUSH TO THE QUIZ SUMMARY
                          print("Quiz Summary: Not implemented yet");
                        },
                        child: Text('Submit Questions'),
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
        if (question.type == QuestionType.multipleChoice)
          buildMultipleChoiceOptions(question.answer as QuestionMultipleChoice),
        // Add other cases for different question types when needed.
      ],
    );
  }

  Widget buildMultipleChoiceOptions(QuestionMultipleChoice question) {
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

  Future<void> displayQuestion(int index) async {
  if (loadedQuestions.isNotEmpty && index < loadedQuestions.length) {
    QuizQuestion currentQuestion = loadedQuestions[index];

    // Print question details
    print("Question ${index + 1}:");
    print("Text: ${currentQuestion.questionText}");
    print("Type: ${currentQuestion.type}");
    print("Difficulty: ${currentQuestion.difficulty}");
    print("Tags: ${currentQuestion.tags}");
    if (currentQuestion.type == QuestionType.multipleChoice) {
      QuestionMultipleChoice multipleChoiceAnswer = currentQuestion.answer as QuestionMultipleChoice;
      print("Options: ${multipleChoiceAnswer.options}");
      print("Correct Answers: ${multipleChoiceAnswer.correctAnswers}");
    // elseif (currentQuestion.type == QuestionType.dragAndDrop) {
    }

    // Implement logic to update the UI with the current question
    // For example, you can set the question text in a Text widget.

    // setState(() {
    //   currentQuestionText = currentQuestion.questionText;
    // });
  } else {
    print("Error: loadedQuestions is empty or index is out of range.");
  }
}


}


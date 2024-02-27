import 'package:flutter/material.dart';
import 'package:education_app/Quizzes/quiz.dart';
import 'package:education_app/Quizzes/quizManager.dart';

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

  @override
  void initState() {
    super.initState();
    quizManager = QuizManager();
    // Replace 'your_quiz_id' with the actual ID of the quiz you want to load, it is static for testing purposes.
    loadQuiz('yKExulogYwk65MqHrFMN');
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

      displayQuestion(currentQuestionIndex);
    } else {
      // Handle the case where the quiz is not found
      // may want to show an error message or navigate back
      print("Quiz not found with ID: $quizId");
    }
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
                          print(
                              "Options selected: ${(loadedQuestions[currentQuestionIndex].answer as QuestionMultipleChoice).selectedOptions}");
                          print(
                              "Current Question Index: $currentQuestionIndex");
                          currentQuestionIndex++;
                          if (currentQuestionIndex <
                              loadedQuestions.length - 1) {
                            print(
                                "Question Index inside if: $currentQuestionIndex");
                            await displayQuestion(currentQuestionIndex);
                          } else {
                            print(
                                "Question Index inside else: $currentQuestionIndex");
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
        // if (question.type == QuestionType.multipleChoice) {
        //   buildMultipleChoiceOptions(question.answer as QuestionMultipleChoice),
        // } else if (question.type == QuestionType.fillInTheBlank) {
        //   buildFillInTheBlankOptions(question.answer as QuestionFillInTheBlank),
        // } //FOR SOME REASON THIS IF STATEMENT WONT WORK SO I DECIDED TO USE A SWITCH STATEMENT...

        if (question.type == QuestionType.multipleChoice)
          buildMultipleChoiceOptions(question.answer as QuestionMultipleChoice),
        if (question.type == QuestionType.fillInTheBlank)
          buildFillInTheBlank(question.answer as QuestionFillInTheBlank),
        if (question.type == QuestionType.dragAndDrop) 
        buildDragAndDrop(question.answer as DragAndDropQuestion),
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

  Widget buildFillInTheBlank(QuestionFillInTheBlank question) {
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

  Widget buildDragAndDrop(DragAndDropQuestion question) {
    // Implement your UI for Drag and Drop question type here.
    // You can use draggable and drag target widgets to create draggable cards.
    // Here's a simple example:

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Draggable cards
            for (String option in question.options)
              Draggable<String>(
                data: option,
                child: Card(
                  elevation: 3,
                  child: Container(
                    width: 100,
                    height: 50,
                    alignment: Alignment.center,
                    child: Text(option),
                  ),
                ),
                feedback: Card(
                  elevation: 5,
                  child: Container(
                    width: 100,
                    height: 50,
                    alignment: Alignment.center,
                    child: Text(option),
                  ),
                ),
                childWhenDragging: Container(),
              ),
          ],
        ),
        SizedBox(height: 20),
        // Drag targets
        for (int i = 0; i < question.options.length; i++)
          DragTarget<String>(
            builder: (context, candidateData, rejectedData) {
              return Card(
                elevation: 3,
                child: Container(
                  width: 100,
                  height: 50,
                  alignment: Alignment.center,
                  child: Text("Drop here"),
                ),
              );
            },
            onWillAccept: (data) {
              // Add your logic to determine if the dragged item is correct.
              // Return true if it's correct, false otherwise.
              return true;
            },
            onAccept: (data) {
              // Handle the accepted item (optional).
              print("Accepted: $data");
            },
            onLeave: (data) {
              // Handle when a draggable item leaves the target area (optional).
              print("Left: $data");
            },
          ),
      ],
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
        QuestionMultipleChoice multipleChoiceAnswer =
            currentQuestion.answer as QuestionMultipleChoice;
        print("Options: ${multipleChoiceAnswer.options}");
        print("Correct Answers: ${multipleChoiceAnswer.correctAnswers}");
        // elseif (currentQuestion.type == QuestionType.dragAndDrop) {
      }

    
      // Implement logic to update the UI with the current question
      // For example, you can set the question text in a Text widget.

      if (currentQuestion.type == QuestionType.fillInTheBlank) {
        QuestionFillInTheBlank fillInTheBlankAnswer = currentQuestion.answer as QuestionFillInTheBlank;
        setState(() {
          fillInTheBlankController.text = fillInTheBlankAnswer.userResponse;
        });
        print("fillInTheBlankAnswer: ${fillInTheBlankController.text}");
        print("Correct Answers: ${fillInTheBlankAnswer.correctAnswers}");
      }

      // setState(() {
      //   currentQuestionText = currentQuestion.questionText;
      // });
    } else {
      print("Error: loadedQuestions is empty or index is out of range.");
    }
  }
}

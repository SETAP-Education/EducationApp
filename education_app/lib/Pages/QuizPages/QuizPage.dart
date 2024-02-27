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

      displayQuestion(currentQuestionIndex);
    } else {
      // Handle the case where the quiz is not found
      // may want to show an error message or navigate back
      print("Quiz not found with ID: $quizId");
    }
  }

  Future<void> moveToNextOrSubmit() async {
    if (currentQuestionIndex >= loadedQuestions.length) {
      // Prevents accessing an index that out of bounds
      return;
    }

    QuizQuestion currentQuestion = loadedQuestions[currentQuestionIndex];

    if (currentQuestion.type == QuestionType.multipleChoice) {
      if (currentQuestion.answer is QuestionMultipleChoice) {
        checkMultipleChoiceAnswer(currentQuestion.answer as QuestionMultipleChoice);
        print("Options selected: ${(currentQuestion.answer as QuestionMultipleChoice).selectedOptions}");
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

    print("Current Question Index: $currentQuestionIndex");

    if (currentQuestionIndex < loadedQuestions.length - 1) {
      // Move to the next question
      setState(() {
        currentQuestionIndex++;
        quizCompleted = false;
      });
      await displayQuestion(currentQuestionIndex);
    } else {
      // Last question, submit the quiz
      setState(() {
        quizCompleted = true;
      });

      // Store user answers in Firebase
      await storeUserAnswersInFirebase();

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
                            currentQuestionIndex--;
                            displayQuestion(currentQuestionIndex);
                            setState(() {
                              quizCompleted = false;
                            });
                          }
                        },
                        child: Text('Previous Question'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await moveToNextOrSubmit();
                        },
                        child: Text(
                          currentQuestionIndex < loadedQuestions.length - 1
                              ? 'Next Question'
                              : 'Submit Quiz',
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

  // Function to check correctness of selected options for multiple-choice question
  void checkMultipleChoiceAnswer(QuestionMultipleChoice question) {
    // Get the correct answers for the question
    List<int> correctAnswers = question.correctAnswers;

    // Get the user's selected options
    List<int> selectedOptions = question.selectedOptions;

    // Sort both lists to compare them easily
    correctAnswers.sort();
    selectedOptions.sort();

    // Check if the selected options match the correct answers
    if (areListsEqual(correctAnswers, selectedOptions)) {
      // The user's answer is correct
      print("Correct! User selected the right options.");
      userSummary[loadedQuestions[currentQuestionIndex].questionText] = {
        'correctIncorrect': 'Correct',
        'userResponse': question.selectedOptions,
      };
    } else {
      // The user's answer is incorrect
      print("Incorrect! User selected the wrong options.");
      userSummary[loadedQuestions[currentQuestionIndex].questionText] = {
        'correctIncorrect': 'Incorrect',
        'userResponse': question.selectedOptions,
      };
    }
  }

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
    };

    // Print the result (you can remove this in the final version)
    print("Question: ${loadedQuestions[currentQuestionIndex].questionText}");
    print("Correct Answers: ${correctAnswers}");
    print("User Response: $userResponse");
    print("Result: ${isCorrect ? 'Correct' : 'Incorrect'}");
  }

  Widget buildDragAndDrop(DragAndDropQuestion question) {
  // Implement your UI for Drag and Drop question type here.
  // You can use draggable and drag target widgets to create draggable cards.
  // Here's an updated example:

  return Column(
    children: [
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
                child: Text(question.options[i]),
              ),
            );
          },
          onWillAccept: (data) {
            // Add your logic to determine if the dragged item is correct.
            // Return true if it's correct, false otherwise.
            return data == question.optionsText[i];
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
      SizedBox(height: 20),
      // Draggable cards
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Draggable cards
          for (int i = 0; i < question.options.length; i++)
            Draggable<String>(
              data: question.optionsText[i],
              child: Card(
                elevation: 3,
                child: Container(
                  width: 100,
                  height: 50,
                  alignment: Alignment.center,
                  child: Text(question.optionsText[i]),
                ),
              ),
              feedback: Card(
                elevation: 5,
                child: Container(
                  width: 100,
                  height: 50,
                  alignment: Alignment.center,
                  child: Text(question.optionsText[i]),
                ),
              ),
              childWhenDragging: Container(),
            ),
        ],
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

  Future<void> storeUserAnswersInFirebase() async {
    try {
      // Assuming you have the currently logged-in user
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Handle the case where the user is not logged in
        print("User not logged in.");
        return;
      }

      // Get the user's ID
      String userId = user.uid;

      // Create a reference to the users collection
      CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

      // Create a reference to the user's document
      DocumentReference userDocument = usersCollection.doc(userId);

      // Create a reference to the quiz history subcollection for the current quiz
      CollectionReference quizHistoryCollection = userDocument.collection('quizHistory').doc(quizId).collection('attempts');

      // Generate a unique ID for this quiz attempt (using timestamp)
      String quizAttemptId = DateTime.now().toUtc().toIso8601String();

      // Create a reference to the quiz attempt document
      DocumentReference quizAttemptDocument = quizHistoryCollection.doc(quizAttemptId);

      // Check user answers and get the summary
      Map<String, dynamic> userSummary = checkUserAnswers(loadedQuestions);

      // Prepare data to store in Firebase
      Map<String, dynamic> quizAttemptData = {
        'timestamp': FieldValue.serverTimestamp(), // Store timestamp
        'userResults': {
          'quizTotal': 20, // widget.quiz.getQuizDifficulty(), // Update this with the actual maximum points
          'userTotal': 4, // calculateUserTotal(userSummary),
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

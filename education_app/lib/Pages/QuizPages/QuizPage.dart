import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizPage extends StatefulWidget {
  final String quizId;
  final String userUid;

  QuizPage({required this.quizId, required this.userUid});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<String> questionIds = [];
  List<String> userAnswers = [];
  int currentQuestionIndex = 0;
  bool quizCompleted = false;

  @override
  void initState() {
    super.initState();
    fetchQuestionIds();
  }

  void fetchQuestionIds() async {
    DocumentReference quizRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userUid)
        .collection('quizzes')
        .doc(widget.quizId);

    DocumentSnapshot quizDoc = await quizRef.get();

    if (!quizDoc.exists) {
      print("Error: Quiz document does not exist.");
      return;
    }

    Map<String, dynamic> quizData = quizDoc.data() as Map<String, dynamic>;

    quizData.forEach((fieldName, fieldValue) {
      if (fieldName.startsWith("question")) {
        questionIds.add(fieldValue);
      }
    });

    displayQuestion(currentQuestionIndex);
  }

  Future<DocumentSnapshot> getQuestionDocument(String questionId) async {
    return await FirebaseFirestore.instance
        .collection('questions')
        .doc(questionId)
        .get();
  }

  void onOptionSelected(String option) {
    setState(() {
      userAnswers.add(option);
    });
  }

  Future<void> displayQuestion(int index) async {
    if (index < questionIds.length) {
      String questionId = questionIds[index];

      DocumentSnapshot questionDoc = await getQuestionDocument(questionId);

      if (questionDoc.exists) {
        setState(() {
          currentQuestionIndex = index;
        });
      } else {
        print("Error: Question document does not exist for $questionId");
      }
    } else {
      print("Quiz completed!");
    }
  }

  Widget buildQuizPage(DocumentSnapshot questionDoc) {
    if (questionDoc != null) {
      switch (questionDoc['type']) {
        case 1:
          return MultipleChoiceQuestion(questionDoc);
        case 2:
          return DragAndDropQuestion(questionDoc);
        case 3:
          return FillInTheBlankQuestion(questionDoc);
        default:
          return Container();
      }
    } else {
      return Container(); // Handle the case when questionDoc is null
    }
  }

  Widget MultipleChoiceQuestion(DocumentSnapshot questionDoc) {
    Map<String, dynamic> answerMap = questionDoc['answer'] ?? {};
    List<dynamic> options = answerMap['options'] ?? [];

    // Ensure a minimum of 2 and a maximum of 6 buttons
    int buttonCount = options.length.clamp(2, 6);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Question Type: Multiple Choice",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Question Text: ${questionDoc['questionText']}",
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 16),
        Column(
          children: List.generate(buttonCount, (index) {
            String option = options[index].toString();
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  // // Handle button press
                  // onOptionSelected(option);
                  setState(() {
                    checkMultipleChoiceAnswer(option);
                  });
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(16),
                  minimumSize: Size(double.infinity, 60),
                ),
                child: Text(
                  option,
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  void checkMultipleChoiceAnswer(String selectedOption) async {
    DocumentSnapshot questionDoc = await getQuestionDocument(questionIds[currentQuestionIndex]);
    Map<String, dynamic> answerMap = questionDoc['answer'] ?? {};
    List<dynamic> correctAnswers = (answerMap['correctAnswers'] ?? []).map<String>((answer) => answer.toString()).toList();

    bool isCorrect = correctAnswers.contains(selectedOption);

    if (userAnswers.length > currentQuestionIndex) {
      // If the user has answered this question before, update the answer
      userAnswers[currentQuestionIndex] = selectedOption;
    } else {
      // Otherwise, add the answer to the list
      userAnswers.add(selectedOption);
    }

    print("$getCorrectAnswer(correctAnswers, options)");
    print("User Answer for Question $currentQuestionIndex: $selectedOption");
    print("Correct Answers List: $correctAnswers");
    print("Result: ${isCorrect ? 'Correct' : 'Incorrect'}");
  }


  String getCorrectAnswer(List<dynamic> correctAnswers, List<dynamic> options) {
    List<String> correctAnswerList = correctAnswers.map<String>((index) {
      if (index is int && index >= 0 && index < options.length) {
        return options[index];
      } else {
        return "Invalid Correct Answer";
      }
    }).toList();

    return correctAnswerList.join(', ');
  }

  Widget DragAndDropQuestion(DocumentSnapshot questionDoc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Question Type: Drag and Drop",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Text(
          "Question Text: ${questionDoc['questionText']}",
          style: TextStyle(fontSize: 18),
        ),
        Text(
          "Difficulty: ${questionDoc['difficulty']}",
          style: TextStyle(fontSize: 16),
        ),
        Text(
          "Tags: ${questionDoc['tags']}",
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget FillInTheBlankQuestion(DocumentSnapshot questionDoc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Question Type: Fill in the Blank",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Text(
          "Question Text: ${questionDoc['questionText']}",
          style: TextStyle(fontSize: 18),
        ),
        Text(
          "Difficulty: ${questionDoc['difficulty']}",
          style: TextStyle(fontSize: 16),
        ),
        Text(
          "Tags: ${questionDoc['tags']}",
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
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
                  borderRadius: BorderRadius.circular(12), // Set border radius
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 0,
                      offset: Offset(0, 3),
                    ),
                  ], // Add shadow
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FutureBuilder<DocumentSnapshot>(
                    future: questionIds.isNotEmpty
                        ? getQuestionDocument(questionIds[currentQuestionIndex])
                        : null,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return buildQuizPage(snapshot.data!);
                      } else {
                        return Container(); // You can customize the loading/error state
                      }
                    },
                  ),
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
                          print("Current Question Index: $currentQuestionIndex");
                          currentQuestionIndex++;
                          if (currentQuestionIndex < questionIds.length - 1) {
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizSummary(
                                questionIds: questionIds,
                                userAnswers: userAnswers,
                              ),
                            ),
                          );
                        },
                        child: Text('Submit Questions'),
                      ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: questionIds.map((id) {
                    int index = questionIds.indexOf(id);
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
}

class QuizSummary extends StatelessWidget {
  final List<String> questionIds;
  final List<String> userAnswers;

  QuizSummary({
    required this.questionIds,
    required this.userAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz Summary"),
      ),
      body: ListView.builder(
        itemCount: questionIds.length,
        itemBuilder: (context, index) {
          String questionId = questionIds[index];
          String userAnswer = userAnswers[index];

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('questions').doc(questionId).get(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                DocumentSnapshot questionDoc = snapshot.data!;
                Map<String, dynamic> answerMap = questionDoc['answer'] ?? {};
                List<dynamic> correctAnswers = answerMap['correctAnswers'] ?? [];
                bool isCorrect = correctAnswers.contains(userAnswer);

                return ListTile(
                  title: Text(questionDoc['questionText']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Your Answer: $userAnswer"),
                      Text("Correct Answer: ${correctAnswers.join(', ')}"),
                      Text("Result: ${isCorrect ? 'Correct' : 'Incorrect'}"),
                    ],
                  ),
                );
              } else {
                return CircularProgressIndicator();
              }
            },
          );
        },
      ),
    );
  }
}






  // void displayMultipleChoiceQuestion(DocumentSnapshot questionDoc) {
  //   // Display details for the current question
  //   print("Details for Multiple Choice Question:");
  //   print("Question Text: ${questionDoc['questionText']}");
  //   print("Difficulty: ${questionDoc['difficulty']}");
  //   print("Tags: ${questionDoc['tags']}");

  //   Map<String, dynamic> answerMap = questionDoc['answer'] ?? {};
  //   List<dynamic> options = answerMap['options'] ?? [];
  //   List<dynamic> correctAnswers = answerMap['correctAnswers'] ?? [];

  //   print("Options: ${options.join(', ')}");

  //   print("Correct Answers List: $correctAnswers");

  //   List<String> correctAnswerList = correctAnswers.map<String>((index) {
  //     if (index is int && index >= 0 && index < options.length) {
  //       return options[index];
  //     } else {
  //       return "Invalid Correct Answer";
  //     }
  //   }).toList();

  //   print("Correct Answers: ${correctAnswerList.join(', ')}");

  //   // Build Quiz Page UI
  //   buildQuizPageUI(
  //     questionType: "Multiple Choice",
  //     questionText: questionDoc['questionText'],
  //     difficulty: questionDoc['difficulty'],
  //     tags: questionDoc['tags'],
  //     options: options,
  //     correctAnswers: correctAnswerList,
  //   );
  // }

  // void displayDragAndDropQuestion(DocumentSnapshot questionDoc) {
  //   // Display details for the current question
  //   print("Details for Drag and Drop Question:");
  //   print("Question Text: ${questionDoc['questionText']}");
  //   print("Difficulty: ${questionDoc['difficulty']}");
  //   print("Tags: ${questionDoc['tags']}");

  //   // Build Quiz Page UI
  //   buildQuizPageUI(
  //     questionType: "Drag and Drop",
  //     questionText: questionDoc['questionText'],
  //     difficulty: questionDoc['difficulty'],
  //     tags: questionDoc['tags'],
  //   );
  // }

  // void displayFillInTheBlankQuestion(DocumentSnapshot questionDoc) {
  //   // Display details for the current question
  //   print("Details for Fill in the Blank Question:");
  //   print("Question Text: ${questionDoc['questionText']}");
  //   print("Difficulty: ${questionDoc['difficulty']}");
  //   print("Tags: ${questionDoc['tags']}");

  //   // Build Quiz Page UI
  //   buildQuizPageUI(
  //     questionType: "Fill in the Blank",
  //     questionText: questionDoc['questionText'],
  //     difficulty: questionDoc['difficulty'],
  //     tags: questionDoc['tags'],
  //   );
  // }

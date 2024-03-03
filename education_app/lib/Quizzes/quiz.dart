import 'package:cloud_firestore/cloud_firestore.dart';

enum QuestionType {
  none, 
  multipleChoice, 
  fillInTheBlank,
  dragAndDrop,
}

String questionTypeToString(QuestionType type) {
  switch(type) {
    case QuestionType.multipleChoice: return "Multiple Choice";
    case QuestionType.fillInTheBlank: return "Fill in the Blank";
    case QuestionType.dragAndDrop: return "Drag & Drop";
    default: return "";
  }
}

// Base class for questions
// Question answers inherit from this
class QuestionAnswer {

  void debugPrint() {}

  Map<String, dynamic> toFirestore() { return {}; }
}

// Question specific values for Multiple Choice
class QuestionMultipleChoice extends QuestionAnswer {

  QuestionMultipleChoice({ required this.options, required this.correctAnswers });

  // Multiple choice have multiple options
  // and also a list of correct answers in case 1 or more is correct
  // Probably should detect if there is 1 or more and display UI accordingly
  List<String> options;
  List<int> correctAnswers;
  List<int> selectedOptions = [];

  @override
  void debugPrint() {
    print("Answers:");
    int idx = 0; 
    for (var i in options) {
      print("$idx. $i");
      idx++; 
    }

    String correctAnswersStr = "";
    for (var i in correctAnswers) {
      correctAnswersStr += "$i,";
    }
    print("Correct options: $correctAnswersStr");
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      "options": options, 
      "correctAnswers": correctAnswers
    };
  }

  factory QuestionMultipleChoice.fromMap(Map<String, dynamic> map) {
    return QuestionMultipleChoice(
        options: map["options"] is Iterable ? List.from(map["options"]) : List.empty(), 
        correctAnswers:  map["correctAnswers"] is Iterable ? List.from(map["correctAnswers"]) : List.empty()
      ); 
  }
}

class QuestionFillInTheBlank extends QuestionAnswer {
  QuestionFillInTheBlank({required this.correctAnswer, this.userResponse = ""});

  String correctAnswer;
  String userResponse;

  @override
  void debugPrint() {
    print("Correct Answer: $correctAnswer");
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      "correctAnswer": correctAnswer,
      "userResponse": userResponse,
    };
  }

  factory QuestionFillInTheBlank.fromMap(Map<String, dynamic> map) {
    return QuestionFillInTheBlank(
      correctAnswer: map["correctAnswer"] ?? "",
      userResponse: map["userResponse"] ?? "",
    );
  }
}


class DragAndDropQuestion extends QuestionAnswer {
  List<String> options;
  List<String> optionsText;
  List<String> correctOrder;

  DragAndDropQuestion({
    required this.options,
    required this.optionsText,
    required this.correctOrder,
  });

  @override
  Map<String, dynamic> toFirestore() {
    return {
      "answer": {
        "options": options,
        "optionsText": optionsText,
        "correctOrder": correctOrder,
      },
      ...super.toFirestore(),
    };
  }

  factory DragAndDropQuestion.fromMap(Map<String, dynamic> map) {
    final answer = map["answer"] as Map<String, dynamic>?;

    if (answer != null) {
      final options = (answer["options"] as List<dynamic>?)?.cast<String>() ?? [];
      final optionsText = (answer["optionsText"] as List<dynamic>?)?.cast<String>() ?? [];
      final correctOrder = (answer["correctOrder"] as List<dynamic>?)?.cast<String>() ?? [];

      return DragAndDropQuestion(
        options: options,
        optionsText: optionsText,
        correctOrder: correctOrder,
      );
    } else {
      // If the structure is different, try to extract directly
      final options = (map["options"] as List<dynamic>?)?.cast<String>() ?? [];
      final optionsText = (map["optionsText"] as List<dynamic>?)?.cast<String>() ?? [];
      final correctOrder = (map["correctOrder"] as List<dynamic>?)?.cast<String>() ?? [];

      return DragAndDropQuestion(
        options: options,
        optionsText: optionsText,
        correctOrder: correctOrder,
      );
    }
  }
}

Map<String, dynamic> checkUserAnswers(
  QuizQuestion question,
  String questionId,
  QuestionType currentType,
  Map<String, dynamic> userSummary,
) {
  if (currentType == QuestionType.multipleChoice) {
    if (question.answer is QuestionMultipleChoice) {
      return checkMultipleChoiceAnswer(
        question.answer as QuestionMultipleChoice,
        questionId,
        userSummary,
      );
    } else {
      print("Error: Incorrect question type for multiple-choice question.");
      return userSummary;
    }
  } else if (currentType == QuestionType.fillInTheBlank) {
    if (question.answer is QuestionFillInTheBlank) {
      return checkFillInTheBlankAnswer(
        question.answer as QuestionFillInTheBlank,
        questionId,
        userSummary,
      );
    } else {
      print("Error: Incorrect question type for fill-in-the-blank question.");
      return userSummary;
    }
  } else {
    // Handle other question types if needed
    return userSummary;
  }
}

Map<String, dynamic> checkMultipleChoiceAnswer(
  QuestionMultipleChoice question,
  String questionId,
  Map<String, dynamic> userSummary,
) {
  List<int> correctAnswers = question.correctAnswers;
  List<int> selectedOptions = question.selectedOptions;
  correctAnswers.sort();
  selectedOptions.sort();

  print("$selectedOptions");

  if (areListsEqual(correctAnswers, selectedOptions)) {
    userSummary[questionId] = {
      'correctIncorrect': 'Correct',
      'userResponse': question.selectedOptions,
      'correctAnswers': correctAnswers,
    };
  } else {
    // The user's answer is incorrect
    print("Incorrect! User selected the wrong options.");
    userSummary[questionId] = {
      'correctIncorrect': 'Incorrect',
      'userResponse': question.selectedOptions,
      'correctAnswers': correctAnswers,
    };
  }

  print("THIS IS THE USER SUMMARY IN checkMultipleChoiceAnswer: $userSummary");
  return userSummary;
}

Map<String, dynamic> checkFillInTheBlankAnswer(
  QuestionFillInTheBlank question,
  String questionId,
  Map<String, dynamic> userSummary,
) {
  // Get the correct answer for the question
  String correctAnswer = question.correctAnswer.toLowerCase();

  // Get the user's response
  String userResponse = question.userResponse.toLowerCase();

  // Check if the user's response matches the correct answer
  bool isCorrect = correctAnswer == userResponse;

  // Update the user summary
  userSummary[questionId] = {
    'correctIncorrect': isCorrect ? 'Correct' : 'Incorrect',
    'userResponse': userResponse,
    'correctAnswer': correctAnswer,
  };

  print("THIS IS THE USER SUMMARY IN checkFillInTheBlankAnswer: $userSummary");
  return userSummary;
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

class QuizQuestion {

  QuizQuestion();

  // This is the text displayed for the actual question
  String questionText = ""; 

  // This is the type of question. This determines how the question will be displayed/answered
  QuestionType type = QuestionType.none; 

  // Stores the difficulty of the question 
  int difficulty = 0; 

  // List of tags/topics for sorting
  List<String> tags = List.empty(growable: true);

  QuestionAnswer answer = QuestionAnswer();


  Map<String, dynamic> toFirestore() {
    return {
      "questionText": questionText, 
      "type": type.index,
      "difficulty": difficulty, 
      "answer": answer.toFirestore(),
      "tags": tags, 
    };
  }

  factory QuizQuestion.fromFirestore(  
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options) 
  {
    final data = snapshot.data(); 

    QuizQuestion question = QuizQuestion(); 

    if (data == null) {
      return question; 
    }
  
    question.questionText = data["questionText"];
    question.type = QuestionType.values[data["type"]];
    question.difficulty = data.containsKey("difficulty") ? data["difficulty"] : 0;
    question.tags = data["tags"] is Iterable ? List.from(data["tags"]) : List.empty();

    if (question.type == QuestionType.multipleChoice) {
      question.answer = QuestionMultipleChoice.fromMap(data["answer"]);
    } else if (question.type == QuestionType.fillInTheBlank) {
      question.answer = QuestionFillInTheBlank.fromMap(data["answer"]);
    } else if (question.type == QuestionType.dragAndDrop) {
      question.answer = DragAndDropQuestion.fromMap(data["answer"]);
    }

    return question; 
  }

  void debugPrint() {
    print("Question: $questionText \n${type.toString()}\n$difficulty");
    print("Tags: ${tags.toString()}");
    answer.debugPrint();
  }
}

// This is a quiz 
class Quiz { 

  Quiz();

  // Name/Id of the Quiz
  String name = ""; 

  // Quiz creator if any
  // Can be null
  String? creator;

  // The share code 
  // Can be null
  String? shareCode;

  // Quizzes can be tagged for specific topics
  List<String> tags = List.empty(growable: true);

  // Store a List of Ids to questions
  // These questions will be stored outside of the quiz
  List<String> questionIds = List.empty(growable: true); 


  // This is not stored in the database and is loaded later when the quiz starts 
  List<QuizQuestion> loadedQuestions = List.empty(growable: true);

  // Functions
  // I recommend using the getters instead of accessing the variables directly

  // Get the difficulty
  int getQuizDifficulty() {

    // Returns the average difficulty of all questions as a quiz difficulty

    if (loadedQuestions.isEmpty) {
      return 0;
    }

    int totalDifficulty = 0;
    for (var i in loadedQuestions) {
      totalDifficulty += i.difficulty;
    }

    totalDifficulty = totalDifficulty ~/ loadedQuestions.length;

    return totalDifficulty;
  }

  // Get the number of questions in the quiz
  int length() { 
    return questionIds.length;
  }

  // Returns a string for the name of the creator
  // or if its auto generated it returns "Auto-Generated"
  String getCreator() {
    return isQuizGenerated() ? "Auto-Generated" : creator!;
  }

  // This returns the sharecode if it exists 
  // If it does not exist it returns an empty string 
  String getShareCode() {
    return shareCode != null ? shareCode! : "";
  }

  // Get if the quiz is generated or is user created
  bool isQuizGenerated() {
    return creator == null ? true : false; 
  }

  // Firestore functions
  Map<String, dynamic> toFirestore() {
    return {
      "name": name, 
      "creator": creator, 
      "sharecode": shareCode,
      "tags": tags,
      "questionIds": questionIds, 
    };
  }

  factory Quiz.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    Quiz quiz = Quiz(); 
    if (data == null) {
      return quiz; 
    }

    quiz.name = data["name"];
    
    quiz.creator = data["creator"];
    quiz.shareCode = data["sharecode"];

    if (data.containsKey("tags")) {
      quiz.tags = List.from(data["tags"]);
    }

    if (data.containsKey("questionIds"))  {
      quiz.questionIds = List.from(data["questionIds"]);
    }

    return quiz; 
  }
}
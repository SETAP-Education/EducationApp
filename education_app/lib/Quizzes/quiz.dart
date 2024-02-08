import 'package:cloud_firestore/cloud_firestore.dart';

enum QuestionType {
  none, 
  multipleChoice,
  fillInTheBlank,
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

// Question specific values for Fill in the Blank Question Type
class QuestionFillInTheBlank extends QuestionAnswer {
  QuestionFillInTheBlank({ required this.correctAnswers, this.userResponse = "" });

  List<String> correctAnswers;
  String userResponse;

  @override
  void debugPrint() {
    print("Correct Answers:");
    for (String answer in correctAnswers) {
      print(answer);
    }
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      "correctAnswers": correctAnswers,
      "userResponse": userResponse,
    };
  }

  factory QuestionFillInTheBlank.fromMap(Map<String, dynamic> map) {
    return QuestionFillInTheBlank(
      correctAnswers: map["correctAnswers"] is Iterable ? List.from(map["correctAnswers"]) : List.empty(),
      userResponse: map["userResponse"] ?? "",
    );
  }
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
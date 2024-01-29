

enum QuestionType {
  none, 
  multipleChoice, 
}


class QuizQuestion {
  // This is the text displayed for the actual question
  String questionText = ""; 

  // This is the type of question. This determines how the question will be displayed/answered
  QuestionType type = QuestionType.none; 

  // Stores the difficulty of the question 
  int difficulty = 0; 

  dynamic answer;

  bool isCorrect(dynamic userAnswer) {
    return answer == userAnswer; 
  }
}



// This is a quiz 
class Quiz { 
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

}


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

  // Store a List of Ids to questions
  // These questions will be stored outside of the quiz
  List<String> questionIds = List.empty(growable: true); 

  // Get the difficulty
  int getQuizDifficulty() {

    // Returns the average difficulty of all questions as a quiz difficulty
    // TODO: Implement this

    return 0;
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

  // Functions
  // Get if the quiz is generated or is user created
  bool isQuizGenerated() {
    return creator == null ? true : false; 
  }
}
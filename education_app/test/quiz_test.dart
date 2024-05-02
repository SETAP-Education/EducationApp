import 'package:test/test.dart';
import 'package:education_app/Quizzes/quiz.dart';

void main() {
  group('areListsEqual', () {
    test('Lists with same elements in the same order should return true', () {
      List<dynamic> list1 = [1, 2, 3];
      List<dynamic> list2 = [1, 2, 3];


      bool result = areListsEqual(list1, list2);


      expect(result, true);
    });

    test('Lists with different elements should return false', () {
      List<dynamic> list1 = [1, 2, 3];
      List<dynamic> list2 = [1, 2, 4];

      // Act
      bool result = areListsEqual(list1, list2);


      expect(result, false);
    });

    test('Lists with different lengths should return false', () {

      List<dynamic> list1 = [1, 2, 3];
      List<dynamic> list2 = [1, 2]; // Different length
      bool result = areListsEqual(list1, list2);


      expect(result, false);
    });

    test('Empty lists should return true', () {
      List<dynamic> list1 = [];
      List<dynamic> list2 = [];
      bool result = areListsEqual(list1, list2);


      expect(result, true);
    });
  });
  group('question types', () {
    test('Test questionTypeToString make sure they return the correct values', () {
      expect(questionTypeToString(QuestionType.multipleChoice), 'Multiple Choice');
      expect(questionTypeToString(QuestionType.fillInTheBlank), 'Fill in the Blank');
      expect(questionTypeToString(QuestionType.dragAndDrop), 'Drag & Drop');
      expect(questionTypeToString(QuestionType.none), '');
    });
  });
    group('fill in the blank tests', () {
    test('Test QuestionFillInTheBlank.fromMap with a valid answer', () {
    Map<String, dynamic> validMap = {
      "correctAnswer": "true",
      "userResponse": "true",
    };
    var question = QuestionFillInTheBlank.fromMap(validMap);
    expect(question.correctAnswer, "true");
    expect(question.userResponse, "true");
  });
    test('Test QuestionFillInTheBlank.fromMap with no user answer', () {
      Map<String, dynamic> mapWithCorrectAnswerOnly = {
        "correctAnswer": "true",
      };
      var question = QuestionFillInTheBlank.fromMap(mapWithCorrectAnswerOnly);
      expect(question.correctAnswer, "true");
      expect(question.userResponse, "");
    });
    test('Test QuestionFillInTheBlank.fromMap with neither correctAnswer nor userResponse', () {
    Map<String, dynamic> mapWithNeither = {};
    var question = QuestionFillInTheBlank.fromMap(mapWithNeither);
    expect(question.correctAnswer, ""); // correctAnswer should default to empty string
    expect(question.userResponse, ""); // userResponse should default to empty string
  });
  });
}

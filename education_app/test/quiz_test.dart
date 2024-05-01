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

    test('Test questionTypeToString', () {
      expect(questionTypeToString(QuestionType.multipleChoice), 'Multiple Choice');
      expect(questionTypeToString(QuestionType.fillInTheBlank), 'Fill in the Blank');
      expect(questionTypeToString(QuestionType.dragAndDrop), 'Drag & Drop');
      expect(questionTypeToString(QuestionType.none), '');
    });
  test('Test QuestionFillInTheBlank.fromMap', () {
    // Test case 1: Valid map with values for correctAnswer and userResponse
    Map<String, dynamic> validMap = {
      "correctAnswer": "true",
      "userResponse": "true",
    };
    var question = QuestionFillInTheBlank.fromMap(validMap);
    expect(question.correctAnswer, "true");
    expect(question.userResponse, "true");
  });
    test('Test QuestionFillInTheBlank.fromMap', () {
      Map<String, dynamic> mapWithCorrectAnswerOnly = {
        "correctAnswer": "true",
      };
      var question = QuestionFillInTheBlank.fromMap(mapWithCorrectAnswerOnly);
      expect(question.correctAnswer, "true");
      expect(question.userResponse,
          ""); // userResponse should default to empty string
    });
    // Test case 4: Map with neither correctAnswer nor userResponse
    test('Test QuestionFillInTheBlank.fromMap', () {
    Map<String, dynamic> mapWithNeither = {};
    var question = QuestionFillInTheBlank.fromMap(mapWithNeither);
    expect(question.correctAnswer, ""); // correctAnswer should default to empty string
    expect(question.userResponse, ""); // userResponse should default to empty string
  });

}

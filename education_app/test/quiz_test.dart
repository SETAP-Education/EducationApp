import 'package:test/test.dart';
import 'package:education_app/Quizzes/quiz.dart';
void main() {
  group('areListsEqual', () {
    test('Lists with same elements in the same order should return true', () {
      // Arrange
      List<dynamic> list1 = [1, 2, 3];
      List<dynamic> list2 = [1, 2, 3];

      // Act
      bool result = areListsEqual(list1, list2);

      // Assert
      expect(result, true);
    });

    test('Lists with different elements should return false', () {
      // Arrange
      List<dynamic> list1 = [1, 2, 3];
      List<dynamic> list2 = [1, 2, 4]; // Different element at index 2

      // Act
      bool result = areListsEqual(list1, list2);

      // Assert
      expect(result, false);
    });

    test('Lists with different lengths should return false', () {
      // Arrange
      List<dynamic> list1 = [1, 2, 3];
      List<dynamic> list2 = [1, 2]; // Different length

      // Act
      bool result = areListsEqual(list1, list2);

      // Assert
      expect(result, false);
    });

    test('Empty lists should return true', () {
      // Arrange
      List<dynamic> list1 = [];
      List<dynamic> list2 = [];

      // Act
      bool result = areListsEqual(list1, list2);

      // Assert
      expect(result, true);
    });
  });

  group('getQuizDifficulty', () {
    test('Empty quiz should return 0 difficulty', () {
      // Arrange
      Quiz quiz = Quiz();

      // Act
      int difficulty = quiz.getQuizDifficulty();

      // Assert
      expect(difficulty, equals(0));
    });

    test('Quiz with questions should return average difficulty', () {
      // Arrange
      Quiz quiz = Quiz();
      quiz.loadedQuestions = [
        QuizQuestion()..difficulty = 1,
        QuizQuestion()..difficulty = 2,
        QuizQuestion()..difficulty = 3,
      ];

      // Act
      int difficulty = quiz.getQuizDifficulty();

      // Assert
      expect(difficulty, equals(2)); // Average of 1, 2, and 3 is 2
    });
  });
}

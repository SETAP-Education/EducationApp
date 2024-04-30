import 'package:test/test.dart';
import 'package:education_app/Quizzes/quiz.dart';
import 'package:education_app/Pages/QuizBuilder.dart';
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

  group('getQuizDifficulty', () {
    test('Empty quiz should return 0 difficulty', () {
      Quiz quiz = Quiz();
      int difficulty = quiz.getQuizDifficulty();


      expect(difficulty, equals(0));
    });

  });
}

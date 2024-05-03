import 'package:test/test.dart';
import 'package:education_app/Quizzes/quizManager.dart';

void main() {
  group('RecentQuiz', () {
    test('Initialization', () {
      RecentQuiz quiz = RecentQuiz();
      expect(quiz.id, '');
      expect(quiz.name, '');
      expect(quiz.xpEarned, 0);
    });
  });
  group('RecentQuiz', () {
    test('Constructor initializes properties correctly', () {
      RecentQuiz recentQuiz = RecentQuiz();

      expect(recentQuiz.id, "");
      expect(recentQuiz.name, "");
      expect(recentQuiz.xpEarned, 0);
    });

    test('Properties can be set correctly', () {
      RecentQuiz recentQuiz = RecentQuiz();
      recentQuiz.id = "123";
      recentQuiz.name = "Quiz 1";
      recentQuiz.xpEarned = 50;

      expect(recentQuiz.id, "123");
      expect(recentQuiz.name, "Quiz 1");
      expect(recentQuiz.xpEarned, 50);
    });
  });
}

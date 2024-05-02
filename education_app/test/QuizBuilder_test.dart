import 'package:education_app/Quizzes/quiz.dart';
import 'package:education_app/Quizzes/quizManager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:education_app/Pages/QuizBuilder.dart';

void main() {
  group('QuizBuilderState', () {
    test('Initialization', () {
      // Arrange
      final quizBuilderState = QuizBuilderState();

      expect(quizBuilderState.quizManager, isA<QuizManager>());
      expect(quizBuilderState.currentQuiz, isA<Quiz>());
      expect(quizBuilderState.questionsInQuiz, isEmpty);
    });

    test('Adding Quiz Question', () {

      final quizBuilderState = QuizBuilderState();
      final question = QuizQuestion();

      quizBuilderState.questionsInQuiz.add(question);

      expect(quizBuilderState.questionsInQuiz.length, 1);
      expect(quizBuilderState.questionsInQuiz[0].questionText, '');
    });
  });
}

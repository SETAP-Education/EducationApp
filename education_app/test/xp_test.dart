import 'package:flutter_test/flutter_test.dart';
import 'package:education_app/Quizzes/xpLogic.dart';

void setXp(int currentXp, int quizXp) {
  xp = currentXp + quizXp;
}


void main() {
  group('Test setXp function', () {
    test('Test setXp with positive quiz XP', () {
      // Arrange
      int initialXp = 100; // Initial XP
      int quizXp = 50; // XP gained from the quiz

      // Act
      setXp(initialXp, quizXp);

      // Assert
      expect(xp, equals(initialXp + quizXp)); // Assert XP is updated correctly
    });

    test('Test setXp with negative quiz XP', () {
      // Arrange
      int initialXp = 100; // Initial XP
      int quizXp = -30; // XP lost from the quiz

      // Act
      setXp(initialXp, quizXp);

      // Assert
      expect(xp, equals(initialXp + quizXp)); // Assert XP is updated correctly
    });

    test('Test setXp with zero quiz XP', () {
      // Arrange
      int initialXp = 100; // Initial XP
      int quizXp = 0; // No change in XP from the quiz

      // Act
      setXp(initialXp, quizXp);

      // Assert
      expect(xp, equals(initialXp + quizXp)); // Assert XP is updated correctly
    });

    // Add more test cases as needed to cover different scenarios
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart'; // Import Flutter material library if not already imported
import 'package:education_app/Quizzes/xpLogic.dart';

void main() {
  group('Test setXp function', () {
    testWidgets('Test setXp with positive quiz XP', (WidgetTester tester) async {
      int initialXp = xp; // Save initial XP
      int quizXp = 50;
      await tester.runAsync(() async {
        // Call setXp function with a mock BuildContext
        setXp(MockBuildContext(), quizXp);
      });
      expect(xp, equals(initialXp + quizXp)); // Assert XP is updated correctly
    });

    testWidgets('Test setXp with negative quiz XP', (WidgetTester tester) async {
      int initialXp = xp; // Save initial XP
      int quizXp = -30;
      await tester.runAsync(() async {
        // Call setXp function with a mock BuildContext
        setXp(MockBuildContext(), quizXp);
      });
      expect(xp, equals(initialXp + quizXp)); // Assert XP is updated correctly
    });

    testWidgets('Test setXp with zero quiz XP', (WidgetTester tester) async {
      int initialXp = xp; // Save initial XP
      int quizXp = 0;
      await tester.runAsync(() async {
        // Call setXp function with a mock BuildContext
        setXp(MockBuildContext(), quizXp);
      });
      expect(xp, equals(initialXp + quizXp)); // Assert XP is updated correctly
    });

    // Add more test cases as needed to cover different scenarios
  });
}

// Mock BuildContext class
class MockBuildContext extends BuildContext {  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
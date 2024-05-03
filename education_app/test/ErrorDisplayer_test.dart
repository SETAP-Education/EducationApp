import 'package:flutter_test/flutter_test.dart';
import 'package:education_app/Pages/AuthenticationPages/ErrorDisplayer.dart';

void main() {
  group('ErrorManager', () {
    test('pushError adds error to the list and notifies listeners', () {
      ErrorManager errorManager = ErrorManager();

      bool listenerCalled = false;
      errorManager.addListener(() {
        listenerCalled = true;
      });

      String errorMessage = 'Test error message';
      errorManager.pushError(errorMessage);

      expect(errorManager.errors, contains(errorMessage));

      expect(listenerCalled, true);
    });
  });
}

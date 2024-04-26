import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:education_app/Pages/AuthenticationPages/RegistrationPage.dart';


void main() {
  testWidgets('registration success', (WidgetTester tester) async {
    // Mock Firebase Auth and Firestore;
    final auth = MockFirebaseAuth();
    final firestore = FakeFirebaseFirestore();

    // Instantiate the RegistrationPage widget
    await tester.pumpWidget(MaterialApp(
      home: RegistrationPage(),
    ));

    // Fill the form with valid data
    await tester.enterText(find.byKey(Key('email_field')), 'test@example.com');
    await tester.enterText(find.byKey(Key('password_field')), 'password');
    await tester.enterText(find.byKey(Key('confirm_password_field')), 'password');

    // Trigger registration
    await tester.tap(find.byKey(Key('register_button')));
    await tester.pump();

    // Verify that the user was created
    await expectLater(find.text('Registration successful'), findsOneWidget);

    // Clean up
    await auth.signOut();
  });

  testWidgets('registration failure', (WidgetTester tester) async {
    // Mock Firebase Auth and Firestore
    final auth = MockFirebaseAuth();
    final firestore = FakeFirebaseFirestore();

    // Instantiate the RegistrationPage widget
    await tester.pumpWidget(MaterialApp(
      home: RegistrationPage(),
    ));

    // Fill the form with invalid data
    await tester.enterText(find.byKey(Key('email_field')), 'test@example.com');
    await tester.enterText(find.byKey(Key('password_field')), 'password');
    await tester.enterText(find.byKey(Key('confirm_password_field')), 'wrong_password');

    // Trigger registration
    await tester.tap(find.byKey(Key('register_button')));
    await tester.pump();

    // Verify that an error message is displayed
    await expectLater(find.text('Password mismatch between password and confirm password'), findsOneWidget);

    // Clean up
    await auth.signOut();
  });
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:education_app/Pages/AuthenticationPages/DisplayNamePage.dart';


//this test does actually pass but the page it takes you to means the test cant end itself so a timeout
//has been put in to force it to stop as the test passes but cannot sign out
void main() {
  testWidgets('DisplayName success', (WidgetTester tester) async {
    // Mock Firebase Auth and Firestore
    final auth = MockFirebaseAuth();
    final firestore = FakeFirebaseFirestore();

    // Initialize Firebase (if needed)
    await Firebase.initializeApp();

    // Instantiate the RegistrationPage widget
    await tester.pumpWidget(MaterialApp(
      home: DisplayUser(),
    ));

    // Fill the form with invalid data
    await tester.enterText(find.byKey(Key('DisplayName_field')), '');
    await tester.tap(find.byKey(Key('Math, programming, database, networks')));
    await tester.pump(); // This ensures that the widget tree is rebuilt after the button press


    // Trigger registration
    await tester.tap(find.byKey(Key('Continue')));
    await tester.pump(); // Wait for UI to update after tapping

    // Verify that an error message is displayed
    expect(find.text('display name cannot be empty'), findsOneWidget);

    // Clean up
    await auth.signOut();
  }, timeout: Timeout(Duration(seconds: 30))); // Set a timeout for the test
}
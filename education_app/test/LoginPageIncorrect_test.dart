import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:education_app/Pages/AuthenticationPages/LoginPage.dart';


//this test does actually pass but the page it takes you to means the test cant end itself so a timeout
//has been put in to force it to stop as the test passes but cannot sign out
main() {
  testWidgets('Login Failed', (WidgetTester tester) async {
    //Mock Firebase Auth and Firestore
    final auth = MockFirebaseAuth();
    final firestore = FakeFirebaseFirestore();

    //Initialize Firebase (if needed)
    await Firebase.initializeApp();

//Instantiate the RegistrationPage widget
    await tester.pumpWidget(MaterialApp(
      home: LoginPage(),
    ));

// Fill the form with valid data
    await tester.enterText(find.byKey(Key('email_field')), 'test@example.com');
    await tester.enterText(find.byKey(Key('password_field')), 'password29');

// Trigger registration
    await tester.tap(find.byKey(Key('login_button')));
    await tester.pump(); // Wait for UI to update after tapping

// Verify that the user was created
    expect(find.text('login successful'), findsOneWidget);


    await tester.tap(find.byKey(Key('log_out')));
    //Clean up
    await auth.signOut();
  }, timeout: Timeout(
      Duration(seconds: 10)));
}
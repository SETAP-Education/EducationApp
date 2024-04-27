import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education_app/Theme/AppTheme.dart';
import 'package:education_app/Pages/SplashPage.dart';
import 'package:flutter/material.dart';
import 'package:education_app/Widgets/Button.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:education_app/Pages/AuthenticationPages/DisplayNamePage.dart';
import 'package:education_app/Theme/AppTheme.dart';

import 'package:education_app/Pages/QuizPages/QuizPage.dart';
import 'package:education_app/Quizzes/quizManager.dart';
import 'package:education_app/Pages/LandingPage.dart';
import 'package:education_app/Pages/AuthenticationPages/ErrorDisplayer.dart';

class SettingsPage extends StatefulWidget {

  SettingsPage({ super.key });

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppTheme.buildAppBar(context, 'Settings page', false, true, "Settings", Text('')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Button(
                important: false,
                width: 450,
                onClick: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsDisplayUser(),
                    ),
                  );
                },
                child: Text('Change display name/ interests', style: GoogleFonts.nunito(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 20),
              Button(
                important: true,
                width: 450,
                onClick: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SplashPage(),
                    ),
                  );
                },
                child: Text('Sign out', style: GoogleFonts.nunito(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        )
    );
  }

}

class SettingsDisplayUser extends StatefulWidget {
  @override
  _SettingsDisplayUserState createState() => _SettingsDisplayUserState();
}

class _SettingsDisplayUserState extends State<SettingsDisplayUser> {
  final TextEditingController _nameController = TextEditingController();
  User? _user;
  List<String> _selectedInterests = [];
  List<String> _interestsList = [];
  String _displayName = '';
  QuizManager quizManager = QuizManager();

  @override
  void initState() {
    super.initState();
    _checkAuthState();
    _fetchInterests();
    _fetchUserData();
  }

  void _checkAuthState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _user = user;
          _fetchUserData(); // Fetch user data when the user changes
        });
      }
    });
  }

  void _fetchInterests() async {
    try {
      DocumentSnapshot interestsDoc = await FirebaseFirestore.instance
          .collection('interests')
          .doc('interests')
          .get();

      if (interestsDoc.exists) {
        setState(() {
          _interestsList = List<String>.from(interestsDoc['interests']);
        });
      }
    } catch (error) {
      print('Failed to fetch interests: $error');
    }
  }

  void _fetchUserData() async {
    if (_user != null) {
      try {
        DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();

        if (userDoc.exists) {
          setState(() {
            _displayName = userDoc.get('displayName') ?? '';
            _selectedInterests = List<String>.from(userDoc.get('interests') ?? []);
            _nameController.text = _displayName; // Set the display name in the text field
          });
        }
      } catch (error) {
        print('Failed to fetch user data: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTheme.buildAppBar(context, 'Display name settings page', false, true, "Settings", Text('')),
      body: Stack(
        children: [
          SingleChildScrollView(
              child: Center(
                  child: Container(
                    width: 600,
                    padding: EdgeInsets.all(8),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text("Hello again!! ",
                                        style: GoogleFonts.nunito(
                                            fontSize: 38,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.italic)),
                                    Text(
                                      "👋",
                                      style: TextStyle(fontSize: 38),
                                    )
                                  ],
                                ),
                                Text("What should we call you?",
                                    style: GoogleFonts.nunito(
                                        fontSize: 26, fontWeight: FontWeight.w600))
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: Container(
                              width: 600,
                              child: TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Display Name',
                                  contentPadding:
                                  EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).textTheme.bodyMedium!.color!),
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).textTheme.bodyMedium!.color!),
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                                style: GoogleFonts.nunito(fontSize: 20.0),
                                cursorColor: Theme.of(context).textTheme.bodyMedium!.color!,
                                onChanged: (value) {
                                  _displayName = value;
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          Text(
                            'What do you wanna learn?',
                            style: GoogleFonts.nunito(
                              fontSize: 26.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          // Text(
                          //   'psst. Don\'t worry you can still access the others later!',
                          //   style: GoogleFonts.nunito(
                          //     fontSize: 16.0,
                          //     fontWeight: FontWeight.w600,
                          //     fontStyle: FontStyle.italic,
                          //   ),
                          // ),
                          SizedBox(height: 16),
                          SizedBox(
                            width: 400,
                            child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                              ),
                              shrinkWrap: true,
                              itemCount: _interestsList.length,
                              itemBuilder: (context, index) {
                                final interest = _interestsList[index];
                                return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                        splashColor: !_selectedInterests.contains(interest)
                                            ? Color(0xFF19c37d)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(24),
                                        onTap: () {
                                          setState(() {
                                            if (_selectedInterests.contains(interest)) {
                                              _selectedInterests.remove(interest);
                                            } else {
                                              _selectedInterests.add(interest);
                                            }
                                          });
                                        },
                                        child: Ink(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: _selectedInterests.contains(interest) ? Color(0xFFF45B69).withOpacity(0.5) : Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(32),
                                          ),
                                          child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [

                                                Container(

                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context).scaffoldBackgroundColor,
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Image.asset("assets/images/${interest.toLowerCase()}.png", color: Theme.of(context).colorScheme.primary, width: 48, height: 48)
                                                ),

                                                SizedBox(height: 8.0),
                                                Text(
                                                  interest,
                                                  style: GoogleFonts.nunito(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context).colorScheme.primary,
                                                  ),
                                                ),
                                              ]
                                          ),
                                        )));
                              },
                            ),
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: Button(
                              width: 400,
                              important: true,
                              onClick: () {
                                // Get the entered display name
                                String displayName = _nameController.text.trim();

                                // Check if display name or interests are empty
                                if (displayName.isEmpty) {
                                  // Add an error message to the error manager
                                  print("No display name");
                                  globalErrorManager.pushError('Display name cannot be empty');
                                } else if (_selectedInterests.isEmpty) {
                                  // Add an error message to the error manager
                                  print("No interests");
                                  globalErrorManager.pushError('You must select at least one interest');
                                } else {
                                  // If there are no errors, proceed with setting the display name and interests
                                  _setDisplayName(_user!.uid, displayName);
                                  _saveInterests(_user!.uid, _selectedInterests);
                                  // Navigate to the landing page
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => LandingPage()));
                                }
                              },
                              child: Text('Save details',
                                  style: GoogleFonts.nunito(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          SizedBox(height: 20),

                        ]),

                    // Add ErrorDisplayer widget to display error messages

                  ))),
          ErrorDisplayer(),
        ],
      ),
    );
  }

  void _setDisplayName(String userId, String displayName) {
    final users = FirebaseFirestore.instance.collection('users');

    // Setting the display name for the user
    users.doc(userId).set({
      'displayName': displayName,
    }, SetOptions(merge: true)).then((_) {
      print('Display Name set successfully!');
    }).catchError((error) {
      print('Failed to set Display Name: $error');
    });
  }

  void _saveInterests(String userId, List<String> interests) {
    final users = FirebaseFirestore.instance.collection('users');

    // Saving the interests for the user
    users.doc(userId).set({
      'interests': interests,
    }, SetOptions(merge: true)).then((_) {
      print('Interests saved successfully!');
    }).catchError((error) {
      print('Failed to save Interests: $error');
    });
  }

  void pushDiagnostic(List<String> interests) async {

    // TODO: This does nothing...
    if (await quizManager.hasUserDoneDiagnostic(_user!.uid)) {

      print("User has done diagnostic");

      // If the user has done the diagnostic push them to home
      // I think we should make a settings page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LandingPage()),
      );

      return;
    }

    final users = FirebaseFirestore.instance.collection('users');
    users.doc(_user!.uid).update({ "doneDiagnostic": true });

    String quizId = await quizManager.generateQuiz(_selectedInterests, 15, 60, 8, name: "Diagnostic Test");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => QuizPage(quizId: quizId, multiplier: 1.0)),
    );


  }
}
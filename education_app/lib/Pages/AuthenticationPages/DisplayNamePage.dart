import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education_app/Widgets/Button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:education_app/Pages/AuthenticationPages/LoginPage.dart';
import 'package:education_app/Pages/LandingPage.dart';
import 'package:google_fonts/google_fonts.dart';

class DisplayUser extends StatefulWidget {
  @override
  _DisplayUser createState() => _DisplayUser();
}

class _DisplayUser extends State<DisplayUser> {
  final TextEditingController _nameController = TextEditingController();
  User? _user;
  List<String> _selectedInterests = [];
  List<String> _interestsList = [];

  @override
  void initState() {
    super.initState();
    _checkAuthState();
    _fetchInterests();
  }

  void _checkAuthState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _user = user; // Set the current user
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

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: () async {
            // Sign out the user
            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
        ),
      ],
    ),
    // On devices where it doesn't all fit. It scrolls 
    body: SingleChildScrollView(child: Center(
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
                      Text("Hey There!! ", style: GoogleFonts.nunito(fontSize: 38, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                      Text("👋", style: TextStyle(fontSize:  38 ),)
                  ]),
                  Text("What should we call you?",  style: GoogleFonts.nunito(fontSize: 26, fontWeight: FontWeight.w600))
                ],
              )
            ),
            SizedBox(height: 20),
            Center(
              child: Container(
                width: 600,
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    
                    labelText: 'Display Name',
                    hintText: _user?.displayName,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).textTheme.bodyMedium!.color!),
                      borderRadius: BorderRadius.circular(30.0),
                    )),
                    style: GoogleFonts.nunito(
                      fontSize: 20.0,
                    ),
                    cursorColor: Theme.of(context).textTheme.bodyMedium!.color!,
                    onEditingComplete: () {},
                  
                ),
              ),
            ),
            SizedBox(height: 30),
            Text(
              'What do you wanna learn?',
              style: GoogleFonts.nunito(
                fontSize: 26.0,
                fontWeight: FontWeight.w600
              ),
            ),
            Text(
              'psst. Don\'t worry you can still access the others later!',
              style: GoogleFonts.nunito(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: 400,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _interestsList.length,
                
                itemBuilder: (context, index) {
                  final interest = _interestsList[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
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
                        height: 94,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _selectedInterests.contains(interest)
                              ? Color(0xFF19c37d)

                              : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: Text(
                            interest,

                            style: GoogleFonts.nunito(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold,
                              color: _selectedInterests.contains(interest)
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    )
                  );
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

                    if (displayName.isNotEmpty) {
                      // Set the display name in Firebase database
                      _setDisplayName(_user!.uid, displayName);

                      // Save selected interests to Firestore
                      _saveInterests(_user!.uid, _selectedInterests);

                      // Navigate to the landing page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LandingPage()),
                      );
                    } else {
                      // Show an error message or handle empty display name
                      print('Display name cannot be empty');
                    }
                  },
                  child: Text('Let\'s go!',
                      style: GoogleFonts.nunito(
                          color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              )),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Get the entered display name
                    String displayName = _nameController.text.trim();

                    if (displayName.isNotEmpty) {
                      // Set the display name in Firebase database
                      _setDisplayName(_user!.uid, displayName);

                      // Save selected interests to Firestore
                      _saveInterests(_user!.uid, _selectedInterests);

                      // Navigate to the landing page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LandingPage()),
                      );
                    } else {
                      // Show an error message or handle empty display name
                      print('Display name cannot be empty');
                    }
                  },
                  child: Text('Continue',
                      style: GoogleFonts.nunito(
                          color: Colors.black, fontSize: 17)),
                ),
              )
            ],
          ),
        ),
      ),
    ),
  );
}




  void _setDisplayName(String userId, String displayName) {
    final users = FirebaseFirestore.instance.collection('users');

    // Setting the display name for the user
    users.doc(userId).set({
      'displayName': displayName,
      'xpLvl': 0,
      'darkMode': true,
    }).then((_) {
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
}

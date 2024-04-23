import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:education_app/Pages/AuthenticationPages/LoginPage.dart';
import 'package:education_app/Pages/LandingPage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class DisplayUser extends StatefulWidget {
  @override
  _DisplayUser createState() => _DisplayUser();
}

class _DisplayUser extends State<DisplayUser> {
  final TextEditingController _nameController = TextEditingController();
  User? _user;
  List<String> _selectedInterests = [];
  List<String> _interestsList = [];

  bool _showError = false;
  Timer? _timer;
  bool _errorMessageVisible = false;

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
      body: Center(
        child: Container(
          width: 600,
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  'Hey there! What should we call you?',
                  style: TextStyle(fontSize: 20),
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
                      hintText: _user?.displayName,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: secondaryColour),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: secondaryColour),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      labelStyle: TextStyle(color: secondaryColour),
                    ),
                    style: GoogleFonts.nunito(
                      fontSize: 20.0,
                    ),
                    cursorColor: secondaryColour,
                    onEditingComplete: () {},
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Interests',
                style: GoogleFonts.nunito(
                  fontSize: 20.0,
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: 300,
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: _interestsList.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 1,
                  ),
                  itemBuilder: (context, index) {
                    final interest = _interestsList[index];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (_selectedInterests.contains(interest)) {
                            _selectedInterests.remove(interest);
                          } else {
                            _selectedInterests.add(interest);
                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _selectedInterests.contains(interest)
                              ? Color(0xFF19c37d)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            interest,
                            style: TextStyle(
                              color: _selectedInterests.contains(interest)
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
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
                      setState(() {
                        _showError = true;
                        _errorMessageVisible = true;
                      });
                      // Show an error message or handle empty display name
                      print('Display name cannot be empty');
                    }
                  },
                  child: Text('Continue',
                      style: GoogleFonts.nunito(
                          color: Colors.black, fontSize: 17)),
                ),
              ),
              _showError ? _buildErrorMessage('Display name cannot be empty') : Container(),
            ],
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
      'xpLvl': 0
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

  Widget _buildErrorMessage(errorMessage) {
    return errorMessage != null && _errorMessageVisible == true // Check if errorMessage is not null and _errorMessageVisible is true
        ? Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.red,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _errorMessageVisible = false;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        : Container(); // Empty container when error message is null or _errorMessageVisible is false
  }

}


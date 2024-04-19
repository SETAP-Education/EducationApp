import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education_app/Pages/LandingPage.dart';
import 'package:education_app/Pages/AuthenticationPages/LoginPage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../SplashPage.dart';

// Basic color scheme - will come up with one on Friday with Max
Color primaryColour = Colors.white;
Color secondaryColour = Colors.black;

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  bool _showPassword = false;
  bool _error = false;
  List<String> _errorMessages = [];
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer if it's not null
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: primaryColour,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 400,
                height: 400,
                // decoration: BoxDecoration(
                //   border: Border.all(color: Colors.black),
                //   borderRadius: BorderRadius.circular(15),
                // ),
                child: Center(
                  child: Image.asset(
                    'images/quiz_app_logo_2.png', // Change to your image asset path
                    width: 400, // Adjust as needed
                    height: 400, // Adjust as needed
                  ),
                ),
              ),
              SizedBox(width: 40),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    child: Text(
                      'Registration',
                      style: GoogleFonts.nunito(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                        color: secondaryColour,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  SizedBox(
                    width: 450, // Set the desired width
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                      onEditingComplete: () {
                        _validateEmail(_emailController.text);
                      },
                    ),
                  ),
                  SizedBox(height: 20.0),
                  // Password text field
                  SizedBox(
                    width: 450,
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: !_showPassword, // Correct placement of obscureText
                      decoration: InputDecoration(
                        labelText: 'Password',
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: secondaryColour),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: secondaryColour),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(right: 8.0), // Adjust the padding as needed
                          child: IconButton(
                            icon: Icon(
                              _showPassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            color: secondaryColour,
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                          ),
                        ),
                        labelStyle: TextStyle(color: secondaryColour),
                      ),
                      style: GoogleFonts.nunito(
                        fontSize: 20.0,
                      ),
                      cursorColor: secondaryColour,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          setState(() {
                            _error = true;
                            _errorMessages.insert(0, "Please enter a password");
                          });
                        }
                        return null;
                      },
                      onEditingComplete: () {
                        _register();
                      },
                    ),
                  ),
                  SizedBox(height: 20.0),
                  // Register button
                  ElevatedButton(
                    onPressed: () {
                      _register();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: Text('Register', style: GoogleFonts.nunito(color: Colors.black, fontSize: 20)),
                  ),
                  SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: GoogleFonts.nunito(color: Colors.black, fontSize: 17.0),
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              _createRoute(LoginPage()),
                            );
                          },
                          child: Text(
                            'Log in',
                            style: TextStyle(
                              color: Color(0xFF19c37d),
                              fontSize: 17.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(List<String> errorMessages) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    if (_error) {
      return Positioned(
        top: screenHeight * 0.01,
        left: screenWidth * 0.15,
        right: screenWidth * 0.15,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent, // Set background color to transparent
          ),
          child: ListView.separated(
            physics: NeverScrollableScrollPhysics(), // Disable scrolling of the ListView
            shrinkWrap: true,
            itemCount: errorMessages.length,
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(height: 8); // Add a gap of 8 between error messages
            },
            itemBuilder: (context, index) {
              if (index >= errorMessages.length) {
                return Container(); // Return an empty container if index is out of range
              }

              _timer = Timer(Duration(seconds: 10), () {
                setState(() {
                  if (errorMessages.length > index) {
                    errorMessages.removeAt(index);
                    _error = errorMessages.isNotEmpty;
                  }
                });
              });

              Color messageColor = Colors.red; // Default color for error messages

                            // Check for different types of error messages and assign colors accordingly

              return Container(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: messageColor, // Assign color based on message type
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          errorMessages[index],
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          errorMessages.removeAt(index);
                          _error = errorMessages.isNotEmpty;
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
              );
            },
          ),
        ),
      );
    } else {
      return Container(); // Empty container when error message is hidden
    }
  }

  Future<void> _register() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      User? user = userCredential.user;

      if (user != null) {
        await _createDatabase(user.uid, _emailController.text, "a"); // REPLACE "a" WITH displayName once that page has been has been implemented
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LandingPage()),
        );
      }
    } catch (e) {
      setState(() {
        _error = true;
        _errorMessages.insert(0, "Please ensure all of your registration details are correct.");
      });
    }
  }

  void _validateEmail(String value) {
    if (_formKey.currentState!.validate()) {
      if (value.isEmpty) {
        setState(() {
          _error = true;
          print("You have an email valid error.");
        });
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        setState(() {
          _error = true;
        });
      } else {
        setState(() {
          _error = false; // Reset error state
        });
      }
    }
  }

  Future<void> _createDatabase(String uid, String email, String displayName) async {
    try {
      // Reference to the "users" collection
      CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

      // Reference to the user document under "users" collection
      DocumentReference userDocument = usersCollection.doc(uid);

      // Add user information to the user document
      await userDocument.set({
        'uid': uid,
        'email': email,
        'displayName': displayName,
      });

      // Create subcollections
      await _createSubcollections(userDocument);

      print('Database creation successful');
    } catch (e) {
      print('Database creation failed: $e');
      // Handle the error accordingly
    }
  }

  Future<void> _createSubcollections(DocumentReference userDocument) async {
    try {
      // Add a subcollection under the user document for quizzes
      // CollectionReference quizzesCollection = userDocument.collection('quizzes');

      // Add a subcollection under the user document for quiz history
      // CollectionReference quizHistoryCollection = userDocument.collection('quizHistory');

      // You can add more subcollections or additional logic as needed

      print('Subcollections creation successful');
    } catch (e) {
      print('Subcollections creation failed: $e');
      // Handle the error accordingly
    }
  }
}

Route _createRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child;
    },
  );
}


import 'package:education_app/Pages/LandingPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:education_app/Pages/AuthenticationPages/RegistrationPage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:education_app/Pages/AuthenticationPages/DisplayNamePage.dart';

// basic colour scheme - will come up with one on friday with max
Color primaryColour = Colors.white;
Color secondaryColour = Colors.black;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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
    return PopScope(
      canPop: false, //When false, blocks the current route from being popped
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: primaryColour,
              ),
              child: Center(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Container(
                      width: constraints.maxWidth < 500 ? null : 500,
                      padding: EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: primaryColour,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: _buildLoginForm(),
                    );
                  },
                ),
              ),
            ),
            if (_error) _buildErrorMessage(_errorMessages),
          ],
        ),
      )
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 600, // Set the desired width
              child: Text(
                'User Login',
                style: GoogleFonts.nunito(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: secondaryColour,
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            SizedBox(
              width: 600, // Set the desired width
              child: TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email',
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
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     if (mounted) {
                //       setState(() {
                //         _error = true;
                //         _errorMessages.insert(0, "Please ensure all fields are filled out");
                //       });
                //     }
                //   } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                //     if (mounted) {
                //       setState(() {
                //         _error = true;
                //         _errorMessages.insert(0, "Please enter a valid Email");
                //       });
                //     }
                //   }
                //   return null;
                // },
                onEditingComplete: () {
                  _validateEmail(_emailController.text);
                },
              ),
            ),
            const SizedBox(height: 20.0),
            // password textfield
            SizedBox(
              width: 600,
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
                      _errorMessages.insert(0, "Please enter your password");
                    });
                  }
                  return null;
                },
                onEditingComplete: () {
                  _login();
                },
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                 onTap: () async {
                   final email = _emailController.text.trim();
                    if (email.isNotEmpty) {
                      try {
                        var user = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
                        if (user.isNotEmpty) {
                          await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                          setState(() {
                            _error = true;
                            _errorMessages.insert(0, "Password reset email sent to $email real");
                          });
                        } else {
                          setState(() {
                            _error = true;
                            _errorMessages.insert(0, "Password reset email sent to $email not real");
                          });
                        }
                      } catch (e) {
                        print('Error: $e');
                      }
                    } else {
                      setState(() {
                        _error = true;
                        _errorMessages.insert(0, "Please enter an email");
                      });
                    }
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Color(0xFF19c37d),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10,),
            // login button
            ElevatedButton(
              onPressed: () {
                _login();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text('Log in', style: GoogleFonts.nunito(color: Colors.black, fontSize: 17)
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DisplayUser(),
                  ),
                );
              },
              child: Text('Bypass', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF19c37d),
              ),
            ),
            const SizedBox(height: 20.0),
            // sign up text and button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Don\'t have an account? ',
                  style: GoogleFonts.nunito(color: Colors.black, fontSize: 17.0),
                ),
                // when user hovers over the sign up text, cursor changes
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegistrationPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Sign up',
                      style: GoogleFonts.nunito(
                        color: Color(0xFF19c37d),
                        fontSize: 17.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
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
              if (errorMessages[index].contains('Password reset email sent to')) {
                messageColor = Color(0xFF19c37d); // Change color for successful message
              }

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

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (userCredential.user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LandingPage()),
          );
        }
      } catch (e) {
        setState(() {
          _error = true;
          _errorMessages.insert(0, "Please ensure all of your login details are correct.");
        });
      }
    }
  }
}

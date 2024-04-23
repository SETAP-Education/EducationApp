import 'package:education_app/Pages/AuthenticationPages/AuthPageForm.dart';
import 'package:education_app/Pages/AuthenticationPages/ErrorDisplayer.dart';
import 'package:education_app/Pages/LandingPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:education_app/Pages/AuthenticationPages/RegistrationPage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../SplashPage.dart';
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


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, //When false, blocks the current route from being popped
      child: Scaffold(
        body: AuthPageForm(child: _buildLoginForm())
      ),
    );
  }


  Widget _buildLoginForm() {
    return Form( 
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            child: Text(
              'Login',
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
          const SizedBox(height: 20.0),
          // password textfield
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
                  globalErrorManager.pushError("Please enter your password");
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
                       
                        globalErrorManager.pushError("Password reset email sent to $email real");
                          
                       
                      } else {

                        globalErrorManager.pushError("Password reset email sent to $email not real");
                        
                      }
                    } catch (e) {
                      print('Error: $e');
                    }
                  } else {
                     globalErrorManager.pushError("Please enter an email");
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
            child: Text('Log in', style: GoogleFonts.nunito(color: Colors.black, fontSize: 20)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LandingPage(),
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
                      _createRoute(RegistrationPage()),
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
        ]
    )
    );

  }

  void _validateEmail(String value) {
    if (_formKey.currentState!.validate()) {
      if (value.isEmpty) {
        globalErrorManager.pushError("Please enter an email address");
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        globalErrorManager.pushError("Email is not in valid format");
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
        globalErrorManager.pushError("Please insure your login details are correct");
      }
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
import 'package:education_app/Pages/AuthenticationPages/AuthPageForm.dart';
import 'package:education_app/Pages/AuthenticationPages/ErrorDisplayer.dart';
import 'package:education_app/Widgets/Button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:education_app/Pages/AuthenticationPages/LoginPage.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:education_app/Pages/AuthenticationPages/DisplayNamePage.dart';
import 'package:education_app/Theme/AppTheme.dart';
import 'dart:async';
import 'package:education_app/Pages/LandingPage.dart';

// Basic color scheme - will come up with one on Friday with Max
Color primaryColour = Colors.white;

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
   final TextEditingController _confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final int minCharacters = 8; 

  bool _showPassword = false; 
  bool _showConfirmPassword = false; 

  void _checkAuthState() async {

    User? firebaseUser = await FirebaseAuth.instance.authStateChanges().first;
    
    if (firebaseUser != null) {
      print("User signed in");
      Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) {
        return LandingPage();
      },));
    }
    else {
      print("User not signed in");
    }
  }

  @override 
  void initState() {
    super.initState();

    _checkAuthState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, //When false, blocks the current route from being popped
      child: Scaffold(
        appBar: AppTheme.buildAppBar(context, 'Quiz App', false, false, "Welcome to our quiz app", Text('')),
        body: AuthPageForm(child: _buildRegistrationForm())
      )
    );
  }

  Widget _buildRegistrationForm() {

    Color? textColour = Theme.of(context).textTheme.bodyMedium!.color;

    return Form(
      key: _formKey,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'User Registration',
                style: GoogleFonts.nunito(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: textColour,
                ),
              ),
            
            const SizedBox(height: 10.0),
            SizedBox(
              width: 450,
              child: TextField(
                
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email',
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: textColour!),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: textColour!),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      labelStyle: TextStyle(color: textColour),
                    ),
                    
                style: GoogleFonts.nunito(
                  fontSize: 20.0,
                ),
              ),
            ),
            SizedBox(height: 20.0),
            // Password text field
            SizedBox(
              width: 450,
              child: TextField(
                controller: _passwordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(labelText: 'Password',
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: textColour),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: textColour),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  labelStyle: TextStyle(color: textColour),
                  suffixIcon: Padding(
                    padding: EdgeInsets.only(right: 8.0), // Adjust the padding as needed
                    child: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      color: textColour,
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                  )
                ),
                style: GoogleFonts.nunito(
                  fontSize: 20.0,
                ),

                onChanged: (value) {
                  // This is hacky...
                  // Set the state so it recalcs the password requirements
                  setState(() {
                    
                  });
                },
              ),
            ),

            SizedBox(height: 10.0),

            _passwordRequirements(_passwordController.text),

            SizedBox(height: 10.0),

            SizedBox(
              width: 450,
              child: TextField(
                controller: _confirmPasswordController,
                obscureText: !_showConfirmPassword,
                decoration: InputDecoration(labelText: 'Confirm Password',
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: textColour),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: textColour),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  labelStyle: TextStyle(color: textColour),
                  suffixIcon: Padding(
                    padding: EdgeInsets.only(right: 8.0), // Adjust the padding as needed
                    child: IconButton(
                      icon: Icon(
                        _showConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      color: textColour,
                      onPressed: () {
                        setState(() {
                          _showConfirmPassword = !_showConfirmPassword;
                        });
                      },
                    ),
                  )
                ),
                style: GoogleFonts.nunito(
                  fontSize: 20.0,
                ),

                onChanged: (value) {
                  
                },
              ),
            ),

            SizedBox(height: 20.0),
            // Register button
            Button(
              important: true,
              width: 450,
              onClick: () {
                _register();
              },
           
              child: Text('Register', style: GoogleFonts.nunito(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: GoogleFonts.nunito(fontSize: 17.0),
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
            ),
          ],
        )
      );
  }


  Future<void> _register() async {
    try {

      bool noEmail = _emailController.text.length == 0;
      bool satisfysMinCharacters = _passwordController.text.length >= minCharacters;
      bool hasOneNumber = _passwordController.text.contains(RegExp(r'[0-9]'));

      if (noEmail) {
        // Password does not satisfy constraints 

        globalErrorManager.pushError("You must enter a valid email");

        // Break out
        return; 
      }

      if (!satisfysMinCharacters || !hasOneNumber) {
        // Password does not satisfy constraints 

        globalErrorManager.pushError("Password does not satisfy requirements");

        // Break out
        return; 
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        globalErrorManager.pushError("Password mismatch between password and confirm password");
        return; 
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      User? user = userCredential.user;

      if (user != null) {
        await _createDatabase();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DisplayUser()),
        );
      }
    } catch (e) {
      print("Registration failed: $e");
      globalErrorManager.pushError("Registration Failed please try again");
    }
  }

  Future<void> _createDatabase() async {
    // Database creation logic...
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }

  Widget _buildPasswordRequirement(String text, bool satisfied) {
    return Row(
      children: [
        satisfied ? Icon(Icons.done, color: Colors.green,) : Icon(Icons.close, color: Colors.red),
        const SizedBox(width: 8.0),
        Text(text, style: GoogleFonts.nunito(color: satisfied ? Colors.grey : Theme.of(context).textTheme.bodyMedium!.color!, fontSize: 18, decoration: satisfied ?  TextDecoration.lineThrough : TextDecoration.none),)
      ]
    );
  }

  Widget _passwordRequirements(String currentPassword) {

    bool satisfysMinCharacters = currentPassword.length >= minCharacters;
    bool hasOneNumber = currentPassword.contains(RegExp(r'[0-9]'));
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).textTheme.bodyMedium!.color!),
        borderRadius: BorderRadius.circular(25)
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPasswordRequirement("Minimum of 8 characters", satisfysMinCharacters),
          _buildPasswordRequirement("Contains a number", hasOneNumber)
        ],
      )

    );
  }
}
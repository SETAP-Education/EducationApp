import 'package:education_app/Pages/AuthenticationPages/AuthPageForm.dart';
import 'package:education_app/Pages/AuthenticationPages/ErrorDisplayer.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:education_app/Pages/LandingPage.dart';
import 'package:education_app/Pages/AuthenticationPages/LoginPage.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:education_app/Pages/AuthenticationPages/DisplayNamePage.dart';

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
  final int minCharacters = 8; 

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, //When false, blocks the current route from being popped
      child: Scaffold(
        body: AuthPageForm(child: _buildRegistrationForm())
      )
    );
  }

  Widget _buildRegistrationForm() {
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
                  color: secondaryColour,
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
              ),
            ),
            SizedBox(height: 20.0),
            // Password text field
            Container(
              width: 450,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(labelText: 'Password',
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

                      onChanged: (value) {
                        // This is hacky...
                        setState(() {
                          
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10.0),

            _passwordRequirements(_passwordController.text),

            SizedBox(height: 20.0),
            // Register button
            ElevatedButton(
              onPressed: () {
                _register();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text('Register', style: GoogleFonts.nunito(color: Colors.black, fontSize: 17)),
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
            ),
          ],
        )
      );
  }

  Future<void> _register() async {
    try {

      bool satisfysMinCharacters = _passwordController.text.length >= minCharacters;
      bool hasOneNumber = _passwordController.text.contains(RegExp(r'[0-9]'));

      if (!satisfysMinCharacters || !hasOneNumber) {
        // Password does not satisfy constraints 

        globalErrorManager.pushError("Bad password");

        // Break out
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Registration failed. Please try again."),
          duration: Duration(seconds: 3),
        ),
      );
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
        Text(text, style: GoogleFonts.nunito(color: satisfied ? Colors.grey : Colors.black, fontSize: 18, decoration: satisfied ?  TextDecoration.lineThrough : TextDecoration.none),)
      ]
    );
  }

  Widget _passwordRequirements(String currentPassword) {

    bool satisfysMinCharacters = currentPassword.length >= minCharacters;
    bool hasOneNumber = currentPassword.contains(RegExp(r'[0-9]'));
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      decoration: BoxDecoration(
        border: Border.all(),
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
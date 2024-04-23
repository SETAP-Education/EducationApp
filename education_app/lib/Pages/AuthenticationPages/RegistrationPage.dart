import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:education_app/Pages/LandingPage.dart';
import 'package:education_app/Pages/AuthenticationPages/LoginPage.dart';
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
                      child: _buildRegistrationForm(),
                    );
                  },
                ),
              ),
            ),
            // if (_error) _buildErrorMessage(_errorMessages),
          ],
        ),
      )
    );
  }

  Widget _buildRegistrationForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 600, // Set the desired width
          child: Text(
            'User Registration',
            style: GoogleFonts.nunito(
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
              color: secondaryColour,
            ),
          ),
        ),
        const SizedBox(height: 10.0),
        Container(
          width: 600,
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
          width: 600,
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
                ),
              ),
            ],
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
    );
  }

  Future<void> _register() async {
    try {
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
}
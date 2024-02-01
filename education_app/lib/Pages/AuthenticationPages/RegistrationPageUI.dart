import 'package:flutter/material.dart';
import 'package:education_app/Pages/AuthenticationPages/RegistrationPageLogic.dart';
import 'package:education_app/Pages/AuthenticationPages/LoginPageUI.dart';
import 'package:google_fonts/google_fonts.dart';

// basic colour scheme - will come up with one on friday with max
Color primaryColour = Colors.grey;
Color secondaryColour = Colors.grey;

class RegistrationPageUI extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final String emailFromLogin;

  RegistrationPageUI({required this.emailFromLogin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 135.0,
        title: Padding(
          padding: EdgeInsets.only(top: 80.0),
          child: Text(
            'Register an account',
            style: GoogleFonts.nunito(
              fontSize: 50.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 600, // Set the desired width
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email',
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColour),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColour),
                    borderRadius: BorderRadius.circular(30.0),
                  ),),
                style: GoogleFonts.nunito(
                  fontSize: 20.0,
                ),
              ),
            ),
            SizedBox(height: 20.0),
            // password textfield
            Container(
              width: 600,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColour),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColour),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
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
            // register button
            ElevatedButton(
              onPressed: () {
                RegistrationPageLogic().register(
                  context,
                  _emailController.text,
                  _passwordController.text,
                );
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
                        MaterialPageRoute(
                          builder: (context) => LoginPageUI(),
                        ),
                      );
                    },
                    child: Text(
                      'Log in',
                      style: TextStyle(
                          color: Color(0xFF19c37d), fontSize: 17.0
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
}

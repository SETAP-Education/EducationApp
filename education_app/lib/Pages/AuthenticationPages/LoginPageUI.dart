import 'package:flutter/material.dart';
import 'package:education_app/Pages/AuthenticationPages/LoginPageLogic.dart';
import 'package:education_app/Pages/AuthenticationPages/RegistrationPageUI.dart';
import 'package:google_fonts/google_fonts.dart';

// basic colour scheme - will come up with one on friday with max
Color primaryColour = Colors.grey;
Color secondaryColour = Colors.grey;

class LoginPageUI extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // title
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 135.0,
        title: Padding(
        padding: EdgeInsets.only(top: 80.0),
          child: Text(
            'User Login',
            style: GoogleFonts.nunito(
              fontSize: 50.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // email textfield
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
              width: 600, // Set the desired width
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password',
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColour), // Set focused border color
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColour), // Set enabled border color
                    borderRadius: BorderRadius.circular(30.0),
                  ),),
                style: GoogleFonts.nunito(
                  fontSize: 20.0,
                ),
              ),
            ),
            SizedBox(height: 20.0),
            // login button
            ElevatedButton(
              onPressed: () {
                LoginPageLogic().login(
                  context,
                  _emailController.text,
                  _passwordController.text,
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text('Log in', style: GoogleFonts.nunito(color: Colors.black, fontSize: 17)
              ),
            ),
            SizedBox(height: 20.0),
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
                          builder: (context) => RegistrationPageUI(
                            emailFromLogin: _emailController.text,
                          ),
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
}

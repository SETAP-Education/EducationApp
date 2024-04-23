import 'package:education_app/Widgets/Button.dart';
import 'package:flutter/material.dart';
import '../Pages/AuthenticationPages/LoginPage.dart';
import 'package:education_app/Pages/AuthenticationPages/RegistrationPage.dart';
import 'package:google_fonts/google_fonts.dart';

class OpeningPage extends StatefulWidget {
  @override
  _OpeningPageState createState() => _OpeningPageState();
}

class _OpeningPageState extends State<OpeningPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
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
              Column (
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Quiz App 🎓',
                        style: GoogleFonts.nunito(
                          fontSize: 60.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // SizedBox(width: 10),
                      // Container(
                      //   width: 50,
                      //   height: 50,
                      //   // decoration: BoxDecoration(
                      //   //   border: Border.all(color: Colors.black),
                      //   //   borderRadius: BorderRadius.circular(15),
                      //   // ),
                      //   child: Center(
                      //     child: Image.asset(
                      //       'images/quiz_logo.png', // Change to your image asset path
                      //       width: 50, // Adjust as needed
                      //       height: 50, // Adjust as needed
                      //     ),
                      //   ),
                      // ),
                    ]
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Welcome to Quiz App, \n where we make learning fun!',
                    style: GoogleFonts.nunito(
                      fontSize: 30.0,
                    ),
                  ),
                  SizedBox(height: 25),
                  Center(
                    child: SizedBox(
                      width: 400, // Constant width
                      child: Button(
                        onClick: () {
                          Navigator.push(
                            context,
                            _createRoute(RegistrationPage()),
                          );
                        },
                        important: true,
                        child: Text(
                          'New here?',
                          style: GoogleFonts.nunito(
                            fontSize: 20.0,
                            color: Colors.white, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 17),
                  Center(
                    child: SizedBox(
                      width: 400, // Constant width
                      child: Button(
                        onClick: () {
                          Navigator.push(
                            context,
                            _createRoute(LoginPage()),
                          );
                        },
                        important: true,
                        child: Text(
                          'Already have an account',
                          style: GoogleFonts.nunito(
                            fontSize: 20.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                  ),
                ]
              ),
            ]
          )
        ),
      ),
    );
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

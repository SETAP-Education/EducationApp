import 'package:education_app/Pages/LandingPage.dart';
import 'package:education_app/Widgets/Button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Pages/AuthenticationPages/LoginPage.dart';
import 'package:education_app/Pages/AuthenticationPages/RegistrationPage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:education_app/Theme/AppTheme.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

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

    Color secondaryColour = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppTheme.buildAppBar(context, 'Quiz App', false, false, "Welcome to our quiz app", Text(
        'Hi there! This is the landing page for AMT. '
        )),
      body: Center(
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 400,
                height: 400,
                child: Center(
                  child: Image.asset(
                    'assets/images/quiz_app_logo_2.png',
                    width: 400,
                    height: 400,
                  ),
                ),
              ),
              SizedBox(width: 40),
              Column (
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Welcome to", style: GoogleFonts.nunito(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: secondaryColour
                      )),

                  Text(
                    'Quizzical 🎓!',
                    style: GoogleFonts.nunito(
                      fontSize: 60.0,
                      fontWeight: FontWeight.bold,
                      color: secondaryColour
                    ),
                  ),
                  SizedBox(height: 10),

                   Text(
                    'Learning doesn\'t have to be boring!',
                    style: GoogleFonts.nunito(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic
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

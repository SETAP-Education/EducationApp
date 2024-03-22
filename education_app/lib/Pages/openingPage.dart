import 'package:education_app/Pages/LandingPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Pages/AuthenticationPages/LoginPage.dart';
import 'package:education_app/Pages/AuthenticationPages/RegistrationPage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import 'dart:async';

class OpeningPage extends StatefulWidget {
  @override
  _OpeningPageState createState() => _OpeningPageState();
}

class _OpeningPageState extends State<OpeningPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Row(
          children: [
        Padding(
        padding: EdgeInsets.only(left: 200),
          child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                '\n \n \n \n       Insert image here :)',
                style: GoogleFonts.nunito(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              )
            ),
        ),
            Column (
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 100, top: 180),
                        child: Text(
                          'quiz_name',
                          style: GoogleFonts.nunito(
                            fontSize: 60.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20, top: 160),
                        child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              '\n    logo',
                              style: GoogleFonts.nunito(
                                fontSize: 10.0,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                        ),
                      ),
                    ]
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.only(left: 100),
                    child: Text(
                        '     Welcome to quiz_name, \n where we make learning fun!',
                        style: GoogleFonts.nunito(
                          fontSize: 30.0,
                        ),
                    ),
                  ),
                  SizedBox(height: 25),
                  Padding(
                      padding: EdgeInsets.only(left: 100),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            _createRoute(RegistrationPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          // backgroundColor: secondaryColour,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          '            New here?            ',
                          style: GoogleFonts.nunito(
                            fontSize: 25.0,
                          ),
                        ),
                      )
                  ),
                  SizedBox(height: 17),
                  Padding(
                      padding: EdgeInsets.only(left: 100),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            _createRoute(LoginPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Already have an account',
                          style: GoogleFonts.nunito(
                            fontSize: 25,
                          ),
                        ),
                      )
                  ),
                ]
            ),
          ]
        )
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
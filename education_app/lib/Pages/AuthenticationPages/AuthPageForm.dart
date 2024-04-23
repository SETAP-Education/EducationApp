


import 'package:education_app/Pages/AuthenticationPages/ErrorDisplayer.dart';
import 'package:flutter/material.dart';
import 'dart:async';

Color primaryColour = Colors.white;
Color secondaryColour = Colors.black;

class AuthPageForm extends StatefulWidget {

  AuthPageForm({ required this.child });

  final Widget child;

  @override
  State<AuthPageForm> createState() => _AuthPageFormState(); 
}

class _AuthPageFormState extends State<AuthPageForm> {

  bool _error = false;


  @override
  Widget build(BuildContext context) {
    return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: primaryColour,
              ),
              child: Center( // Center widget added here
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Align the column content vertically centered
                  children: [
                    LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        return Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: primaryColour,
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: _buildFormBase(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            ErrorDisplayer()
          ],
        );
  }

  Widget _buildFormBase() {
    return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: SizedBox(
                width: 400,
                height: 400,
                child: Center(
                  child: Image.asset(
                    'images/quiz_app_logo_2.png', // Change to your image asset path
                    width: 400, // Adjust as needed
                    height: 400, // Adjust as needed
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 50, top: 50),
              child: widget.child
            )
          ]
        ),
        
      );
  }
}
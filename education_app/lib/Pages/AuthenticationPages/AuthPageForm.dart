import 'package:education_app/Pages/AuthenticationPages/ErrorDisplayer.dart';
import 'package:flutter/material.dart';



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

              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        return Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                           
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
                    'images/quiz_app_logo_2.png',
                    width: 400,
                    height: 400,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 50, top: 50),
              child: widget.child
            )
          ]
        ),
        
      );
  }
}
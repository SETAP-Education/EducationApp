


import 'dart:async';

import 'package:flutter/material.dart';

class ErrorManager extends ChangeNotifier {

  List<String> errors = []; 

  void pushError(String str) {
    errors.add(str);
    notifyListeners();
  }
}

ErrorManager globalErrorManager = ErrorManager(); 

class ErrorDisplayer extends StatefulWidget {

  @override
  State<ErrorDisplayer> createState() => _ErrorDisplayerState();
}

class _ErrorDisplayerState extends State<ErrorDisplayer> {

  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer if it's not null
    super.dispose();
  }

  @override 
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return ListenableBuilder(listenable: globalErrorManager, builder: (context, child) {

      if (globalErrorManager.errors.isEmpty) {
        return Container(); 
      }

      return Positioned(
        top: screenHeight * 0.01,
        left: screenWidth * 0.15,
        right: screenWidth * 0.15,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent, // Set background color to transparent
          ),
          child: ListView.separated(
            physics: NeverScrollableScrollPhysics(), // Disable scrolling of the ListView
            shrinkWrap: true,
            itemCount: globalErrorManager.errors.length,
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(height: 8); // Add a gap of 8 between error messages
            },
            itemBuilder: (context, index) {
              if (index >= globalErrorManager.errors.length) {
                return Container(); // Return an empty container if index is out of range
              }

              _timer = Timer(Duration(seconds: 4), () {
                setState(() {
                  if (globalErrorManager.errors.length > index) {
                    globalErrorManager.errors.removeAt(index);

                  }
                });
              });

              Color messageColor = Colors.red; // Default color for error messages

              // Check for different types of error messages and assign colors accordingly
              if (globalErrorManager.errors[index].contains('Password reset email sent to')) {
                messageColor = Color(0xFF19c37d); // Change color for successful message
              }

              return Container(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: messageColor, // Assign color based on message type
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          globalErrorManager.errors[index],
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          globalErrorManager.errors.removeAt(index);
                          
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    });
   
  }
}
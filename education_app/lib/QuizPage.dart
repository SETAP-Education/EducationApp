import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Pages/AuthenticationPages/LoginPage.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Quiz', style: GoogleFonts.nunito(color: Colors.black, fontSize: 24)),
        backgroundColor: Colors.grey[200],
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              //await FirebaseAuth.instance.signOut();
              //Navigator.push(context, MaterialPageRoute(builder: (context) => 'FUTURE SETTINGS PAGE'())); // Go back to the login page
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Sign out the user
              await FirebaseAuth.instance.signOut();
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage())); // Go back to the login page
            },
          ),
        ],
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.black)),
              margin: const EdgeInsets.all(30.0),
              width: MediaQuery.of(context).size.width * 0.4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      margin: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 10.0),
                      child: Text('Available', style: GoogleFonts.nunito(color: Colors.black, fontSize: 28),
                  )
                ),
                  Text('Test yourself!', style: GoogleFonts.nunito(color: Colors.black, fontSize: 20)),
                  Container(
                      margin: const EdgeInsets.fromLTRB(0.0, 80.0, 0.0, 10.0),
                      child: Text('[DISPLAY ALL AVAILABLE TESTS BELOW]', style: GoogleFonts.nunito(color: Colors.black, fontSize: 20))
                  )
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(30.0),
              width: MediaQuery.of(context).size.width * 0.4,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.width * 0.1,
                      margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
                      child: Text('XP: [4439]', style: GoogleFonts.nunito(color: Colors.black, fontSize: 24),
                  )),
                  Container(
                      alignment: Alignment.topCenter,
                      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.width * 0.58,
                    //child: Text('History', style: GoogleFonts.nunito(color: Colors.black, fontSize: 28),
                      child: Column(
                        children: [
                          Container(
                              margin: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 10.0),
                            child: Text('History', style: GoogleFonts.nunito(color: Colors.black, fontSize: 28),
                          )),
                          Text('View your recent efforts!', style: GoogleFonts.nunito(color: Colors.black, fontSize: 20),
                          ),
                          Container(
                              margin: const EdgeInsets.fromLTRB(0.0, 80.0, 0.0, 10.0),
                              child: Text('[DISPLAY ALL AVAILABLE TESTS BELOW]', style: GoogleFonts.nunito(color: Colors.black, fontSize: 20))
                          )
                    ],
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
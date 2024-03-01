import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:education_app/Pages/AuthenticationPages/LoginPage.dart';
import 'package:education_app/Pages/LandingPage.dart';
import 'package:google_fonts/google_fonts.dart';

class DisplayUser extends StatefulWidget {
  @override
  _DisplayUser createState() => _DisplayUser();
}

class _DisplayUser extends State<DisplayUser> {
  final TextEditingController _nameController = TextEditingController();
  User? _user;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  void _checkAuthState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _user = user; // Set the current user
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Display User'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Sign out the user
              await FirebaseAuth.instance.signOut();
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage())); // Go back to the login page
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, ${_user?.displayName}!',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(
              width: 400, // Set the desired width
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  hintText: _user?.displayName,
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
                cursorColor: secondaryColour,
                onEditingComplete: () {
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the quiz page when the button is pressed
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LandingPage())
                );
              },
              child: Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

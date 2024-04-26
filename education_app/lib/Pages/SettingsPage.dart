import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education_app/Theme/AppTheme.dart';
import 'package:education_app/Pages/SplashPage.dart';
import 'package:flutter/material.dart';
import 'package:education_app/Widgets/Button.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:education_app/Pages/AuthenticationPages/DisplayNamePage.dart';
import 'package:education_app/Theme/AppTheme.dart';

class SettingsPage extends StatefulWidget {

  SettingsPage({ super.key });

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppTheme.buildAppBar(context, 'Settings page', false, true, "Settings", Text('')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Button(
                important: false,
                width: 450,
                onClick: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DisplayUser(),
                    ),
                  );
                },
                child: Text('Change display name/ interests', style: GoogleFonts.nunito(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 20),
              Button(
                important: true,
                width: 450,
                onClick: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SplashPage(),
                    ),
                  );
                },
                child: Text('Sign out', style: GoogleFonts.nunito(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        )
    );
  }

}


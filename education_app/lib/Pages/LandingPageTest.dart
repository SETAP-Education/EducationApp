import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  User? _user;
  List<String> userInterests = [];
  int xpLevel = 0; // Assuming XP level is an integer
  late String _displayName = "Placeholder";

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  void _checkAuthState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _user = user;
        });
        if (user != null) {
          _getUserInterests(user.uid);
          _getUserXPLevel(user.uid);
          _getUserDisplayName(user.uid); // Call to get user display name
        }
      }
    });
  }

  void _getUserInterests(String uid) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        setState(() {
          userInterests = List<String>.from(userSnapshot.get('interests'));
        });
      }
    } catch (e) {
      print('Error fetching user interests: $e');
    }
  }

  void _getUserXPLevel(String uid) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        setState(() {
          xpLevel = userSnapshot.get('xpLvl');
        });
      }
    } catch (e) {
      print('Error fetching user XP level: $e');
    }
  }

  void _getUserDisplayName(String uid) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        setState(() {
          _displayName = userSnapshot.get('displayName');
        });
      }
    } catch (e) {
      print('Error fetching user display name: $e');
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Text('Quiz App'),
      actions: _user != null
          ? [
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
              ),
            ]
          : null,
    ),
    body: _user != null
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  // width: MediaQuery.of(context).size.width * 2/3,
                  margin: const EdgeInsets.all(30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 2/3,
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFFf3edf6).withOpacity(1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 5,
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Interests:',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              Wrap(
                                spacing: 8.0,
                                children: userInterests
                                    .map((interest) => Chip(label: Text(interest)))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width * 1/3,
                  margin: const EdgeInsets.fromLTRB(0, 30, 30, 30),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          // width: MediaQuery.of(context).size.width * 2/3,
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFFf3edf6).withOpacity(1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 5,
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'XP Level:',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: xpLevel * 2,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        '${xpLevel}XP',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                _getXPLevelDescription(xpLevel),
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        flex: 7,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 1/3,
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFFf3edf6).withOpacity(1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 5,
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quiz History:',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              // Placeholder for quiz history widget
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        : Center(
            child: ElevatedButton(
              onPressed: () {
                // Navigate to login page
              },
              child: Text('Login'),
            ),
          ),
  );
}





  String _getXPLevelDescription(int xp) {
    if (xp >= 0 && xp <= 20) {
      return 'Beginner';
    } else if (xp >= 21 && xp <= 40) {
      return 'Intermediate';
    } else if (xp >= 41 && xp <= 60) {
      return 'Advanced';
    } else if (xp >= 61 && xp <= 80) {
      return 'Expert';
    } else {
      return 'Master';
    }
  }
}

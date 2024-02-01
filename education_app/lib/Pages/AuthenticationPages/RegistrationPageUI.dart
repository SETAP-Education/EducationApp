import 'package:flutter/material.dart';
import 'package:education_app/Pages/AuthenticationPages/RegistrationPageLogic.dart';
import 'package:education_app/Pages/AuthenticationPages/LoginPageUI.dart';

class RegistrationPageUI extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final String emailFromLogin;

  RegistrationPageUI({required this.emailFromLogin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                RegistrationPageLogic().register(
                  context,
                  _emailController.text,
                  _passwordController.text,
                );
              },
              child: Text('Register'),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: TextStyle(color: Colors.black),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPageUI(),
                      ),
                    );
                  },
                  child: Text(
                    'Log in',
                    style: TextStyle(
                      color: Color(0xFF19c37d),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
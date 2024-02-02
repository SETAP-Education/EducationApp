import 'package:flutter/material.dart';
import 'package:education_app/Pages/AuthenticationPages/LoginPageLogic.dart';
import 'package:education_app/Pages/AuthenticationPages/RegistrationPageUI.dart';
// import 'package:education_app/Pages/LandingPage.dart';

class LoginPageUI extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
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
                LoginPageLogic().login(
                  context,
                  _emailController.text,
                  _passwordController.text,
                );
              },
              child: Text('Login'),
            ),
            SizedBox(height: 16.0),
            // ElevatedButton(
            //   onPressed: () {
            //     LoginPageLogic().bypass(context);
            //   },
            //   child: Text('Bypass'),
            // ),
            // SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Call bypass logic method from LoginPageLogic.dart
                LoginPageLogic().test();
              },
              child: Text('test'),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Don\'t have an account? ',
                  style: TextStyle(color: Colors.black),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegistrationPageUI(
                          emailFromLogin: _emailController.text,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Sign up',
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

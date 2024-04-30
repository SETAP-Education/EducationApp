import 'package:flutter/material.dart';
import 'package:education_app/Theme/AppTheme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = true;
  ThemeData _currentTheme = AppTheme.lightTheme;
  ThemeData get currentTheme => _currentTheme;
  bool get isDarkMode => _isDarkMode;

  void setTheme(bool isDarkMode) {
    _isDarkMode = isDarkMode;
    _currentTheme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
    notifyListeners();

    // Update user preference in Firestore if user is logged in
    _updateUserThemePreference(isDarkMode);
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _currentTheme = _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
    notifyListeners();

    // Update user preference in Firestore if user is logged in
    _updateUserThemePreference(_isDarkMode);
  }

  Future<void> _updateUserThemePreference(bool isDarkMode) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'darkMode': isDarkMode});
      } catch (error) {
        print("Error updating user theme preference: $error");
      }
    }
  }
}

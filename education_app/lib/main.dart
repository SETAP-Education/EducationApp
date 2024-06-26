import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Pages/SplashPage.dart';
import 'package:education_app/Firebase/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:education_app/Theme/AppTheme.dart';
import 'package:education_app/Theme/ThemeNotifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(), // Add this line
      child: const MyApp(),
    ),
  );
} 

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SETaP Education Project',
      debugShowCheckedModeBanner: false,
      theme: context.watch<ThemeNotifier>().isDarkMode
          ? AppTheme.darkTheme
          : AppTheme.lightTheme,
      home: SplashPage(),
    );
  }
}
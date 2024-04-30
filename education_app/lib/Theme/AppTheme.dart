import 'package:education_app/Pages/SettingsPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:education_app/Theme/ThemeNotifier.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:education_app/Pages/AuthenticationPages/LoginPage.dart';

class AppTheme {

  static ThemeData lightTheme = ThemeData(
    colorScheme: const ColorScheme.light(
      background: Colors.transparent,
      primary: Color(0xFF19c37d),
      secondary: Color(0xFF333333),
      primaryContainer: Color.fromARGB(255, 255, 255, 255),
      secondaryContainer: Color.fromARGB(255, 231, 231, 231),
      error: Colors.orange,
    ),

     scaffoldBackgroundColor: const Color.fromARGB(255, 230, 231, 236),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color(0xFF333333)),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.blue,
      selectionColor: Colors.blue.withOpacity(0.5),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    colorScheme: const ColorScheme.dark(
      background: Colors.transparent,
      primary: Color(0xFF19c37d),
      secondary: Color(0xFFE7E7E7),
      primaryContainer: Color(0xFF202226),
      secondaryContainer: Color.fromARGB(255, 65, 68, 74),
      error: Colors.orange,
    ),
    scaffoldBackgroundColor: const Color(0xFF131517),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color(0xFFE7E7E7)),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.blue,
      selectionColor: Colors.blue.withOpacity(0.5),
    ),
  );

  static TextStyle defaultTitleText(BuildContext context) {
    return GoogleFonts.openSans(
      fontSize: 40,
      fontWeight: FontWeight.w300,
      letterSpacing: -1.5,
      color: Theme.of(context).colorScheme.secondary,
    );
  }

  static TextStyle defaultBodyText(BuildContext context) {
    return GoogleFonts.roboto(
      fontSize: 18,
      fontWeight: FontWeight.w300,
      letterSpacing: -0.5,
      color: Theme.of(context).colorScheme.secondary,
    );
  }

  static AppBar buildAppBar(BuildContext context, String title, bool includeTitleAndIcons, bool autoImply, String dialogTitle, Text contentText) {//, bool automaticallyImplyLeading) {
    // Get the current theme
    ThemeNotifier themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);

    // Define icons for light and dark mode
    Icon lightModeIcon = Icon(Icons.light_mode_outlined, color: Theme.of(context).colorScheme.secondary);
    Icon darkModeIcon = Icon(Icons.dark_mode_outlined, color: Theme.of(context).colorScheme.secondary);

    // Determine the current icon based on the theme
    Icon currentIcon = themeNotifier.isDarkMode ? lightModeIcon : darkModeIcon;

    if (includeTitleAndIcons && autoImply) {
      return AppBar(
        clipBehavior: Clip.none,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.secondary),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        flexibleSpace: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(56.0, 8, 8, 8), // Adjust the left padding as needed
              child: IconButton(
                icon: currentIcon,
                tooltip: 'Theme button',
                onPressed: () {
                  // Toggle between light and dark mode
                  themeNotifier.toggleTheme();
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.secondary),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    tooltip: 'Settings',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsPage(),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.exit_to_app, color: Theme.of(context).colorScheme.secondary),
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      );
    } else if (includeTitleAndIcons && !autoImply) {
      return AppBar(
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.secondary),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        flexibleSpace: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: IconButton(
                icon: currentIcon,
                tooltip: 'Theme button',
                onPressed: () {
                  themeNotifier.toggleTheme();
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.secondary),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    tooltip: 'Settings',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsPage()
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.exit_to_app, color: Theme.of(context).colorScheme.secondary),
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      );
    } else if (!includeTitleAndIcons && autoImply) {
      return AppBar(
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.secondary),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        flexibleSpace: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5, top: 5),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Return to previous page',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5, top: 5),
              child: IconButton(
                icon: currentIcon,
                tooltip: 'Theme button',
                onPressed: () {
                  themeNotifier.toggleTheme();
                },
              ),
            )
          ],
        ),
      );
    } else {
      return AppBar(
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontSize: 20.0,
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: currentIcon,
          tooltip: 'Theme button',
          onPressed: () {
            themeNotifier.toggleTheme();
          },
        ),
        automaticallyImplyLeading: false,
      );
    }
  }

  static InputDecoration inputBoxDecoration(BuildContext context, String labelText, bool obscureText, bool _showPassword, Function togglePasswordVisibility, hintTextText) {
    Widget? suffixIconWidget;
    if (obscureText) {
      suffixIconWidget = IconButton(
        icon: Icon(
          _showPassword ? Icons.visibility_off : Icons.visibility,
        ),
        color: Theme.of(context).colorScheme.secondary,
        onPressed: () {
          // Call the callback to update showPassword in the parent widget
          togglePasswordVisibility();
        },
      );
    }

    return InputDecoration(
      labelText: labelText,
      labelStyle: defaultBodyText(context),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
      ),
      hintText: hintTextText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
      suffixIcon: suffixIconWidget,
    );
  }

  static ElevatedButton buildElevatedButton({
    required VoidCallback onPressed,
    required String buttonText,
    BuildContext? context,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF19c37d),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
      child: Text(
        buttonText,
        style: context != null ? AppTheme.defaultBodyText(context) : null,
      ),
    );
  }
}

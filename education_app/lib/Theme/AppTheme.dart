import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:education_app/Theme/ThemeNotifier.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:education_app/Pages/AuthenticationPages/LoginPage.dart';
import 'package:education_app/Pages/AuthenticationPages/DisplayNamePage.dart';

class AppTheme {

  static ThemeData lightTheme = ThemeData(
    colorScheme: const ColorScheme.light(
      background: Colors.transparent,
      primary: Color(0xFF19c37d),
      secondary: Color(0xFF333333),
      primaryContainer: Colors.white,
      secondaryContainer: Color.fromARGB(255, 208, 208, 208),
      error: Colors.orange,
    ),
     scaffoldBackgroundColor: Color(0xFFF9FAFE),
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
     scaffoldBackgroundColor: Color(0xFF131517),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color(0xFFE7E7E7)),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.blue,
      selectionColor: Colors.blue.withOpacity(0.5),
    ),
  );

//   In order to implement colour scheme properly, each instance of color needs to be replaced with the following:
//
//       Dark Shade of Grey
//       current: 'Color(0xff343541)'
//       replace with: 'Theme.of(context).colorScheme.background'
//       
//       current: 'Colors.white'
//       replace with: 'Theme.of(context).colorScheme.secondary'
//       
//       Lighter shade of Grey
//       current: 'Color(0xFF40414f)'
//       replace with: 'Theme.of(context).colorScheme.primary'

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
    // return TextStyle(
    //   fontSize: 20,
    //   fontWeight: FontWeight.w300,
    //   letterSpacing: -0.5,
    //   color: Theme.of(context).colorScheme.secondary,
    // );
  }

//   In order to implement colour scheme properly, each instance of color needs to be replaced with the following:
//
//       Title Text Style
//       current: 'Not too sure'
//       replace with: 'AppTheme.defaultTitleText(context)'
//       
//       Body Text Style 1
//       current: 'Not too sure'
//       replace with: 'AppTheme.defaultBodyText(context)'

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
                ),
                IconButton(
                  icon: Icon(Icons.help_outline, color: Theme.of(context).colorScheme.secondary,),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(dialogTitle, style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                          content: contentText,
                          backgroundColor: Color(0xFF40414f),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Close', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0), // Adjust the right padding as needed
              child: Row(
                children: [
                  // IconButton(
                  //   icon: Icon(Icons.settings),
                  //   onPressed: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => SettingsPage(),
                  //       ),
                  //     );
                  //   },
                  // ),
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
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8), // Adjust the left padding as needed
              child: IconButton(
                icon: currentIcon,
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
                ),
                IconButton(
                  icon: Icon(Icons.help_outline, color: Theme.of(context).colorScheme.secondary,),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(dialogTitle, style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                          content: contentText,
                          backgroundColor: Color(0xFF40414f),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Close', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0), // Adjust the right padding as needed
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DisplayUser(),
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
    } else {
      return AppBar(
        // title: Text(title),
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontSize: 20.0, // Set the desired font size
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: currentIcon,
          onPressed: () {
            // Toggle between light and dark mode
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
      contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
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
        backgroundColor: Color(0xFF19c37d),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0), // 15 for rounded edges, 5 for curved corners
        ),
        // Add other button style configurations as needed
      ),
      child: Text(
        buttonText,
        style: context != null ? AppTheme.defaultBodyText(context) : null,
      ),
    );
  }


}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutPage extends StatelessWidget {
  const LogoutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define colors from the provided palette
    Color backgroundColor = Color.fromARGB(255, 3, 94, 114); // Primary color
    Color appBarColor = Color(0xFF135D66); // Secondary color
    Color iconColor = Colors.white; // Icon color
    Color textColor = Color(0xFF77B0AA); // Tertiary color
    Color buttonColor = Color.fromARGB(255, 5, 5, 5); // Quaternary color
    Color buttonText = Color.fromARGB(255, 217, 228, 228); // Button text color

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: appBarColor,
        iconTheme: IconThemeData(color: iconColor), // Set icon color
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated power icon
            TweenAnimationBuilder<double>(
              duration: Duration(seconds: 1),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Icon(
                    Icons.power_settings_new,
                    size: 100,
                    color: textColor, // Icon color
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            // Animated logout message
            TweenAnimationBuilder<double>(
              duration: Duration(seconds: 1),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Text(
                    'You have been logged out successfully.',
                    style: TextStyle(
                      fontSize: 20,
                      color: textColor, // Text color
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            // Animated login button
            TweenAnimationBuilder<double>(
              duration: Duration(seconds: 1),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Set 'partiloggedin' flag to false
                      await setLoggedIn(false);
                      // Navigate back to login screen
                      Navigator.popUntil(context, ModalRoute.withName('/'));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor, // Button color
                    ),
                    child: Text(
                      'Login Again',
                      style: TextStyle(
                        color: buttonText, // Button text color
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      backgroundColor: backgroundColor, // Background color
    );
  }
}

Future<void> setLoggedIn(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('partiloggedin', value);
  await prefs.setBool('coordinloggedin', value);
}

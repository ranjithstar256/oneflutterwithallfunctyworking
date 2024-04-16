import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:oneflutter/ParticipantsFiles/AllEvents.dart';
import 'package:oneflutter/Registrations/LoginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'CoordinatorFiles/CoOrdinatorLogin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase before runApp

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SportArena',
      theme: ThemeData(
        primaryColor: const Color(0xFF4C9085), // Set primary color to #4C9085
        hintColor: Colors.white, // Set accent color to white
        scaffoldBackgroundColor:
            Colors.white, // Set scaffold background color to white
        textTheme: const TextTheme(
          bodyLarge:
              TextStyle(color: Colors.black87), // Set body text color to black
          bodyMedium:
              TextStyle(color: Colors.black87), // Set body text color to black
          titleMedium: TextStyle(
              color: Colors.black87), // Set subtitle text color to black
          titleSmall: TextStyle(
              color: Colors.black87), // Set subtitle text color to black
        ),
      ),
      home: FutureBuilder<bool>(
        future: checkIfLoggedIn(), // Check if user is already logged in
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          // If user is already logged in, navigate to main content
          if (snapshot.data == true) {
            return AllEvents(
              coordinatorId: '',
            );
          } else {
            // Otherwise, navigate to login page
            return HomePage();
          }
        },
      ),
    );
  }
}

Future<bool> checkIfLoggedIn() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('partiloggedin') ?? false;
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose User Type'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Participant'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CoOrdinatorLogin()),
                );
              },
              child: const Text('Coordinator'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:oneflutter/CoOrdinatorSignIn.dart';
import 'package:oneflutter/ParticipantsFiles/AllEvents.dart';
import 'package:oneflutter/Registrations/LoginPage.dart';
import 'package:oneflutter/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Registrations/signuppage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase before runApp

  runApp(MyApp6());
}

class MyApp6 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Co-ordinator Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}

class MyApp666 extends StatelessWidget {
  const MyApp666({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto', // Customizing font family
      ),
      home: const UserSignUpPage(),
    );
  }
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
                  MaterialPageRoute(builder: (context) => SignInTen()),
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

/*
co ordinator sign up apk code !
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:oneflutter/ParticipantsFiles/AllEvents.dart';
import 'package:oneflutter/Registrations/LoginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'CoordinatorFiles/AddEventPage.dart';
import 'CoordinatorFiles/CoOrdinatorSignUp.dart';
import 'CoordinatorFiles/CoordinatorLoginScreen.dart';
import 'CoordinatorFiles/ViewingGameRegistrationsPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase before runApp

  runApp(MyApp6());
}

class MyApp6 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Co-ordinator Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<bool>(
        future: checkIfLoggedIn(), // Check if user is already logged in
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          // If user is already logged in, navigate to main content
          if (snapshot.data == true) {
            return CoordinatorActionScreen();
          } else {
            // Otherwise, navigate to login page
            return CoordinatorLoginScreen();
          }
        },
      ),
    );
  }
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

class CoordinatorActionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getcoid(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasData) {
          String coordinatorId = snapshot.data.toString();
          Fluttertoast.showToast(
            msg: coordinatorId ?? 'No coordinator ID found',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black,
            textColor: Colors.white,
          );
          return Scaffold(
            appBar: AppBar(
              title: const Text('Choose an action'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      setLoggedIn(true);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewRegistrationPage(
                              coordinatorId: coordinatorId),
                        ),
                      );
                    },
                    child: const Text('View Registration'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setLoggedIn(true);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddEventPage(coordinatorId: coordinatorId),
                        ),
                      );
                    },
                    child: const Text('Add Event'),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Text('No coordinator ID found');
        }
      },
    );
  }
}

Future<void> setLoggedIn(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('coordinloggedin', value);
}

Future<void> setcoid(String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('coordinid', value);
}

Future<String?> getcoid() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('coordinid');
}
*/

/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:oneflutter/CoOrdinatorSignIn.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Registrations/ForgotPasswordPage.dart';
import 'AddEventPage.dart';
import 'CoOrdinatorSignUp.dart';
import 'ViewingGameRegistrationsPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
            //return CoordinatorLoginScreenn();
            return SignInTen();
          }
        },
      ),
    );
  }
}

class CoordinatorLoginScreenn extends StatefulWidget {
  @override
  _CoordinatorLoginScreenState createState() => _CoordinatorLoginScreenState();
}

class _CoordinatorLoginScreenState extends State<CoordinatorLoginScreenn> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _coordinatorIdController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coordinator Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 20.0),
                width: 120, // Adjust the width as needed
                height: 120, // Adjust the height as needed
                child: Image.asset('assets/images/splash.png'),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _coordinatorIdController,
                      decoration:
                          const InputDecoration(labelText: 'Coordinator ID'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your coordinator ID';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await _loginCoordinator();
                        }
                      },
                      child: const Text('Login'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordPage(),
                              ),
                            );
                            // Forgot password action
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        // Navigate back to the sign-up page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CoOrdinatorSignUp()),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? "),
                          Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loginCoordinator() async {
    String coordinatorId = _coordinatorIdController.text.trim();
    String password = _passwordController.text.trim();

    try {
      QuerySnapshot<Map<String, dynamic>> result = await FirebaseFirestore
          .instance
          .collection('coordinators')
          .where('coordinatorid', isEqualTo: coordinatorId)
          .where('cooripassword', isEqualTo: password)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        // Save logged in status and coordinator ID
        await setLoggedIn(true);
        await setcoid(coordinatorId);

        // Navigate to the action screen after successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CoordinatorActionScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid credentials')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to login')),
      );
    }
  }

  @override
  void dispose() {
    _coordinatorIdController.dispose();
    _passwordController.dispose();
    super.dispose();
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

Future<bool> checkIfLoggedIn() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('coordinloggedin') ?? false;
}

Future<String?> getcoid() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('coordinid');
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

*/ /*


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoastdart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Registrations/ForgotPasswordPage.dart';
import 'AddEventPage.dart';
import 'ViewingGameRegistrationsPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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

class CoordinatorLoginScreen extends StatefulWidget {
  @override
  _CoordinatorLoginScreenState createState() => _CoordinatorLoginScreenState();
}

class _CoordinatorLoginScreenState extends State<CoordinatorLoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _coordinatorIdController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Coordinator Login'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _coordinatorIdController,
                    decoration:
                        const InputDecoration(labelText: 'Coordinator ID'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your coordinator ID';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await _loginCoordinator();
                      }
                    },
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 10),
                  // Add some space between continue button and forgot password text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordPage()),
                          );
                          // Forgot password action
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.blue, // Change text color to blue
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Add some space between forgot password text and edge of screen
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Add some space between forgot password text and divider
                  const Divider(),
                  // Horizontal line
                  const SizedBox(height: 20),
                  // Add some space between divider and sign-up text
                  GestureDetector(
                    onTap: () {
                      // Navigate back to the sign-up page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CoOrdinatorLogin()),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? "),
                        Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.blue, // Change text color to blue
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )));
  }

  Future<void> _loginCoordinator() async {
    String coordinatorId = _coordinatorIdController.text.trim();
    String password = _passwordController.text.trim();

    try {
      DocumentSnapshot docSnapshot =
          await _firestore.collection('coordinators').doc(coordinatorId).get();
      if (docSnapshot.exists) {
        Map<String, dynamic> coordinatorData =
            docSnapshot.data() as Map<String, dynamic>;
        if (coordinatorData['cooripassword'] == password) {
          // Navigate to the next screen after successful login
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    CoordinatorActionScreen()), // Replace NextScreen with your actual next screen
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Incorrect password')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coordinator ID not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to login')),
      );
    }
  }

  @override
  void dispose() {
    _coordinatorIdController.dispose();
    _passwordController.dispose();
    super.dispose();
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

Future<bool> checkIfLoggedIn() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('coordinloggedin') ?? false;
}

Future<String?> getcoid() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('coordinid');
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

class CoordinatorLogin2Screen extends StatefulWidget {
  @override
  _CoordinatorLogin2ScreenState createState() =>
      _CoordinatorLogin2ScreenState();
}

class _CoordinatorLogin2ScreenState extends State<CoordinatorLogin2Screen> {
  final TextEditingController _coordinatorIdController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _errorMessage = '';

  Future<void> _login() async {
    setState(() {
      _errorMessage = '';
    });

    final String coordinatorId = _coordinatorIdController.text.trim();
    final String password = _passwordController.text.trim();

    // Check if form is valid
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Perform login validation against Firestore
    final QuerySnapshot<Map<String, dynamic>> result = await FirebaseFirestore
        .instance
        .collection('coordinators')
        .where('coordinatorid', isEqualTo: coordinatorId)
        .where('cooripassword', isEqualTo: password)
        .limit(1)
        .get();

    if (result.docs.isNotEmpty) {
      // Login successful
      // Navigate to next screen or perform necessary actions
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                CoordinatorActionScreen()), // Replace NextScreen with your actual next screen
      );
    } else {
      setState(() {
        _errorMessage = 'Invalid credentials. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coordinator Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _coordinatorIdController,
                decoration: const InputDecoration(labelText: 'Coordinator ID'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your Coordinator ID.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Login'),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _coordinatorIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
*/

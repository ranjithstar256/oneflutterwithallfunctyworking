import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:oneflutter/ParticipantsFiles/AllEvents.dart';
import 'package:oneflutter/Registrations/signuppage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ForgotPasswordPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase before runApp

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Title',
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
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // State variable to track password visibility
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Icon(
              Icons.lock,
              size: 60,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 10),
            Text(
              'Login to your account',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordVisible,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String enteredEmail = _emailController.text;
                String enteredPassword = _passwordController.text;

                // Perform login operation here

                // For demonstration purposes, assume login is successful
                setLoggedIn(true);

                // Navigate to next page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AllEvents()),
                );
              },
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // Navigate to forgot password page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordPage(),
                      ),
                    );
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                // Navigate to sign-up page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserSignUpPage()),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> setLoggedIn(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('partiloggedin', value);
}

/*
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20), // Add some space at the top
            const Icon(
              Icons.lock,
              size: 60, // Adjust icon size as needed
              color: Colors.blue, // Change icon color
            ),
            const SizedBox(height: 10), // Add some space between icon and text
            const Text(
              'Login to your account',
              style: TextStyle(
                fontSize: 24, // Adjust text size as needed
                fontWeight: FontWeight.bold, // Apply bold font weight
              ),
            ),
            const SizedBox(
                height: 20), // Add some space between text and email field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email), // Icon to the left
                ),
              ),
            ),
            const SizedBox(
                height:
                    10), // Add some space between email field and password field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock), // Icon to the left
                ),
                obscureText: true,
              ),
            ),
            const SizedBox(
                height:
                    20), // Add some space between password field and continue button
            ElevatedButton(
              onPressed: () async {
                String enteredEmail = _emailController.text;
                String enteredPassword = _passwordController.text;

                // Assuming you have a method to retrieve user data from Firestore based on email
                UserData? userData =
                    await getUserDataFromFirestore(enteredEmail);

                if (userData != null && userData.password == enteredPassword) {
                  // Successful login, navigate to home page
                  setLoggedIn(true);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AllEvents()),
                  );
                } else {
                  // Invalid credentials, show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid email or password.'),
                    ),
                  );
                }
              },
              child: const Text('Sign In'),
            ),
            const SizedBox(
                height:
                    10), // Add some space between continue button and forgot password text
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ForgotPasswordPage()),
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
                const SizedBox(
                    width:
                        20), // Add some space between forgot password text and edge of screen
              ],
            ),
            const SizedBox(
                height:
                    20), // Add some space between forgot password text and divider
            const Divider(), // Horizontal line
            const SizedBox(
                height: 20), // Add some space between divider and sign-up text
            GestureDetector(
              onTap: () {
                // Navigate back to the sign-up page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserSignUpPage()),
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
      ),
    );
  }
}

Future<UserData?> getUserDataFromFirestore(String email) async {
  try {
    // Get Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Query Firestore to get user data based on the entered email
    QuerySnapshot querySnapshot = await firestore
        .collection('studentsSignUps')
        //      studentsSignUps
        .where('email', isEqualTo: email)
        .get();

    // Check if any document matches the query
    if (querySnapshot.docs.isNotEmpty) {
      // Retrieve user data from the first document
      var userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
      // Check if userData is not null
      if (userData != null) {
        // Return UserData object with email and password
        return UserData(
          email: userData['email'],
          password: userData['password'],
        );
      } else {
        // Handle case where userData is null
        return null;
      }
    } else {
      // No user found with the entered email
      return null;
    }
  } catch (error) {
    // Handle any errors that occur during data retrieval
    print('Error retrieving user data: $error');
    return null;
  }
}

Future<void> setLoggedIn(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('partiloggedin', value);
}
*/

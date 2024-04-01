import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oneflutter/EventRegistrationPage.dart';
import 'package:oneflutter/HomePage.dart';

import 'AddEventPage.dart';
import 'AllEvents.dart';
import 'LoginPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const UserSignUpPage(),
    );
  }
}

class UserSignUpPage extends StatefulWidget {
  const UserSignUpPage({super.key});

  @override
  _UserSignUpPageState createState() => _UserSignUpPageState();
}

class _UserSignUpPageState extends State<UserSignUpPage> {
  // Define a list of menu items
  final List<String> menuItems = [
    'Add Event',
    'All Events',
    'Main Page',
    'Home Page',
    'Login Page',
    'Event Registration Page',
  ];

  // Method to handle menu item selection
  void _handleMenuItemSelected(String menuItem) {
    switch (menuItem) {
      case 'Add Event':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddEventPage()),
        );
        break;
      case 'All Events':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AllEvents()),
        );
        break;
      case 'Main Page':
        // Navigate to the main page (replace with appropriate route)
        break;
      case 'Home Page':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        // Navigate to the home page (replace with appropriate route)
        break;
      case 'Login Page':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        break;
      case 'Event Registration Page':
        // Navigate to the event registration page (replace with appropriate route)
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EventRegistrationPage(
                  eventName: "VollyBall",
                  eventDate: "04-04-2024",
                  venue: "SDM College",
                  isTeamGame: true,
                  coordinatorId: "0256")),
        );
        break;
    }
  }

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _dobController =
      TextEditingController(); // Remove this controller

  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _collegeNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  DateTime? _selectedDate; // Add this variable to store the selected date
  @override
  void initState() {
    super.initState();
    _dobController
        .addListener(_calculateAge); // Listen for changes in DOB field
  }

  @override
  void dispose() {
    _dobController.removeListener(
        _calculateAge); // Remove listener when disposing of the state
    super.dispose();
  }

  void _calculateAge() {
    if (_selectedDate != null) {
      final today = DateTime.now();
      final dob = _selectedDate!;
      final age = today.year -
          dob.year -
          (today.month < dob.month ||
                  (today.month == dob.month && today.day < dob.day)
              ? 1
              : 0);
      setState(() {
        _ageController.text = age.toString();
      });
    }
  }

  void _saveUserData() async {
    String fullname = _fullNameController.text;
    String username = _usernameController.text;
    String age = _ageController.text;
    String collegename = _collegeNameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    // Check if all fields are not empty and a date is selected
    if (fullname.isNotEmpty &&
        username.isNotEmpty &&
        age.isNotEmpty &&
        collegename.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        _selectedDate != null) {
      String dob = DateFormat('yyyy-MM-dd')
          .format(_selectedDate!); // Format selected date

      // Get Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Add user data to Firestore
      await firestore.collection('reg').add({
        'fullName': fullname,
        'username': username,
        'dob': dob,
        'age': age,
        'collegeName': collegename,
        'email': email,
        'password': password,
      });

      // Clear text fields after saving
      _fullNameController.clear();
      _usernameController.clear();
      _ageController.clear();
      _collegeNameController.clear();
      _emailController.clear();
      _passwordController.clear();

      // Show a message indicating successful save
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User data saved successfully!'),
        ),
      );
    } else {
      // Show an error message if any field is empty or date is not selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all the fields and select a date.'),
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dobController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuItemSelected,
            itemBuilder: (BuildContext context) {
              return menuItems.map((String menuItem) {
                return PopupMenuItem<String>(
                  value: menuItem,
                  child: Text(menuItem),
                );
              }).toList();
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.person_add, size: 60, color: Colors.blue),
              const SizedBox(height: 10),
              const Text('Sign Up',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text("Let's create an account",
                  style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),

              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person), // Icon to the left
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.account_circle), // Icon to the left
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              // Replace TextFormField for DOB with TextButton
              TextButton(
                onPressed: () => _selectDate(context),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today), // Icon to the left
                    const SizedBox(width: 10),
                    Text(
                      _selectedDate != null
                          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                          : 'Select Date of Birth', // Show selected date or placeholder
                    ),
                  ],
                ),
              ),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  prefixIcon: Icon(Icons.event), // Icon to the left
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _collegeNameController,
                decoration: const InputDecoration(
                  labelText: 'College Name',
                  prefixIcon: Icon(Icons.school), // Icon to the left
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your college name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email), // Icon to the left
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock), // Icon to the left
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
                obscureText: true,
              ),
              const SizedBox(height: 20), // A

              SizedBox(
                width: double
                    .infinity, // Make the sign-up button width match the parent
                child: ElevatedButton(
                  onPressed: _saveUserData,
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(
                        const Size(double.infinity, 48)), // Set button width
                  ),
                  child: const Text('Sign Up'),
                ),
              ),

              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  // Navigate to sign-in page
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()));
                },
                child: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(color: Colors.black54),
                      ),
                      TextSpan(
                        text: 'Login',
                        style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      // Place PopupMenuButton here, outside of AppBar
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: PopupMenuButton<String>(
          onSelected: _handleMenuItemSelected,
          itemBuilder: (BuildContext context) {
            return menuItems.map((String menuItem) {
              return PopupMenuItem<String>(
                value: menuItem,
                child: Text(menuItem),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}

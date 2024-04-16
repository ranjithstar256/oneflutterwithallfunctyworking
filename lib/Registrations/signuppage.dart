import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oneflutter/ParticipantsFiles/CoordinatorDetailsScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'LoginPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

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

class UserSignUpPage extends StatefulWidget {
  const UserSignUpPage({Key? key});

  @override
  _UserSignUpPageState createState() => _UserSignUpPageState();
}

class _UserSignUpPageState extends State<UserSignUpPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _collegeNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  String _participantType = 'Male';

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _dobController.addListener(_calculateAge);
  }

  @override
  void dispose() {
    _dobController.removeListener(_calculateAge);
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
      String dob = DateFormat('yyyy-MM-dd').format(_selectedDate!);

      // Get Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Add user data to Firestore
      await firestore.collection('studentsSignUps').add({
        'fullName': fullname,
        'username': username,
        'dob': dob,
        'gender': _participantType,
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
      _participantType = 'Male';

      // Show a message indicating successful save
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User data saved successfully!'),
        ),
      );

      await saveEmailid(email);
      setLoggedIn(true);
      // Navigate to AllEvents after successful sign-up
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CoordinatorDetailsScreen()),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Create an Account',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _fullNameController,
              labelText: 'Full Name',
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: 12),
            _buildInputField(
              controller: _usernameController,
              labelText: 'Username',
              prefixIcon: Icons.account_circle,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => _selectDate(context),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 10),
                  Text(
                    _selectedDate != null
                        ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                        : 'Select Date of Birth',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildInputField(
              controller: _ageController,
              labelText: 'Age',
              prefixIcon: Icons.event,
            ),
            const SizedBox(height: 12),
            _buildGenderSelection(),
            const SizedBox(height: 12),
            _buildInputField(
              controller: _collegeNameController,
              labelText: 'College Name',
              prefixIcon: Icons.school,
            ),
            const SizedBox(height: 12),
            _buildInputField(
              controller: _emailController,
              labelText: 'Email',
              prefixIcon: Icons.email,
            ),
            const SizedBox(height: 12),
            _buildInputField(
              controller: _passwordController,
              labelText: 'Password',
              prefixIcon: Icons.lock,
              isPassword: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveUserData,
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
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
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
      ),
      obscureText: isPassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $labelText';
        }
        return null;
      },
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Radio(
              value: 'Male',
              groupValue: _participantType,
              onChanged: (value) {
                setState(() {
                  _participantType = value.toString();
                });
              },
            ),
            const Text('Male'),
            Radio(
              value: 'Female',
              groupValue: _participantType,
              onChanged: (value) {
                setState(() {
                  _participantType = value.toString();
                });
              },
            ),
            const Text('Female'),
            Radio(
              value: 'Transgender',
              groupValue: _participantType,
              onChanged: (value) {
                setState(() {
                  _participantType = value.toString();
                });
              },
            ),
            const Text('Transgender'),
          ],
        ),
      ],
    );
  }

  Future<void> saveEmailid(String mobileNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('UsermobileNumber', mobileNumber);
  }
}

Future<void> setLoggedIn(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('partiloggedin', value);
}

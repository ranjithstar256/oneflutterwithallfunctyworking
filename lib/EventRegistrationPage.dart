import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set status bar and action bar colors
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.green[200], // Set status bar color to light green
      systemNavigationBarColor:
          Colors.green[900], // Set navigation bar color to dark green
      statusBarIconBrightness:
          Brightness.dark, // Set status bar icons to dark color
      systemNavigationBarIconBrightness:
          Brightness.light, // Set navigation bar icons to light color
    ),
  );
  await Firebase.initializeApp();
  runApp(MaterialApp(
      //home: EventRegistrationPage(),
      ));
}

class EventRegistrationPage extends StatelessWidget {
  final String eventName;
  final String eventDate;
  final String venue;
  bool isTeamGame; // Variable to indicate if it's a team game or not
  final String coordinatorId; // Coordinator ID

  EventRegistrationPage({
    required this.eventName,
    required this.eventDate,
    required this.venue,
    required this.isTeamGame,
    required this.coordinatorId,
  });

  final TextEditingController participantNameController =
      TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController collegeNameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController teamNameController = TextEditingController();
  final TextEditingController memberNamesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Wrap Column with SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display event details
              Text('Event: $eventName'),
              Text('Date: $eventDate'),
              Text('Venue: $venue'),

              // Different registration form based on game type
              isTeamGame
                  ? _buildTeamRegistrationForm()
                  : _buildIndividualRegistrationForm(),

              ElevatedButton(
                onPressed: () {
                  // Handle form submission and data saving to Firestore
                  _saveFormData(context);
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndividualRegistrationForm() {
    // Return form for individual game registration
    return Column(
      children: [
        TextField(
          controller: participantNameController,
          decoration: const InputDecoration(labelText: 'Participant Name'),
        ),
        TextField(
          controller: ageController,
          decoration: const InputDecoration(labelText: 'Age'),
        ),
        TextField(
          controller: collegeNameController,
          decoration: const InputDecoration(labelText: 'College Name'),
        ),
        TextField(
          controller: genderController,
          decoration: const InputDecoration(labelText: 'Gender'),
        ),
        TextField(
          controller: mobileController,
          decoration: const InputDecoration(labelText: 'Mobile'),
        ),
        TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
      ],
    );
  }

  Widget _buildTeamRegistrationForm() {
    // Return form for team game registration
    return Column(
      children: [
        TextField(
          controller: teamNameController,
          decoration: const InputDecoration(labelText: 'Team Name'),
        ),
        TextField(
          controller: memberNamesController,
          decoration: const InputDecoration(labelText: 'Member Names'),
        ),
        TextField(
          controller: collegeNameController,
          decoration: const InputDecoration(labelText: 'College Name'),
        ),
        TextField(
          controller: genderController,
          decoration: const InputDecoration(labelText: 'Gender'),
        ),
        TextField(
          controller: mobileController,
          decoration: const InputDecoration(labelText: 'Mobile'),
        ),
        TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
      ],
    );
  }

  // Method to save form data to Firestore
  void _saveFormData(BuildContext context) async {
    // Access Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Get data from text controllers
    String participantName = participantNameController.text;
    int age = int.tryParse(ageController.text) ?? 0; // Parse age as integer
    String collegeName = collegeNameController.text;
    String gender = genderController.text;
    String mobile = mobileController.text;
    String email = emailController.text;
    String teamName = teamNameController.text;
    String memberNames = memberNamesController.text;

    // Example document reference path
    DocumentReference eventDocRef =
        firestore.collection('events').doc(eventName);

    try {
      // Save data to Firestore under coordinator's document
      await eventDocRef.collection('participants').doc(coordinatorId).set({
        'participantName': participantName,
        'age': age,
        'collegeName': collegeName,
        'gender': gender,
        'mobile': mobile,
        'email': email,
        'teamName': teamName,
        'memberNames': memberNames,
      });
      // Data saved successfully
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Registration data saved successfully'),
        duration: Duration(seconds: 2),
      ));
      // Clear text fields after successful save
      participantNameController.clear();
      ageController.clear();
      collegeNameController.clear();
      genderController.clear();
      mobileController.clear();
      emailController.clear();
      teamNameController.clear();
      memberNamesController.clear();
    } catch (error) {
      // Error handling
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error saving registration data: $error'),
        duration: const Duration(seconds: 2),
      ));
    }
  }
}

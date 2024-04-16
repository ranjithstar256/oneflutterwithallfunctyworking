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
  runApp(const MaterialApp(
      //home: EventRegistrationPage(),
      ));
}

class EventRegistrationPage extends StatefulWidget {
  final String eventName;
  final String eventDate;
  final String venue;
  bool isTeamGame;
  final String coordinatorId;
  final String participantType;
  final int teamsize;

  EventRegistrationPage({
    required this.eventName,
    required this.eventDate,
    required this.venue,
    required this.isTeamGame,
    required this.coordinatorId,
    required this.participantType,
    required this.teamsize,
  });

  @override
  _EventRegistrationPageState createState() => _EventRegistrationPageState();
}

class _EventRegistrationPageState extends State<EventRegistrationPage> {
  final TextEditingController participantNameController =
      TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController collegeNameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController teamNameController = TextEditingController();
  final TextEditingController memberNamesController = TextEditingController();

  //final TextEditingController eventNameController = TextEditingController();
  List<String> memberNamesList = [];

  // Define a variable to hold the selected gender
  String selectedGender = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Registration'),
        backgroundColor: const Color(0xFF4C9085), // Custom app bar color
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Event: ${widget.eventName}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    'Date: ${widget.eventDate}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Venue: ${widget.venue}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            _buildIndividualRegistrationForm(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _saveFormData(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF4C9085), // Custom button color
                  minimumSize: const Size(double.infinity, 48),
                ),
                child:
                    const Text('Submit', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndividualRegistrationForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: participantNameController,
            labelText: 'Participant Name',
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: ageController,
            labelText: 'Age',
          ),
          const SizedBox(height: 12),
          const Text(
            'Gender',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Wrap(
            direction: Axis.horizontal,
            // Changed to horizontal to allow wrapping
            spacing: 8.0,
            // Reduced spacing between children
            runSpacing: 4.0,
            // Reduced spacing between runs
            children: [
              if (widget.participantType == 'Both' ||
                  widget.participantType == 'Male')
                _buildGenderRadioButton('Male'),
              if (widget.participantType == 'Both' ||
                  widget.participantType == 'Female')
                _buildGenderRadioButton('Female'),
              if (widget.participantType == 'Both')
                _buildGenderRadioButton('Transgender'),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: collegeNameController,
            labelText: 'College Name',
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: mobileController,
            labelText: 'Mobile',
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: emailController,
            labelText: 'Email',
          ),
          const SizedBox(height: 24),
          const SizedBox(height: 12),
          if (widget.isTeamGame) const Text('Team Event Data'),
          const SizedBox(height: 12),
          if (widget.isTeamGame)
            _buildTextField(
              controller: teamNameController,
              labelText: 'Team Name',
            ),
          const SizedBox(height: 12),
          if (widget.isTeamGame)
            MultipleNamesTextField(
              onUpdateMemberNames: (List<String> names) {
                memberNamesList = names;
              },
              teamsize: widget.teamsize,
            ),
        ],
      ),
    );
  }

  Widget _buildGenderRadioButton(String gender) {
    return Row(
      children: [
        Radio<String>(
          value: gender,
          groupValue: selectedGender,
          onChanged: (value) {
            setState(() {
              selectedGender = value!;
            });
          },
        ),
        Text(gender),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey), // Add border decoration
        borderRadius: BorderRadius.circular(8.0), // Add border radius
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          labelText: labelText,
          border: InputBorder.none, // Remove default border
        ),
      ),
    );
  }

  void _saveFormData(BuildContext context) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    String participantName = participantNameController.text.trim();
    int age = int.tryParse(ageController.text) ?? 0;
    String collegeName = collegeNameController.text.trim();

    String mobile = mobileController.text.trim();
    String email = emailController.text.trim();
    String teamName = teamNameController.text.trim();
    String eventName = widget.eventName;
    String stcoordinatorId =
        widget.coordinatorId; // Get coordinatorId from widget

    try {
      await firestore
          .collection('events')
          .doc(eventName)
          .collection('participants')
          .add({
        'participantName': participantName,
        'age': age,
        'collegeName': collegeName,
        'gender': selectedGender,
        'mobile': mobile,
        'email': email,
        'teamName': teamName,
        'coordinatorid': stcoordinatorId, // Save coordinatorId in Firestore
        'memberNames': memberNamesList.join(', '),
      });

      // Show success message and clear form fields
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Registration data saved successfully'),
        duration: Duration(seconds: 2),
      ));
      // Clear form fields
      // ...
    } catch (error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error saving registration data: $error'),
        duration: const Duration(seconds: 2),
      ));
    }
  }
}

class MultipleNamesTextField extends StatefulWidget {
  final Function(List<String>) onUpdateMemberNames;
  final int teamsize;

  MultipleNamesTextField({
    required this.onUpdateMemberNames,
    required this.teamsize,
  });

  @override
  _MultipleNamesTextFieldState createState() => _MultipleNamesTextFieldState();
}

class _MultipleNamesTextFieldState extends State<MultipleNamesTextField> {
  TextEditingController memberNamesController = TextEditingController();
  List<String> memberNames = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Member Names',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: memberNamesController,
          decoration: InputDecoration(
            labelText: 'Enter a name',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (memberNames.length < widget.teamsize) {
                  setState(() {
                    memberNames.add(memberNamesController.text);
                    memberNamesController.clear();
                    widget.onUpdateMemberNames(memberNames);
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Team size limit reached'),
                    ),
                  );
                }
              },
            ),
          ),
          onSubmitted: (value) {
            if (memberNames.length < widget.teamsize) {
              setState(() {
                memberNames.add(value);
                memberNamesController.clear();
                widget.onUpdateMemberNames(memberNames);
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Team size limit reached'),
                ),
              );
            }
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Members:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          itemCount: memberNames.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Text('${index + 1}.'),
              title: Text(memberNames[index]),
            );
          },
        ),
      ],
    );
  }
}

/*import 'package:cloud_firestore/cloud_firestore.dart';
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
  runApp(const MaterialApp(
      //home: EventRegistrationPage(),
      ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: EventRegistrationPage(
        eventName: 'Sample Event',
        eventDate: '2024-04-16',
        venue: 'Sample Venue',
        isTeamGame: true,
        coordinatorId: 'coordinator123',
      ),
    );
  }
}

class EventRegistrationPage extends StatefulWidget {
  final String eventName;
  final String eventDate;
  final String venue;
  final bool isTeamGame;
  final String coordinatorId;

  EventRegistrationPage({
    required this.eventName,
    required this.eventDate,
    required this.venue,
    required this.isTeamGame,
    required this.coordinatorId,
  });

  @override
  _EventRegistrationPageState createState() => _EventRegistrationPageState();
}

class _EventRegistrationPageState extends State<EventRegistrationPage> {
  final TextEditingController participantNameController =
      TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController collegeNameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController teamNameController = TextEditingController();
  List<String> memberNamesList = [];
  String selectedGender = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Registration'),
        backgroundColor: const Color(0xFF4C9085),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEventDetails(),
            _buildIndividualRegistrationForm(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _saveFormData(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4C9085),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child:
                    const Text('Submit', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event: ${widget.eventName}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          Text(
            'Date: ${widget.eventDate}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            'Venue: ${widget.venue}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndividualRegistrationForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: participantNameController,
            labelText: 'Participant Name',
          ),
          SizedBox(height: 12),
          _buildTextField(
            controller: ageController,
            labelText: 'Age',
          ),
          SizedBox(height: 12),
          _buildTextField(
            controller: collegeNameController,
            labelText: 'College Name',
          ),
          SizedBox(height: 12),
          _buildGenderSelection(),
          SizedBox(height: 12),
          _buildTextField(
            controller: mobileController,
            labelText: 'Mobile',
          ),
          SizedBox(height: 12),
          _buildTextField(
            controller: emailController,
            labelText: 'Email',
          ),
          if (widget.isTeamGame)
            TeamRegistrationForm(
              onTeamNameChanged: (teamName) {},
              onMemberNamesChanged: (memberNames) {
                setState(() {
                  memberNamesList = memberNames;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Row(
      children: [
        Flexible(
          child: Radio<String>(
            value: 'Male',
            groupValue: selectedGender,
            onChanged: (value) {
              setState(() {
                selectedGender = value!;
              });
            },
          ),
        ),
        const Text('Male'),
        Flexible(
          child: Radio<String>(
            value: 'Female',
            groupValue: selectedGender,
            onChanged: (value) {
              setState(() {
                selectedGender = value!;
              });
            },
          ),
        ),
        const Text('Female', style: TextStyle(fontSize: 12)),
        Flexible(
          child: Radio<String>(
            value: 'Transgender',
            groupValue: selectedGender,
            onChanged: (value) {
              setState(() {
                selectedGender = value!;
              });
            },
          ),
        ),
        const Text('Transgender', style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          labelText: labelText,
          border: InputBorder.none,
        ),
      ),
    );
  }

  void _saveFormData(BuildContext context) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    String participantName = participantNameController.text.trim();
    int age = int.tryParse(ageController.text) ?? 0;
    String collegeName = collegeNameController.text.trim();
    String gender = selectedGender;
    String mobile = mobileController.text.trim();
    String email = emailController.text.trim();
    String teamName = teamNameController.text.trim();
    String eventName = widget.eventName;
    String stcoordinatorId = widget.coordinatorId;

    // Basic validation
    if (participantName.isEmpty ||
        age == 0 ||
        collegeName.isEmpty ||
        gender.isEmpty ||
        mobile.isEmpty ||
        email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill in all required fields'),
        duration: Duration(seconds: 2),
      ));
      return;
    }

    try {
      await firestore
          .collection('events')
          .doc(eventName)
          .collection('participants')
          .add({
        'participantName': participantName,
        'age': age,
        'collegeName': collegeName,
        'gender': gender,
        'mobile': mobile,
        'email': email,
        'teamName': teamName,
        'coordinatorid': stcoordinatorId,
        'memberNames': memberNamesList.join(', '),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Registration data saved successfully'),
        duration: Duration(seconds: 2),
      ));

      // Clear form fields
      participantNameController.clear();
      ageController.clear();
      collegeNameController.clear();
      genderController.clear();
      mobileController.clear();
      emailController.clear();
      teamNameController.clear();
      memberNamesList.clear();
      selectedGender = '';
    } on FirebaseException catch (e) {
      // Handle Firestore errors
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error saving registration data: ${e.message}'),
        duration: const Duration(seconds: 2),
      ));
    } catch (error) {
      // Handle other errors
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An unexpected error occurred: $error'),
        duration: const Duration(seconds: 2),
      ));
    }
  }
}

class MultipleNamesTextField extends StatefulWidget {
  final Function(List<String>) onUpdateMemberNames;

  MultipleNamesTextField({required this.onUpdateMemberNames});

  @override
  _MultipleNamesTextFieldState createState() => _MultipleNamesTextFieldState();
}

class _MultipleNamesTextFieldState extends State<MultipleNamesTextField> {
  final TextEditingController memberNamesController = TextEditingController();
  List<String> memberNames = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Member Names',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: memberNamesController,
          decoration: InputDecoration(
            labelText: 'Enter a name',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                setState(() {
                  memberNames.add(memberNamesController.text);
                  memberNamesController.clear();
                  widget.onUpdateMemberNames(memberNames);
                });
              },
            ),
          ),
          onSubmitted: (value) {
            setState(() {
              memberNames.add(value);
              memberNamesController.clear();
              widget.onUpdateMemberNames(memberNames);
            });
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Members:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          itemCount: memberNames.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Text('${index + 1}.'),
              title: Text(memberNames[index]),
            );
          },
        ),
      ],
    );
  }
}

class TeamRegistrationForm extends StatefulWidget {
  final Function(String) onTeamNameChanged;
  final Function(List<String>) onMemberNamesChanged;

  TeamRegistrationForm({
    required this.onTeamNameChanged,
    required this.onMemberNamesChanged,
  });

  @override
  _TeamRegistrationFormState createState() => _TeamRegistrationFormState();
}

class _TeamRegistrationFormState extends State<TeamRegistrationForm> {
  final TextEditingController teamNameController = TextEditingController();
  final TextEditingController participantNameController =
      TextEditingController();
  final TextEditingController collegeNameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  List<String> memberNamesList = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: teamNameController,
          labelText: 'Team Name',
          onChanged: (value) => widget.onTeamNameChanged(value),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: participantNameController,
          labelText: 'Participant Name',
        ),
        _buildTextField(
          controller: collegeNameController,
          labelText: 'College Name',
        ),
        _buildTextField(
          controller: genderController,
          labelText: 'Gender',
        ),
        _buildTextField(
          controller: mobileController,
          labelText: 'Mobile',
        ),
        _buildTextField(
          controller: emailController,
          labelText: 'Email',
        ),
        const SizedBox(height: 12),
        MultipleNamesTextField(
          onUpdateMemberNames: (List<String> names) {
            setState(() {
              memberNamesList = names;
              widget.onMemberNamesChanged(names);
            });
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          labelText: labelText,
          border: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
    );
  }
}*/

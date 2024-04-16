import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
            return CoOrdinatorLogin();
          }
        },
      ),
    );
  }
}

class CoOrdinatorLogin extends StatefulWidget {
  @override
  _CoOrdinatorLoginPageState createState() => _CoOrdinatorLoginPageState();
}

class _CoOrdinatorLoginPageState extends State<CoOrdinatorLogin> {
  final TextEditingController _collegeNameController = TextEditingController();
  final TextEditingController _coordinatoridController =
      TextEditingController();
  final TextEditingController _coordinatorNameController =
      TextEditingController();
  final TextEditingController _coordinatorEventNameController =
      TextEditingController();
  final TextEditingController _coordinatorvenueController =
      TextEditingController();
  bool _isSaving = false;
  DateTime? fromDate;
  DateTime? toDate;
  File? collegePic;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickFile() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        collegePic = File(picked.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (picked != null) {
      setState(() {
        fromDate = picked.start;
        toDate = picked.end;
      });
    }
  }

  void _checkCombo(BuildContext context) async {
    setState(() {
      _isSaving = true;
    });
    String collegeName = _collegeNameController.text.trim();
    String stcoordinatorid = _coordinatoridController.text.trim();
    String coordinatorName = _coordinatorNameController.text.trim();
    String eventName = _coordinatorEventNameController.text.trim();
    String venue = _coordinatorvenueController.text.trim();

    // Check if all required fields are filled
    if (collegeName.isEmpty ||
        stcoordinatorid.isEmpty ||
        coordinatorName.isEmpty ||
        venue.isEmpty ||
        eventName.isEmpty ||
        fromDate == null ||
        toDate == null ||
        collegePic == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill all the fields and upload college picture'),
        backgroundColor: Colors.red,
      ));
      setState(() {
        _isSaving = false;
      });
      return;
    }

    try {
      // Upload the college picture to Firebase Storage
      await _uploadCollegePic(stcoordinatorid);
      setState(() {
        _isSaving = false;
      });
    } catch (error) {
      // Show error message if saving fails
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to save coordinator details: $error'),
        backgroundColor: Colors.red,
      ));

      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _uploadCollegePic(String coordinatorid) async {
    if (collegePic != null) {
      try {
        // Upload the image to Firebase Storage
        final Reference ref = FirebaseStorage.instance
            .ref()
            .child('college_coordinators')
            .child(coordinatorid)
            .child('college_pics')
            .child('college_pic_${DateTime.now().millisecondsSinceEpoch}.jpg');

        await ref.putFile(collegePic!);

        // Get the download URL for the uploaded image
        final String downloadURL = await ref.getDownloadURL();
        String formattedFromDate = DateFormat('dd-MM-yyyy').format(fromDate!);
        String formattedToDate = DateFormat('dd-MM-yyyy').format(toDate!);

        // Save coordinator details to Firestore along with the image URL
        await _firestore.collection('coordinators').add({
          'collegeName': _collegeNameController.text.trim(),
          'coordinatorid': _coordinatoridController.text.trim(),
          'coordinatorName': _coordinatorNameController.text.trim(),
          'venue': _coordinatorvenueController.text.trim(),
          'fromDate': formattedFromDate,
          'toDate': formattedToDate,
          'eventName': _coordinatorEventNameController.text.trim(),
          'collegePicUrl': downloadURL,
        });

        // Save coordinator ID to SharedPreferences
        await setcoid(coordinatorid);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Coordinator details saved successfully'),
          backgroundColor: Colors.green,
        ));

        // Clear the form fields
        _collegeNameController.clear();
        _coordinatoridController.clear();
        _coordinatorNameController.clear();
        _coordinatorEventNameController.clear();
        _coordinatorvenueController.clear();

        setState(() {
          fromDate = null;
          toDate = null;
          collegePic = null;
        });
        setLoggedIn(true);
      } catch (error) {
        // Show error message if saving fails
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to save coordinator details: $error'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Co-ordinator Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Builder(
            builder: (context) => Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          controller: _collegeNameController,
                          decoration: const InputDecoration(
                            labelText: 'College Name',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          controller: _coordinatoridController,
                          decoration: const InputDecoration(
                            labelText: 'Co - Ordinatorid',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          controller: _coordinatorEventNameController,
                          decoration: const InputDecoration(
                            labelText: 'Event Name',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          controller: _coordinatorvenueController,
                          decoration: const InputDecoration(
                            labelText: 'Venue',
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => pickFile(),
                        child: const Text('Upload College Picture'),
                      ),
                      if (collegePic != null)
                        Image.file(
                          collegePic!,
                          height: 100,
                          width: 100,
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          controller: _coordinatorNameController,
                          decoration: const InputDecoration(
                            labelText: 'Coordinator Name',
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _selectDate(context),
                        child: Text(
                          'Select Event Date: \n ${fromDate != null && toDate != null ? "${fromDate!.toLocal().toString().split(' ')[0]} - ${toDate!.toLocal().toString().split(' ')[0]}" : "Choose Dates"}',
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _checkCombo(context),
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                ),
                if (_isSaving)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
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

/* void _showDialog(BuildContext context, String prcoordinatorid) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose an action'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setLoggedIn(true);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ViewRegistrationPage(coordinatorId: prcoordinatorid),
                  ),
                );
              },
              child: const Text('View Registration'),
            ),
            TextButton(
              onPressed: () {
                setLoggedIn(true);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddEventPage(coordinatorId: prcoordinatorid),
                  ),
                );
              },
              child: const Text('Add Event'),
            ),
          ],
        );
      },
    );
  }*/

/* void _showDialog(BuildContext context, String prcoordinatorid) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose an action'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setLoggedIn(true);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ViewRegistrationPage(coordinatorId: prcoordinatorid),
                  ),
                );
              },
              child: const Text('View Registration'),
            ),
            TextButton(
              onPressed: () {
                setLoggedIn(true);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddEventPage(coordinatorId: prcoordinatorid),
                  ),
                );
              },
              child: const Text('Add Event'),
            ),
          ],
        );
      },
    );
  }*/

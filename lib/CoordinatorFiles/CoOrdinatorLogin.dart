import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

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
      title: 'Co-ordinator Login ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CoOrdinatorLogin(),
    );
  }
}

class CoOrdinatorLogin extends StatefulWidget {
  @override
  _CoOrdinatorLoginPageState createState() => _CoOrdinatorLoginPageState();
}

class _CoOrdinatorLoginPageState extends State<CoOrdinatorLogin> {
  final TextEditingController _collegeNameController = TextEditingController();
  final TextEditingController _collegeIdController = TextEditingController();
  final TextEditingController _coordinatorNameController =
      TextEditingController();
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
    String collegeName = _collegeNameController.text.trim();
    String collegeId = _collegeIdController.text.trim();
    String coordinatorName = _coordinatorNameController.text.trim();
    String formattedFromDate = DateFormat('dd-MM-yyyy').format(fromDate!);
    String formattedToDate = DateFormat('dd-MM-yyyy').format(toDate!);

    // Check if all required fields are filled
    if (collegeName.isEmpty ||
        collegeId.isEmpty ||
        coordinatorName.isEmpty ||
        fromDate == null ||
        toDate == null ||
        collegePic == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill all the fields and upload college picture'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    try {
      // Save coordinator details to Firestore
      await _firestore.collection('coordinators').add({
        'collegeName': collegeName,
        'collegeId': collegeId,
        'coordinatorName': coordinatorName,
        'fromDate': formattedFromDate,
        'toDate': formattedToDate,
        // You may need to adjust this according to how you store images in Firestore
        'collegePicUrl': '',
        // Placeholder for now
      });

      // Upload the college picture to Firebase Storage
      await _uploadCollegePic(collegeId);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Coordinator details saved successfully'),
        backgroundColor: Colors.green,
      ));

      // Clear the form fields
      _collegeNameController.clear();
      _collegeIdController.clear();
      _coordinatorNameController.clear();
      setState(() {
        fromDate = null;
        toDate = null;
        collegePic = null;
      });
    } catch (error) {
      // Show error message if saving fails
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to save coordinator details: $error'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose an action'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ViewRegistrationPage()),
                );
              },
              child: const Text('View Registration'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddEventPage()),
                );
              },
              child: const Text('Add Event'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadCollegePic(String collegeId) async {
    if (collegePic != null) {
      try {
        // Upload the image to Firebase Storage
        final Reference ref = FirebaseStorage.instance
            .ref()
            .child('college_coordinators')
            .child(collegeId)
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
          'collegeId': _collegeIdController.text.trim(),
          'coordinatorName': _coordinatorNameController.text.trim(),
          'fromDate': formattedFromDate,
          'toDate': formattedToDate,
          'collegePicUrl': downloadURL,
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Coordinator details saved successfully'),
          backgroundColor: Colors.green,
        ));

        // Clear the form fields
        _collegeNameController.clear();
        _collegeIdController.clear();
        _coordinatorNameController.clear();
        setState(() {
          fromDate = null;
          toDate = null;
          collegePic = null;
        });
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
          padding: EdgeInsets.all(20),
          child: Center(
            child: Builder(
              builder: (context) => SingleChildScrollView(
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
                        controller: _collegeIdController,
                        decoration: const InputDecoration(
                          labelText: 'College ID',
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
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}

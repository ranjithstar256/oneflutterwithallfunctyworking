import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:oneflutter/CoOrdinatorSignIn.dart';
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
            return CoOrdinatorSignUp();
          }
        },
      ),
    );
  }
}

class CoOrdinatorSignUp extends StatefulWidget {
  @override
  _CoOrdinatorLoginPageState createState() => _CoOrdinatorLoginPageState();
}

class _CoOrdinatorLoginPageState extends State<CoOrdinatorSignUp> {
  final TextEditingController _collegeNameController = TextEditingController();
  final TextEditingController _coordinatoridController =
      TextEditingController();
  final TextEditingController _coordinatorNameController =
      TextEditingController();
  final TextEditingController _coordinatorEventNameController =
      TextEditingController();
  final TextEditingController _coordinatorvenueController =
      TextEditingController();
  final TextEditingController _coordinatorpasswordController =
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
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });
      String collegeName = _collegeNameController.text.trim();
      String stcoordinatorid = _coordinatoridController.text.trim();
      String coordinatorName = _coordinatorNameController.text.trim();
      String eventName = _coordinatorEventNameController.text.trim();
      String venue = _coordinatorvenueController.text.trim();
      String password = _coordinatorpasswordController.text.trim();

      // Check if all required fields are filled
      if (collegeName.isEmpty ||
          stcoordinatorid.isEmpty ||
          coordinatorName.isEmpty ||
          venue.isEmpty ||
          password.isEmpty ||
          eventName.isEmpty ||
          fromDate == null ||
          toDate == null ||
          collegePic == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Please fill all the fields and upload college picture'),
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
          'cooripassword': _coordinatorpasswordController.text.trim(),
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
        _coordinatorpasswordController.clear();

        setState(() {
          fromDate = null;
          toDate = null;
          collegePic = null;
        });
        setLoggedIn(true);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CoordinatorActionScreen()),
        );
      } catch (error) {
        // Show error message if saving fails
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to save coordinator details: $error'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextFormField(
                            controller: _coordinatoridController,
                            style: GoogleFonts.inter(
                              fontSize: 18.0,
                              color: const Color(0xFF151624),
                            ),
                            maxLines: 1,
                            cursorColor: const Color(0xFF151624),
                            decoration: InputDecoration(
                              labelText: 'Co - Ordinatorid',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 16.0,
                                color: const Color(0xFF151624).withOpacity(0.5),
                              ),
                              fillColor:
                                  _coordinatoridController.text.isNotEmpty
                                      ? Colors.transparent
                                      : const Color.fromRGBO(248, 247, 251, 1),
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: BorderSide(
                                  color: _coordinatoridController.text.isEmpty
                                      ? Colors.transparent
                                      : const Color.fromRGBO(44, 185, 176, 1),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(44, 185, 176, 1),
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.type_specimen,
                                color: _coordinatoridController.text.isEmpty
                                    ? const Color(0xFF151624).withOpacity(0.5)
                                    : const Color.fromRGBO(44, 185, 176, 1),
                                size: 16,
                              ),
                              suffix: Container(
                                alignment: Alignment.center,
                                width: 24.0,
                                height: 24.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100.0),
                                  color: const Color.fromRGBO(44, 185, 176, 1),
                                ),
                                child: _coordinatoridController.text.isEmpty
                                    ? const Center()
                                    : const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 13,
                                      ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your coordinator ID';
                              }
                              if (value.length < 7 || value.length > 16) {
                                return 'Coordinator ID must be between 7 and 16 characters long';
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextFormField(
                            controller: _coordinatorpasswordController,
                            style: GoogleFonts.inter(
                              fontSize: 18.0,
                              color: const Color(0xFF151624),
                            ),
                            maxLines: 1,
                            cursorColor: const Color(0xFF151624),
                            decoration: InputDecoration(
                              labelText: 'Enter password',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 16.0,
                                color: const Color(0xFF151624).withOpacity(0.5),
                              ),
                              fillColor:
                                  _coordinatorpasswordController.text.isNotEmpty
                                      ? Colors.transparent
                                      : const Color.fromRGBO(248, 247, 251, 1),
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: BorderSide(
                                  color: _coordinatorpasswordController
                                          .text.isEmpty
                                      ? Colors.transparent
                                      : const Color.fromRGBO(44, 185, 176, 1),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(44, 185, 176, 1),
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline_rounded,
                                color: _coordinatorpasswordController
                                        .text.isEmpty
                                    ? const Color(0xFF151624).withOpacity(0.5)
                                    : const Color.fromRGBO(44, 185, 176, 1),
                                size: 16,
                              ),
                              suffix: Container(
                                alignment: Alignment.center,
                                width: 24.0,
                                height: 24.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100.0),
                                  color: const Color.fromRGBO(44, 185, 176, 1),
                                ),
                                child:
                                    _coordinatorpasswordController.text.isEmpty
                                        ? const Center()
                                        : const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 13,
                                          ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 8 || value.length > 16) {
                                return 'Password must be between 8 and 16 characters long';
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextFormField(
                            controller: _collegeNameController,
                            style: GoogleFonts.inter(
                              fontSize: 18.0,
                              color: const Color(0xFF151624),
                            ),
                            maxLines: 1,
                            cursorColor: const Color(0xFF151624),
                            decoration: InputDecoration(
                              labelText: 'College Name',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 16.0,
                                color: const Color(0xFF151624).withOpacity(0.5),
                              ),
                              fillColor: _collegeNameController.text.isNotEmpty
                                  ? Colors.transparent
                                  : const Color.fromRGBO(248, 247, 251, 1),
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: BorderSide(
                                  color: _collegeNameController.text.isEmpty
                                      ? Colors.transparent
                                      : const Color.fromRGBO(44, 185, 176, 1),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(44, 185, 176, 1),
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.type_specimen,
                                color: _collegeNameController.text.isEmpty
                                    ? const Color(0xFF151624).withOpacity(0.5)
                                    : const Color.fromRGBO(44, 185, 176, 1),
                                size: 16,
                              ),
                              suffix: Container(
                                alignment: Alignment.center,
                                width: 24.0,
                                height: 24.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100.0),
                                  color: const Color.fromRGBO(44, 185, 176, 1),
                                ),
                                child: _collegeNameController.text.isEmpty
                                    ? const Center()
                                    : const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 13,
                                      ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your college name';
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextFormField(
                            controller: _coordinatorEventNameController,
                            style: GoogleFonts.inter(
                              fontSize: 18.0,
                              color: const Color(0xFF151624),
                            ),
                            maxLines: 1,
                            cursorColor: const Color(0xFF151624),
                            decoration: InputDecoration(
                              labelText: 'Event Name',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 16.0,
                                color: const Color(0xFF151624).withOpacity(0.5),
                              ),
                              fillColor: _coordinatorEventNameController
                                      .text.isNotEmpty
                                  ? Colors.transparent
                                  : const Color.fromRGBO(248, 247, 251, 1),
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: BorderSide(
                                  color: _coordinatorEventNameController
                                          .text.isEmpty
                                      ? Colors.transparent
                                      : const Color.fromRGBO(44, 185, 176, 1),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(44, 185, 176, 1),
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.event,
                                color: _coordinatorEventNameController
                                        .text.isEmpty
                                    ? const Color(0xFF151624).withOpacity(0.5)
                                    : const Color.fromRGBO(44, 185, 176, 1),
                                size: 16,
                              ),
                              suffix: Container(
                                alignment: Alignment.center,
                                width: 24.0,
                                height: 24.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100.0),
                                  color: const Color.fromRGBO(44, 185, 176, 1),
                                ),
                                child:
                                    _coordinatorEventNameController.text.isEmpty
                                        ? const Center()
                                        : const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 13,
                                          ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter event name';
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextFormField(
                            controller: _coordinatorvenueController,
                            style: GoogleFonts.inter(
                              fontSize: 18.0,
                              color: const Color(0xFF151624),
                            ),
                            maxLines: 1,
                            cursorColor: const Color(0xFF151624),
                            decoration: InputDecoration(
                              labelText: 'Venue',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 16.0,
                                color: const Color(0xFF151624).withOpacity(0.5),
                              ),
                              fillColor:
                                  _coordinatorvenueController.text.isNotEmpty
                                      ? Colors.transparent
                                      : const Color.fromRGBO(248, 247, 251, 1),
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: BorderSide(
                                  color: _coordinatorvenueController
                                          .text.isEmpty
                                      ? Colors.transparent
                                      : const Color.fromRGBO(44, 185, 176, 1),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(44, 185, 176, 1),
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.location_on_outlined,
                                color: _coordinatorvenueController.text.isEmpty
                                    ? const Color(0xFF151624).withOpacity(0.5)
                                    : const Color.fromRGBO(44, 185, 176, 1),
                                size: 16,
                              ),
                              suffix: Container(
                                alignment: Alignment.center,
                                width: 24.0,
                                height: 24.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100.0),
                                  color: const Color.fromRGBO(44, 185, 176, 1),
                                ),
                                child: _coordinatorvenueController.text.isEmpty
                                    ? const Center()
                                    : const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 13,
                                      ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter venue';
                              }
                              return null;
                            },
                          ),
                        ),
                        ElevatedButton(
                          onPressed: pickFile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // background color
                          ),
                          child: const Text(
                            'Upload College Picture',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (collegePic != null)
                          Image.file(
                            collegePic!,
                            height: 100,
                            width: 100,
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextFormField(
                            controller: _coordinatorNameController,
                            style: GoogleFonts.inter(
                              fontSize: 18.0,
                              color: const Color(0xFF151624),
                            ),
                            maxLines: 1,
                            cursorColor: const Color(0xFF151624),
                            decoration: InputDecoration(
                              labelText: 'Coordinator Name',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 16.0,
                                color: const Color(0xFF151624).withOpacity(0.5),
                              ),
                              fillColor:
                                  _coordinatorNameController.text.isNotEmpty
                                      ? Colors.transparent
                                      : const Color.fromRGBO(248, 247, 251, 1),
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: BorderSide(
                                  color: _coordinatorNameController.text.isEmpty
                                      ? Colors.transparent
                                      : const Color.fromRGBO(44, 185, 176, 1),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(44, 185, 176, 1),
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: _coordinatorNameController.text.isEmpty
                                    ? const Color(0xFF151624).withOpacity(0.5)
                                    : const Color.fromRGBO(44, 185, 176, 1),
                                size: 16,
                              ),
                              suffix: Container(
                                alignment: Alignment.center,
                                width: 24.0,
                                height: 24.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100.0),
                                  color: const Color.fromRGBO(44, 185, 176, 1),
                                ),
                                child: _coordinatorNameController.text.isEmpty
                                    ? const Center()
                                    : const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 13,
                                      ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your coordinator name';
                              }
                              return null;
                            },
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _selectDate(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // background color
                          ),
                          child: Text(
                            'Select Event Date: \n ${fromDate != null && toDate != null ? "${fromDate!.toLocal().toString().split(' ')[0]} - ${toDate!.toLocal().toString().split(' ')[0]}" : "Choose Dates"}',
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Validation passed, perform registration action
                              _checkCombo(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF21899C),
                            // background color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            shadowColor:
                                const Color(0xFF4C2E84).withOpacity(0.2),
                            elevation: 6.0,
                          ),
                          child: const Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignInTen(),
                              ),
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
                                    fontWeight: FontWeight.bold,
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

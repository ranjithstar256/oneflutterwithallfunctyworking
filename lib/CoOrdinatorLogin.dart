import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _checkCombo(BuildContext context) async {
    String collegeName = _collegeNameController.text.trim();
    String collegeId = _collegeIdController.text.trim();

    // Check if the combo exists in Firestore
    QuerySnapshot querySnapshot = await _firestore
        .collection('coordinator')
        .where('collegeName', isEqualTo: collegeName)
        .where('collegeId', isEqualTo: collegeId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Combo exists
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Combo is valid!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Combo does not exist
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Combo is invalid!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Co-ordinator Login'),
      ),
      body: Center(
        child: Builder(
          builder: (context) => Column(
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
                onPressed: () => _checkCombo(context),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

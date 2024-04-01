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
      home: CollectionNames(),
    );
  }
}

class CollectionNames extends StatefulWidget {
  @override
  _CollectionNamesState createState() => _CollectionNamesState();
}

class _CollectionNamesState extends State<CollectionNames> {
  List<String> collectionNames = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchCollectionNames();
  }

  Future<void> fetchCollectionNames() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Fetch the document that contains collection names
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('metadata')
          .doc('collections')
          .get();

      // Extract collection names from the document
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      if (data.containsKey('names')) {
        setState(() {
          collectionNames = List<String>.from(data['names']);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('No collection names found in the document.');
      }
    } catch (error) {
      print('Error fetching collection names: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Collections'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : collectionNames.isEmpty
              ? Center(
                  child: Text('No collections found.'),
                )
              : ListView.builder(
                  itemCount: collectionNames.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(collectionNames[index]),
                    );
                  },
                ),
    );
  }
}

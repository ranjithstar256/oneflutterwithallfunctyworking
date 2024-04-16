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
      home: AllCollegeEvents(),
    );
  }
}

class AllCollegeEvents extends StatefulWidget {
  @override
  _AllCollegeEventsState createState() => _AllCollegeEventsState();
}

class _AllCollegeEventsState extends State<AllCollegeEvents> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All College Events'),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('coordinators').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No data available'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var document = snapshot.data!.docs[index];
              // Ensure that index is within valid range
              if (index >= snapshot.data!.docs.length) {
                return SizedBox.shrink(); // or any other widget
              }
              return ListTile(
                title: Text(document['collegeName']),
                subtitle: Text(
                    'Coordinator: ${document['coordinatorName']}\nDate: ${document['FromDate']} - ${document['toDate']}'),
                leading: Image.network(document['collegePicUrl']),
                // Add more details as needed
              );
            },
          );
        },
      ),
    );
  }
}

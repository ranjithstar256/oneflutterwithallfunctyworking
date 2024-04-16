import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'AllEvents.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coordinator Details',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CoordinatorDetailsScreen(),
    );
  }
}

class CoordinatorDetailsScreen extends StatelessWidget {
  const CoordinatorDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coordinator Details'),
      ),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection('coordinators').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No coordinators available'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var document = snapshot.data!.docs[index];

              return GestureDetector(
                onTap: () {
                  String coordinatorId = document['coordinatorid'];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AllEvents(coordinatorId: coordinatorId),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      title: Text(
                        document['collegeName'],
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              document['collegePicUrl'],
                              width: double.infinity,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text('Event Name: ${document['eventName']}',
                              style: const TextStyle(fontSize: 16)),
                          /* Text('Co Ordinator Id: ${document['collegeId']}',
                              style: const TextStyle(fontSize: 16)),*/
                          const SizedBox(height: 5),
                          Text('Venue: ${document['venue']}',
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 5),
                          Text(
                            'Event Dates: ${_formatDate(document['fromDate'])} - ${_formatDate(document['toDate'])}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      var date = timestamp.toDate();
      return DateFormat('dd-MM-yyyy').format(date);
    } else if (timestamp is String) {
      return timestamp;
    } else {
      return '';
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import 'EventRegistrationPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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

  runApp(MaterialApp(
    home: AllEvents(),
  ));
}

class AllEvents extends StatelessWidget {
  final Logger logger = Logger();

  bool isTeamGameah = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Events'),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('events').get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;

                return ListTile(
                  title: Text('Event Date: ${data['eventDate']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Venue: ${data['venue']}'),
                      TextButton(
                        onPressed: () {
                          if (data['gameType'] == 'Team') {
                            isTeamGameah = true;
                          } else {
                            isTeamGameah = false;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventRegistrationPage(
                                  eventName:
                                      data['selectedGame'] ?? 'def ev name',
                                  eventDate: data['eventDate'] ?? 'def ev date',
                                  venue: data['venue'] ?? 'def ev venue',
                                  isTeamGame:
                                      data['gameType'] == 'Team' ? true : false,
                                  coordinatorId: data['coordinatorid'] ??
                                      'sdm2566' // Assuming 'gameType' indicates if it's a team game
                                  ),
                            ),
                          );
                        },
                        child: Text('Register for Event'),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}

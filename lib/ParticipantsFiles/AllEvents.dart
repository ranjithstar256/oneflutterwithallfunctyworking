import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'RegisteringForEvent.dart';

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

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Select an option',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // Scaffold background color
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4C9085), // Custom app bar color
          foregroundColor: Colors.white, // App bar text color
          iconTheme: IconThemeData(color: Colors.white), // App bar icon color
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                const Color(0xFF4C9085)), // Custom button color
          ),
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green)
            .copyWith(background: const Color(0xFF4C9085)),
      ),
      home: AllEvents(
        coordinatorId: '',
      ),
    );
  }
}

class AllEvents extends StatelessWidget {
  final Logger logger = Logger();
  final String coordinatorId;

  AllEvents({required this.coordinatorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Events'),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('events')
            .where('coordinatorid', isEqualTo: coordinatorId)
            .get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Check if user is already logged in by checking a flag in shared preferences
            setLoggedIn(true);
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final currentDate = DateTime.now();

            final upcomingEvents = snapshot.data!.docs.where((doc) {
              final eventData = doc.data() as Map<String, dynamic>;
              final dateString = eventData['eventDate'] as String;
              final parts = dateString.split(' ');
              final dateParts = parts[0].split('-');
              final timeParts = parts[1].split(':');
              final year = int.parse(dateParts[0]);
              final month = int.parse(dateParts[1]);
              final day = int.parse(dateParts[2]);
              final hour = int.parse(timeParts[0]);
              final minute = int.parse(timeParts[1]);
              final eventDate = DateTime(year, month, day, hour, minute);
              return eventDate.isAfter(currentDate);
            }).toList();

            return ListView.builder(
              itemCount: upcomingEvents.length,
              itemBuilder: (context, index) {
                var data = upcomingEvents[index].data() as Map<String, dynamic>;

                logger.i('Event Date: ${data['eventDate']}');

                return Card(
                  elevation: 4,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(
                      'Event Date: ${data['eventDate']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text('Game: ${data['selectedGame']}'),
                        const SizedBox(height: 4),
                        Text('Venue: ${data['venue']}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EventRegistrationPage(
                                  eventName:
                                      data['selectedGame'] ?? 'def ev name',
                                  eventDate: data['eventDate'] ?? 'def ev date',
                                  venue: data['venue'] ?? 'def ev venue',
                                  isTeamGame: data['gameType'] == 'Team',
                                  coordinatorId:
                                      data['coordinatorid'] ?? 'sdm2566',
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'Register for Event',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

Future<void> setLoggedIn(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('partiloggedin', value);
}

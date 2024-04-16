import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ViewGameParticipantsPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase before runApp

  runApp(const MaterialApp(
    // Wrap your widget with MaterialApp
    home: YourCallingWidget(
      coordinatorId: '',
    ),
  ));
}

class YourCallingWidget extends StatelessWidget {
  final String coordinatorId;

  const YourCallingWidget({Key? key, required this.coordinatorId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Registration Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to the ViewRegistrationPage with a specific event name
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewRegistrationPage(
                  coordinatorId: coordinatorId,
                ),
              ),
            );
          },
          child: const Text('View Registrations'),
        ),
      ),
    );
  }
}

class ViewRegistrationPage extends StatefulWidget {
  final String coordinatorId;

  const ViewRegistrationPage({Key? key, required this.coordinatorId})
      : super(key: key);

  @override
  _ViewRegistrationPageState createState() => _ViewRegistrationPageState();
}

class _ViewRegistrationPageState extends State<ViewRegistrationPage> {
  late Future<List<String>> _gamesListFuture;

  @override
  void initState() {
    super.initState();
    _gamesListFuture = _fetchGamesList();
  }

  Future<List<String>> _fetchGamesList() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('coordinatorid',
            isEqualTo: widget.coordinatorId) // Filter by coordinatorId
        .get();
    Set<String> gamesSet = Set();

    querySnapshot.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      gamesSet.add(data['selectedGame']);
    });

    return gamesSet.toList();
  }

  // Method to handle menu item selection

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Registrations'),
      ),
      body: FutureBuilder<List<String>>(
        future: _gamesListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            List<String> gamesList = snapshot.data!;
            return ListView.builder(
              itemCount: gamesList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(gamesList[index]),
                  onTap: () {
                    String coid = getcoid().toString();
                    // Navigate to GameRegistrationsPage when a game is tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewGameParticipantsPage(
                          gameName: gamesList[index],
                          coordinatorId: coid,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

Future<String?> getcoid() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('coordinid');
}

/* void _handleMenuItemSelected(String menuItem, String coid) {
    switch (menuItem) {
      case 'Add Event':
        Navigator.push(
          context as BuildContext,
          MaterialPageRoute(
              builder: (context) => const AddEventPage(
                    coordinatorId: '',
                  )),
        );
        break;
      case 'All Events':
        Navigator.push(
          context as BuildContext,
          MaterialPageRoute(
              builder: (context) => AllEvents(
                    coordinatorId: '',
                  )),
        );
        break;
      case 'Main Page':
        // Navigate to the main page (replace with appropriate route)
        break;
      case 'Home Page':
        Navigator.push(
          context as BuildContext,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        // Navigate to the home page (replace with appropriate route)
        break;
      case 'Login Page':
        Navigator.push(
          context as BuildContext,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        break;
      case 'Event Registration Page':
        // Navigate to the event registration page (replace with appropriate route)
        Navigator.push(
          context as BuildContext,
          MaterialPageRoute(
              builder: (context) => EventRegistrationPage(
                  eventName: "VollyBall",
                  eventDate: "04-04-2024",
                  venue: "SDM College",
                  isTeamGame: true,
                  coordinatorId: "0256")),
        );
        break;
      case 'View Registration Page':
        // Navigate to the event registration page (replace with appropriate route)
        Navigator.push(
            context as BuildContext,
            MaterialPageRoute(
                builder: (context) =>
                    ViewRegistrationPage(coordinatorId: coid)));
        break;
    }
  }*/
/*
  final List<String> menuItems = [
    'Add Event',
    'All Events',
    'Main Page',
    'Home Page',
    'Login Page',
    'Event Registration Page',
  ];*/
/*



*
* stream builder
   body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('reg').snapshots(),
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
                Map<String, dynamic>? data =
                    document.data() as Map<String, dynamic>?;

                // Check if data is not null
                if (data != null) {
                  return ListTile(
                    title: Text('Full Name: ${data['fullName']}'),
                    subtitle: Text('Email: ${data['email']}'),
                  );
                } else {
                  return const SizedBox(); // Return an empty SizedBox if data is null
                }
              }).toList(),
            );
          }
        },
      ),
* */
/* floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: PopupMenuButton<String>(
          onSelected: _handleMenuItemSelected,
          itemBuilder: (BuildContext context) {
            return menuItems.map((String menuItem) {
              return PopupMenuItem<String>(
                value: menuItem,
                child: Text(menuItem),
              );
            }).toList();
          },
        ),
      ),*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:oneflutter/CoOrdinatorSignIn.dart';

import '../Registrations/signuppage.dart';
import '../logoutPage.dart';
import '../navigation_bar.dart';
import '../uicomponents/EventsTile.dart';
import 'AllEvents.dart';

void main() async {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: []); // Hide the system UI overlays
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

class CoordinatorDetailsScreen extends StatefulWidget {
  const CoordinatorDetailsScreen({super.key});

  @override
  _CoordinatorDetailsScreenState createState() =>
      _CoordinatorDetailsScreenState();
}

class _CoordinatorDetailsScreenState extends State<CoordinatorDetailsScreen> {
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Perform logout operation here
                // For demonstration, navigate back to login page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LogoutPage()),
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  ValueNotifier<String> _searchQuery = ValueNotifier<String>('');
  List<DocumentSnapshot> _allEvents = []; // Initialize list to store all events
  ValueNotifier<List<DocumentSnapshot>> _filteredEvents =
      ValueNotifier<List<DocumentSnapshot>>(
          []); // Use ValueNotifier to track changes

  @override
  void initState() {
    super.initState();
    _searchQuery.addListener(_filterEvents);
  }

  @override
  void dispose() {
    _searchQuery.dispose();
    _filteredEvents.dispose(); // Dispose the ValueNotifier
    super.dispose();
  }

  void _filterEvents() {
    String searchQuery = _searchQuery.value.toLowerCase();
    List<DocumentSnapshot> filteredList = _allEvents.where((event) {
      return event['eventName'].toLowerCase().contains(searchQuery);
    }).toList();
    _filteredEvents.value =
        filteredList; // Update the ValueNotifier with the filtered list
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = const Color(0xFF003C43);
    // Color secondaryColor = const Color(0xFF135D66);
    Color tertiaryColor = const Color.fromARGB(255, 234, 244, 242);
    void _onItemTapped(int index) {
      if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyAppdddd()),
        );
      }
      if (index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyAppeeee()),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(''),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        // Use the custom bottom navigation bar here
        currentIndex: 0, // Assuming Participant page is at index 1
        onTap: _onItemTapped,
      ),
      drawer: Drawer(
        child: Container(
          color: tertiaryColor,
          child: ListView(
            children: [
              const SizedBox(
                  height: 50), // Space between DrawerHeader and first ListTile
              const SizedBox(
                  height:
                      35), // Space between Notification and Privacy ListTile
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: Text(
                  'Privacy and Data',
                  style: TextStyle(fontSize: 20, color: primaryColor),
                ),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => PrivacyPage()));
                },
              ),
              const SizedBox(
                  height: 35), // Space between Privacy and Help ListTile
              ListTile(
                leading: const Icon(Icons.call),
                title: Text(
                  'Help Center',
                  style: TextStyle(fontSize: 20, color: primaryColor),
                ),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => HelpPage()));
                },
              ),
              const SizedBox(
                  height: 35), // Space between Help and Logout ListTile
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(
                  'Logout',
                  style: TextStyle(fontSize: 20, color: primaryColor),
                ),
                onTap: () {
                  _showLogoutDialog(context);
                },
              ),
              const SizedBox(
                  height: 35), // Space between Logout and bottom of the drawer
            ],
          ),
        ),
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

          // Initialize _allEvents with all events
          if (_allEvents.isEmpty) {
            _allEvents = snapshot.data!.docs;
            _filteredEvents.value =
                _allEvents; // Initialize _filteredEvents with all events
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 0, left: 25, bottom: 0),
                child: Text(
                  "Explore Events held in Colleges",
                  style: GoogleFonts.castoro(
                    textStyle: TextStyle(
                      color: Color.fromARGB(255, 5, 81, 99),
                      fontSize: 37,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: TextField(
                  onChanged: (value) {
                    _searchQuery.value = value; // Update search query
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search for events..',
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade600),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade600),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ValueListenableBuilder<List<DocumentSnapshot>>(
                  valueListenable: _filteredEvents,
                  builder: (context, value, child) {
                    return ListView.builder(
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        var document = value[index];
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
                              child: EventsTile(
                                collegeName: document['collegeName'],
                                gamesImagePath: document['collegePicUrl'],
                                sportsName: document['eventName'],
                                date:
                                    'Event Dates: ${_formatDate(document['fromDate'])} - ${_formatDate(document['toDate'])}',
                                venue: document['venue'],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
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

class InfoCard extends StatelessWidget {
  const InfoCard({
    required this.name,
    required this.profession,
    Key? key,
  }) : super(key: key);

  final String name, profession;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 50, // Increase the radius to 50
            child: Icon(
              CupertinoIcons.person,
              color: Colors.black,
              size: 40, // Adjust icon size as needed
            ),
          ),
          SizedBox(height: 20), // Adjust spacing between CircleAvatar and text
          Text(
            name,
            style: TextStyle(color: Colors.black),
          ),
          Text(
            profession,
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }
}

class PrivacyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy Policy',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Our Privacy Policy outlines the types of personal information that is received and collected by our app and how it is used. By using our app, you consent to the practices described in this policy.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Information Collection and Use',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'We may collect information from you when you register on our app, place an order, subscribe to our newsletter, respond to a survey, fill out a form, or enter information on our app.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Data Usage',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Any of the information we collect from you may be used in the following ways: to personalize your experience, to improve our app, to improve customer service, to process transactions, and to send periodic emails regarding your order or other products and services.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Help Center',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.info),
                title: Text('About Us'),
                onTap: () {
                  // Navigate to the About Us page
                },
              ),
              ListTile(
                leading: Icon(Icons.email),
                title: Text('Contact Us'),
                onTap: () {
                  // Navigate to the Contact Us page
                },
              ),
              ListTile(
                leading: Icon(Icons.question_answer),
                title: Text('FAQs'),
                onTap: () {
                  // Navigate to the FAQs page
                },
              ),
              ListTile(
                leading: Icon(Icons.policy),
                title: Text('Privacy Policy'),
                onTap: () {
                  // Navigate to the Privacy Policy page
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

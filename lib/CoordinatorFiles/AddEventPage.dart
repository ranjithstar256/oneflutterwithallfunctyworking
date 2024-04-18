import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(
    home: AddEventPage(
      coordinatorId: '',
    ),
  ));
}

class AddEventPage extends StatefulWidget {
  final String coordinatorId;

  const AddEventPage({super.key, required this.coordinatorId});

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _venueController = TextEditingController();
  String _participantType = 'Both'; // Default participant type
  String _gameType = 'Individual'; // Default game type
  String _selectedGame = ''; // Selected game
  int _teamSize = 1; // Default team size

  // List of games
  List<String> games = [
    'Cricket',
    'Football',
    'Kabadi',
    'Javelin Throw',
    'Shotput',
    'High Jump',
    'Throw Ball',
    'Relay',
    'Chess',
    'Table Tennis'
  ];

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _saveEventData() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate != null &&
          _selectedTime != null &&
          _selectedGame.isNotEmpty &&
          _venueController.text.isNotEmpty) {
        String eventDateTime =
            '${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day} ${_selectedTime!.hour}:${_selectedTime!.minute}';

        try {
          // Add event data to Firestore
          await firestore.collection('events').add({
            'eventDate': eventDateTime,
            'venue': _venueController.text,
            'participantType': _participantType,
            'gameType': _gameType,
            'selectedGame': _selectedGame,
            // Include selected game
            'teamSize': _teamSize,
            'coordinatorid': widget.coordinatorId,
            // Use coordinatorId from widget
            'collegeId': widget.coordinatorId,
            // Use coordinatorId from widget
          });

          // Clear form fields after saving
          _venueController.clear();
          setState(() {
            _teamSize = 1;
            _participantType = 'Both';
            _gameType = 'Individual';
            _selectedDate = null;
            _selectedTime = null;
            _selectedGame = ''; // Clear selected game
          });

          // Show a message indicating successful save
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event data saved successfully!'),
            ),
          );
        } catch (e) {
          // Show an error message if saving fails
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save event: $e'),
            ),
          );
        }
      } else {
        // Show an error message if date, time, game, or venue is not selected
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select event date, time, game, and venue.'),
          ),
        );
      }
    }
  }

  void _showGameSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select a Game'),
          content: SingleChildScrollView(
            child: Column(
              children: games.map((game) {
                if (game == 'Chess') {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Indoor Games',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ListTile(
                        title: Text(game),
                        onTap: () {
                          setState(() {
                            _selectedGame = game; // Set the selected game
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                } else if (game == 'Cricket') {
                  // Add a subheading for "Outdoor Games" before "Cricket"
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                          height: 10), // Add some spacing before the subheading
                      const Text('Outdoor Games',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ListTile(
                        title: Text(game),
                        onTap: () {
                          setState(() {
                            _selectedGame = game; // Set the selected game
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                } else {
                  // For other games, just add them to the list
                  return ListTile(
                    title: Text(game),
                    onTap: () {
                      setState(() {
                        _selectedGame = game; // Set the selected game
                      });
                      Navigator.of(context).pop();
                    },
                  );
                }
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Event'),
        backgroundColor: const Color(0xFF4C9085), // Custom app bar color
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(26.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Event Date',
                    style: TextStyle(fontSize: 24),
                  ),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      alignment: Alignment.center,
                      height: MediaQuery.of(context).size.height / 23,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: const Color(0xFF21899C),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4C2E84).withOpacity(0.2),
                            offset: const Offset(0, 15.0),
                            blurRadius: 60.0,
                          ),
                        ],
                      ),
                      child: Text(
                        _selectedDate == null
                            ? 'Select Date'
                            : 'Date: ${_selectedDate!.toString().split(' ')[0]}',
                        style: GoogleFonts.inter(
                          fontSize: 16.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Event Time',
                    style: TextStyle(fontSize: 24),
                  ),
                  GestureDetector(
                    onTap: () => _selectTime(context),
                    child: Container(
                      alignment: Alignment.center,
                      height: MediaQuery.of(context).size.height / 23,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: const Color(0xFF21899C),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4C2E84).withOpacity(0.2),
                            offset: const Offset(0, 15.0),
                            blurRadius: 60.0,
                          ),
                        ],
                      ),
                      child: Text(
                        _selectedTime == null
                            ? 'Select Time'
                            : 'Time: ${_selectedTime!.format(context)}',
                        style: GoogleFonts.inter(
                          fontSize: 16.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _venueController,
                    style: GoogleFonts.inter(
                      fontSize: 18.0,
                      color: const Color(0xFF151624),
                    ),
                    maxLines: 1,
                    keyboardType: TextInputType.text,
                    cursorColor: const Color(0xFF151624),
                    decoration: InputDecoration(
                      labelText: 'Venue',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 16.0,
                        color: const Color(0xFF151624).withOpacity(0.5),
                      ),
                      fillColor: _venueController.text.isNotEmpty
                          ? Colors.transparent
                          : const Color.fromRGBO(248, 247, 251, 1),
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40),
                        borderSide: BorderSide(
                          color: _venueController.text.isEmpty
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
                        Icons.location_on,
                        color: _venueController.text.isEmpty
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
                        child: _venueController.text.isEmpty
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
                        return 'Please enter the venue';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _showGameSelectionDialog(context),
                    child: Container(
                      alignment: Alignment.center,
                      height: MediaQuery.of(context).size.height / 23,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: const Color(0xFF21899C),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4C2E84).withOpacity(0.2),
                            offset: const Offset(0, 15.0),
                            blurRadius: 60.0,
                          ),
                        ],
                      ),
                      child: Text(
                        'Add Game',
                        style: GoogleFonts.inter(
                          fontSize: 16.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _selectedGame,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Who Can Participate',
                    style: TextStyle(fontSize: 24),
                  ),
                  Row(
                    children: [
                      Radio(
                        value: 'Male',
                        groupValue: _participantType,
                        onChanged: (value) {
                          setState(() {
                            _participantType = value.toString();
                          });
                        },
                      ),
                      const Text('Male'),
                      Radio(
                        value: 'Female',
                        groupValue: _participantType,
                        onChanged: (value) {
                          setState(() {
                            _participantType = value.toString();
                          });
                        },
                      ),
                      const Text('Female'),
                      Radio(
                        value: 'Both',
                        groupValue: _participantType,
                        onChanged: (value) {
                          setState(() {
                            _participantType = value.toString();
                          });
                        },
                      ),
                      const Text('Both'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Game Type',
                    style: TextStyle(fontSize: 24),
                  ),
                  Row(
                    children: [
                      Radio(
                        value: 'Individual',
                        groupValue: _gameType,
                        onChanged: (value) {
                          setState(() {
                            _gameType = value.toString();
                          });
                        },
                      ),
                      const Text('Individual'),
                      Radio(
                        value: 'Team',
                        groupValue: _gameType,
                        onChanged: (value) {
                          setState(() {
                            _gameType = value.toString();
                          });
                        },
                      ),
                      const Text('Team'),
                    ],
                  ),
                  _gameType == 'Team'
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            const Text('Team Size'),
                            Slider(
                              value: _teamSize.toDouble(),
                              min: 1,
                              max: 10,
                              divisions: 9,
                              onChanged: (value) {
                                setState(() {
                                  _teamSize = value.toInt();
                                });
                              },
                              activeColor:
                                  const Color.fromRGBO(44, 185, 176, 1),
                              inactiveColor:
                                  const Color(0xFF151624).withOpacity(0.5),
                              thumbColor: const Color.fromRGBO(44, 185, 176, 1),
                            ),
                            Text('$_teamSize'),
                          ],
                        )
                      : const SizedBox(),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        _saveEventData();
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: MediaQuery.of(context).size.height / 23,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: const Color(0xFF21899C),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4C2E84).withOpacity(0.2),
                            offset: const Offset(0, 15.0),
                            blurRadius: 60.0,
                          ),
                        ],
                      ),
                      child: Text(
                        'Save Event',
                        style: GoogleFonts.inter(
                          fontSize: 16.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<String?> getcoid() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('coordinid');
}

/*
working code without passsing coordinatorid
class AddEventPage extends StatefulWidget {
  final String coordinatorid;

  AddEventPage(this.coordinatorid);

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final List<String> menuItems = [
    'Add Event',
    'All Events',
    'Main Page',
    'Home Page',
    'Login Page',
    'Event Registration Page',
  ];

  // Method to handle menu item selection
  void _handleMenuItemSelected(String menuItem) {
    switch (menuItem) {
      case 'Add Event':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddEventPage()),
        );
        break;
      case 'All Events':
        Navigator.push(
          context,
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
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        // Navigate to the home page (replace with appropriate route)
        break;
      case 'Login Page':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        break;
      case 'Event Registration Page':
        // Navigate to the event registration page (replace with appropriate route)
        Navigator.push(
          context,
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
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ViewRegistrationPage()));
        break;
    }
  }

  final TextEditingController _venueController = TextEditingController();
  String _participantType = 'Both'; // Default participant type
  String _gameType = 'Individual'; // Default game type
  String _selectedGame = ''; // Selected game
  int _teamSize = 1; // Default team size
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // List of games
  List<String> games = [
    'Cricket',
    'Football',
    'Kabadi',
    'Javelin Throw',
    'Shotput',
    'High Jump',
    'Throw Ball',
    'Relay',
    'Chess',
    'Table Tennis'
  ];

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveEventData() async {
    if (_selectedDate != null &&
        _selectedTime != null &&
        _selectedGame.isNotEmpty) {
      String eventDateTime =
          '${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day} ${_selectedTime!.hour}:${_selectedTime!.minute}';

      // Firestore instance

      // Add event data to Firestore
      await firestore
          .collection('events')
          */
/*.doc('sdm2666')
          .collection('events')*/
/*

          .add({
        'eventDate': eventDateTime,
        'venue': _venueController.text,
        'participantType': _participantType,
        'gameType': _gameType,
        'selectedGame': _selectedGame, // Include selected game
        'teamSize': _teamSize,
        'coordinatorid': '0256',
      });

      // Clear form fields after saving
      _venueController.clear();
      setState(() {
        _teamSize = 1;
        _participantType = 'Both';
        _gameType = 'Individual';
        _selectedDate = null;
        _selectedTime = null;
        _selectedGame = ''; // Clear selected game
      });

      // Show a message indicating successful save
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event data saved successfully!'),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AllEvents()),
      );
    } else {
      // Show an error message if date, time, or game is not selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select event date, time, and game.'),
        ),
      );
    }
  }

  void _showGameSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select a Game'),
          content: SingleChildScrollView(
            child: Column(
              children: games.map((game) {
                if (game == 'Chess') {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Indoor Games',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ListTile(
                        title: Text(game),
                        onTap: () {
                          setState(() {
                            _selectedGame = game; // Set the selected game
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                } else if (game == 'Cricket') {
                  // Add a subheading for "Outdoor Games" before "Cricket"
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                          height: 10), // Add some spacing before the subheading
                      const Text('Outdoor Games',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ListTile(
                        title: Text(game),
                        onTap: () {
                          setState(() {
                            _selectedGame = game; // Set the selected game
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                } else {
                  // For other games, just add them to the list
                  return ListTile(
                    title: Text(game),
                    onTap: () {
                      setState(() {
                        _selectedGame = game; // Set the selected game
                      });
                      Navigator.of(context).pop();
                    },
                  );
                }
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Event'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text('Event Date'),
              ElevatedButton(
                onPressed: () => _selectDate(context),
                child: Text(_selectedDate == null
                    ? 'Select Date'
                    : 'Date: ${_selectedDate!.toString().split(' ')[0]}'),
              ),
              const SizedBox(height: 20),
              const Text('Event Time'),
              ElevatedButton(
                onPressed: () => _selectTime(context),
                child: Text(_selectedTime == null
                    ? 'Select Time'
                    : 'Time: ${_selectedTime!.format(context)}'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _venueController,
                decoration: const InputDecoration(labelText: 'Venue'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _showGameSelectionDialog(context),
                child: const Text('Add Game'),
              ),
              const SizedBox(height: 20),
              Text(
                _selectedGame,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
              const Text('Who Can Participate'),
              Row(
                children: [
                  Radio(
                    value: 'Male',
                    groupValue: _participantType,
                    onChanged: (value) {
                      setState(() {
                        _participantType = value.toString();
                      });
                    },
                  ),
                  const Text('Male'),
                  Radio(
                    value: 'Female',
                    groupValue: _participantType,
                    onChanged: (value) {
                      setState(() {
                        _participantType = value.toString();
                      });
                    },
                  ),
                  const Text('Female'),
                  Radio(
                    value: 'Both',
                    groupValue: _participantType,
                    onChanged: (value) {
                      setState(() {
                        _participantType = value.toString();
                      });
                    },
                  ),
                  const Text('Both'),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Game Type'),
              Row(
                children: [
                  Radio(
                    value: 'Individual',
                    groupValue: _gameType,
                    onChanged: (value) {
                      setState(() {
                        _gameType = value.toString();
                      });
                    },
                  ),
                  const Text('Individual'),
                  Radio(
                    value: 'Team',
                    groupValue: _gameType,
                    onChanged: (value) {
                      setState(() {
                        _gameType = value.toString();
                      });
                    },
                  ),
                  const Text('Team'),
                ],
              ),
              _gameType == 'Team'
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Text('Team Size'),
                        Slider(
                          value: _teamSize.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          onChanged: (value) {
                            setState(() {
                              _teamSize = value.toInt();
                            });
                          },
                        ),
                        Text('$_teamSize'),
                      ],
                    )
                  : const SizedBox(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveEventData,
                child: const Text('Save Event'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
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
      ),
    );
  }
}
*/

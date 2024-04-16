// import library
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
      home: CollegeListPage(),
    );
  }
}

//class name
class CollegeListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('College List'),
      ),
      body: ListView(
        children: [
          CollegeCard(
            collegeImage:
                'https://firebasestorage.googleapis.com/v0/b/twofour-fef75.appspot.com/o/college_coordinators%2FSanta655%2Fcollege_pics%2Fcollege_pic_1713098806836.jpg?alt=media&token=0773edd4-74ba-4dee-aa43-dbc15544bf1a',
            collegeName: 'ABC College',
            eventName: 'Event 1',
            venue: 'Auditorium',
            eventDate: '10th November 2022',
          ),
          CollegeCard(
            collegeImage:
                'https://firebasestorage.googleapis.com/v0/b/twofour-fef75.appspot.com/o/college_coordinators%2FSanta655%2Fcollege_pics%2Fcollege_pic_1713098806836.jpg?alt=media&token=0773edd4-74ba-4dee-aa43-dbc15544bf1a',
            collegeName: 'XYZ College',
            eventName: 'Event 2',
            venue: 'Main Hall',
            eventDate: '15th December 2022',
          ),
          CollegeCard(
            collegeImage:
                'https://firebasestorage.googleapis.com/v0/b/twofour-fef75.appspot.com/o/college_coordinators%2FSanta655%2Fcollege_pics%2Fcollege_pic_1713098806836.jpg?alt=media&token=0773edd4-74ba-4dee-aa43-dbc15544bf1a',
            collegeName: '123 College',
            eventName: 'Event 3',
            venue: 'Room 101',
            eventDate: '20th January 2023',
          ),
        ],
      ),
    );
  }
}

class CollegeCard extends StatelessWidget {
  final String collegeImage;
  final String collegeName;
  final String eventName;
  final String venue;
  final String eventDate;

  CollegeCard({
    required this.collegeImage,
    required this.collegeName,
    required this.eventName,
    required this.venue,
    required this.eventDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(collegeImage),
          Text(collegeName),
          Text('Event Name: $eventName'),
          Text('Venue: $venue'),
          Text('Date: $eventDate'),
        ],
      ),
    );
  }
}

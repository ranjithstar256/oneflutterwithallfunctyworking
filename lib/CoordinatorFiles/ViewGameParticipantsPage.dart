import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewGameParticipantsPage extends StatelessWidget {
  final String gameName;
  final String coordinatorId; // Add coordinatorId parameter

  const ViewGameParticipantsPage({
    Key? key,
    required this.gameName,
    required this.coordinatorId,
  }) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchRegistrationsForGame(
      String gameName, String prcoordinatorId) async {
    String cco = getcoid().toString();
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('events')
        .doc('Chess')
        .collection('participants')
        .where('coordinatorid', isEqualTo: cco) // Filter by coordinatorId
        .get();

    List<Map<String, dynamic>> participants = [];
    querySnapshot.docs.forEach((doc) {
      participants.add(doc.data() as Map<String, dynamic>);
    });

    return participants;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrations for $gameName'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchRegistrationsForGame(gameName, coordinatorId),
        // Pass coordinatorId
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
            List<Map<String, dynamic>> participants = snapshot.data!;
            return ListView.builder(
              itemCount: participants.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                        'Participant Name: ${participants[index]['participantName']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Age: ${participants[index]['age']}'),
                        Text(
                            'College Name: ${participants[index]['collegeName']}'),
                        Text('Email: ${participants[index]['email']}'),
                        Text('Gender: ${participants[index]['gender']}'),
                        Text('Mobile: ${participants[index]['mobile']}'),
                        Text(
                            'Member Names: ${participants[index]['memberNames']}'),
                        Text('Team Name: ${participants[index]['teamName']}'),
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

Future<String?> getcoid() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('coordinid');
}

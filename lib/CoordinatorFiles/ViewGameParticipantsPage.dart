import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewGameParticipantsPage extends StatelessWidget {
  final String gameName;

  const ViewGameParticipantsPage({Key? key, required this.gameName})
      : super(key: key);

  Future<List<Map<String, dynamic>>> fetchRegistrationsForGame(
      String gameName) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('events')
        .doc(gameName)
        .collection('participants')
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
        future: fetchRegistrationsForGame(gameName),
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

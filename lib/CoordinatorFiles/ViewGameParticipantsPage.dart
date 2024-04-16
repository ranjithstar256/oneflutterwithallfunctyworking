import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewGameParticipantsPage extends StatelessWidget {
  final String gameName;
  final String coordinatorId;

  const ViewGameParticipantsPage({
    Key? key,
    required this.gameName,
    required this.coordinatorId,
  }) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchRegistrationsForGame(
      String gameName, String coordinatorId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('events')
        .doc(gameName)
        .collection('participants')
        .where('coordinatorid', isEqualTo: coordinatorId)
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
                Map<String, dynamic> participant = participants[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                        'Participant Name: ${participant['participantName']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Age: ${participant['age']}'),
                        Text('College Name: ${participant['collegeName']}'),
                        Text('Email: ${participant['email']}'),
                        Text('Gender: ${participant['gender']}'),
                        Text('Mobile: ${participant['mobile']}'),
                        if (participant.containsKey('teamName') &&
                            participant['teamName'].isNotEmpty)
                          Text('Team Name: ${participant['teamName']}'),
                        if (participant.containsKey('memberNames') &&
                            participant['memberNames'].isNotEmpty)
                          Text('Member Names: ${participant['memberNames']}'),
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

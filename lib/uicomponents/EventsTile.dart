import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventsTile extends StatelessWidget {
  final String gamesImagePath;
  final String collegeName;
  final String sportsName;
  final String date;
  final String venue;

  EventsTile({
    required this.gamesImagePath,
    required this.collegeName,
    required this.sportsName,
    required this.date,
    required this.venue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, bottom: 25, right: 15),
      child: Container(
        padding: const EdgeInsets.all(12),
        width: 230,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color.fromARGB(255, 3, 94, 114),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(
                top: 10.0,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white, // Set the color of the border to white
                  width: 1.5, // Set the width of the border
                ),
                borderRadius:
                    BorderRadius.circular(12), // Set the border radius
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  gamesImagePath,
                  width: 170.0,
                  height: 200.0,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            //college name
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 0, bottom: 0),
              child: Text(
                collegeName,
                style: GoogleFonts.castoro(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            Text(
              sportsName,
              style: GoogleFonts.castoro(
                textStyle: const TextStyle(color: Colors.white, fontSize: 16.5),
              ),
            ),
            const SizedBox(height: 10), // Add some space below the date text
            Container(
              height: 3, // Set the height of the line
              width: double.infinity, // Make the line stretch horizontally
              color: Colors.white, // Set the color of the line to white
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 0, bottom: 5),
              child: Text(
                venue,
                style: GoogleFonts.castoro(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            Text(
              date,
              style: GoogleFonts.castoro(
                textStyle: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GamesTile extends StatelessWidget {
  final String gameName;
  final String date;
  final String venue;

  GamesTile({
    required this.gameName,
    required this.date,
    required this.venue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 5, right: 5),
      child: Container(
        padding: const EdgeInsets.all(5),
        width: 300,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color.fromARGB(255, 3, 94, 114),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(
                top: 10.0,
              ),
            ),

            //college name
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 0, bottom: 0),
              child: Text(
                gameName,
                style: GoogleFonts.castoro(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10), // Add some space below the date text
            Container(
              height: 3, // Set the height of the line
              width: double.infinity, // Make the line stretch horizontally
              color: Colors.white, // Set the color of the line to white
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 0, bottom: 5),
              child: Text(
                venue,
                style: GoogleFonts.castoro(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            Text(
              date,
              style: GoogleFonts.castoro(
                textStyle: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

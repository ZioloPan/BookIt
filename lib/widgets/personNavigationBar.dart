import 'package:flutter/material.dart';
import '../pages/personHome.dart';
import '../pages/personProfile.dart';
import '../pages/personCalendar.dart';
import '../pages/personReview.dart';

class PersonNavigationBar extends StatelessWidget {
  final String personId;

  const PersonNavigationBar({super.key, required this.personId});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: const Color.fromARGB(255, 255, 241, 208),
      shape: const CircularNotchedRectangle(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PersonHomePage(personId: personId),
                  ),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.home),
              iconSize: 30,
              color: Colors.black,
            ),
            IconButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PersonCalendarPage(personId: personId),
                  ),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.calendar_today),
              iconSize: 30,
              color: Colors.black,
            ),
            IconButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PersonReviewPage(personId: personId),
                  ),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.star),
              iconSize: 30,
              color: Colors.black,
            ),
            IconButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PersonProfilePage(personId: personId),
                  ),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.person),
              iconSize: 30,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}

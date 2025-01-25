import 'package:flutter/material.dart';
import '../pages/businessHome.dart';
import '../pages/businessProfile.dart';
import '../pages/businessCalendar.dart';
import '../pages/businessReview.dart';

class BusinessNavigationBar extends StatelessWidget {
  const BusinessNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: const Color.fromARGB(255, 255, 241, 208), // Kremowy kolor
      shape: const CircularNotchedRectangle(), // Separacja wizualna
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
                    builder: (context) => const BusinessHomePage(),
                  ),
                  (route) => false, // Usuwa wszystkie poprzednie trasy
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
                    builder: (context) => const BusinessCalendarPage(),
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
                    builder: (context) => const BusinessReviewPage(),
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
                    builder: (context) => const BusinessProfilePage(),
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

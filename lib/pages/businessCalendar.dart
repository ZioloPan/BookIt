import 'package:flutter/material.dart';
import '../widgets/businessNavigationBar.dart';

class BusinessCalendarPage extends StatelessWidget {
  const BusinessCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 171, 165),
      body: SafeArea(
        child: Container(), // Puste na razie
      ),
      bottomNavigationBar: const BusinessNavigationBar(),
    );
  }
}
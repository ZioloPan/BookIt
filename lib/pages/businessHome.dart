import 'package:flutter/material.dart';
import '../widgets/businessNavigationBar.dart';

class BusinessHomePage extends StatelessWidget {
  const BusinessHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 171, 165),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 150,
                height: 150,
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Your Appointments:',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    leading: Icon(Icons.event, color: Colors.black),
                    title: Text('Appointment 1',
                        style: TextStyle(color: Colors.black)),
                    subtitle: Text('Details for appointment 1',
                        style: TextStyle(color: Colors.black87)),
                  ),
                  ListTile(
                    leading: Icon(Icons.event, color: Colors.black),
                    title: Text('Appointment 2',
                        style: TextStyle(color: Colors.black)),
                    subtitle: Text('Details for appointment 2',
                        style: TextStyle(color: Colors.black87)),
                  ),
                  ListTile(
                    leading: Icon(Icons.event, color: Colors.black),
                    title: Text('Appointment 3',
                        style: TextStyle(color: Colors.black)),
                    subtitle: Text('Details for appointment 3',
                        style: TextStyle(color: Colors.black87)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BusinessNavigationBar(),
    );
  }
}
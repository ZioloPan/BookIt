import 'package:flutter/material.dart';
import '../widgets/businessNavigationBar.dart';

class BusinessCalendarPage extends StatelessWidget {
  final String businessId;

  const BusinessCalendarPage({super.key, required this.businessId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 171, 165),
      body: SafeArea(
        child: Center(
          child: Text(
            'Calendar for Business ID: $businessId',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
      bottomNavigationBar: BusinessNavigationBar(
        businessId: businessId, // Przekazanie ID biznesu do paska nawigacji
      ),
    );
  }
}

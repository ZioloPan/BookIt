import 'package:flutter/material.dart';
import '../services/business-service.dart';
import '../widgets/businessNavigationBar.dart';

class BusinessHomePage extends StatefulWidget {
  final String businessId;

  const BusinessHomePage({super.key, required this.businessId});

  @override
  _BusinessHomePageState createState() => _BusinessHomePageState();
}

class _BusinessHomePageState extends State<BusinessHomePage> {
  String _businessName = '';

  @override
  void initState() {
    super.initState();
    _loadBusinessData();
  }

  Future<void> _loadBusinessData() async {
    try {
      final business = await BusinessService().getBusinessById(int.parse(widget.businessId));
      print('Cała odpowiedź z backendu: $business');

      final businessDto = business['businessDto'];
      if (businessDto != null) {
        final name = businessDto['name'];
        print('Wyciągnięta nazwa biznesu: $name');

        setState(() {
          _businessName = name ?? '';
        });
      } else {
        print('Brak businessDto w odpowiedzi');
      }
    } catch (e) {
      print('Error loading business data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 171, 165),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 150,
                  height: 150,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  _businessName.isNotEmpty
                      ? 'Welcome, $_businessName'
                      : 'Welcome, Business',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Center(
                child: Text(
                  'No appointments loaded.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BusinessNavigationBar(
        businessId: widget.businessId,
      ),
    );
  }
}

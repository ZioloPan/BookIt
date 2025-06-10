import 'package:flutter/material.dart';
import '../services/business-service.dart';
import '../services/reservation-service.dart';
import '../widgets/businessNavigationBar.dart';

class BusinessHomePage extends StatefulWidget {
  final String businessId;

  const BusinessHomePage({super.key, required this.businessId});

  @override
  _BusinessHomePageState createState() => _BusinessHomePageState();
}

class _BusinessHomePageState extends State<BusinessHomePage> {
  String? _businessName;
  List<Map<String, dynamic>> _todayAppointments = [];

  @override
  void initState() {
    super.initState();
    _loadBusinessData();
    _fetchAppointmentsForToday();
  }

  Future<void> _loadBusinessData() async {
    try {
      final business = await BusinessService().getBusinessById(int.parse(widget.businessId));
      setState(() {
        _businessName = business['businessDto']['name'] ?? 'Unknown Business';
      });
    } catch (e) {
      print('Error loading business data: $e');
    }
  }

  Future<void> _fetchAppointmentsForToday() async {
    try {
      final today = DateTime.now();
      final todayDateString = today.toIso8601String().split('T').first;
      final reservations = await ReservationService().getReservationsForDay(todayDateString);

      final filtered = reservations.where((res) {
        return res['businessId'].toString() == widget.businessId;
      }).toList();

      setState(() {
        _todayAppointments = filtered.map((res) {
          return {
            'employeeName': res['workerName'] ?? 'Unknown',
            'personName': res['clientName'] ?? 'Unknown',
            'time': res['time'] ?? 'Unknown',
          };
        }).toList();
      });
    } catch (e) {
      print('Error loading appointments: $e');
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
                  _businessName != null
                      ? 'Welcome, $_businessName'
                      : 'Welcome, Business',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Today’s Appointments:',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _todayAppointments.isEmpty
                    ? const Center(
                        child: Text(
                          'No appointments for today.',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        itemCount: _todayAppointments.length,
                        itemBuilder: (context, index) {
                          final appointment = _todayAppointments[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              leading: const Icon(Icons.event, color: Colors.black),
                              title: Text(
                                '${appointment['employeeName']}',
                                style: const TextStyle(color: Colors.black),
                              ),
                              subtitle: Text(
                                'Client: ${appointment['personName']}\nTime: ${appointment['time']}',
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ),
                          );
                        },
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
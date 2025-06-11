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
  String _businessName = '';
  List<Map<String, dynamic>> _appointments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBusinessData();
    _loadTodayAppointments();
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

  Future<void> _loadTodayAppointments() async {
    try {
      final now = DateTime.now();
      final dateStr = "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final reservations = await ReservationService().getReservationsForDay(dateStr);
      setState(() {
        _appointments = List<Map<String, dynamic>>.from(reservations);
        _loading = false;
      });
    } catch (e) {
      print('Error loading today appointments: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  String formatDateTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }

  void _showAppointmentDetails(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Appointment Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Client: ${appointment['client']?['firstName'] ?? '-'} ${appointment['client']?['lastName'] ?? ''}'),
                Text('Service: ${appointment['service']?['name'] ?? '-'}'),
                Text('Employee: ${appointment['worker']?['firstName'] ?? '-'} ${appointment['worker']?['lastName'] ?? ''}'),
                Text('Date: ${formatDateTime(appointment['date'])}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
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
              const Text(
                'Today\'s appointments',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _appointments.isEmpty
                        ? const Center(
                            child: Text(
                              'No appointments loaded.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _appointments.length,
                            itemBuilder: (context, index) {
                              final appointment = _appointments[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                child: ListTile(
                                  leading: const Icon(Icons.calendar_today, color: Colors.black),
                                  title: Text(
                                    '${appointment['client']?['firstName'] ?? '-'} ${appointment['client']?['lastName'] ?? ''} - ${appointment['service']?['name'] ?? '-'}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    'Date: ${formatDateTime(appointment['date'])}',
                                  ),
                                  onTap: () => _showAppointmentDetails(appointment),
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

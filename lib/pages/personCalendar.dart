import 'package:flutter/material.dart';

import '../widgets/personNavigationBar.dart';
import '../services/reservation-service.dart';
import '../services/business-service.dart';

class PersonCalendarPage extends StatefulWidget {
  final String personId;

  const PersonCalendarPage({
    super.key,
    required this.personId,
  });

  @override
  _PersonCalendarPageState createState() => _PersonCalendarPageState();
}

class _PersonCalendarPageState extends State<PersonCalendarPage> {
  final ReservationService _reservationService = ReservationService();
  final BusinessService _businessService = BusinessService();

  List<Map<String, dynamic>> _appointments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppointmentsWithDetails();
  }

  Future<void> _fetchAppointmentsWithDetails() async {
    try {
      // Pobierz wszystkie rezerwacje
      final allAppointments = await _reservationService.getAllReservations();
      final now = DateTime.now();

      // Filtruj tylko rezerwacje dla danego użytkownika i nie zakończone
      final filteredAppointments = allAppointments.where((appointment) {
        final String dateStr = appointment['date'];
        final bool finished = appointment['finished'] ?? false;
        final int clientId = appointment['client'] is Map
            ? appointment['client']['id']
            : appointment['client'];
        try {
          final appointmentDateTime = DateTime.parse(dateStr);
          return !finished &&
              clientId == int.parse(widget.personId) &&
              appointmentDateTime.isAfter(now);
        } catch (e) {
          print('Error parsing date for appointment: $e');
          return false;
        }
      }).toList();

      // Pobierz szczegóły pracownika i biznesu dla każdej wizyty
      for (var appointment in filteredAppointments) {
        final worker = appointment['worker'];
        final service = appointment['service'];
        String employeeName = 'Unknown';
        String businessName = 'Unknown';
        String businessAddress = '';
        String serviceName = '';
        String serviceCategory = '';
        double? servicePrice;
        double? serviceDuration;
        String businessPhone = '';
        String businessLocalNumber = '';

        if (worker != null) {
          employeeName = '${worker['firstName'] ?? ''} ${worker['lastName'] ?? ''}';
        }
        if (service != null) {
          serviceName = service['name'] ?? '';
          serviceCategory = service['category'] ?? '';
          servicePrice = service['price']?.toDouble();
          serviceDuration = service['duration']?.toDouble();
          // Pobierz biznes po businessId z serwisu
          final businessId = service['businessId'];
          if (businessId != null) {
            final business = await _businessService.getBusinessById(businessId);
            businessName = business['name'] ?? business['businessDto']?['name'] ?? 'Unknown';
            businessPhone = business['phoneNumber'] ?? business['businessDto']?['phoneNumber'] ?? '';
            final address = business['address'] ?? business['businessDto']?['address'];
            if (address != null) {
              businessAddress = '${address['city']}, ${address['street']} ${address['buildingNumber'] ?? ''}';
              businessLocalNumber = address['localNumber'] ?? '';
            }
          }
        }

        appointment['employeeName'] = employeeName;
        appointment['businessName'] = businessName;
        appointment['businessAddress'] = businessAddress;
        appointment['serviceName'] = serviceName;
        appointment['serviceCategory'] = serviceCategory;
        appointment['servicePrice'] = servicePrice;
        appointment['serviceDuration'] = serviceDuration;
        appointment['businessPhone'] = businessPhone;
        appointment['businessLocalNumber'] = businessLocalNumber;
      }

      setState(() {
        _appointments = filteredAppointments;
        _loading = false;
      });
    } catch (e) {
      print('Error loading appointments: $e');
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load appointments: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Funkcja do formatowania daty i godziny
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
          title: Text('Appointment Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Business: ${appointment['businessName']}'),
                Text('Address: ${appointment['businessAddress']}'),
                Text('Local number: ${appointment['businessLocalNumber']}'),
                Text('Phone: ${appointment['businessPhone']}'),
                Text('Employee: ${appointment['employeeName']}'),
                Text('Service: ${appointment['serviceName']}'),
                Text('Category: ${appointment['serviceCategory']}'),
                Text('Price: ${appointment['servicePrice'] ?? '-'} zł'),
                Text('Duration: ${appointment['serviceDuration']?.toStringAsFixed(1) ?? '-'} h'),
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
      backgroundColor: const Color.fromARGB(255, 169, 220, 223),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your appointments',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _appointments.isEmpty
                          ? const Center(
                              child: Text(
                                'No upcoming appointments.',
                                style: TextStyle(fontSize: 16, color: Colors.black54),
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
                                      '${appointment['businessName']} - ${appointment['employeeName']}',
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
      bottomNavigationBar: PersonNavigationBar(personId: widget.personId),
    );
  }
}

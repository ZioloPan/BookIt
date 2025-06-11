import 'package:flutter/material.dart';
import '../widgets/personNavigationBar.dart';
import '../services/reservation-service.dart';

class PersonReviewPage extends StatefulWidget {
  final String personId;

  const PersonReviewPage({
    super.key,
    required this.personId,
  });

  @override
  _PersonReviewPageState createState() => _PersonReviewPageState();
}

class _PersonReviewPageState extends State<PersonReviewPage> {
  List<Map<String, dynamic>> _appointments = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchFinishedAppointments();
  }

  Future<void> _fetchFinishedAppointments() async {
    setState(() {
      _loading = true;
    });
    try {
      // Pobierz wszystkie wizyty zalogowanego użytkownika (backend sam filtruje po tokenie)
      final reservations = await ReservationService().getAllReservations();
      // Filtruj tylko zakończone (finished: true)
      final finishedAppointments = reservations; // bez filtra na finished

      // Dodaj formatowanie pól do kafelków
      for (var appointment in finishedAppointments) {
        final business = appointment['business'] ?? {};
        final worker = appointment['worker'] ?? {};
        appointment['businessName'] = business['name'] ?? 'Unknown Business';
        appointment['employeeName'] = '${worker['firstName'] ?? 'Unknown'} ${worker['lastName'] ?? ''}';
        appointment['dateStr'] = (appointment['date'] as String).split('T').first;
        appointment['timeStr'] = (appointment['date'] as String).split('T').length > 1
            ? (appointment['date'] as String).split('T')[1].substring(0, 5)
            : '';
        appointment['businessId'] = business['id'] ?? '';
      }

      setState(() {
        _appointments = finishedAppointments;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 169, 220, 223),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Add review to your appointments,",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _appointments.isEmpty
                        ? const Center(
                            child: Text(
                              'No finished appointments.',
                              style: TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _appointments.length,
                            itemBuilder: (context, index) {
                              final appointment = _appointments[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                                child: ListTile(
                                  leading: const Icon(Icons.event, color: Colors.black),
                                  title: Text(
                                    '${appointment['businessName']} - ${appointment['employeeName']}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                  subtitle: Text(
                                    'Date: ${appointment['dateStr']}\nTime: ${appointment['timeStr']}',
                                    style: const TextStyle(color: Colors.black87),
                                  ),
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/appointmentDetails',
                                      arguments: appointment,
                                    );
                                  },
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

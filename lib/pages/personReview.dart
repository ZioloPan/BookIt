import 'package:flutter/material.dart';
import '../services/appointment-service.dart';
import '../services/employee-service.dart';
import '../services/business-service.dart';
import '../widgets/personNavigationBar.dart';
import 'personReviewDetails.dart';

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
  final AppointmentService _appointmentService = AppointmentService();
  final EmployeeService _employeeService = EmployeeService();
  final BusinessService _businessService = BusinessService();

  List<Map<String, dynamic>> _appointments = [];

  @override
  void initState() {
    super.initState();
    _fetchPastAppointmentsWithDetails();
  }

  Future<void> _fetchPastAppointmentsWithDetails() async {
    try {
      final allAppointments = await _appointmentService.getAllAppointments();
      final now = DateTime.now();

      final filteredAppointments = allAppointments.where((appointment) {
        final String appointmentDate = appointment['date'];
        final String appointmentTime = appointment['time'];

        try {
          final appointmentDateTime = DateTime.parse('$appointmentDate $appointmentTime:00');
          return appointment['personId'] == widget.personId &&
              appointmentDateTime.isBefore(now);
        } catch (e) {
          print('Error parsing date/time for appointment: $e');
          return false;
        }
      }).toList();

      for (var appointment in filteredAppointments) {
        final employee = await _employeeService.getEmployeeById(appointment['employeeId']);
        final business = await _businessService.getBusinessById(employee?['businessId']);

        appointment['employeeName'] = employee != null
            ? '${employee['name']} ${employee['lastName']}'
            : 'Unknown Employee';
        appointment['businessName'] = business != null
            ? business['salonName']
            : 'Unknown Business';
        appointment['businessId'] = business?['id'] ?? 'Unknown';
      }

      setState(() {
        _appointments = filteredAppointments;
      });
    } catch (e) {
      print('Error loading appointments: $e');
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
                child: _appointments.isEmpty
                    ? const Center(
                        child: Text(
                          'No past appointments.',
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
                              leading: const Icon(Icons.history, color: Colors.black),
                              title: Text(
                                '${appointment['businessName']} - ${appointment['employeeName']}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('Date: ${appointment['date']}\nTime: ${appointment['time']}'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PersonReviewDetailsPage(
                                      personId: widget.personId,
                                      businessId: appointment['businessId'],
                                    ),
                                  ),
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

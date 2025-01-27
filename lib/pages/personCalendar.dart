import 'package:flutter/material.dart';
import '../services/appointment-service.dart';
import '../services/employee-service.dart';
import '../services/business-service.dart';
import '../widgets/personNavigationBar.dart';

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
  final AppointmentService _appointmentService = AppointmentService();
  final EmployeeService _employeeService = EmployeeService();
  final BusinessRegisterService _businessService = BusinessRegisterService();

  List<Map<String, dynamic>> _appointments = [];

  @override
  void initState() {
    super.initState();
    _fetchAppointmentsWithDetails();
  }

  Future<void> _fetchAppointmentsWithDetails() async {
    try {
      final allAppointments = await _appointmentService.getAllAppointments();
      final now = DateTime.now();

      final filteredAppointments = allAppointments.where((appointment) {
        final String appointmentDate = appointment['date'];
        final String appointmentTime = appointment['time'];

        try {
          final appointmentDateTime = DateTime.parse('$appointmentDate $appointmentTime:00');
          return appointment['personId'] == widget.personId &&
              appointmentDateTime.isAfter(now);
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
              const Text(
                'Your appointments,',
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
                                'Date: ${appointment['date']}\nTime: ${appointment['time']}',
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
      bottomNavigationBar: PersonNavigationBar(personId: widget.personId),
    );
  }
}

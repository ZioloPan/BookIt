import 'package:flutter/material.dart';
import '../services/employee-service.dart';
import '../services/appointment-service.dart';
import '../services/person-service.dart';
import '../widgets/businessNavigationBar.dart';

class BusinessCalendarPage extends StatefulWidget {
  final String businessId;

  const BusinessCalendarPage({super.key, required this.businessId});

  @override
  _BusinessCalendarPageState createState() => _BusinessCalendarPageState();
}

class _BusinessCalendarPageState extends State<BusinessCalendarPage> {
  final AppointmentService _appointmentService = AppointmentService();
  final EmployeeService _employeeService = EmployeeService();
  final PersonService _personService = PersonService();

  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _filteredAppointments = [];
  List<Map<String, dynamic>> _employees = [];
  List<Map<String, dynamic>> _persons = [];
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final employees = await _employeeService.getAllEmployees();
      final appointments = await _appointmentService.getAllAppointments();
      final persons = await _personService.getAllPersons();

      setState(() {

        _employees = employees
            .where((employee) => employee['businessId'] == widget.businessId)
            .toList();

        final businessEmployeeIds = _employees.map((e) => e['id']).toSet();
        _appointments = appointments.where((appointment) {
          return businessEmployeeIds.contains(appointment['employeeId']);
        }).toList();

        _persons = persons;
      });
    } catch (e) {
      print('Error loading data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _filterAppointmentsForSelectedDate();
      });
    }
  }

  void _filterAppointmentsForSelectedDate() {
    if (_selectedDate == null) return;

    final selectedDateString = _selectedDate!.toIso8601String().split('T').first;

    setState(() {
      _filteredAppointments = _appointments.where((appointment) {
        return appointment['date'] == selectedDateString;
      }).toList();

      for (var appointment in _filteredAppointments) {
        final employee = _employees.firstWhere(
          (e) => e['id'] == appointment['employeeId'],
          orElse: () => {'name': 'Unknown', 'lastName': 'Employee'},
        );
        final person = _persons.firstWhere(
          (p) => p['id'] == appointment['personId'],
          orElse: () => {'name': 'Unknown', 'lastName': 'Client'},
        );

        appointment['employeeName'] = '${employee['name']} ${employee['lastName']}';
        appointment['clientName'] = '${person['name']} ${person['lastName']}';
      }
    });
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
              ElevatedButton(
                onPressed: () => _selectDate(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 14.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text('Select Date'),
              ),
              if (_selectedDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Selected date: ${_selectedDate!.toIso8601String().split('T').first}',
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              const SizedBox(height: 16),
              Expanded(
                child: _filteredAppointments.isEmpty
                    ? const Center(
                        child: Text(
                          'No appointments for the selected date.',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredAppointments.length,
                        itemBuilder: (context, index) {
                          final appointment = _filteredAppointments[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 8.0,
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.event, color: Colors.black),
                              title: Text(
                                '${appointment['employeeName']}',
                                style: const TextStyle(color: Colors.black),
                              ),
                              subtitle: Text(
                                'Client: ${appointment['clientName']}\nTime: ${appointment['time']}',
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

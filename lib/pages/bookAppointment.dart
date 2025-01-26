import 'package:flutter/material.dart';
import '../services/employee-service.dart'; // Importowanie serwisu dla pracowników
import '../services/appointment-service.dart'; // Importowanie serwisu dla wizyt
import '../widgets/personNavigationBar.dart'; // Importowanie navigation bar
import 'personHome.dart'; // Importowanie strony głównej po zalogowaniu

class BookAppointmentPage extends StatefulWidget {
  final String businessId;
  final String personId;

  const BookAppointmentPage({
    super.key,
    required this.businessId,
    required this.personId,
  });

  @override
  _BookAppointmentPageState createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final EmployeeService _employeeService = EmployeeService();
  final AppointmentService _appointmentService = AppointmentService();

  List<Map<String, dynamic>> _employees = [];
  List<String> _availableSlots = [];

  String? _selectedEmployee;
  DateTime? _selectedDate;
  String? _selectedSlot;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    try {
      final employees = await _employeeService.getAllEmployees();
      setState(() {
        _employees = employees
            .where((employee) => employee['businessId'] == widget.businessId)
            .toList();
      });
    } catch (e) {
      print('Error loading employees: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load employees: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchAvailableSlots() async {
    if (_selectedEmployee == null || _selectedDate == null) return;

    final String selectedDateString = _selectedDate!.toIso8601String().split('T').first;
    final appointments = await _appointmentService.getAllAppointments();

    final occupiedSlots = appointments
        .where((appointment) =>
            appointment['employeeId'] == _selectedEmployee &&
            appointment['date'] == selectedDateString)
        .map((appointment) => appointment['time'])
        .toSet();

    const allSlots = [
      '08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00'
    ];

    setState(() {
      _availableSlots = allSlots.where((slot) => !occupiedSlots.contains(slot)).toList();
      _selectedSlot = null; // Reset selected slot
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      print('Selected date: ${_selectedDate!.toIso8601String()}');
    }
  }

  Future<void> _bookAppointment() async {
    if (_selectedEmployee != null && _selectedDate != null && _selectedSlot != null) {
      try {
        await _appointmentService.addAppointment(
          employeeId: _selectedEmployee!,
          personId: widget.personId,
          date: _selectedDate!.toIso8601String().split('T').first,
          time: _selectedSlot!,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment booked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => PersonHomePage(personId: widget.personId),
          ),
          (route) => false,
        );
      } catch (e) {
        print('Error booking appointment: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to book appointment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
              DropdownButtonFormField<String>(
                value: _selectedEmployee,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 14.0,
                  ),
                ),
                hint: const Text('Choose an employee'),
                items: _employees.map((employee) {
                  return DropdownMenuItem<String>(
                    value: employee['id'],
                    child: Text('${employee['name']} ${employee['lastName']}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEmployee = value;
                    _fetchAvailableSlots();
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await _selectDate(context);
                  await _fetchAvailableSlots();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
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
              DropdownButtonFormField<String>(
                value: _selectedSlot,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 14.0,
                  ),
                ),
                hint: const Text('Choose a time slot'),
                items: _availableSlots.map((slot) {
                  return DropdownMenuItem<String>(
                    value: slot,
                    child: Text(slot),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSlot = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: _selectedEmployee != null &&
                          _selectedDate != null &&
                          _selectedSlot != null
                      ? _bookAppointment
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 14.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Book Appointment'),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: PersonNavigationBar(personId: widget.businessId),
    );
  }
}

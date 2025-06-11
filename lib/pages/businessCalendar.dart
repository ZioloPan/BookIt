import 'package:flutter/material.dart';
import '../widgets/businessNavigationBar.dart';
import '../services/reservation-service.dart';
import '../services/business-service.dart';

class BusinessCalendarPage extends StatefulWidget {
  final String businessId;

  const BusinessCalendarPage({super.key, required this.businessId});

  @override
  _BusinessCalendarPageState createState() => _BusinessCalendarPageState();
}

class _BusinessCalendarPageState extends State<BusinessCalendarPage> {
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _filteredAppointments = [];
  List<Map<String, dynamic>> _employees = [];
  List<Map<String, dynamic>> _persons = [];
  DateTime? _selectedDate;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final business =
          await BusinessService().getBusinessById(int.parse(widget.businessId));
      final businessDto = business['businessDto'];
      final employees =
          (businessDto?['workers'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final persons =
          (businessDto?['clients'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      setState(() {
        _employees = employees;
        _persons = persons;
        _appointments = [];
        _filteredAppointments = [];
        _selectedDate = null;
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
        _loading = true;
      });

      final dateStr = "${pickedDate.year.toString().padLeft(4, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      try {
        final reservations = await ReservationService().getReservationsForDay(dateStr);
        setState(() {
          _appointments = List<Map<String, dynamic>>.from(reservations);
          _filterAppointmentsForSelectedDate();
          _loading = false;
        });
      } catch (e) {
        print('Error loading data: $e');
        setState(() {
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterAppointmentsForSelectedDate() {
    if (_selectedDate == null) return;

    final selectedDateString = _selectedDate!.toIso8601String().split('T').first;

    setState(() {
      _filteredAppointments = _appointments.where((appointment) {
        // Jeśli appointment['date'] to np. "2025-06-12T11:00:00", porównaj tylko datę
        final datePart = (appointment['date'] as String).split('T').first;
        return datePart == selectedDateString;
      }).toList();

      for (var appointment in _filteredAppointments) {
        final client = appointment['client'] ?? {};
        final employee = appointment['worker'] ?? {};

        appointment['employeeName'] = '${employee['firstName'] ?? 'Unknown'} ${employee['lastName'] ?? ''}';
        appointment['clientName'] = '${client['firstName'] ?? 'Unknown'} ${client['lastName'] ?? ''}';
        appointment['time'] = (appointment['date'] as String).split('T').length > 1
            ? (appointment['date'] as String).split('T')[1].substring(0, 5)
            : '';
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
              if (_loading)
                const Center(
                  child: CircularProgressIndicator(),
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

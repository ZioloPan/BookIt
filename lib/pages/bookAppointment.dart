import 'package:flutter/material.dart';
import '../widgets/personNavigationBar.dart';
import 'personHome.dart';
import '../services/reservation-service.dart';
import '../services/business-service.dart';

class BookAppointmentPage extends StatefulWidget {
  final int businessId;
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
  final ReservationService _reservationService = ReservationService();
  final BusinessService _businessService = BusinessService();

  List<Map<String, dynamic>> _employees = [];
  List<Map<String, dynamic>> _services = [];
  List<String> _availableSlots = [];

  String? _selectedEmployee;
  String? _selectedService;
  DateTime? _selectedDate;
  String? _selectedSlot;

  @override
  void initState() {
    super.initState();
    _fetchEmployeesAndServices();
  }

  Future<void> _fetchEmployeesAndServices() async {
    try {
      final business = await _businessService.getBusinessById(widget.businessId);
      final businessDto = business['businessDto'] ?? business;
      setState(() {
        _employees = List<Map<String, dynamic>>.from(businessDto['workers'] ?? []);
        _services = List<Map<String, dynamic>>.from(businessDto['services'] ?? []);
      });
    } catch (e) {
      print('Error loading employees/services: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load employees/services: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchAvailableSlots() async {
    if (_selectedService == null || _selectedDate == null) return;
    try {
      final slots = await _reservationService.getAvailableSlots(
        formatDate(_selectedDate!),
        int.parse(_selectedService!),
        int.tryParse(_selectedEmployee ?? ''),
      );
      print('DEBUG: Otrzymane sloty: $slots');
      setState(() {
        _availableSlots = slots;
        _selectedSlot = null;
      });
    } catch (e, stack) {
      print('Błąd pobierania slotów: $e');
      print('STACKTRACE: $stack');
      setState(() {
        _availableSlots = [];
        _selectedSlot = null;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _bookAppointment() async {
    if (_selectedEmployee != null &&
        _selectedDate != null &&
        _selectedSlot != null &&
        _selectedService != null) {
      try {
        // Format the date and time for the backend
        String formattedDate = _selectedDate!.toIso8601String().split('T').first;
        String selectedHour = _selectedSlot!; // Assuming _selectedSlot contains the time

        await _reservationService.bookAppointment(
          int.parse(_selectedService!),
          formatDateTimeForBackend(_selectedDate!, _selectedSlot!),
          int.parse(_selectedEmployee!),
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

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  String formatDateTimeForBackend(DateTime date, String hour) {
    // hour: "09:00:00" -> "09:00"
    final hourShort = hour.substring(0,5);
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year} $hourShort";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 169, 220, 223),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Image(
                    image: AssetImage('assets/images/logo.png'),
                    width: 150,
                    height: 150,
                  ),
                ),
                const SizedBox(height: 16),
                // Wybór pracownika
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
                      value: employee['id'].toString(),
                      child: Text('${employee['firstName']} ${employee['lastName']}'),
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
                // Wybór serwisu
                DropdownButtonFormField<String>(
                  value: _selectedService,
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
                  hint: const Text('Choose a service'),
                  items: _services.map((service) {
                    return DropdownMenuItem<String>(
                      value: service['id'].toString(),
                      child: Text('${service['name']} (${service['duration']} h)'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedService = value;
                      _fetchAvailableSlots();
                    });
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _selectDate(context);
                      await _fetchAvailableSlots();
                    },
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
                ),
                if (_selectedDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Selected date: ${formatDate(_selectedDate!)}',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                const SizedBox(height: 16),
                // Sloty czasowe
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
                            _selectedSlot != null &&
                            _selectedService != null
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
      ),
      bottomNavigationBar: PersonNavigationBar(personId: widget.personId),
    );
  }
}

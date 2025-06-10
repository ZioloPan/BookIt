import 'package:flutter/material.dart';
import '../services/business-service.dart';
import '../services/availability-service.dart';

class AvailabilitiesPage extends StatefulWidget {
  final String businessId;

  const AvailabilitiesPage({super.key, required this.businessId});

  @override
  State<AvailabilitiesPage> createState() => _AvailabilitiesPageState();
}

class _AvailabilitiesPageState extends State<AvailabilitiesPage> {
  final _businessService = BusinessService();
  final _availabilityService = AvailabilityService();

  List<Map<String, dynamic>> _workers = [];
  Map<String, dynamic>? _selectedWorker;
  bool _loading = true;

  final _dateController = TextEditingController();
  final _startHourController = TextEditingController();
  final _endHourController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchWorkers();
  }

  Future<void> _fetchWorkers() async {
    setState(() {
      _loading = true;
    });
    try {
      final business = await _businessService.getBusinessForOwner();
      final businessDto = business?['businessDto'] ?? business;
      final workers = (businessDto?['workers'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      setState(() {
        _workers = workers;
        _selectedWorker = workers.isNotEmpty ? workers.first : null;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas pobierania pracowników: $e')),
      );
    }
  }

  Future<void> _addAvailability() async {
    if (_selectedWorker == null) return;
    try {
      await _availabilityService.addAvailability(
        workerId: _selectedWorker!['id'],
        date: _dateController.text,
        startHour: _startHourController.text,
        endHour: _endHourController.text,
      );
      _dateController.clear();
      _startHourController.clear();
      _endHourController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dostępność dodana!')),
      );
    } catch (e, stack) {
      print('Błąd podczas dodawania dostępności: $e');
      print('STACKTRACE: $stack');
      // Możesz usunąć SnackBar lub zostawić pusty blok catch
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      // Format: dd-MM-yyyy
      _dateController.text = "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
    }
  }

  Future<void> _pickTime(BuildContext context, TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      controller.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _startHourController.dispose();
    _endHourController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 171, 165),
      appBar: AppBar(
        title: const Text('Availabilities'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Worker selector
                  DropdownButton<Map<String, dynamic>>(
                    value: _selectedWorker,
                    isExpanded: true,
                    hint: const Text('Wybierz pracownika'),
                    items: _workers
                        .map((worker) => DropdownMenuItem(
                              value: worker,
                              child: Text(
                                '${worker['firstName'] ?? ''} ${worker['lastName'] ?? ''}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ))
                        .toList(),
                    onChanged: (worker) {
                      setState(() {
                        _selectedWorker = worker;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Add availability form only
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Dodaj dostępność', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _dateController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Data (YYYY-MM-DD)',
                            border: OutlineInputBorder(),
                          ),
                          onTap: () => _pickDate(context),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _startHourController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Godzina rozpoczęcia (HH:MM)',
                            border: OutlineInputBorder(),
                          ),
                          onTap: () => _pickTime(context, _startHourController),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _endHourController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Godzina zakończenia (HH:MM)',
                            border: OutlineInputBorder(),
                          ),
                          onTap: () => _pickTime(context, _endHourController),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _addAvailability,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Dodaj dostępność'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
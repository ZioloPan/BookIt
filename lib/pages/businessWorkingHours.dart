import 'package:flutter/material.dart';
import '../services/business-service.dart';
import '../services/workingHours-service.dart';

class BusinessWorkingHoursPage extends StatefulWidget {
  const BusinessWorkingHoursPage({super.key});

  @override
  State<BusinessWorkingHoursPage> createState() => _BusinessWorkingHoursPageState();
}

class _BusinessWorkingHoursPageState extends State<BusinessWorkingHoursPage> {
  final _businessService = BusinessService();
  final _workingHoursService = WorkingHoursService();

  bool _loading = true;
  Map<String, dynamic>? _business;
  List<dynamic> _workingHours = [];
  bool _editMode = false;
  bool _isAdd = false;

  // Edycja godzin
  final List<String> _weekDays = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY',
  ];
  Map<String, TimeOfDay?> _startTimes = {};
  Map<String, TimeOfDay?> _endTimes = {};
  Map<String, bool> _isOpen = {};

  @override
  void initState() {
    super.initState();
    _fetchBusiness();
  }

  Future<void> _fetchBusiness() async {
    setState(() {
      _loading = true;
    });
    try {
      final business = await _businessService.getBusinessForOwner();
      final businessDto = business?['businessDto'] ?? business;
      final workingHours = businessDto?['workingHours'] ?? [];
      print('DEBUG: workingHours z backendu: $workingHours');
      setState(() {
        _business = businessDto;
        _workingHours = workingHours;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas pobierania danych biznesu: $e')),
      );
    }
  }

  void _showEditOrAdd({required bool isAdd}) {
    setState(() {
      _editMode = true;
      _isAdd = isAdd;
      // Zawsze pokazuj wszystkie dni tygodnia
      // _selectedDays = [];
      _startTimes = {};
      _endTimes = {};
      _isOpen = {};
      if (!isAdd && _workingHours.isNotEmpty) {
        for (var wh in _workingHours) {
          final day = wh['weekDay'];
          _startTimes[day] = _parseTime(wh['startTime']);
          _endTimes[day] = _parseTime(wh['endTime']);
          _isOpen[day] = wh['isOpen'] ?? true;
        }
      } else {
        // Domyślnie wszystkie dni otwarte 9-17
        for (var day in _weekDays) {
          _isOpen[day] = true;
          _startTimes[day] = const TimeOfDay(hour: 9, minute: 0);
          _endTimes[day] = const TimeOfDay(hour: 17, minute: 0);
        }
      }
    });
  }

  TimeOfDay? _parseTime(String? time) {
    if (time == null) return null;
    final parts = time.split(':');
    if (parts.length < 2) return null;
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> _pickTime(BuildContext context, String day, bool isStart) async {
    final initialTime = isStart
        ? (_startTimes[day] ?? const TimeOfDay(hour: 9, minute: 0))
        : (_endTimes[day] ?? const TimeOfDay(hour: 17, minute: 0));
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTimes[day] = picked;
        } else {
          _endTimes[day] = picked;
        }
      });
    }
  }

  Future<void> _saveWorkingHours() async {
    if (_business == null) return;
    final businessId = _business!['id'];
    // ZAWSZE wysyłaj wszystkie dni tygodnia
    final List<Map<String, dynamic>> workingHoursList = _weekDays.map((day) {
      final start = _startTimes[day];
      final end = _endTimes[day];
      return {
        "weekDay": day,
        "isOpen": _isOpen[day] ?? false,
        "startTime": (_isOpen[day] ?? false) && start != null
            ? "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}"
            : null,
        "endTime": (_isOpen[day] ?? false) && end != null
            ? "${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}"
            : null,
      };
    }).toList();

    try {
      if (_isAdd) {
        await _workingHoursService.addWorkingHours(
          businessId: businessId,
          workingHoursList: workingHoursList,
        );
      } else {
        await _workingHoursService.updateWorkingHours(
          businessId: businessId,
          workingHoursList: workingHoursList,
        );
      }
      setState(() {
        _editMode = false;
      });
      await _fetchBusiness();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Godziny otwarcia zapisane!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas zapisywania godzin: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 171, 165),
      appBar: AppBar(
        title: const Text('Saloon Working Hours'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: _editMode
                  ? _buildEditForm(context)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_workingHours.isNotEmpty)
                          ...[
                            const Text(
                              'Aktualne godziny otwarcia:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ..._workingHours.map((wh) => Card(
                                  child: ListTile(
                                    title: Text(
                                        '${wh['weekDay']}: ${wh['open'] == true ? '${wh['startTime']} - ${wh['endTime']}' : 'Zamknięte'}'),
                                  ),
                                )),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _showEditOrAdd(isAdd: false),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Edit'),
                              ),
                            ),
                          ]
                        else
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _showEditOrAdd(isAdd: true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Add working hours'),
                            ),
                          ),
                      ],
                    ),
            ),
    );
  }

  Widget _buildEditForm(BuildContext context) {
    return ListView(
      children: [
        const Text(
          'Ustaw godziny otwarcia dla każdego dnia tygodnia:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        // Zawsze pokazuj wszystkie dni tygodnia
        ..._weekDays.map((day) => Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _isOpen[day] ?? false,
                          onChanged: (val) {
                            setState(() {
                              _isOpen[day] = val ?? false;
                            });
                          },
                        ),
                        const Text('Otwarty'),
                      ],
                    ),
                    if (_isOpen[day] ?? false)
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickTime(context, day, true),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Godzina otwarcia',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  _startTimes[day] != null
                                      ? _startTimes[day]!.format(context)
                                      : 'Wybierz',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickTime(context, day, false),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Godzina zamknięcia',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  _endTimes[day] != null
                                      ? _endTimes[day]!.format(context)
                                      : 'Wybierz',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            )),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveWorkingHours,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continue'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _editMode = false;
              });
            },
            child: const Text('Anuluj'),
          ),
        ),
      ],
    );
  }
}
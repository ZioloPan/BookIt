import 'package:flutter/material.dart';
import '../widgets/businessNavigationBar.dart';
import '../services/employee-service.dart';
import 'editEmployeeDetails.dart';

class EditEmployeePage extends StatefulWidget {
  final String businessId;

  const EditEmployeePage({super.key, required this.businessId});

  @override
  _EditEmployeePageState createState() => _EditEmployeePageState();
}

class _EditEmployeePageState extends State<EditEmployeePage> {
  final EmployeeService _employeeService = EmployeeService();
  List<Map<String, dynamic>> _employees = [];

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
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
              const Center(
                child: Text(
                  'Edit Employees:',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _employees.isEmpty
                    ? const Center(
                        child: Text(
                          'No employees available.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _employees.length,
                        itemBuilder: (context, index) {
                          final employee = _employees[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              leading: const Icon(Icons.person, color: Colors.black),
                              title: Text(
                                '${employee['name']} ${employee['lastName']}',
                                style: const TextStyle(
                                    color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Email: ${employee['email']}',
                                    style: const TextStyle(color: Colors.black87),
                                  ),
                                  Text(
                                    'Phone: ${employee['phone']}',
                                    style: const TextStyle(color: Colors.black87),
                                  ),
                                ],
                              ),
                              onTap: () {
                                print('Editing employee: ${employee['id']}');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditEmployeeDetailsPage(
                                      id: employee['id'],
                                      businessId: widget.businessId,
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
      bottomNavigationBar: BusinessNavigationBar(
        businessId: widget.businessId, // Przekazanie ID biznesu do paska nawigacji
      ),
    );
  }
}

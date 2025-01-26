import 'package:flutter/material.dart';
import '../widgets/businessNavigationBar.dart';
import '../services/employee-service.dart';

class DeleteEmployeePage extends StatefulWidget {
  final String businessId;

  const DeleteEmployeePage({super.key, required this.businessId});

  @override
  State<DeleteEmployeePage> createState() => _DeleteEmployeePageState();
}

class _DeleteEmployeePageState extends State<DeleteEmployeePage> {
  final EmployeeService _employeeService = EmployeeService();
  List<Map<String, dynamic>> _employees = [];
  bool _isLoading = true;

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
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading employees: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load employees: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteEmployee(String employeeId) async {
    try {
      final success = await _employeeService.deleteEmployee(employeeId);
      if (success) {
        setState(() {
          _employees.removeWhere((employee) => employee['id'] == employeeId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Employee deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to delete employee.');
      }
    } catch (e) {
      print('Error deleting employee: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete employee: $e'),
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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Delete Employees:',
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
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.person,
                                      color: Colors.black,
                                    ),
                                    title: Text(
                                      '${employee['name']} ${employee['lastName']}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Email: ${employee['email']}',
                                          style: const TextStyle(
                                              color: Colors.black87),
                                        ),
                                        Text(
                                          'Phone: ${employee['phone']}',
                                          style: const TextStyle(
                                              color: Colors.black87),
                                        ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        _deleteEmployee(employee['id']);
                                      },
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
        businessId: widget.businessId, // Przekazanie ID biznesu do paska nawigacji
      ),
    );
  }
}

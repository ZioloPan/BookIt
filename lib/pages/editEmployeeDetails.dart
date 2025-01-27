import 'package:flutter/material.dart';
import '../widgets/businessNavigationBar.dart';
import '../services/employee-service.dart';

class EditEmployeeDetailsPage extends StatefulWidget {
  final String id;
  final String businessId;

  const EditEmployeeDetailsPage({
    super.key,
    required this.id,
    required this.businessId,
  });

  @override
  _EditEmployeeDetailsPageState createState() => _EditEmployeeDetailsPageState();
}

class _EditEmployeeDetailsPageState extends State<EditEmployeeDetailsPage> {
  final EmployeeService _employeeService = EmployeeService();

  late TextEditingController _nameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _loadEmployeeDetails();
  }

  Future<void> _loadEmployeeDetails() async {
    try {
      final employee = await _employeeService.getEmployeeById(widget.id);

      if (employee != null) {
        setState(() {
          _nameController.text = employee['name'] ?? '';
          _lastNameController.text = employee['lastName'] ?? '';
          _emailController.text = employee['email'] ?? '';
          _phoneController.text = employee['phone'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Employee not found.'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error loading employee details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load employee details: $e'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _updateEmployee() async {
    final updatedEmployee = {
      'id': widget.id,
      'businessId': widget.businessId,
      'name': _nameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
    };

    try {
      final success = await _employeeService.updateEmployee(widget.id, updatedEmployee);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Employee updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('Failed to update employee.');
      }
    } catch (e) {
      print('Error updating employee: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update employee: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 171, 165),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Edit Employee Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLabeledTextField('First Name', _nameController),
                    const SizedBox(height: 16),
                    _buildLabeledTextField('Last Name', _lastNameController),
                    const SizedBox(height: 16),
                    _buildLabeledTextField('Email', _emailController),
                    const SizedBox(height: 16),
                    _buildLabeledTextField('Phone', _phoneController),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateEmployee,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 14.0,
                          ),
                        ),
                        child: const Text('Save Changes'),
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

  Widget _buildLabeledTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
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
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../services/business-service.dart';
import '../widgets/businessNavigationBar.dart';

class AddEmployeePage extends StatefulWidget {
  final String businessId;

  const AddEmployeePage({super.key, required this.businessId});

  @override
  State<AddEmployeePage> createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nipController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _nipController.dispose();
    super.dispose();
  }

  Future<void> _addEmployee() async {
    final name = _nameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final nip = _nipController.text.trim();

    if (name.isEmpty || lastName.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty || nip.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields are required!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final workerData = {
      "firstName": name,
      "lastName": lastName,
      "email": email,
      "password": password,
      "phoneNumber": phone,
      "userRole": "WORKER",
      "nip": nip,
    };

    try {
      await BusinessService().addWorkerToBusiness(int.parse(widget.businessId), workerData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Employee added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add employee: $e'),
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Add New Employee',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildTextField('Name', _nameController),
                const SizedBox(height: 16),
                _buildTextField('Last Name', _lastNameController),
                const SizedBox(height: 16),
                _buildTextField('Email', _emailController),
                const SizedBox(height: 16),
                _buildTextField('Phone Number', _phoneController),
                const SizedBox(height: 16),
                _buildTextField('Password', _passwordController, isPassword: true),
                const SizedBox(height: 16),
                _buildTextField('NIP', _nipController),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addEmployee,
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
                      child: const Text('Confirm'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BusinessNavigationBar(
        businessId: widget.businessId,
      ),
    );
  }

  Widget _buildTextField(String hintText, TextEditingController controller, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 14.0,
        ),
      ),
    );
  }
}

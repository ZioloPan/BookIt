import 'package:flutter/material.dart';

import '../widgets/personNavigationBar.dart';
import '../auth/auth_storage.dart'; // dla getStoredToken
import '../services/user-service.dart';

class EditPersonPage extends StatefulWidget {
  final String personId;

  const EditPersonPage({
    super.key,
    required this.personId,
  });

  @override
  _EditPersonPageState createState() => _EditPersonPageState();
}

class _EditPersonPageState extends State<EditPersonPage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late TextEditingController _repeatPasswordController;

  bool _isLoading = true;
  String? _errorMessage;
  int? _userId;

  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _repeatPasswordController = TextEditingController();
    _loadPersonDetails();
  }

  Future<void> _loadPersonDetails() async {
    try {
      final token = await getStoredToken();
      if (token == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Not logged in.';
        });
        return;
      }
      final user = await _userService.getCurrentUser(token);
      setState(() {
        _userId = user.id;
        _firstNameController.text = user.firstName;
        _lastNameController.text = user.lastName;
        _emailController.text = user.email;
        _phoneController.text = user.phoneNumber;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load person details.';
      });
    }
  }

  Future<void> _updatePerson() async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      setState(() {
        _errorMessage = 'All fields except password must be filled out.';
      });
      return;
    }

    if (_passwordController.text.isNotEmpty &&
        _passwordController.text != _repeatPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match.';
      });
      return;
    }

    final updatedData = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
    };

    if (_passwordController.text.isNotEmpty) {
      updatedData['password'] = _passwordController.text.trim();
    }

    try {
      if (_userId == null) {
        setState(() {
          _errorMessage = 'User ID not loaded.';
        });
        return;
      }

      await _userService.updateUser(_userId!, updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Person updated successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update person.';
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 169, 220, 223),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      Image.asset(
                        'assets/images/logo.png',
                        width: 150,
                        height: 150,
                      ),
                      const SizedBox(height: 32),
                      const Center(
                        child: Text(
                          'Edit Your Profile',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _buildLabeledTextField('First Name', _firstNameController),
                      const SizedBox(height: 16),
                      _buildLabeledTextField('Last Name', _lastNameController),
                      const SizedBox(height: 16),
                      _buildLabeledTextField('Email', _emailController),
                      const SizedBox(height: 16),
                      _buildLabeledTextField('Phone', _phoneController),
                      const SizedBox(height: 16),
                      _buildLabeledTextField('Password', _passwordController, obscureText: true),
                      const SizedBox(height: 16),
                      _buildLabeledTextField('Repeat Password', _repeatPasswordController, obscureText: true),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updatePerson,
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
            ),
      bottomNavigationBar: PersonNavigationBar(personId: widget.personId),
    );
  }

  Widget _buildLabeledTextField(String label, TextEditingController controller, {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
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
import 'package:flutter/material.dart';
import '../widgets/businessNavigationBar.dart';
import '../auth/auth_storage.dart';
import '../services/user-service.dart';

class EditBusinessOwnerPage extends StatefulWidget {
  final String personId;

  const EditBusinessOwnerPage({
    super.key,
    required this.personId,
  });

  @override
  _EditBusinessOwnerPageState createState() => _EditBusinessOwnerPageState();
}

class _EditBusinessOwnerPageState extends State<EditBusinessOwnerPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _nipController;
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
    _nipController = TextEditingController();
    _passwordController = TextEditingController();
    _repeatPasswordController = TextEditingController();
    _loadOwnerDetails();
  }

  Future<void> _loadOwnerDetails() async {
    try {
      final token = await getStoredToken();
      print('TOKEN: $token');
      if (token == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Not logged in.';
        });
        return;
      }
      final user = await _userService.getCurrentUser(token);
      print('USER: $user');
      setState(() {
        _userId = user.id;
        _firstNameController.text = user.firstName;
        _lastNameController.text = user.lastName;
        _emailController.text = user.email;
        _phoneController.text = user.phoneNumber;
        //_nipController.text = user.nip; // <-- dodaj tę linię!
        _isLoading = false;
      });
    } catch (e) {
      print('LOAD OWNER ERROR: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load owner details.';
      });
    }
  }

  Future<void> _updateOwner() async {
    if (_formKey.currentState!.validate()) {
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
        'nip': _nipController.text.trim(),
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

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Business owner updated!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to update business owner.';
        });
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nipController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 171, 165),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Edit Business Owner Profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (_errorMessage != null) ...[
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          children: [
                            _buildTextField('First Name', _firstNameController, isRequired: true),
                            const SizedBox(height: 16),
                            _buildTextField('Last Name', _lastNameController, isRequired: true),
                            const SizedBox(height: 16),
                            _buildTextField('Email', _emailController, isRequired: true, keyboardType: TextInputType.emailAddress),
                            const SizedBox(height: 16),
                            _buildTextField('Phone', _phoneController, isRequired: true, keyboardType: TextInputType.phone),
                            const SizedBox(height: 16),
                            _buildTextField('NIP', _nipController, isRequired: true),
                            const SizedBox(height: 16),
                            _buildTextField('Password', _passwordController, obscureText: true),
                            const SizedBox(height: 16),
                            _buildTextField('Repeat Password', _repeatPasswordController, obscureText: true),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _updateOwner,
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
                                child: const Text('Save changes'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BusinessNavigationBar(businessId: widget.personId),
    );
  }

  Widget _buildTextField(
    String hintText,
    TextEditingController controller, {
    bool isRequired = false,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
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
      validator: isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $hintText';
              }
              return null;
            }
          : null,
    );
  }
}
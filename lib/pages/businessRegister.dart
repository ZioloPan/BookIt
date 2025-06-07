import 'package:flutter/material.dart';
import '../services/auth-service.dart';
import 'businessWelcome.dart';

class BusinessRegisterPage extends StatefulWidget {
  final String email;
  final Color backgroundColor;

  const BusinessRegisterPage({
    super.key,
    required this.email,
    required this.backgroundColor,
  });

  @override
  _BusinessRegisterPageState createState() => _BusinessRegisterPageState();
}

class _BusinessRegisterPageState extends State<BusinessRegisterPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  final _nipNumberController = TextEditingController();

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    _nipNumberController.dispose();
    super.dispose();
  }

  Future<void> _registerBusinessOwner() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phone = _phoneNumberController.text.trim();
    final password = _passwordController.text.trim();
    final repeatPassword = _repeatPasswordController.text.trim();
    final nip = _nipNumberController.text.trim();
    final email = widget.email.trim();

    if (firstName.isEmpty || lastName.isEmpty || phone.isEmpty || password.isEmpty || nip.isEmpty) {
      _showError('All fields are required!');
      return;
    }

    if (password != repeatPassword) {
      _showError('Passwords do not match!');
      return;
    }

    try {
      final success = await _authService.registerBusinessOwner(
        firstName: firstName,
        lastName: lastName,
        password: password,
        email: email,
        phoneNumber: phone,
        nip: nip,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business owner registered successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BusinessWelcomePage()),
        );
      }
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: SafeArea(
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
                const SizedBox(height: 16),
                _buildTextField(controller: _passwordController, hintText: "Password", obscureText: true),
                const SizedBox(height: 16),
                _buildTextField(controller: _repeatPasswordController, hintText: "Repeat Password", obscureText: true),
                const SizedBox(height: 16),
                _buildTextField(controller: _firstNameController, hintText: "First name"),
                const SizedBox(height: 16),
                _buildTextField(controller: _lastNameController, hintText: "Last name"),
                const SizedBox(height: 16),
                TextField(
                  controller: TextEditingController(text: widget.email),
                  enabled: false,
                  decoration: InputDecoration(
                    fillColor: Colors.grey[200],
                    filled: true,
                    hintText: "Email",
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
                const SizedBox(height: 16),
                _buildTextField(controller: _phoneNumberController, hintText: "Phone number"),
                const SizedBox(height: 16),
                _buildTextField(controller: _nipNumberController, hintText: "NIP number"),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _registerBusinessOwner,
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
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
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

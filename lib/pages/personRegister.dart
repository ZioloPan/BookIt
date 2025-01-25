import 'package:flutter/material.dart';

class PersonRegisterPage extends StatelessWidget {
  final String email;
  final Color backgroundColor;

  const PersonRegisterPage({
    super.key,
    required this.email,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
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
                _buildTextField(hintText: "Password", obscureText: true),
                const SizedBox(height: 16),
                _buildTextField(hintText: "Repeat Password", obscureText: true),
                const SizedBox(height: 16),
                _buildTextField(hintText: "Name"),
                const SizedBox(height: 16),
                _buildTextField(hintText: "Last Name"),
                const SizedBox(height: 16),
                _buildTextField(hintText: "Email", initialValue: email),
                const SizedBox(height: 16),
                _buildTextField(hintText: "Phone"),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
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
    required String hintText,
    String? initialValue,
    bool obscureText = false,
  }) {
    return TextField(
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
      controller: initialValue != null ? TextEditingController(text: initialValue) : null,
    );
  }
}
import 'package:flutter/material.dart';
import '../services/business-service.dart';
import 'businessLogin.dart';

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
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  final _salonNameController = TextEditingController();
  final _salonCategoryController = TextEditingController();
  final _salonPhoneNumberController = TextEditingController();
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _localNumberController = TextEditingController();
  final _postCodeController = TextEditingController();
  final _nipNumberController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    _salonNameController.dispose();
    _salonCategoryController.dispose();
    _salonPhoneNumberController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _localNumberController.dispose();
    _postCodeController.dispose();
    _nipNumberController.dispose();
    super.dispose();
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
                _buildTextField(controller: _salonNameController, hintText: "Salon’s name"),
                const SizedBox(height: 16),
                _buildTextField(controller: _salonCategoryController, hintText: "Salon’s category"),
                const SizedBox(height: 16),
                _buildTextField(controller: _salonPhoneNumberController, hintText: "Salon’s phone number"),
                const SizedBox(height: 16),
                TextField(
                  controller: TextEditingController(text: widget.email),
                  enabled: false,
                  decoration: InputDecoration(
                    fillColor: Colors.grey[200],
                    filled: true,
                    hintText: "Salon’s email",
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
                const Text(
                  "Salon’s address",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTextField(controller: _cityController, hintText: "City"),
                const SizedBox(height: 16),
                _buildTextField(controller: _streetController, hintText: "Street"),
                const SizedBox(height: 16),
                _buildTextField(controller: _localNumberController, hintText: "Local number"),
                const SizedBox(height: 16),
                _buildTextField(controller: _postCodeController, hintText: "Post code"),
                const SizedBox(height: 16),
                _buildTextField(controller: _nipNumberController, hintText: "NIP number"),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final service = BusinessRegisterService();

                      try {
                        await service.addBusiness(
                          password: _passwordController.text,
                          salonName: _salonNameController.text,
                          salonCategory: _salonCategoryController.text,
                          salonPhoneNumber: _salonPhoneNumberController.text,
                          salonEmail: widget.email,
                          city: _cityController.text,
                          street: _streetController.text,
                          localNumber: _localNumberController.text,
                          postCode: _postCodeController.text,
                          nipNumber: _nipNumberController.text,
                        );

                        // Przekierowanie po sukcesie
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BusinessLoginPage(
                              backgroundColor: widget.backgroundColor,
                            ),
                          ),
                        );
                      } catch (e) {
                        // Obsługa błędu
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
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

import 'package:flutter/material.dart';
import '../services/business-service.dart';
import 'businessHome.dart';

class BusinessCreatePage extends StatefulWidget {
  const BusinessCreatePage({super.key});

  @override
  State<BusinessCreatePage> createState() => _BusinessCreatePageState();
}

class _BusinessCreatePageState extends State<BusinessCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController(text: 'HAIRSTYLE');
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _localNumberController = TextEditingController();
  final _postCodeController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submitBusiness() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final businessData = {
      "name": _nameController.text,
      "type": _typeController.text,
      "phoneNumber": _phoneController.text,
      "email": _emailController.text,
      "addressRequest": {
        "city": _cityController.text,
        "street": _streetController.text,
        "localNumber": _localNumberController.text,
        "postCode": _postCodeController.text
      }
    };

    try {
      await BusinessService().addBusiness(businessData);
      final createdBusiness = await BusinessService().getBusinessForOwner();
      final businessId = createdBusiness?['businessDto']['id'].toString();

      if (businessId != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BusinessHomePage(businessId: businessId),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Business created, but ID was not returned.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 171, 165),
      appBar: AppBar(
        title: const Text('Create Business'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  Image.asset(
                    'assets/images/logo.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 16),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  _buildTextFormField(
                    controller: _nameController,
                    hintText: 'Business Name',
                    validator: (value) =>
                        value!.isEmpty ? 'Enter business name' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _phoneController,
                    hintText: 'Phone Number',
                    validator: (value) =>
                        value!.isEmpty ? 'Enter phone number' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _emailController,
                    hintText: 'Email',
                    validator: (value) =>
                        value!.isEmpty ? 'Enter email' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _cityController,
                    hintText: 'City',
                    validator: (value) =>
                        value!.isEmpty ? 'Enter city' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _streetController,
                    hintText: 'Street',
                    validator: (value) =>
                        value!.isEmpty ? 'Enter street' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _localNumberController,
                    hintText: 'Local Number',
                    validator: (value) =>
                        value!.isEmpty ? 'Enter local number' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _postCodeController,
                    hintText: 'Post Code',
                    validator: (value) =>
                        value!.isEmpty ? 'Enter post code' : null,
                  ),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitBusiness,
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
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
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

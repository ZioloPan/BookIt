import 'package:flutter/material.dart';
import '../services/business-service.dart';

class EditBusinessPage extends StatefulWidget {
  const EditBusinessPage({super.key});

  @override
  _EditBusinessPageState createState() => _EditBusinessPageState();
}

class _EditBusinessPageState extends State<EditBusinessPage> {
  final _formKey = GlobalKey<FormState>();
  final BusinessService _businessService = BusinessService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _localNumberController = TextEditingController();
  final TextEditingController _postCodeController = TextEditingController();

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchBusinessDetails();
  }

  Future<void> _fetchBusinessDetails() async {
    try {
      final business = await _businessService.getBusinessForOwner();
      if (business != null) {
        setState(() {
          _nameController.text = business['name'] ?? '';
          _typeController.text = business['type'] ?? '';
          _phoneNumberController.text = business['phoneNumber'] ?? '';
          _emailController.text = business['email'] ?? '';
          final address = business['address'] ?? business['addressRequest'] ?? {};
          _cityController.text = address['city'] ?? '';
          _streetController.text = address['street'] ?? '';
          _localNumberController.text = address['localNumber'] ?? '';
          _postCodeController.text = address['postCode'] ?? '';
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No business assigned to the owner found.')),
        );
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error while fetching business data: $e')),
      );
    }
  }

  Future<void> _updateBusiness() async {
    if (_formKey.currentState!.validate()) {
      final updatedBusiness = {
        "name": _nameController.text,
        "type": _typeController.text,
        "phoneNumber": _phoneNumberController.text,
        "email": _emailController.text,
        "addressRequest": {
          "city": _cityController.text,
          "street": _streetController.text,
          "localNumber": _localNumberController.text,
          "postCode": _postCodeController.text,
        }
      };
      try {
        await _businessService.updateBusiness(updatedBusiness);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Business data updated!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error while updating: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _localNumberController.dispose();
    _postCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 171, 165),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Edit Business',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          children: [
                            _buildTextField('Business Name', _nameController, isRequired: true),
                            const SizedBox(height: 16),
                            _buildTextField('Type (e.g. HAIRSTYLE)', _typeController, isRequired: true),
                            const SizedBox(height: 16),
                            _buildTextField('Phone Number', _phoneNumberController, isRequired: true, keyboardType: TextInputType.phone),
                            const SizedBox(height: 16),
                            _buildTextField('Email', _emailController, isRequired: true, keyboardType: TextInputType.emailAddress),
                            const SizedBox(height: 16),
                            _buildTextField('City', _cityController, isRequired: true),
                            const SizedBox(height: 16),
                            _buildTextField('Street', _streetController, isRequired: true),
                            const SizedBox(height: 16),
                            _buildTextField('Local Number', _localNumberController, isRequired: true),
                            const SizedBox(height: 16),
                            _buildTextField('Post Code', _postCodeController, isRequired: true),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _updateBusiness,
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
    );
  }

  Widget _buildTextField(
    String hintText,
    TextEditingController controller, {
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
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
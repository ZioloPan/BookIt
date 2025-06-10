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
          const SnackBar(content: Text('Nie znaleziono biznesu przypisanego do właściciela.')),
        );
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas pobierania danych biznesu: $e')),
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
            const SnackBar(content: Text('Dane biznesu zostały zaktualizowane!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd podczas aktualizacji: $e')),
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
      appBar: AppBar(
        title: const Text('Edytuj Biznes'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      _buildLabeledTextField('Nazwa', _nameController, true),
                      const SizedBox(height: 16),
                      _buildLabeledTextField('Typ (np. HAIRSTYLE)', _typeController, true),
                      const SizedBox(height: 16),
                      _buildLabeledTextField('Telefon', _phoneNumberController, true, TextInputType.phone),
                      const SizedBox(height: 16),
                      _buildLabeledTextField('Email', _emailController, true, TextInputType.emailAddress),
                      const SizedBox(height: 16),
                      const Text('Adres', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _buildLabeledTextField('Miasto', _cityController, true),
                      const SizedBox(height: 16),
                      _buildLabeledTextField('Ulica', _streetController, true),
                      const SizedBox(height: 16),
                      _buildLabeledTextField('Numer lokalu', _localNumberController, true),
                      const SizedBox(height: 16),
                      _buildLabeledTextField('Kod pocztowy', _postCodeController, true),
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
                          child: const Text('Zapisz zmiany'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildLabeledTextField(
      String label, TextEditingController controller, bool isRequired,
      [TextInputType keyboardType = TextInputType.text]) {
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
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
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
          validator: isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Wprowadź $label';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }
}
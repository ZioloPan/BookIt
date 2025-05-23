import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/business-service.dart';
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

  LatLng? _selectedLocation;

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

  Future<void> _registerBusiness() async {
    if (_passwordController.text.isEmpty ||
        _repeatPasswordController.text.isEmpty ||
        _salonNameController.text.isEmpty ||
        _salonCategoryController.text.isEmpty ||
        _salonPhoneNumberController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _streetController.text.isEmpty ||
        _localNumberController.text.isEmpty ||
        _postCodeController.text.isEmpty ||
        _nipNumberController.text.isEmpty ||
        _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields are required, including location!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text != _repeatPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final service = BusinessService();

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
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Business registered successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const BusinessWelcomePage(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                const SizedBox(height: 16),
                const Text(
                  "Pick salon location on map",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 250,
                  child: FlutterMap(
                    options: MapOptions(
                      center: _selectedLocation ?? LatLng(52.2297, 21.0122),
                      zoom: 12.0,
                      onTap: (tapPosition, point) {
                        setState(() {
                          _selectedLocation = point;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: ['a', 'b', 'c'],
                      ),
                      if (_selectedLocation != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedLocation!,
                              width: 40,
                              height: 40,
                              builder: (ctx) => const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (_selectedLocation != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Lat: ${_selectedLocation!.latitude.toStringAsFixed(5)}, Lon: ${_selectedLocation!.longitude.toStringAsFixed(5)}",
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _registerBusiness,
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
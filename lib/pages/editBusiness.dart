import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/business-service.dart';

class EditBusinessPage extends StatefulWidget {
  final String businessId;

  const EditBusinessPage({super.key, required this.businessId});

  @override
  _EditBusinessPageState createState() => _EditBusinessPageState();
}

class _EditBusinessPageState extends State<EditBusinessPage> {
  final _formKey = GlobalKey<FormState>();
  final BusinessService _service = BusinessService();

  final TextEditingController _salonNameController = TextEditingController();
  final TextEditingController _salonCategoryController = TextEditingController();
  final TextEditingController _salonPhoneNumberController = TextEditingController();
  final TextEditingController _salonEmailController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _localNumberController = TextEditingController();
  final TextEditingController _postCodeController = TextEditingController();
  final TextEditingController _nipNumberController = TextEditingController();

  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _fetchBusinessDetails();
  }

  Future<void> _fetchBusinessDetails() async {
    try {
      final businesses = await _service.getAllBusinesses();
      final business = businesses.firstWhere((b) => b['id'] == widget.businessId);

      setState(() {
        _salonNameController.text = business['salonName'] ?? '';
        _salonCategoryController.text = business['salonCategory'] ?? '';
        _salonPhoneNumberController.text = business['salonPhoneNumber'] ?? '';
        _salonEmailController.text = business['salonEmail'] ?? '';
        _cityController.text = business['address']['city'] ?? '';
        _streetController.text = business['address']['street'] ?? '';
        _localNumberController.text = business['address']['localNumber'] ?? '';
        _postCodeController.text = business['address']['postCode'] ?? '';
        _nipNumberController.text = business['nipNumber'] ?? '';
        final lat = business['latitude']?.toDouble();
        final lon = business['longitude']?.toDouble();
        _selectedLocation = LatLng(lat, lon);
      });
    } catch (e) {
      print('Error fetching business details: $e');
    }
  }

  Future<void> _updateBusiness() async {
    if (_formKey.currentState!.validate() && _selectedLocation != null) {
      final updatedData = {
        'salonName': _salonNameController.text,
        'salonCategory': _salonCategoryController.text,
        'salonPhoneNumber': _salonPhoneNumberController.text,
        'salonEmail': _salonEmailController.text,
        'address': {
          'city': _cityController.text,
          'street': _streetController.text,
          'localNumber': _localNumberController.text,
          'postCode': _postCodeController.text,
        },
        'nipNumber': _nipNumberController.text,
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
      };

      final success = await _service.updateBusiness(widget.businessId, updatedData);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update business.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _salonNameController.dispose();
    _salonCategoryController.dispose();
    _salonPhoneNumberController.dispose();
    _salonEmailController.dispose();
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
      backgroundColor: const Color.fromARGB(255, 244, 171, 165),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildLabeledTextField('Salon Name', _salonNameController, true),
                const SizedBox(height: 16),
                _buildLabeledTextField('Salon Category', _salonCategoryController, false),
                const SizedBox(height: 16),
                _buildLabeledTextField('Phone Number', _salonPhoneNumberController, false, TextInputType.phone),
                const SizedBox(height: 16),
                _buildLabeledTextField('Email', _salonEmailController, false, TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildLabeledTextField('City', _cityController, false),
                const SizedBox(height: 16),
                _buildLabeledTextField('Street', _streetController, false),
                const SizedBox(height: 16),
                _buildLabeledTextField('Local Number', _localNumberController, false),
                const SizedBox(height: 16),
                _buildLabeledTextField('Post Code', _postCodeController, false),
                const SizedBox(height: 16),
                _buildLabeledTextField('NIP Number', _nipNumberController, false),
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
                  child: _selectedLocation == null
                      ? const Center(child: CircularProgressIndicator())
                      : FlutterMap(
                          options: MapOptions(
                            center: _selectedLocation,
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
                    child: const Text('Update Business'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledTextField(String label, TextEditingController controller, bool isRequired, [TextInputType keyboardType = TextInputType.text]) {
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
                    return 'Please enter $label';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }
}
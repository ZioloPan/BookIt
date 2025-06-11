import 'package:flutter/material.dart';
import '../services/business-service.dart';
import '../services/services-service.dart';

class BusinessServicePage extends StatefulWidget {
  final String businessId;
  const BusinessServicePage({super.key, required this.businessId});

  @override
  State<BusinessServicePage> createState() => _BusinessServicePageState();
}

class _BusinessServicePageState extends State<BusinessServicePage> {
  final _businessService = BusinessService();
  final _servicesService = ServicesService();

  List<dynamic> _services = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchBusiness();
  }

  Future<void> _fetchBusiness() async {
    setState(() {
      _loading = true;
    });
    try {
      final business = await _businessService.getBusinessForOwner();
      final businessDto = business?['businessDto'] ?? business;
      final services = businessDto?['services'] ?? [];
      setState(() {
        _services = services;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _showServiceDialog({Map<String, dynamic>? service}) {
    final nameController = TextEditingController(text: service?['name'] ?? '');
    final descriptionController = TextEditingController(text: service?['description'] ?? '');
    final priceController = TextEditingController(text: service?['price']?.toString() ?? '');
    final categoryController = TextEditingController(text: service?['category'] ?? '');
    final durationController = TextEditingController(text: service?['duration']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(service == null ? 'Add Service' : 'Edit Service'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(hintText: 'Name', controller: nameController),
              const SizedBox(height: 8),
              _buildTextField(hintText: 'Description', controller: descriptionController),
              const SizedBox(height: 8),
              _buildTextField(
                hintText: 'Price',
                controller: priceController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              _buildTextField(hintText: 'Category', controller: categoryController),
              const SizedBox(height: 8),
              _buildTextField(
                hintText: 'Duration (hours)',
                controller: durationController,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 14.0,
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  if (service == null) {
                    await _servicesService.addService(
                      businessId: int.parse(widget.businessId),
                      name: nameController.text,
                      description: descriptionController.text,
                      price: double.tryParse(priceController.text) ?? 0,
                      category: categoryController.text,
                      duration: int.tryParse(durationController.text) ?? 0,
                    );
                  } else {
                    await _servicesService.updateService(
                      businessId: int.parse(widget.businessId),
                      serviceId: service['id'],
                      name: nameController.text,
                      description: descriptionController.text,
                      price: double.tryParse(priceController.text) ?? 0,
                      category: categoryController.text,
                      duration: int.tryParse(durationController.text) ?? 0,
                    );
                  }
                  Navigator.pop(context);
                  _fetchBusiness();
                } catch (e) {
                  Navigator.pop(context);
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
              child: Text(service == null ? 'Add' : 'Save'),
            ),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 171, 165),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Saloon Services',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showServiceDialog(),
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
                  child: const Text('Add Service'),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _services.isEmpty
                        ? const Center(child: Text('No services available.'))
                        : ListView.builder(
                            itemCount: _services.length,
                            itemBuilder: (context, index) {
                              final service = _services[index];
                              return Card(
                                child: ListTile(
                                  title: Text(service['name'] ?? ''),
                                  subtitle: Text(
                                    'Category: ${service['category'] ?? ''}\n'
                                    'Price: ${service['price'] ?? ''} zł\n'
                                    'Duration: ${service['duration'] ?? ''} h',
                                  ),
                                  onTap: () => _showServiceDialog(service: service),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
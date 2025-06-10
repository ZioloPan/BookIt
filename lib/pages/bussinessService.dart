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
      // Nie wyświetlamy błędu jeśli nie ma usług
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
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(labelText: 'Duration (min)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
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
                  SnackBar(content: Text('Błąd: $e')),
                );
              }
            },
            child: Text(service == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 171, 165),
      appBar: AppBar(
        title: const Text('Saloon Services'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showServiceDialog(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Add Service'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _services.isEmpty
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
                                    'Duration: ${service['duration'] ?? ''} min',
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
    );
  }
}
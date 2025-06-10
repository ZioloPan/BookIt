import 'package:flutter/material.dart';
import '../widgets/personNavigationBar.dart';
import '../services/business-service.dart';
import '../services/user-service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'bookAppointment.dart';

class PersonHomePage extends StatefulWidget {
  final String personId;

  const PersonHomePage({
    super.key,
    required this.personId,
  });

  @override
  _PersonHomePageState createState() => _PersonHomePageState();
}

class _PersonHomePageState extends State<PersonHomePage> {
  final BusinessService _businessService = BusinessService();
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();
  final _secureStorage = FlutterSecureStorage();

  List<Map<String, dynamic>> _allBusinesses = [];
  List<Map<String, dynamic>> _filteredBusinesses = [];
  String? _personName;

  @override
  void initState() {
    super.initState();
    _fetchBusinesses();
    _fetchCurrentUser();
  }

  Future<void> _fetchBusinesses() async {
    try {
      final businesses = await _businessService.getAllBusinesses();
      setState(() {
        _allBusinesses = businesses;
        _filteredBusinesses = businesses;
      });
    } catch (e) {
      debugPrint('Error fetching businesses: $e');
    }
  }

  Future<void> _fetchCurrentUser() async {
    final token = await _secureStorage.read(key: 'jwt_token');
    if (token == null) return;

    try {
      final user = await _userService.getCurrentUser(token);
      setState(() {
        _personName = user.firstName;
      });
    } catch (e) {
      setState(() {
        _personName = 'User';
      });
    }
  }

  void _filterBusinesses(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBusinesses = _allBusinesses;
      } else {
        _filteredBusinesses = _allBusinesses
            .where((business) =>
                business['name']?.toLowerCase().contains(query.toLowerCase()) ?? false)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 169, 220, 223),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${_personName ?? 'Loading...'}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  hintText: 'Search Salon',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 14.0,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _filterBusinesses('');
                    },
                  ),
                ),
                onChanged: _filterBusinesses,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _filteredBusinesses.isEmpty
                    ? const Center(
                        child: Text('No salons found.'),
                      )
                    : ListView.builder(
                        itemCount: _filteredBusinesses.length,
                        itemBuilder: (context, index) {
                          final business = _filteredBusinesses[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              leading: const Icon(Icons.store, color: Colors.black),
                              title: Text(
                                business['name'] ?? 'Unnamed Business',
                                style: const TextStyle(
                                    color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Type: ${business['type'] ?? 'No type'}',
                                    style: const TextStyle(color: Colors.black87),
                                  ),
                                  Text(
                                    'City: ${business['address']?['city'] ?? 'No city'}',
                                    style: const TextStyle(color: Colors.black87),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookAppointmentPage(
                                      businessId: business['id'],
                                      personId: widget.personId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: PersonNavigationBar(personId: widget.personId),
    );
  }
}

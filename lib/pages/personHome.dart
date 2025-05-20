  import 'package:flutter/material.dart';
  import 'package:latlong2/latlong.dart';
  import '../widgets/personNavigationBar.dart';
  import '../services/business-service.dart';
  import '../services/person-service.dart';
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
    final PersonService _personService = PersonService();
    final TextEditingController _searchController = TextEditingController();

    List<Map<String, dynamic>> _allBusinesses = [];
    List<Map<String, dynamic>> _filteredBusinesses = [];
    String? _personName;

    // Category filter
    Set<String> _selectedCategories = {};
    List<String> _allCategories = [];

    // Default location (Warsaw) for emulator
    final LatLng _currentLocation = LatLng(52.2297, 21.0122);
    bool _sortByDistance = false;

    @override
    void initState() {
      super.initState();
      _fetchBusinesses();
      _fetchPersonDetails();
    }

    Future<void> _fetchBusinesses() async {
      final businesses = await _businessService.getAllBusinesses();
      final categories = businesses
          .map((b) => b['salonCategory']?.toString() ?? '')
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      setState(() {
        _allBusinesses = businesses;
        _filteredBusinesses = businesses;
        _allCategories = categories;
      });
    }

    Future<void> _fetchPersonDetails() async {
      final person = await _personService.getPersonById(widget.personId);
      setState(() {
        _personName = person != null ? person['name'] : 'User';
      });
    }

    void _filterBusinesses(String query) {
      setState(() {
        List<Map<String, dynamic>> filtered = _allBusinesses;
        if (query.isNotEmpty) {
          filtered = filtered
              .where((business) =>
                  business['salonName']?.toLowerCase().contains(query.toLowerCase()) ?? false)
              .toList();
        }
        if (_selectedCategories.isNotEmpty) {
          filtered = filtered
              .where((business) => _selectedCategories.contains(business['salonCategory']))
              .toList();
        }
        _filteredBusinesses = filtered;
      });
    }

    void _onCategoryFilterChanged(Set<String> selected) {
      setState(() {
        _selectedCategories = selected;
        _filterBusinesses(_searchController.text);
      });
    }

    void _showCategoryFilterDialog() async {
      final selected = Set<String>.from(_selectedCategories);
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Filter by Category'),
            content: SizedBox(
              width: double.maxFinite,
              child: StatefulBuilder(
                builder: (context, setStateDialog) {
                  return ListView(
                    shrinkWrap: true,
                    children: _allCategories
                        .map((category) => CheckboxListTile(
                              value: selected.contains(category),
                              title: Text(category),
                              onChanged: (checked) {
                                setStateDialog(() {
                                  if (checked == true) {
                                    selected.add(category);
                                  } else {
                                    selected.remove(category);
                                  }
                                });
                                // Update parent immediately
                                _onCategoryFilterChanged(selected);
                              },
                            ))
                        .toList(),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    }

    double _distanceToBusiness(Map<String, dynamic> business) {
      final lat = business['latitude']?.toDouble() ?? 0.0;
      final lon = business['longitude']?.toDouble() ?? 0.0;
      return Distance().as(
        LengthUnit.Kilometer,
        _currentLocation,
        LatLng(lat, lon),
      );
    }

    void _toggleSort() {
      setState(() {
        _sortByDistance = !_sortByDistance;
      });
    }

    List<Map<String, dynamic>> _getSortedBusinesses() {
      final businesses = List<Map<String, dynamic>>.from(_filteredBusinesses);
      if (_sortByDistance) {
        businesses.sort(
          (a, b) => _distanceToBusiness(a).compareTo(_distanceToBusiness(b)),
        );
      } else {
        businesses.sort(
          (a, b) => (a['salonName'] ?? '').toString().toLowerCase().compareTo(
                (b['salonName'] ?? '').toString().toLowerCase(),
              ),
        );
      }
      return businesses;
    }

    @override
    Widget build(BuildContext context) {
      final sortedBusinesses = _getSortedBusinesses();

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
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _toggleSort,
                      icon: Icon(_sortByDistance ? Icons.place : Icons.sort_by_alpha),
                      label: Text(_sortByDistance ? 'By Distance' : 'A-Z'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _showCategoryFilterDialog,
                      icon: const Icon(Icons.filter_list),
                      label: const Text('Category'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedCategories.isNotEmpty
                            ? Colors.teal
                            : Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: sortedBusinesses.isEmpty
                      ? const Center(
                          child: Text('No salons found.'),
                        )
                      : ListView.builder(
                          itemCount: sortedBusinesses.length,
                          itemBuilder: (context, index) {
                            final salon = sortedBusinesses[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                leading: const Icon(Icons.store, color: Colors.black),
                                title: Text(
                                  salon['salonName'] ?? 'Unnamed Salon',
                                  style: const TextStyle(
                                      color: Colors.black, fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'City: ${salon['address']['city'] ?? 'No city available'}',
                                      style: const TextStyle(color: Colors.black87),
                                    ),
                                    Text(
                                      'Category: ${salon['salonCategory'] ?? 'No category available'}',
                                      style: const TextStyle(color: Colors.black87),
                                    ),
                                    Text(
                                      'Distance: ${_distanceToBusiness(salon).toStringAsFixed(2)} km',
                                      style: const TextStyle(color: Colors.black87),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BookAppointmentPage(
                                        businessId: salon['id'],
                                        personId: widget.personId
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
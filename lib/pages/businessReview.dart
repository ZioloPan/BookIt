import 'package:flutter/material.dart';
import '../widgets/businessNavigationBar.dart';
import '../services/review-service.dart';
import '../services/person-service.dart';
import 'businessReviewDetails.dart';

class BusinessReviewPage extends StatefulWidget {
  final String businessId;

  const BusinessReviewPage({super.key, required this.businessId});

  @override
  _BusinessReviewPageState createState() => _BusinessReviewPageState();
}

class _BusinessReviewPageState extends State<BusinessReviewPage> {
  final ReviewService _reviewService = ReviewService();
  final PersonService _personService = PersonService();
  List<Map<String, dynamic>> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final reviews = await _reviewService.getAllReviews();
      final filteredReviews = reviews.where((review) => review['businessId'] == widget.businessId).toList();

      for (var review in filteredReviews) {
        final person = await _personService.getPersonById(review['personId']);
        if (person != null) {
          review['clientName'] = '${person['name']} ${person['lastName']}';
        } else {
          review['clientName'] = 'Anonymous';
        }
      }

      setState(() {
        _reviews = filteredReviews;
      });
    } catch (e) {
      print('Error loading reviews: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 171, 165),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Your Reviews:',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _reviews.isEmpty
                    ? const Center(
                        child: Text(
                          'No reviews available.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _reviews.length,
                        itemBuilder: (context, index) {
                          final review = _reviews[index];
                          return ListTile(
                            leading: const Icon(Icons.person, color: Colors.black),
                            title: Text(
                              review['clientName'] ?? 'Anonymous',
                              style: const TextStyle(color: Colors.black),
                            ),
                            subtitle: Row(
                              children: List.generate(5, (i) {
                                return Icon(
                                  i < (review['rating'] ?? 0) ? Icons.star : Icons.star_border,
                                  color: Colors.yellow,
                                );
                              }),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BusinessReviewDetailsPage(
                                    id: review['id'],
                                    clientName: review['clientName'] ?? 'Anonymous',
                                    stars: review['rating'] ?? 0,
                                    comment: review['comment'] ?? '',
                                    businessId: widget.businessId, // Przekazanie businessId
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BusinessNavigationBar(
        businessId: widget.businessId, // Przekazanie businessId do nawigacji
      ),
    );
  }
}

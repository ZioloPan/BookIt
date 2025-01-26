import 'package:flutter/material.dart';
import '../services/review-service.dart'; // Importowanie serwisu dla recenzji
import '../widgets/personNavigationBar.dart'; // Importowanie navigation bar

class PersonReviewDetailsPage extends StatefulWidget {
  final String personId;
  final String businessId;

  const PersonReviewDetailsPage({
    super.key,
    required this.personId,
    required this.businessId,
  });

  @override
  _PersonReviewDetailsPageState createState() => _PersonReviewDetailsPageState();
}

class _PersonReviewDetailsPageState extends State<PersonReviewDetailsPage> {
  final ReviewService _reviewService = ReviewService();
  final TextEditingController _commentController = TextEditingController();
  int _selectedStars = 0;

  Future<void> _submitReview() async {
    try {
      await _reviewService.addReview(
        personId: widget.personId,
        businessId: widget.businessId,
        rating: _selectedStars,
        comment: _commentController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit review: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
              const Text(
                'Write a Review:',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Write your comment here...',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16.0),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Rate the Business:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedStars = index + 1;
                      });
                    },
                    icon: Icon(
                      index < _selectedStars ? Icons.star : Icons.star_border,
                      color: Colors.yellow,
                      size: 32,
                    ),
                  );
                }),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedStars > 0 && _commentController.text.isNotEmpty
                      ? _submitReview
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Submit Review'),
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

import 'dart:convert';
import 'package:http/http.dart' as http;

class ReviewService {
  final String _baseUrl = 'http://192.168.100.12:3000/reviews';

  Future<List<Map<String, dynamic>>> getAllReviews() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> reviews = jsonDecode(response.body);
        return reviews.cast<Map<String, dynamic>>();
      } else {
        print('Failed to fetch reviews: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error occurred while fetching reviews: $e');
      return [];
    }
  }

  Future<void> addReview({
    required String businessId,
    required String personId,
    required int rating,
    required String comment,
  }) async {
    final Map<String, dynamic> reviewData = {
      'businessId': businessId,
      'personId': personId,
      'rating': rating,
      'comment': comment,
    };

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(reviewData),
      );

      if (response.statusCode == 201) {
        print('Review added successfully!');
      } else {
        print('Failed to add review: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while adding review: $e');
    }
  }
}

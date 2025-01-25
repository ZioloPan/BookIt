import 'package:flutter/material.dart';
import '../widgets/businessNavigationBar.dart';
import 'businessReviewDetails.dart';

class BusinessReviewPage extends StatelessWidget {
  const BusinessReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Przykładowe dane
    final List<Map<String, dynamic>> reviews = [
      {'id': 1, 'clientName': 'John Doe', 'stars': 5, 'comment': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'},
      {'id': 2, 'clientName': 'Jane Smith', 'stars': 3, 'comment': 'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'},
      {'id': 3, 'clientName': 'Alice Johnson', 'stars': 4, 'comment': 'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.'},
    ];

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
                child: ListView.builder(
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return ListTile(
                      leading: const Icon(Icons.person, color: Colors.black),
                      title: Text(
                        review['clientName'],
                        style: const TextStyle(color: Colors.black),
                      ),
                      subtitle: Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            i < review['stars'] ? Icons.star : Icons.star_border,
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
                              clientName: review['clientName'],
                              stars: review['stars'],
                              comment: review['comment'],
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
      bottomNavigationBar: const BusinessNavigationBar(), // Zastąpienie
    );
  }
}

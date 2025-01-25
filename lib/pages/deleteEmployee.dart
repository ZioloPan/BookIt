import 'package:flutter/material.dart';
import '../widgets/businessNavigationBar.dart';

class DeleteEmployeePage extends StatelessWidget {
  const DeleteEmployeePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Przykładowe dane pracowników
    final List<Map<String, String>> employees = [
      {'name': 'John', 'lastName': 'Doe', 'email': 'john.doe@example.com', 'phone': '123456789'},
      {'name': 'Jane', 'lastName': 'Smith', 'email': 'jane.smith@example.com', 'phone': '987654321'},
      {'name': 'Alice', 'lastName': 'Johnson', 'email': 'alice.johnson@example.com', 'phone': '456123789'},
      {'name': 'Bob', 'lastName': 'Brown', 'email': 'bob.brown@example.com', 'phone': '789321456'},
      {'name': 'Charlie', 'lastName': 'Davis', 'email': 'charlie.davis@example.com', 'phone': '321654987'},
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
                  'Delete Employees:',
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
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: const Icon(Icons.person, color: Colors.black),
                        title: Text(
                          '${employee['name']} ${employee['lastName']}',
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email: ${employee['email']}',
                              style: const TextStyle(color: Colors.black87),
                            ),
                            Text(
                              'Phone: ${employee['phone']}',
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Logika usuwania w przyszłości
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BusinessNavigationBar(),
    );
  }
}
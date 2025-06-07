// auth-service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String _baseUrl = 'http://10.0.2.2:3000/auth';

  Future<bool> registerBusinessOwner({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String nip, // ✅ dodaj to
  }) async {
    final Map<String, dynamic> userData = {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'nip': nip, // ✅ i tutaj też
    };

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register/business'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201) {
        print('Business owner registered successfully!');
        return true;
      } else {
        print('Failed to register business owner: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error occurred during registration: $e');
      return false;
    }
  }

  // Optional helper to get userId if needed later
  Future<String?> getUserIdByEmail(String email) async {
    final uri = Uri.parse('$_baseUrl/user-id?email=$email');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['userId'].toString();
      }
    } catch (e) {
      print('Error fetching userId: $e');
    }
    return null;
  }
}
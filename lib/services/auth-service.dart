import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String _baseUrl = 'http://10.0.2.2:8080';

  /// Logowanie użytkownika – zwraca token i dane użytkownika
  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print('Login successful: $data');
        return data;
      } else {
        print('Login failed. Status: ${response.statusCode}');
        print('Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  /// Rejestracja właściciela biznesu (bez salonu)
  Future<bool> registerBusinessOwner({
    required String firstName,
    required String lastName,
    required String password,
    required String email,
    required String phoneNumber,
    required String nip,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/register/business');
    final Map<String, dynamic> userData = {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'nip': nip,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Business owner registered successfully!');
        return true;
      } else {
        print('Failed to register business owner: ${response.statusCode}');
        print('Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  /// Rejestracja klienta (przeniesiona z PersonService)
  Future<bool> registerClient({
    required String firstName,
    required String lastName,
    required String password,
    required String email,
    required String phoneNumber,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/register/client');
    final Map<String, dynamic> requestData = {
      'firstName': firstName,
      'lastName': lastName,
      'password': password,
      'email': email,
      'phoneNumber': phoneNumber,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      print('🔵 response.statusCode: ${response.statusCode}');
      print('🔵 response.body: ${response.body}');

      if (response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 409) {
        throw Exception('User with this email already exists');
      } else {
        throw Exception('Failed to register user');
      }
    } catch (e) {
      throw Exception('Error during registration: $e');
    }
  }

  /// Pobierz userId po e-mailu
  Future<String?> getUserIdByEmail(String email) async {
    final url = Uri.parse('$_baseUrl/auth/user-id?email=$email');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['userId'].toString();
      }
    } catch (e) {
      print('Error fetching userId: $e');
    }
    return null;
  }
}

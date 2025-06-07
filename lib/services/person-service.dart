import 'dart:convert';
import 'package:http/http.dart' as http;

class PersonService {
  final String _authBaseUrl = 'http://10.0.2.2:8080/auth';
  final String _legacyBaseUrl = 'http://10.0.2.2:8080/login';

  // ✅ NOWA metoda rejestracji klienta (docelowa)
  Future<bool> registerClient({
    required String firstName,
    required String lastName,
    required String password,
    required String email,
    required String phoneNumber,
  }) async {
    final Map<String, dynamic> requestData = {
      'firstName': firstName,
      'lastName': lastName,
      'password': password,
      'email': email,
      'phoneNumber': phoneNumber,
    };

    try {
      final response = await http.post(
        Uri.parse('$_authBaseUrl/register/client'),
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

  // 🔁 STARE METODY (tymczasowo używane)
  Future<List<Map<String, dynamic>>> getAllPersons() async {
    try {
      final response = await http.get(Uri.parse(_legacyBaseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> persons = jsonDecode(response.body);
        return persons.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getPersonById(String personId) async {
    try {
      final response = await http.get(Uri.parse('$_legacyBaseUrl/$personId'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> addPerson({
    required String name,
    required String lastName,
    required String password,
    required String email,
    required String phone,
  }) async {
    final Map<String, dynamic> personData = {
      'name': name,
      'lastName': lastName,
      'password': password,
      'email': email,
      'phone': phone,
    };

    try {
      final response = await http.post(
        Uri.parse(_legacyBaseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(personData),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to add person');
      }
    } catch (e) {
      throw Exception('Error occurred while adding person');
    }
  }

  Future<bool> updatePerson(String personId, Map<String, dynamic> updatedData) async {
    try {
      final response = await http.patch(
        Uri.parse('$_legacyBaseUrl/$personId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedData),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

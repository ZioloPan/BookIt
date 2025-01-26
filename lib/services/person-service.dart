import 'dart:convert';
import 'package:http/http.dart' as http;

class PersonService {
  final String _baseUrl = 'http://192.168.100.12:3000/persons';

  Future<List<Map<String, dynamic>>> getAllPersons() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

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
      final response = await http.get(Uri.parse('$_baseUrl/$personId'));

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
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
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
        Uri.parse('$_baseUrl/$personId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  final String _baseUrl = 'http://10.0.2.2:8080/user';

  Future<bool> emailExists(String email) async {
    final uri = Uri.parse('$_baseUrl/exist').replace(queryParameters: {
      'email': email,
    });

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return false;
      } else if (response.statusCode == 409) {
        return true;
      } else {
        throw Exception('Unexpected response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking email existence: $e');
    }
  }
}

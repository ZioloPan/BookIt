import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginService {
  final String _baseUrl = 'http://10.0.2.2:8080';

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
        // Parsujemy JSON, np. { "token": "...", "user": {...} }
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print('sukces!!!!!!!!! Kod: $data');
        return data; 
      } else {
        print('Logowanie nieudane. Kod: ${response.statusCode}');
        print('Treść odpowiedzi: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Błąd podczas logowania: $e');
      return null;
    }
  }
}

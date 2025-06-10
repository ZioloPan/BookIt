import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WorkingHoursService {
  final String _baseUrl = 'http://10.0.2.2:8080/working-hours';
  final _secureStorage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _secureStorage.read(key: 'jwt_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> addWorkingHours({
    required int businessId,
    required List<Map<String, dynamic>> workingHoursList,
  }) async {
    final uri = Uri.parse('$_baseUrl/$businessId');
    final body = jsonEncode({
      "workingHoursList": workingHoursList,
    });

    print('DEBUG: POST $uri');
    print('DEBUG: BODY: $body');

    final headers = await _getHeaders();

    final response = await http.post(
      uri,
      headers: headers,
      body: body,
    );

    print('DEBUG: RESPONSE STATUS: ${response.statusCode}');
    print('DEBUG: RESPONSE BODY: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add working hours. Status code: ${response.statusCode}. Body: ${response.body}');
    }
  }

  Future<void> updateWorkingHours({
    required int businessId,
    required List<Map<String, dynamic>> workingHoursList,
  }) async {
    final uri = Uri.parse('$_baseUrl/$businessId');
    final body = jsonEncode({
      "workingHoursList": workingHoursList,
    });

    print('DEBUG: PUT $uri');
    print('DEBUG: BODY: $body');

    final headers = await _getHeaders();

    final response = await http.put(
      uri,
      headers: headers,
      body: body,
    );

    print('DEBUG: RESPONSE STATUS: ${response.statusCode}');
    print('DEBUG: RESPONSE BODY: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to update working hours. Status code: ${response.statusCode}. Body: ${response.body}');
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AvailabilityService {
  final String _baseUrl = 'http://10.0.2.2:8080/availability';
  final _secureStorage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _secureStorage.read(key: 'jwt_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> addAvailability({
    required int workerId,
    required String date,
    required String startHour,
    required String endHour,
  }) async {
    final uri = Uri.parse('$_baseUrl');
    final body = jsonEncode({
      "workerId": workerId,
      "date": date,
      "startHour": startHour,
      "endHour": endHour,
    });

    final headers = await _getHeaders();

    print('DEBUG: POST $uri');
    print('DEBUG: HEADERS: $headers');
    print('DEBUG: BODY: $body');

    final response = await http.post(
      uri,
      headers: headers,
      body: body,
    );

    print('DEBUG: RESPONSE STATUS: ${response.statusCode}');
    print('DEBUG: RESPONSE BODY: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add availability. Status code: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> getAvailabilitiesForWorker({
    required int workerId,
    required String startDate,
    required String endDate,
  }) async {
    final uri = Uri.parse('$_baseUrl/$workerId?startDate=$startDate&endDate=$endDate');
    final headers = await _getHeaders();

    print('DEBUG: GET $uri');
    print('DEBUG: HEADERS: $headers');

    final response = await http.get(uri, headers: headers);

    print('DEBUG: RESPONSE STATUS: ${response.statusCode}');
    print('DEBUG: RESPONSE BODY: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to fetch availabilities. Status code: ${response.statusCode}');
    }
  }

  Future<void> deleteAvailability(int id) async {
    final uri = Uri.parse('$_baseUrl/$id');
    final headers = await _getHeaders();

    final response = await http.delete(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete availability. Status code: ${response.statusCode}');
    }
  }
}
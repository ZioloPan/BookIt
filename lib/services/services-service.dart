import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ServicesService {
  final String _baseUrl = 'http://10.0.2.2:8080/service';
  final _secureStorage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _secureStorage.read(key: 'jwt_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> addService({
    required int businessId,
    required String name,
    required String description,
    required double price,
    required String category,
    required int duration,
  }) async {
    final uri = Uri.parse('$_baseUrl/$businessId');
    final body = jsonEncode({
      "businessId": businessId,
      "name": name,
      "description": description,
      "price": price,
      "category": category,
      "duration": duration,
    });

    final headers = await _getHeaders();

    print('DEBUG: POST $uri');
    print('DEBUG: BODY: $body');

    final response = await http.post(uri, headers: headers, body: body);

    print('DEBUG: RESPONSE STATUS: ${response.statusCode}');
    print('DEBUG: RESPONSE BODY: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add service. Status code: ${response.statusCode}');
    }
  }

  Future<void> updateService({
    required int businessId,
    required int serviceId,
    required String name,
    required String description,
    required double price,
    required String category,
    required int duration,
  }) async {
    final uri = Uri.parse('$_baseUrl/$businessId/$serviceId');
    final body = jsonEncode({
      "businessId": businessId,
      "name": name,
      "description": description,
      "price": price,
      "category": category,
      "duration": duration,
    });

    final headers = await _getHeaders();

    print('DEBUG: PUT $uri');
    print('DEBUG: BODY: $body');

    final response = await http.put(uri, headers: headers, body: body);

    print('DEBUG: RESPONSE STATUS: ${response.statusCode}');
    print('DEBUG: RESPONSE BODY: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to update service. Status code: ${response.statusCode}');
    }
  }

  Future<void> deleteService({
    required int businessId,
    required int serviceId,
  }) async {
    final uri = Uri.parse('$_baseUrl/$businessId/$serviceId');
    final headers = await _getHeaders();

    print('DEBUG: DELETE $uri');

    final response = await http.delete(uri, headers: headers);

    print('DEBUG: RESPONSE STATUS: ${response.statusCode}');
    print('DEBUG: RESPONSE BODY: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to delete service. Status code: ${response.statusCode}');
    }
  }
}
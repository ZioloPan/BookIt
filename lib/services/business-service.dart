import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class BusinessService {
  final String _baseUrl = 'http://10.0.2.2:8080/business';
  final _secureStorage = const FlutterSecureStorage();

  Future<List<Map<String, dynamic>>> getAllBusinesses() async {
    final uri = Uri.parse(_baseUrl);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> businessList = decoded['businessDtoList'];

        return businessList.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load businesses. Status code: \${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching businesses: \$e');
    }
  }

  Future<Map<String, dynamic>> getBusinessById(int businessId) async {
    final uri = Uri.parse('$_baseUrl/$businessId');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        return decoded as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch business. Status code: \${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching business details: \$e');
    }
  }

  Future<void> addBusiness(Map<String, dynamic> businessData) async {
    final uri = Uri.parse(_baseUrl);
    final token = await _secureStorage.read(key: 'jwt_token');

    if (token == null) {
      throw Exception('JWT token not found');
    }

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(businessData),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add business. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding business: $e');
    }
  }


  Future<Map<String, dynamic>?> getBusinessForOwner() async {
    final uri = Uri.parse('$_baseUrl/owner');

    try {
      final token = await _secureStorage.read(key: 'jwt_token');
      if (token == null) throw Exception('JWT token not found');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        return decoded as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        return null; // brak przypisanego biznesu
      } else {
        throw Exception('Failed to get business for owner: \${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching business for owner: $e');
    }
  }

  Future<void> addWorkerToBusiness(int businessId, Map<String, dynamic> workerData) async {
    final uri = Uri.parse('$_baseUrl/$businessId/worker');
    final token = await _secureStorage.read(key: 'jwt_token');

    if (token == null) {
      throw Exception('JWT token not found');
    }

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(workerData),
      );

      print('DEBUG: Odpowiedź serwera: ${response.statusCode} ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to add worker. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding worker: $e');
    }
  }

  Future<void> deleteWorkerFromBusiness(int businessId, String email) async {
    final uri = Uri.parse('$_baseUrl/$businessId/worker');
    final token = await _secureStorage.read(key: 'jwt_token');

    if (token == null) throw Exception('JWT token not found');

    final body = jsonEncode({'email': email});
    print('DEBUG: Sending DELETE to $uri with body: $body');

    try {
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      print('DEBUG: DELETE response: ${response.statusCode} ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete worker. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting worker: $e');
    }
  }

  Future<void> updateBusiness(Map<String, dynamic> updatedBusiness) async {
    final uri = Uri.parse('$_baseUrl/update');
    final token = await _secureStorage.read(key: 'jwt_token');

    if (token == null) throw Exception('JWT token not found');

    try {
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updatedBusiness),
      );

      print('DEBUG: PUT response: ${response.statusCode} ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to update business. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating business: $e');
    }
  }

}

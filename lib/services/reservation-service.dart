import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ReservationService {
  final String _baseUrl = 'http://10.0.2.2:8080/reservation';
  final _secureStorage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _secureStorage.read(key: 'jwt_token');
  }

  Future<List<Map<String, dynamic>>> getAllReservations() async {
    final uri = Uri.parse(_baseUrl);
    final token = await _getToken();

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token'
    });

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return List<Map<String, dynamic>>.from(decoded['reservationDtoList'] ?? []);
    } else {
      throw Exception('Failed to fetch reservations: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> getReservationsForDay(String date) async {
    final uri = Uri.parse('$_baseUrl/day?date=$date');
    final token = await _getToken();

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token'
    });

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return List<Map<String, dynamic>>.from(decoded['reservationDtoList'] ?? []);
    } else {
      throw Exception('Failed to fetch reservations for $date');
    }
  }

  Future<List<String>> getAvailableSlots(String date, int serviceId) async {
    final uri = Uri.parse('$_baseUrl/choose-date/$serviceId?date=$date');
    final token = await _getToken();

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token'
    });

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return List<String>.from(decoded['slots'] ?? []);
    } else {
      throw Exception('Failed to fetch slots');
    }
  }

  Future<void> bookAppointment(int serviceId, String date, int workerId) async {
    final uri = Uri.parse('$_baseUrl/book/$serviceId');
    final token = await _getToken();

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'date': date,
        'workerId': workerId
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to book appointment');
    }
  }

  Future<void> deleteReservation(int reservationId) async {
    final uri = Uri.parse('$_baseUrl/$reservationId');
    final token = await _getToken();

    final response = await http.delete(uri, headers: {
      'Authorization': 'Bearer $token'
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to delete reservation');
    }
  }

  Future<void> markReservationFinished(int reservationId) async {
    final uri = Uri.parse('$_baseUrl/$reservationId');
    final token = await _getToken();

    final response = await http.post(uri, headers: {
      'Authorization': 'Bearer $token'
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to mark reservation as finished');
    }
  }
}

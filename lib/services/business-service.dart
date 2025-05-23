import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config.dart';

class BusinessService {
  final String _baseUrl = '${Config.baseUrl}/businesses';

  Future<void> addBusiness({
    required String password,
    required String salonName,
    required String salonCategory,
    required String salonPhoneNumber,
    required String salonEmail,
    required String city,
    required String street,
    required String localNumber,
    required String postCode,
    required String nipNumber,
    required double latitude,
    required double longitude,
  }) async {
    final Map<String, dynamic> businessData = {
      'password': password,
      'salonName': salonName,
      'salonCategory': salonCategory,
      'salonPhoneNumber': salonPhoneNumber,
      'salonEmail': salonEmail,
      'address': {
        'city': city,
        'street': street,
        'localNumber': localNumber,
        'postCode': postCode,
      },
      'nipNumber': nipNumber,
      'latitude': latitude,
      'longitude': longitude,
    };

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(businessData),
      );

      if (response.statusCode == 201) {
        print('Business registered successfully!');
      } else {
        print('Failed to register business: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while registering business: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllBusinesses() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> businesses = jsonDecode(response.body);
        return businesses.cast<Map<String, dynamic>>();
      } else {
        print('Failed to fetch businesses: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error occurred while fetching businesses: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getBusinessById(String businessId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$businessId'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('Failed to fetch business: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error occurred while fetching business: $e');
      return null;
    }
  }

  Future<bool> updateBusiness(String businessId, Map<String, dynamic> updatedData) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/$businessId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        print('Business updated successfully!');
        return true;
      } else {
        print('Failed to update business: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error occurred while updating business: $e');
      return false;
    }
  }
}
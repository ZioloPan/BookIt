import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth/auth_storage.dart';

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phoneNumber;
  final String userRole;
  final bool isActive;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.userRole,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        email: json['email'],
        password: json['password'],
        phoneNumber: json['phoneNumber'],
        userRole: json['userRole'],
        isActive: json['isActive'],
      );
}

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

  Future<List<User>> getAllUsers() async {
    final uri = Uri.parse(_baseUrl);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> usersJson = decoded['userDtoList'];
        return usersJson.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load users. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  Future<User> getCurrentUser(String token) async {
    final uri = Uri.parse('$_baseUrl/current');

    try {
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('getCurrentUser status: ${response.statusCode}');
      print('getCurrentUser body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print('getCurrentUser decoded json: $json');
        // Dla business ownera:
        if (json['businessOwner'] != null) {
          return User.fromJson(json['businessOwner']);
        }
        // Dla innych ról, np. klient:
        if (json['user'] != null) {
          return User.fromJson(json['user']);
        }
        // Jeśli backend zwraca bezpośrednio usera:
        if (json['id'] != null) {
          return User.fromJson(json);
        }
        throw Exception('Unknown user response structure: $json');
      } else {
        throw Exception('Failed to get current user. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching current user: $e');
    }
  }

  Future<void> updateUser(int userId, Map<String, dynamic> updatedData) async {
    final uri = Uri.parse('$_baseUrl/$userId');

    try {
      final token = await getStoredToken();
      if (token == null) {
        throw Exception('No token found. User not logged in.');
      }

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updatedData),
      );

      print('DEBUG: POST /user/$userId response: ${response.statusCode} ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 204 && response.statusCode != 201) {
        throw Exception('Failed to update user. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

}

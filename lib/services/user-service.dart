import 'dart:convert';
import 'package:http/http.dart' as http;

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

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return User.fromJson(json['user']);
      } else {
        throw Exception('Failed to get current user. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching current user: $e');
    }
  }
}

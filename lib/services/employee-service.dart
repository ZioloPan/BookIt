import 'dart:convert';
import 'package:http/http.dart' as http;

class EmployeeService {
  final String _baseUrl = 'http://192.168.100.12:3000/employees';

  Future<List<Map<String, dynamic>>> getAllEmployees() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> employees = jsonDecode(response.body);
        return employees.cast<Map<String, dynamic>>();
      } else {
        print('Failed to fetch employees: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error occurred while fetching employees: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getEmployeeById(String employeeId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$employeeId'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('Failed to fetch employee: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error occurred while fetching employee: $e');
      return null;
    }
  }

  Future<void> addEmployee({
    required String businessId,
    required String name,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    final Map<String, dynamic> employeeData = {
      'businessId': businessId,
      'name': name,
      'lastName': lastName,
      'email': email,
      'phone': phone,
    };

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(employeeData),
      );

      if (response.statusCode == 201) {
        print('Employee added successfully!');
      } else {
        print('Failed to add employee: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while adding employee: $e');
    }
  }

  Future<bool> updateEmployee(String employeeId, Map<String, dynamic> updatedData) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/$employeeId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        print('Employee updated successfully!');
        return true;
      } else {
        print('Failed to update employee: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error occurred while updating employee: $e');
      return false;
    }
  }

  Future<bool> deleteEmployee(String employeeId) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/$employeeId'));

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Employee deleted successfully!');
        return true;
      } else {
        print('Failed to delete employee: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error occurred while deleting employee: $e');
      return false;
    }
  }
}
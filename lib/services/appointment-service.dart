import 'dart:convert';
import 'package:http/http.dart' as http;

class AppointmentService {
  final String _baseUrl = 'http://192.168.100.12:3000/appointments';

  Future<List<Map<String, dynamic>>> getAllAppointments() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> appointments = jsonDecode(response.body);
        return appointments.cast<Map<String, dynamic>>();
      } else {
        print('Failed to fetch appointments: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error occurred while fetching appointments: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getAppointmentById(String appointmentId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$appointmentId'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('Failed to fetch appointment: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error occurred while fetching appointment: $e');
      return null;
    }
  }

  Future<void> addAppointment({
    required String employeeId,
    required String personId,
    required String date,
    required String time,
  }) async {
    final Map<String, dynamic> appointmentData = {
      'employeeId': employeeId,
      'personId': personId,
      'date': date,
      'time': time,
    };

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(appointmentData),
      );

      if (response.statusCode == 201) {
        print('Appointment added successfully!');
      } else {
        print('Failed to add appointment: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while adding appointment: $e');
    }
  }

  Future<bool> updateAppointment(String appointmentId, Map<String, dynamic> updatedData) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/$appointmentId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        print('Appointment updated successfully!');
        return true;
      } else {
        print('Failed to update appointment: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error occurred while updating appointment: $e');
      return false;
    }
  }

  Future<bool> deleteAppointment(String appointmentId) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/$appointmentId'));

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Appointment deleted successfully!');
        return true;
      } else {
        print('Failed to delete appointment: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error occurred while deleting appointment: $e');
      return false;
    }
  }
}
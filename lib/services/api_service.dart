import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/sensor_model.dart';
import '../models/message_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  static Future<Map<String, dynamic>> register(
  User user,
  String password,
  String confirmPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': user.name,
          'email': user.email,
          'password': password,
          'password_confirmation': confirmPassword,
        }),
      );

      final responseData = jsonDecode(response.body);
      print('Response body: $responseData'); // 🔍 debugging

      if (response.statusCode == 201 || response.statusCode == 200) {
        final userData = responseData['user'];
        if (userData == null) {
          throw Exception("User data tidak ditemukan di response");
        }

        return {
          'status': responseData['status'],
          'user': User.fromJson(userData),
          'message': responseData['message'] ?? 'Registrasi berhasil',
        };
      } else {
        return {
          'status': responseData['status'] ?? false,
          'message': responseData['message'] ?? 'Registrasi gagal',
          'errors': responseData['errors'] ?? {},
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Koneksi gagal: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == true) {
        return {
          'status': true,
          // 🔑 CRITICAL FIX: Extract and include the token
          'token': responseData['token'], 
          'user': User.fromJson(responseData['user']), 
          'message': responseData['message'] ?? 'Login berhasil',
        };
      } else {
        return {
          'status': false,
          'message': responseData['message'] ?? 'Email atau password salah',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Koneksi gagal: $e',
      };
    }
  }

  static Future<List<SensorData>> fetchSensorData(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_sensor_data'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        return data.map((e) => SensorData.fromJson(e)).toList();
      } else {
        throw Exception('Gagal load sensor: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  static Future<Map<String, dynamic>> controlActuator(
    String name,
    bool state,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/control_actuator'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "name": name,
          "state": state ? "ON" : "OFF",
        }),
      );

      final responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      return {
        "status": false,
        "message": "Gagal mengirim perintah: $e",
      };
    }
  }

  static Future<List<UserMessage>> getUserMessages(String token) async {
  final res = await http.get(
    Uri.parse("$baseUrl/user/messages"),
    headers: {"Authorization": "Bearer $token"},
    );

    final data = jsonDecode(res.body);
    List messages = data["messages"];

    return messages.map((m) => UserMessage.fromJson(m)).toList();
  }
}
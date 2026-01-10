import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/sensor_model.dart';
import '../models/message_model.dart';

class ApiService {
  static const String baseUrl = 'https://uncollapsable-overfly-blaine.ngrok-free.dev/api';

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
      return {'status': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
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
      return {'status': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  static Future<List<SensorData>> fetchSensorData(String token) async {
  print("Menggunakan Token: $token");
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/get_sensor_data'),
      headers: _getHeaders(token),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      // Cek apakah key 'data' ada
      if (body.containsKey('data')) {
        final List data = body['data'];
        return data.map((e) => SensorData.fromJson(e)).toList();
      }
      return [];
    } else {
      print('Server Error: ${response.statusCode} - ${response.body}');
      return [];
    }
  } catch (e) {
    print('Error Fetching: $e');
    return [];
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
        body: jsonEncode({"name": name, "state": state ? "ON" : "OFF"}),
      );

      final responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      return {"status": false, "message": "Gagal mengirim perintah: $e"};
    }
  }

  static Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      'Authorization': 'Bearer $token',
    };
  }

  // ========== USER MESSAGES (CLIENT) ==========
  static Future<List<UserMessage>> getUserMessages(String token) async {
    final stopwatch = Stopwatch()..start();

    try {
      final url = Uri.parse('$baseUrl/user/messages');
      developer.log('🌐 GET Request to: $url', name: 'ApiService');
      developer.log(
        '🔑 Token: ${token.substring(0, min(30, token.length))}...',
        name: 'ApiService',
      );

      final response = await http.get(url, headers: _getHeaders(token));

      developer.log(
        '📥 Response Status: ${response.statusCode}',
        name: 'ApiService',
      );
      developer.log(
        '📥 Response Body Length: ${response.body.length}',
        name: 'ApiService',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final List<dynamic> messagesData = responseData['data'] ?? [];
          developer.log(
            '✅ Received ${messagesData.length} messages',
            name: 'ApiService',
          );

          final messages = messagesData.map((json) {
            return UserMessage.fromJson(json);
          }).toList();

          developer.log(
            '⏱️ Request took: ${stopwatch.elapsedMilliseconds}ms',
            name: 'ApiService',
          );
          return messages;
        } else {
          developer.log('❌ API returned success: false', name: 'ApiService');
          throw Exception(responseData['message'] ?? 'API error');
        }
      } else {
        developer.log(
          '❌ HTTP Error ${response.statusCode}',
          name: 'ApiService',
        );
        developer.log('❌ Response: ${response.body}', name: 'ApiService');
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      developer.log('❌ Exception in getUserMessages: $e', name: 'ApiService');
      rethrow;
    }
  }

  static Future<bool> sendMessageToAdmin(String token, String message) async {
    final stopwatch = Stopwatch()..start();

    try {
      final url = Uri.parse('$baseUrl/user/messages');
      developer.log('🌐 POST Request to: $url', name: 'ApiService');
      developer.log(
        '💬 Message: ${message.substring(0, min(100, message.length))}...',
        name: 'ApiService',
      );

      final response = await http.post(
        url,
        headers: _getHeaders(token),
        body: jsonEncode({'message': message}),
      );

      developer.log(
        '📤 Response Status: ${response.statusCode}',
        name: 'ApiService',
      );
      developer.log('📤 Response Body: ${response.body}', name: 'ApiService');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final success = responseData['success'] == true;

        if (success) {
          developer.log('✅ Message sent successfully', name: 'ApiService');
        } else {
          developer.log('❌ API returned success: false', name: 'ApiService');
        }

        developer.log(
          '⏱️ Request took: ${stopwatch.elapsedMilliseconds}ms',
          name: 'ApiService',
        );
        return success;
      } else {
        developer.log(
          '❌ HTTP Error ${response.statusCode}',
          name: 'ApiService',
        );
        return false;
      }
    } catch (e) {
      developer.log(
        '❌ Exception in sendMessageToAdmin: $e',
        name: 'ApiService',
      );
      return false;
    }
  }

  static Future<bool> deleteUserMessage(String token, int messageId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/user/messages/$messageId'),
        headers: _getHeaders(token),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Delete user message error: $e');
      return false;
    }
  }
}

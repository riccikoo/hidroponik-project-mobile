import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

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
}
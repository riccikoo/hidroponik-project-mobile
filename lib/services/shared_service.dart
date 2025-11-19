import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedService {
  static const _tokenKey = 'token';
  static const _userDataKey = 'user_data';
  static const _loggedInKey = 'is_logged_in';

  static Future<void> saveLoginData(String? token, Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    if (token != null && token.isNotEmpty) {
      await prefs.setString(_tokenKey, token);
    }
    await prefs.setString(_userDataKey, jsonEncode(userData));
    await prefs.setBool(_loggedInKey, true);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) ?? false;
  }

  static Future<String?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userDataKey);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userDataKey);
    await prefs.setBool(_loggedInKey, false);
  }

  static Future<Map<String, dynamic>?> getUserAsMap() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);
    if (userDataString == null) return null;
    return jsonDecode(userDataString);
  }
  
}

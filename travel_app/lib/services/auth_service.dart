import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final String _apiUrl = dotenv.env['API_URL'] ?? '';

  // ✅ Mirip dengan getUserById di web
  static Future<Map<String, dynamic>?> getUserById(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      print(
          '🔍 Fetching user $userId with token: ${token?.substring(0, 20)}...');

      final response = await http.get(
        Uri.parse('$_apiUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 API Response Status: ${response.statusCode}');
      print('📡 API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        print(
            '❌ Failed to fetch user: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error in getUserById: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    try {
      print('🔐 Attempting login for: $username');

      final response = await http.post(
        Uri.parse('$_apiUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      print('📡 Login Response Status: ${response.statusCode}');
      print('📡 Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data; // return { token, user }
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (err) {
      print('❌ Login error: $err');
      rethrow;
    }
  }

  static Future<void> register(
      String name, String username, String email, String password) async {
    try {
      print('📝 Attempting register for: $username');

      final response = await http.post(
        Uri.parse('$_apiUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'username': username,
          'email': email,
          'password': password,
          'role': 'USER',
        }),
      );

      print('📡 Register Response Status: ${response.statusCode}');
      print('📡 Register Response Body: ${response.body}');

      if (response.statusCode == 201) {
        print('✅ Register success');
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Register failed');
      }
    } catch (e) {
      print('❌ Register error: $e');
      rethrow;
    }
  }

  // ✅ Simpan session mirip dengan localStorage di web
  static Future<void> saveUserSession(
      Map<String, dynamic> user, String token) async {
    final prefs = await SharedPreferences.getInstance();

    print('💾 Saving user session:');
    print('- Token: ${token.substring(0, 20)}...');
    print('- User ID: ${user['id']}');
    print('- Username: ${user['username']}');
    print('- Email: ${user['email']}');
    print('- Balance: ${user['balance']}');

    // Simpan semua data yang dibutuhkan
    await prefs.setString('token', token);
    await prefs.setInt('userId', user['id']); // ✅ Key: userId
    await prefs.setString('name', user['name'] ?? '');
    await prefs.setString('username', user['username'] ?? '');
    await prefs.setString('email', user['email'] ?? '');
    await prefs.setDouble('balance', (user['balance'] as num? ?? 0).toDouble());
    await prefs.setString('image', user['image'] ?? '');
    await prefs.setString('role', user['role'] ?? 'USER');

    // Verifikasi data tersimpan
    print('✅ Session saved successfully');
    print('✅ Stored userId: ${prefs.getInt('userId')}');
  }

  // ✅ Update user profile (mirip dengan updateUserProfile di web)
  static Future<Map<String, dynamic>?> updateUserProfile(
      int userId, Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      print('🔄 Updating user profile for ID: $userId');

      final response = await http.put(
        Uri.parse('$_apiUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(userData),
      );

      print('📡 Update Response Status: ${response.statusCode}');
      print('📡 Update Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        print(
            '❌ Failed to update user: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error in updateUserProfile: $e');
      return null;
    }
  }

  // ✅ Get stored user data (untuk debugging)
  static Future<void> debugStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    print('🔍 DEBUG - Stored data:');
    print('- All keys: ${prefs.getKeys()}');
    print('- Token: ${prefs.getString('token')?.substring(0, 20)}...');
    print('- UserId: ${prefs.getInt('userId')}');
    print('- Username: ${prefs.getString('username')}');
    print('- Email: ${prefs.getString('email')}');
    print('- Balance: ${prefs.getDouble('balance')}');
    print('- Image: ${prefs.getString('image')}');
  }

  // ✅ Clear session (untuk logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('🗑️ Session cleared');
  }
}

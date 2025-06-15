import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final String _apiUrl = dotenv.env['API_URL'] ?? '';

  static get console => null;

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
      console.log("LOGIN user object:", response);

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
  // Update method saveUserSession di AuthService

  static Future<void> saveUserSession(
      Map<dynamic, dynamic> user, String token) async {
    final prefs = await SharedPreferences.getInstance();

    print('💾 Saving user session:');
    print('- Token: ${token.substring(0, 20)}...');
    print('- User ID: ${user['userId']}');
    print('- Username: ${user['username']}');
    print('- Email: ${user['email']}');
    print('- Balance: ${user['balance']}');

    try {
      // ✅ Safe casting dengan null check
      await prefs.setString('token', token);

      // Pastikan id adalah integer
      final userId = user['userId'];
      if (userId is int) {
        await prefs.setInt('userId', userId);
      } else if (userId is num) {
        await prefs.setInt('userId', userId.toInt());
      } else {
        throw Exception('Invalid userId type: ${userId.runtimeType}');
      }

      await prefs.setString('name', user['name']?.toString() ?? '');
      await prefs.setString('username', user['username']?.toString() ?? '');
      await prefs.setString('email', user['email']?.toString() ?? '');

      // Handle balance dengan aman
      final balance = user['balance'];
      if (balance is double) {
        await prefs.setDouble('balance', balance);
      } else if (balance is num) {
        await prefs.setDouble('balance', balance.toDouble());
      } else {
        await prefs.setDouble('balance', 0.0);
      }

      await prefs.setString('image', user['image']?.toString() ?? '');
      await prefs.setString('role', user['role']?.toString() ?? 'USER');

      // Verifikasi data tersimpan
      print('✅ Session saved successfully');
      print('✅ Stored userId: ${prefs.getInt('userId')}');
    } catch (e) {
      print('❌ Error saving user session: $e');
      rethrow;
    }
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

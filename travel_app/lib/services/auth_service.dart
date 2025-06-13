import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String? createdAt;
  final String? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.createdAt,
    this.updatedAt,
  });
}

Future<Map<String, dynamic>?> getUserById(int userId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  final response = await http.get(
    Uri.parse('http://localhost:3000/users/$userId'), // ganti sesuai API-mu
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    print('Failed to fetch user: ${response.body}');
    return null;
  }
}

class AuthService {
  static final String _apiUrl = dotenv.env['API_URL'] ?? '';

  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data; // return { token, user }
      } else {
        throw Exception('Login failed');
      }
    } catch (err) {
      print('Login error: $err');
      rethrow;
    }
  }

  static Future<void> register(
      String name, String username, String email, String password) async {
    try {
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

      if (response.statusCode == 201) {
        print('Register success: ${response.body}');
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Register failed');
      }
    } catch (e) {
      print('Register error: $e');
      rethrow;
    }
  }

  static Future<void> saveUserSession(
      Map<String, dynamic> user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('name', user['name']);
    await prefs.setString('email', user['email']);
    await prefs.setDouble('balance', (user['balance'] as num).toDouble());
    await prefs.setString('image', user['image'] ?? '');
  }
}

// class AuthService {
//   static final String _apiUrl = dotenv.env['API_URL'] ?? '';

//   /// Login user
//   static Future<String?> login(String email, String password) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$_apiUrl/auth/login'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'email': email, 'password': password}),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return data['token'] as String;
//       } else {
//         throw Exception('Login failed');
//       }
//     } catch (err) {
//       print('login error: $err');
//       return null;
//     }
//   }

//   /// Register user
//   static Future<User?> register(
//       String name, String email, String password) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$_apiUrl/auth/register'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'name': name,
//           'email': email,
//           'password': password,
//         }),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final data = jsonDecode(response.body);
//         return User.fromJson(data);
//       } else {
//         throw Exception('Registration failed');
//       }
//     } catch (err) {
//       print('register error: $err');
//       return null;
//     }
//   }

//   /// Get current user by token
//   static Future<User?> getCurrentUser(String token) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$_apiUrl/auth/me'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return User.fromJson(data);
//       } else {
//         throw Exception('Failed to get user');
//       }
//     } catch (err) {
//       print('getCurrentUser error: $err');
//       return null;
//     }
//   }
// }

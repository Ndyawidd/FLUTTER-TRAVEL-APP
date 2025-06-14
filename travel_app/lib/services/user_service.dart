import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Define the User model
class User {
  final int userId;
  final String name;
  final String username;
  final String email;
  final String role;
  final String? image;
  final String password;
  final double balance;

  User({
    required this.userId,
    required this.name,
    required this.username,
    required this.email,
    required this.role,
    this.image,
    required this.password,
    required this.balance,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] ?? json['id'] ?? 0,
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      image: json['image'],
      password: json['password'] ?? '',
      balance: double.parse(json['balance']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'username': username,
      'email': email,
      'role': role,
      'image': image,
      'password': password,
      'balance': balance,
    };
  }
}

class UserService {
  static final String _apiUrl = dotenv.env['API_URL'] ?? '';

  /// Get user by ID
  static Future<User> getUserById(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('Failed to fetch user: ${response.statusCode}');
      }
    } catch (err) {
      print('getUserById error: $err');
      throw Exception('Failed to fetch user: $err');
    }
  }

  /// Update user profile with FormData (for file uploads)
  static Future<User> updateUserProfile(
      int userId, Map<String, dynamic> formData) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$_apiUrl/users/$userId'),
      );

      // Add text fields
      formData.forEach((key, value) {
        if (key != 'imageFile' && value != null) {
          request.fields[key] = value.toString();
        }
      });

      // Add image file if exists
      if (formData.containsKey('imageFile') && formData['imageFile'] != null) {
        var imageFile = formData['imageFile'];
        if (imageFile is String) {
          // If it's a base64 string, convert it back to bytes
          var bytes = base64Decode(imageFile.split(',').last);
          request.files.add(
            http.MultipartFile.fromBytes(
              'image',
              bytes,
              filename: 'profile_image.jpg',
            ),
          );
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (err) {
      print('updateUserProfile error: $err');
      throw Exception('Failed to update profile: $err');
    }
  }

  /// Update user profile with JSON data (without file upload)
  static Future<User> updateUserProfileJson(
      int userId, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$_apiUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return User.fromJson(responseData);
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (err) {
      print('updateUserProfileJson error: $err');
      throw Exception('Failed to update profile: $err');
    }
  }

  /// Delete user
  static Future<Map<String, dynamic>> deleteUser(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_apiUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          return jsonDecode(response.body);
        } else {
          return {'success': true, 'message': 'User deleted successfully'};
        }
      } else {
        throw Exception('Failed to delete user: ${response.statusCode}');
      }
    } catch (err) {
      print('deleteUser error: $err');
      throw Exception('Failed to delete user: $err');
    }
  }

  /// Get all users (if needed)
  static Future<List<User>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/users'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch users: ${response.statusCode}');
      }
    } catch (err) {
      print('getAllUsers error: $err');
      return [];
    }
  }

  /// Create new user
  static Future<User> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/users'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('Failed to create user: ${response.statusCode}');
      }
    } catch (err) {
      print('createUser error: $err');
      throw Exception('Failed to create user: $err');
    }
  }

  /// Update user balance
  static Future<User> updateUserBalance(int userId, double newBalance) async {
    try {
      final response = await http.put(
        Uri.parse('$_apiUrl/users/$userId/balance'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'balance': newBalance}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('Failed to update balance: ${response.statusCode}');
      }
    } catch (err) {
      print('updateUserBalance error: $err');
      throw Exception('Failed to update balance: $err');
    }
  }
}

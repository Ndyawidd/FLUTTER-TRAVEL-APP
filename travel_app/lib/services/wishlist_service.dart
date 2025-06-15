import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WishlistService {
  static final String _apiUrl = dotenv.env['API_URL'] ?? '';

  static Future<List<dynamic>> getUserWishlist(int userId) async {
    final url = Uri.parse('$_apiUrl/wishlists/user/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch wishlist");
    }
  }

  static Future<void> addToWishlist(int userId, int ticketId) async {
    final url = Uri.parse('$_apiUrl/wishlists');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId, "ticketId": ticketId}),
    );

    print("POST /wishlists => Status: ${response.statusCode}");
    print("Response body: ${response.body}");

    // Handle success cases (200, 201) or already exists case
    if (response.statusCode == 200 || response.statusCode == 201) {
      return; // Success
    } else if (response.statusCode == 500) {
      // Check if it's "Already in wishlist" error
      try {
        final responseBody = jsonDecode(response.body);
        if (responseBody['error'] == 'Already in wishlist') {
          // Item already in wishlist, treat as success
          return;
        }
      } catch (e) {
        // If JSON decode fails, fall through to throw exception
      }
    }

    throw Exception("Failed to add to wishlist");
  }

  static Future<void> removeFromWishlist(int userId, int ticketId) async {
    final url = Uri.parse('$_apiUrl/wishlists');
    final response = await http.delete(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId, "ticketId": ticketId}),
    );

    print("DELETE /wishlists => Status: ${response.statusCode}");
    print("Response body: ${response.body}");

    // Handle success case or not found case
    if (response.statusCode == 200) {
      return; // Success
    } else if (response.statusCode == 404 || response.statusCode == 500) {
      // Check if it's "not found" or similar error
      try {
        final responseBody = jsonDecode(response.body);
        if (responseBody['error']?.contains('not found') == true ||
            responseBody['error']?.contains('Not in wishlist') == true) {
          // Item not in wishlist, treat as success
          return;
        }
      } catch (e) {
        // If JSON decode fails, fall through to throw exception
      }
    }

    throw Exception("Failed to remove from wishlist");
  }
}

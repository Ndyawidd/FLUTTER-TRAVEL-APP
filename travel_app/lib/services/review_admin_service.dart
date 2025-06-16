import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ReviewService {
  // static const String _apiUrl =
  //     'YOUR_API_URL_HERE'; // Replace with your actual API URL
  static final String _apiUrl = dotenv.env['API_URL'] ?? '';
  // Fetch all reviews

  static Future<List<Map<String, dynamic>>> fetchAllReviews() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/reviews'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((review) => review as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to fetch reviews');
      }
    } catch (error) {
      print('fetchAllReviews error: $error');
      return [];
    }
  }

  // Fetch reviews by ticket ID
  static Future<List<Map<String, dynamic>>> fetchReviewsByTicketId(
      int ticketId) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/reviews/ticket/$ticketId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((review) => review as Map<String, dynamic>).toList();
      } else {
        throw Exception('Review not found for ticket ID: $ticketId');
      }
    } catch (error) {
      print('fetchReviewsByTicketId error (ID: $ticketId): $error');
      return [];
    }
  }

  // Post a new review
  static Future<Map<String, dynamic>?> postReview({
    required int userId,
    required String orderId,
    required int ticketId,
    required int rating,
    required String comment,
    String? image,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/reviews'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'orderId': orderId,
          'ticketId': ticketId,
          'rating': rating,
          'comment': comment,
          if (image != null) 'image': image,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create review');
      }
    } catch (error) {
      print('postReview error: $error');
      return null;
    }
  }

  // Post a response to a review
  static Future<Map<String, dynamic>?> postResponse(
      int reviewId, String responseText) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/reviews/response'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'reviewId': reviewId,
          'response': responseText,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to add response');
      }
    } catch (error) {
      print('postResponse error: $error');
      rethrow;
    }
  }

  // Delete a response
  static Future<bool> deleteResponse(int responseId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_apiUrl/reviews/response/$responseId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete response');
      }
    } catch (error) {
      print('deleteResponse error: $error');
      return false;
    }
  }

  // Delete a review
  static Future<bool> deleteReview(int reviewId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_apiUrl/reviews/$reviewId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete review');
      }
    } catch (error) {
      print('deleteReview error: $error');
      return false;
    }
  }

  // Edit a response
  static Future<Map<String, dynamic>?> editResponse(
      int responseId, String newResponseText) async {
    try {
      final response = await http.put(
        Uri.parse('$_apiUrl/reviews/response/$responseId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'response': newResponseText,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to edit response');
      }
    } catch (error) {
      print('editResponse error: $error');
      return null;
    }
  }
}

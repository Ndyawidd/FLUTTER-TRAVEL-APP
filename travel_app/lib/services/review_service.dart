import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ReviewService {
  static final String _apiUrl = dotenv.env['API_URL'] ?? '';

  // Model untuk Review
  static Map<String, dynamic> createReviewData({
    required int userId,
    required String orderId,
    required int ticketId,
    required int rating,
    required String comment,
    String? image,
  }) {
    return {
      'userId': userId,
      'orderId': orderId,
      'ticketId': ticketId,
      'rating': rating,
      'comment': comment,
      if (image != null) 'image': image,
    };
  }

  // Post Review
  static Future<Map<String, dynamic>?> postReview({
    required int userId,
    required String orderId,
    required int ticketId,
    required int rating,
    required String comment,
    String? image,
  }) async {
    try {
      final reviewData = createReviewData(
        userId: userId,
        orderId: orderId,
        ticketId: ticketId,
        rating: rating,
        comment: comment,
        image: image,
      );

      final response = await http.post(
        Uri.parse('$_apiUrl/reviews'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(reviewData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create review: ${response.statusCode}');
      }
    } catch (error) {
      print('postReview error: $error');
      return null;
    }
  }

  // Fetch Reviews by Ticket ID
  static Future<List<Map<String, dynamic>>> fetchReviewsByTicketId(
      int ticketId) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/reviews/ticket/$ticketId'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Review not found for ticket ID: $ticketId');
      }
    } catch (error) {
      print('fetchReviewsByTicketId error (ID: $ticketId): $error');
      return [];
    }
  }

  // Fetch All Reviews
  static Future<List<Map<String, dynamic>>> fetchAllReviews() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/reviews'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch reviews');
      }
    } catch (error) {
      print('fetchAllReviews error: $error');
      return [];
    }
  }

  // Delete Review
  static Future<bool> deleteReview(int reviewId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_apiUrl/reviews/$reviewId'),
      );

      return response.statusCode == 204;
    } catch (error) {
      print('deleteReview error: $error');
      return false;
    }
  }

  // Convert File to Base64
  static Future<String> convertFileToBase64(File file) async {
    try {
      List<int> imageBytes = await file.readAsBytes();
      return base64Encode(imageBytes);
    } catch (error) {
      throw Exception('Failed to convert file to base64: $error');
    }
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Define the Review model
class Review {
  final int reviewId;
  final int userId;
  final String? orderId;
  final int ticketId;
  final int rating;
  final String comment;
  final String userName;
  final String? image;
  final DateTime createdAt;

  Review({
    required this.reviewId,
    required this.userId,
    this.orderId,
    required this.ticketId,
    required this.rating,
    required this.comment,
    required this.userName,
    this.image,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['reviewId'] ?? json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      orderId: json['orderId'],
      ticketId: json['ticketId'] ?? 0,
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      userName: json['user']?['name'] ?? json['userName'] ?? 'Anonymous',
      image: json['image'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviewId': reviewId,
      'userId': userId,
      if (orderId != null) 'orderId': orderId,
      'ticketId': ticketId,
      'rating': rating,
      'comment': comment,
      'userName': userName,
      if (image != null) 'image': image,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ReviewService {
  static final String _apiUrl = dotenv.env['API_URL'] ?? '';

  // Helper method to create review data
  static Map<String, dynamic> createReviewData({
    required int userId,
    String? orderId,
    required int ticketId,
    required int rating,
    required String comment,
    String? image,
  }) {
    return {
      'userId': userId,
      if (orderId != null) 'orderId': orderId,
      'ticketId': ticketId,
      'rating': rating,
      'comment': comment,
      if (image != null) 'image': image,
    };
  }

  /// Add new review (supports both approaches)
  static Future<Review> addReview({
    required int userId,
    String? orderId,
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

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Review.fromJson(data);
      } else {
        throw Exception('Failed to add review: ${response.statusCode}');
      }
    } catch (err) {
      print('addReview error: $err');
      throw Exception('Failed to add review: $err');
    }
  }

  /// Legacy method for backward compatibility
  static Future<Map<String, dynamic>?> postReview({
    required int userId,
    required String orderId,
    required int ticketId,
    required int rating,
    required String comment,
    String? image,
  }) async {
    try {
      final review = await addReview(
        userId: userId,
        orderId: orderId,
        ticketId: ticketId,
        rating: rating,
        comment: comment,
        image: image,
      );
      return review.toJson();
    } catch (error) {
      print('postReview error: $error');
      return null;
    }
  }

  /// Get reviews by ticket ID (returns Review objects)
  static Future<List<Review>> getReviewsByTicketId(int ticketId) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/reviews/ticket/$ticketId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Review.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch reviews: ${response.statusCode}');
      }
    } catch (err) {
      print('getReviewsByTicketId error: $err');
      return []; // Return empty list if error
    }
  }

  /// Legacy method for backward compatibility (returns raw Map data)
  static Future<List<Map<String, dynamic>>> fetchReviewsByTicketId(
      int ticketId) async {
    try {
      final reviews = await getReviewsByTicketId(ticketId);
      return reviews.map((review) => review.toJson()).toList();
    } catch (error) {
      print('fetchReviewsByTicketId error (ID: $ticketId): $error');
      return [];
    }
  }

  /// Get review by ID
  static Future<Review> getReviewById(int reviewId) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/reviews/$reviewId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Review.fromJson(data);
      } else {
        throw Exception('Failed to fetch review: ${response.statusCode}');
      }
    } catch (err) {
      print('getReviewById error: $err');
      throw Exception('Failed to fetch review: $err');
    }
  }

  /// Update review
  static Future<Review> updateReview(
      int reviewId, Map<String, dynamic> reviewData) async {
    try {
      final response = await http.put(
        Uri.parse('$_apiUrl/reviews/$reviewId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(reviewData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Review.fromJson(data);
      } else {
        throw Exception('Failed to update review: ${response.statusCode}');
      }
    } catch (err) {
      print('updateReview error: $err');
      throw Exception('Failed to update review: $err');
    }
  }

  /// Delete review
  static Future<bool> deleteReview(int reviewId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_apiUrl/reviews/$reviewId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (err) {
      print('deleteReview error: $err');
      return false;
    }
  }

  /// Delete review (legacy method returning detailed response)
  static Future<Map<String, dynamic>> deleteReviewDetailed(int reviewId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_apiUrl/reviews/$reviewId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body.isNotEmpty) {
          return jsonDecode(response.body);
        } else {
          return {'success': true, 'message': 'Review deleted successfully'};
        }
      } else {
        throw Exception('Failed to delete review: ${response.statusCode}');
      }
    } catch (err) {
      print('deleteReviewDetailed error: $err');
      throw Exception('Failed to delete review: $err');
    }
  }

  /// Get average rating for a ticket
  static Future<double> getAverageRating(int ticketId) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/reviews/ticket/$ticketId/average'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return double.parse(data['averageRating']?.toString() ?? '0');
      } else {
        // If endpoint doesn't exist, calculate manually from reviews
        final reviews = await getReviewsByTicketId(ticketId);
        if (reviews.isEmpty) return 0.0;

        double totalRating =
            reviews.fold(0.0, (sum, review) => sum + review.rating);
        return totalRating / reviews.length;
      }
    } catch (err) {
      print('getAverageRating error: $err');
      return 0.0;
    }
  }

  /// Get all reviews (returns Review objects)
  static Future<List<Review>> getAllReviews() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/reviews'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Review.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch reviews: ${response.statusCode}');
      }
    } catch (err) {
      print('getAllReviews error: $err');
      return [];
    }
  }

  /// Legacy method for backward compatibility (returns raw Map data)
  static Future<List<Map<String, dynamic>>> fetchAllReviews() async {
    try {
      final reviews = await getAllReviews();
      return reviews.map((review) => review.toJson()).toList();
    } catch (error) {
      print('fetchAllReviews error: $error');
      return [];
    }
  }

  /// Get reviews by user ID
  static Future<List<Review>> getReviewsByUserId(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/reviews/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Review.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch user reviews: ${response.statusCode}');
      }
    } catch (err) {
      print('getReviewsByUserId error: $err');
      return [];
    }
  }

  /// Convert File to Base64
  static Future<String> convertFileToBase64(File file) async {
    try {
      List<int> imageBytes = await file.readAsBytes();
      return base64Encode(imageBytes);
    } catch (error) {
      throw Exception('Failed to convert file to base64: $error');
    }
  }
}

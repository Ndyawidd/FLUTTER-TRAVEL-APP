import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Define the Review model
class Review {
  final int reviewId;
  final int userId;
  final int ticketId;
  final int rating;
  final String comment;
  final String userName;
  final DateTime createdAt;

  Review({
    required this.reviewId,
    required this.userId,
    required this.ticketId,
    required this.rating,
    required this.comment,
    required this.userName,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['reviewId'] ?? json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      ticketId: json['ticketId'] ?? 0,
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      userName: json['user']?['name'] ?? json['userName'] ?? 'Anonymous',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviewId': reviewId,
      'userId': userId,
      'ticketId': ticketId,
      'rating': rating,
      'comment': comment,
      'userName': userName,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ReviewService {
  static final String _apiUrl = dotenv.env['API_URL'] ?? '';

  /// Get reviews by ticket ID
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
      return []; // Return empty list jika error
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

  /// Add new review
  static Future<Review> addReview(Map<String, dynamic> reviewData) async {
    try {
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
  static Future<Map<String, dynamic>> deleteReview(int reviewId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_apiUrl/reviews/$reviewId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          return jsonDecode(response.body);
        } else {
          return {'success': true, 'message': 'Review deleted successfully'};
        }
      } else {
        throw Exception('Failed to delete review: ${response.statusCode}');
      }
    } catch (err) {
      print('deleteReview error: $err');
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
        // Jika endpoint tidak ada, hitung manual dari reviews
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

  /// Get all reviews (if needed for admin)
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
}

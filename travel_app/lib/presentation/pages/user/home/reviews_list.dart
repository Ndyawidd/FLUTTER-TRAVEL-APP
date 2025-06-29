import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:travel_app/services/review_service.dart';

class ReviewsListPage extends StatefulWidget {
  final int ticketId;

  const ReviewsListPage({super.key, required this.ticketId});

  @override
  State<ReviewsListPage> createState() => _ReviewsListPageState();
}

class _ReviewsListPageState extends State<ReviewsListPage> {
  List<Review> reviews = [];
  bool isLoading = true;

  final String baseUrl = dotenv.env['API_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    setState(() => isLoading = true);
    try {
      final fetchedReviews =
          await ReviewService.getReviewsByTicketId(widget.ticketId);

      final adjustedReviews = fetchedReviews.map((review) {
        if (review.image != null &&
            review.image!.isNotEmpty &&
            !review.image!.startsWith('http') &&
            !review.image!.startsWith('data:image')) {
          review = Review(
            reviewId: review.reviewId,
            userId: review.userId,
            orderId: review.orderId,
            ticketId: review.ticketId,
            rating: review.rating,
            comment: review.comment,
            userName: review.userName,
            image: '$baseUrl${review.image}',
            createdAt: review.createdAt,
          );
        }
        return review;
      }).toList();

      setState(() {
        reviews = adjustedReviews;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Error fetching reviews: $e");
    }
  }

  String _getStarDisplay(int rating) => '⭐' * rating + '☆' * (5 - rating);

  String _formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

  Widget _buildReviewImage(String? image) {
    if (image == null || image.isEmpty) return const SizedBox();

    if (image.startsWith('data:image') || image.contains('base64,')) {
      final base64Str = image.split(',').last;
      return Image.memory(
        base64Decode(base64Str),
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Text("Gagal memuat base64"),
      );
    }

    if (image.startsWith('/')) {
      final file = File(image);
      return Image.file(
        file,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Text("Gagal memuat file"),
      );
    }

    return Image.network(
      image,
      width: double.infinity,
      height: 180,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Text(
        "Gagal memuat gambar",
        style: TextStyle(fontSize: 10, color: Colors.redAccent),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F1F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "${_getStarDisplay(review.rating)} ${review.rating}/5 - ${review.userName}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                _formatDate(review.createdAt),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            review.comment,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 8),
          if (review.image != null && review.image!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildReviewImage(review.image),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Semua Review",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            )),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF154BCB),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reviews.isEmpty
              ? const Center(
                  child: Text(
                    "Belum ada review untuk destinasi ini",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) =>
                      _buildReviewCard(reviews[index]),
                ),
    );
  }
}

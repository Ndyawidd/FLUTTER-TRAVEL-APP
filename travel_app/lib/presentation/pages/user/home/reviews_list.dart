import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      setState(() {
        reviews = fetchedReviews;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Error fetching reviews: $e");
    }
  }

  String _getStarDisplay(int rating) =>
      '⭐' * rating + '☆' * (5 - rating);

  String _formatDate(DateTime date) =>
      DateFormat('dd/MM/yyyy').format(date);

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
          // Header: Rating + User + Tanggal
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
          // Komentar
          Text(
            review.comment,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Semua Review"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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

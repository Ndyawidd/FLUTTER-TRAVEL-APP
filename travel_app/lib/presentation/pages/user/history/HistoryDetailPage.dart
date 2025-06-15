import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:travel_app/services/order_service.dart';
import 'package:travel_app/services/ticket_service.dart';
import 'addReview.dart';

class HistoryDetailPage extends StatelessWidget {
  final Order order;

  const HistoryDetailPage({super.key, required this.order});

  String formatDate(String? isoDate) {
    if (isoDate == null) return "N/A";
    final dateTime = DateTime.parse(isoDate);
    return DateFormat("MMMM d, y - HH:mm").format(dateTime);
  }

  Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case "CONFIRMED":
        return Colors.green;
      case "PENDING":
        return Colors.orange;
      case "CANCELLED":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<int?> _getUserIdFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('userId');
    } catch (error) {
      print('Error getting userId: $error');
      return null;
    }
  }

  Future<void> _navigateToReview(BuildContext context, Ticket ticket) async {
    // Get user data from storage
    final userId = await _getUserIdFromStorage();

    if (userId == null) {
      // Show error dialog if user not found
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text(
              'Silakan login terlebih dahulu untuk memberikan review.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Prepare order details
    final orderDetails = {
      'orderId': order.orderId,
      'ticketId': order.ticketId,
      'date': order.date,
      'updatedAt': ticket.updatedAt,
      'status': order.status,
      'quantity': order.quantity,
      'totalPrice': order.totalPrice,
      'ticket': {
        'name': ticket.name,
        'location': ticket.location,
        'image': ticket.image,
      },
    };

    // Navigate to AddReviewPage with required parameters
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddReviewPage(
          orderId: order.orderId,
          orderDetails: orderDetails,
          userDetails: {"id": userId}, 
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isReviewDisabled = order.status != 'CONFIRMED';

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: TicketService.fetchTicketById(order.ticketId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(child: Text('Failed to load ticket details'));
            }

            final ticket = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back & Title
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon:
                            const Icon(Icons.arrow_back, color: Colors.orange),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Detail History",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1450A3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Review Section
                  GestureDetector(
                    onTap: () {
                      if (!isReviewDisabled) {
                        _navigateToReview(context, ticket);
                      } else {
                        // Show info dialog for disabled review
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Info'),
                            content: const Text(
                                'Review hanya dapat diberikan untuk pesanan yang sudah dikonfirmasi.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Review your order",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF1450A3),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isReviewDisabled
                                ? "Review dapat diberikan setelah pesanan dikonfirmasi"
                                : "Let's leave positive destination and write the review!",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 24),
                            decoration: BoxDecoration(
                              color: isReviewDisabled
                                  ? Colors.grey
                                  : const Color(0xFF1450A3),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              "Write a Review",
                              style: TextStyle(
                                color: isReviewDisabled
                                    ? Colors.black45
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Order Detail
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            ticket.image,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 100),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title & Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                ticket.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: getStatusColor(order.status)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: getStatusColor(order.status),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                order.status,
                                style: TextStyle(
                                    color: getStatusColor(order.status),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ticket.location,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black54),
                        ),
                        const Divider(height: 32),

                        // Detail Info
                        detailRow("Order ID", order.orderId),
                        detailRow("Order Date", formatDate(order.date)),
                        detailRow(
                          "Payment Date",
                          order.status == "CONFIRMED"
                              ? formatDate(ticket.updatedAt)
                              : "N/A",
                        ),
                        detailRow(
                            "Ticket Quantity", "${order.quantity} tickets"),
                        detailRow("Total Price",
                            "Rp ${NumberFormat('#,###').format(order.totalPrice)}"),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 13, color: Colors.black54)),
          Flexible(
            child: Text(value,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}

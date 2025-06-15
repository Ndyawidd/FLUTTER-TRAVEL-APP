import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddReviewPage(),
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
                          const Text(
                            "Let's leave positive destination and write the review!",
                            style:
                                TextStyle(fontSize: 12, color: Colors.black54),
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
                            Text(
                              ticket.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            Text(
                              order.status,
                              style: TextStyle(
                                  color: getStatusColor(order.status),
                                  fontWeight: FontWeight.bold),
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
                            "Rp ${order.totalPrice.toStringAsFixed(0)}"),
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
          Text(value,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'addReview.dart';

class HistoryDetailPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const HistoryDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button dan judul
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.orange),
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
              // Review your order card
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddReviewPage(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline,
                          color: Color(0xFF1450A3)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Review your order",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF1450A3),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Let's leave positive destination and write the review!",
                            style:
                                TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Order detail card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        order['image'],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order['place'],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order['location'],
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "No Pesanan",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black54),
                              ),
                              Text(
                                order['orderNumber'],
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                "Waktu Pemesanan",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black54),
                              ),
                              Text(
                                "12 Apr 2025 16:54",
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                "Waktu Pembayaran",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black54),
                              ),
                              Text(
                                "12 Apr 2025 16:54",
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Jumlah Tiket
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Jumlah Tiket",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black54),
                              ),
                              Text(
                                "${order['ticketQuantity']} tiket",
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Total Harga
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total Harga",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black54),
                              ),
                              Text(
                                "Rp${order['totalPrice']}",
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

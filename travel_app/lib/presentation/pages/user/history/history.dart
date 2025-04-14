import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  final List<Map<String, dynamic>> orders = const [
    {
      "orderNumber": "123456789",
      "place": "Taman Hutan Raya",
      "price": "Rp. 500.000",
      "status": "Payment Successful",
      "statusColor": Colors.green,
    },
    {
      "orderNumber": "123456789",
      "place": "Taman Hutan Raya",
      "price": "Rp. 500.000",
      "status": "Waiting Payment",
      "statusColor": Colors.orange,
    },
    {
      "orderNumber": "123456789",
      "place": "Taman Hutan Raya",
      "price": "Rp. 500.000",
      "status": "Payment Cancelled",
      "statusColor": Colors.red,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final orders = [
      {
        "orderNumber": "123456789",
        "place": "Taman Hutan Raya",
        "price": "Rp. 500.000",
        "status": "Payment Successful",
        "statusColor": Colors.green,
      },
      {
        "orderNumber": "123456789",
        "place": "Taman Hutan Raya",
        "price": "Rp. 500.000",
        "status": "Waiting Payment",
        "statusColor": Colors.orange,
      },
      {
        "orderNumber": "123456789",
        "place": "Taman Hutan Raya",
        "price": "Rp. 500.000",
        "status": "Payment Cancelled",
        "statusColor": Colors.red,
      },
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "History",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 16),
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.blue, size: 28),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search history",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // History Cards
            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return HistoryCard(
                    orderNumber: order['orderNumber'].toString(),
                    place: order['place'].toString(),
                    price: order['price'].toString(),
                    status: order['status'].toString(),
                    statusColor: order['statusColor'] as Color,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryCard extends StatelessWidget {
  final String orderNumber;
  final String place;
  final String price;
  final String status;
  final Color statusColor;

  const HistoryCard({
    super.key,
    required this.orderNumber,
    required this.place,
    required this.price,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris atas: No. Pesanan dan Harga
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("No. Pesanan",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text(
                orderNumber,
                style: const TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.w600),
              ),
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          // Nama Tempat
          Text(
            place,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          // Status
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              status,
              style: TextStyle(color: statusColor, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

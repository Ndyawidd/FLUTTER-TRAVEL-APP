import 'package:flutter/material.dart';
import 'HistoryDetailPage.dart';
import '../../../widgets/search_bar.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  final List<Map<String, dynamic>> orders = const [
    {
      "orderNumber": "TPMT250412001",
      "place": "Labuan Bajo",
      'image': 'assets/images/labuanbajo.jpg',
      "location": "Bandung, Indonesia",
      "status": "Successful",
      "statusColor": Colors.green,
    },
    {
      "orderNumber": "TPMT250412002",
      "place": "Bali",
      'image': 'assets/images/labuanbajo.jpg',
      "location": "Denpasar, Indonesia",
      "status": "Waiting ",
      "statusColor": Colors.orange,
    },
    {
      "orderNumber": "TPMT250412003",
      "place": "Yogyakarta",
      'image': 'assets/images/labuanbajo.jpg',
      "location": "Yogyakarta, Indonesia",
      "status": "Cancelled",
      "statusColor": Colors.red,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "History",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1450A3),
              ),
            ),
            const SizedBox(height: 16),
            // Search Bar
            const SearchBarWidget(),
            const SizedBox(height: 16),
            // History Cards
            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HistoryDetailPage(order: order),
                        ),
                      );
                    },
                    child: HistoryCard(
                      image: order['image'].toString(),
                      orderNumber: order['orderNumber'].toString(),
                      place: order['place'].toString(),
                      location: order['location'].toString(),
                      status: order['status'].toString(),
                      statusColor: order['statusColor'] as Color,
                    ),
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
  final String image;
  final String orderNumber;
  final String place;
  final String location;
  final String status;
  final Color statusColor;

  const HistoryCard({
    super.key,
    required this.image,
    required this.orderNumber,
    required this.place,
    required this.location,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Thumbnail image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              image,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      "No Pesanan",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const Spacer(),
                    Text(
                      orderNumber,
                      style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Status
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                status,
                style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }
}

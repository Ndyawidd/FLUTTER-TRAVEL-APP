import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HistoryDetailPage.dart';
import 'package:travel_app/services/order_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Order> _orders = [];
  List<Order> _filteredOrders = [];
  int? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserAndFetchOrders();
  }

  Future<void> _loadUserAndFetchOrders() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');

    if (userId != null) {
      await _fetchOrders();
    } else {
      debugPrint("No userId found in SharedPreferences");
    }

    setState(() => isLoading = false);
  }

  Future<void> _fetchOrders() async {
    if (userId == null) return;

    try {
      final allOrders = await OrderService.fetchOrders();
      final userOrders =
          allOrders.where((order) => order.userId == userId).toList();

      setState(() {
        _orders = userOrders;
        _filteredOrders = userOrders;
      });
    } catch (e) {
      debugPrint("Error fetching orders: $e");
      setState(() {
        _orders = [];
        _filteredOrders = [];
      });
    }
  }

  void _onSearchChanged(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredOrders = _orders
          .where(
              (order) => order.ticketTitle.toLowerCase().contains(lowerQuery))
          .toList();
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "History",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1450A3),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
                hintText: "Search destination...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredOrders.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                "No booking history found.",
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = _filteredOrders[index];
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HistoryDetailPage(order: order),
                                ),
                              ),
                              child: HistoryCard(
                                image: order.image,
                                orderNumber: order.orderId,
                                place: order.ticketTitle,
                                location: order.userName,
                                status: order.status,
                                statusColor: _getStatusColor(order.status),
                                quantity: order.quantity,
                                totalPrice: order.totalPrice,
                                date: order.date,
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
  final int quantity;
  final double totalPrice;
  final String date;

  const HistoryCard({
    super.key,
    required this.image,
    required this.orderNumber,
    required this.place,
    required this.location,
    required this.status,
    required this.statusColor,
    required this.quantity,
    required this.totalPrice,
    required this.date,
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
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              image,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported,
                  size: 60,
                  color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 4),
                Text(
                  "Quantity: $quantity",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  "Total: Rp ${totalPrice.toStringAsFixed(0)}",
                  style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  "Date: $date",
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text("Order ID",
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const Spacer(),
                    Text(orderNumber,
                        style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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
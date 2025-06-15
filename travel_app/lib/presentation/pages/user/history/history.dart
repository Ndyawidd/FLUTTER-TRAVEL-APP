import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HistoryDetailPage.dart';
import 'package:travel_app/services/order_service.dart';
import 'package:intl/intl.dart';

const kPrimaryBlue = Color(0xFF154BCB);
const kSecondaryOrange = Color(0xFFFF8500);
const kCardBgColor = Color(0xFFF1F5FE);
const kBorderColor = Color(0xFFD8E0F2);
const kLightGrey = Color(0xFFE8E8E8);
const kTextGrey = Color(0xFF757575);

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
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserAndFetchOrders();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _searchController.text;
      _filterOrders();
    });
  }

  void _filterOrders() {
    if (searchQuery.isEmpty) {
      _filteredOrders = List.from(_orders);
    } else {
      final lowerQuery = searchQuery.toLowerCase();
      _filteredOrders = _orders
          .where((order) => 
              order.ticketTitle.toLowerCase().contains(lowerQuery) ||
              order.userName.toLowerCase().contains(lowerQuery))
          .toList();
    }
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    return 'Rp. ${formatter.format(price.toInt())}';
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
        _filterOrders();
      });
    } catch (e) {
      debugPrint("Error fetching orders: $e");
      setState(() {
        _orders = [];
        _filteredOrders = [];
      });
    }
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

  Widget _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return const Icon(Icons.check_circle, size: 16, color: Colors.green);
      case 'PENDING':
        return const Icon(Icons.schedule, size: 16, color: Colors.orange);
      case 'CANCELLED':
        return const Icon(Icons.cancel, size: 16, color: Colors.red);
      default:
        return const Icon(Icons.help, size: 16, color: Colors.grey);
    }
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari riwayat booking...',
          hintStyle: TextStyle(color: kTextGrey, fontSize: 16),
          prefixIcon: Icon(Icons.search, color: kPrimaryBlue),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: kTextGrey),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: kCardBgColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isSearching = searchQuery.isNotEmpty;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kCardBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSearching ? Icons.search_off : Icons.history,
              size: 64,
              color: kTextGrey,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isSearching ? "Tidak ada hasil pencarian" : "Belum ada riwayat booking",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching 
                ? "Coba kata kunci lain"
                : "Riwayat pemesanan Anda akan muncul di sini",
            style: TextStyle(
              fontSize: 16,
              color: kTextGrey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "History",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: kPrimaryBlue,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_orders.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: kPrimaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_filteredOrders.length}',
                style: const TextStyle(
                  color: kPrimaryBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: 20),
              if (searchQuery.isNotEmpty) ...[
                Text(
                  'Hasil pencarian untuk "$searchQuery"',
                  style: TextStyle(
                    fontSize: 16,
                    color: kTextGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(kPrimaryBlue),
                        ),
                      )
                    : _filteredOrders.isEmpty
                        ? _buildEmptyState()
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
                                  statusIcon: _getStatusIcon(order.status),
                                  quantity: order.quantity,
                                  totalPrice: order.totalPrice,
                                  date: order.date,
                                  formatPrice: _formatPrice,
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
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
  final Widget statusIcon;
  final int quantity;
  final double totalPrice;
  final String date;
  final String Function(double) formatPrice;

  const HistoryCard({
    super.key,
    required this.image,
    required this.orderNumber,
    required this.place,
    required this.location,
    required this.status,
    required this.statusColor,
    required this.statusIcon,
    required this.quantity,
    required this.totalPrice,
    required this.date,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    image,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: kCardBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: kTextGrey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: kTextGrey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              style: TextStyle(
                                color: kTextGrey,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          statusIcon,
                          const SizedBox(width: 6),
                          Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kCardBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Order ID",
                        style: TextStyle(
                          color: kTextGrey,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        orderNumber,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Quantity",
                        style: TextStyle(
                          color: kTextGrey,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "$quantity tiket",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Harga",
                        style: TextStyle(
                          color: kTextGrey,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        formatPrice(totalPrice),
                        style: const TextStyle(
                          color: kPrimaryBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tanggal",
                        style: TextStyle(
                          color: kTextGrey,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        date,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
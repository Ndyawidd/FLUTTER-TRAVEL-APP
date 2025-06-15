import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../services/order_service.dart';
import '../../../../services/user_service.dart';
import '../../../../services/ticket_service.dart';
import 'orderdetail.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String selectedFilter = 'ALL';
  String searchQuery = '';
  List<Order> allOrders = [];
  List<Order> filteredOrders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      isLoading = true;
    });

    try {
      final orders = await OrderService.fetchOrders();
      setState(() {
        allOrders = orders;
        _filterOrders();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterOrders() {
    setState(() {
      filteredOrders = allOrders.where((order) {
        final matchesFilter = selectedFilter == 'ALL' ||
            order.status.toUpperCase() == selectedFilter;
        final matchesSearch = searchQuery.isEmpty ||
            order.userName.toLowerCase().contains(searchQuery) ||
            order.ticketTitle.toLowerCase().contains(searchQuery);
        return matchesFilter && matchesSearch;
      }).toList();
    });
  }

  String _formatRupiah(int amount) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    return 'Rp. ${formatter.format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Order Management",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A4D8F),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                  _filterOrders();
                },
                decoration: InputDecoration(
                  hintText: 'Search by name or ticket title',
                  prefixIcon: const Icon(Icons.search, color: Colors.orange),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Color(0xFF1450A3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide:
                        const BorderSide(color: Color(0xFF1450A3), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 40,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      buildFilterButton('ALL'),
                      const SizedBox(width: 8),
                      buildFilterButton('PENDING'),
                      const SizedBox(width: 8),
                      buildFilterButton('CONFIRMED', isWide: true),
                      const SizedBox(width: 8),
                      buildFilterButton('CANCELLED', isWide: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredOrders.isEmpty
                        ? Center(
                            child: Text(
                              searchQuery.isNotEmpty
                                  ? 'No orders found for "$searchQuery"'
                                  : selectedFilter == 'ALL'
                                      ? 'No orders available'
                                      : 'No ${selectedFilter.toLowerCase()} orders found',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadOrders,
                            child: ListView.separated(
                              itemCount: filteredOrders.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final order = filteredOrders[index];
                                final total = order.totalPrice;

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OrderDetailPage(
                                          orderData: {
                                            'orderId': order.orderId,
                                            'name': order.userName,
                                            'title': order.ticketTitle,
                                            'quantity': order.quantity,
                                            'price': order.totalPrice,
                                            'image': order.image,
                                            'status': order.status,
                                            'date': order.date,
                                            'userId': order.userId,
                                            'ticketId': order.ticketId,
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          color: const Color(0xFF1450A3)),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        )
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            FutureBuilder<String?>(
                                              future:
                                                  _getUserImage(order.userId),
                                              builder: (context, snapshot) {
                                                return CircleAvatar(
                                                  radius: 20,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    child: _buildUserImage(
                                                        snapshot.data,
                                                        order.userName),
                                                  ),
                                                );
                                              },
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                order.userName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(
                                                    order.status),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                order.status,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: order.image.isNotEmpty
                                                  ? Image.network(
                                                      order.image,
                                                      width: 80,
                                                      height: 80,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return _buildImagePlaceholder();
                                                      },
                                                    )
                                                  : _buildImagePlaceholder(),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    order.ticketTitle,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Quantity: ${order.quantity}',
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Total: ${_formatRupiah(total.toInt())}',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF1450A3),
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Date: ${_formatDate(order.date)}',
                                                    style: TextStyle(
                                                      color: Colors.grey[500],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFFFFA500),
        unselectedItemColor: Colors.white,
        backgroundColor: const Color(0xFF1450A3),
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/admin/ticket');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/admin/review');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: 'Ticket',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.reviews),
            label: 'Review',
          ),
        ],
      ),
    );
  }

  Widget buildFilterButton(String status, {bool isWide = false}) {
    final isSelected = selectedFilter == status;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedFilter = status;
        });
        _filterOrders();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? const Color(0xFFFFA500) : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.black,
        padding: EdgeInsets.symmetric(horizontal: isWide ? 20 : 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(status),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'CONFIRMED':
        return Colors.blue;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Future<String?> _getUserImage(int userId) async {
    try {
      final user = await UserService.getUserById(userId);
      return user.image;
    } catch (e) {
      print('Error fetching user image: $e');
      return null;
    }
  }

  Widget _buildUserImage(String? imageUrl, String userName) {
    print('Building user image for: $userName');
    print('Image URL: $imageUrl');

    // Priority: 1. Server image URL, 2. Default avatar
    if (imageUrl != null && imageUrl.isNotEmpty) {
      print('Displaying user image: $imageUrl');

      // Handle both HTTP URLs and base64 data URLs
      if (imageUrl.startsWith('data:image')) {
        // It's a base64 data URL
        try {
          final base64String = imageUrl.split(',')[1];
          final bytes = base64Decode(base64String);
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            width: 40,
            height: 40,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading base64 user image: $error');
              return _buildDefaultUserAvatar(userName);
            },
          );
        } catch (e) {
          print('Error decoding base64 user image: $e');
          return _buildDefaultUserAvatar(userName);
        }
      } else if (imageUrl.startsWith('http')) {
        // It's a regular HTTP URL
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: 40,
          height: 40,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading network user image: $error');
            return _buildDefaultUserAvatar(userName);
          },
        );
      } else {
        // It might be a relative path, try with API URL
        final fullUrl = '${dotenv.env['API_URL']}$imageUrl';
        return Image.network(
          fullUrl,
          fit: BoxFit.cover,
          width: 40,
          height: 40,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading relative path user image: $error');
            return _buildDefaultUserAvatar(userName);
          },
        );
      }
    }

    print('Displaying default user avatar');
    return _buildDefaultUserAvatar(userName);
  }

  Widget _buildDefaultUserAvatar(String userName) {
    // Create a default avatar with the user's initial
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF1450A3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
        size: 40,
      ),
    );
  }
}

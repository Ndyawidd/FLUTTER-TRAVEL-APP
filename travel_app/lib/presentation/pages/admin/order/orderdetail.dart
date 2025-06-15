import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../services/order_service.dart';
import '../../../../services/user_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class OrderDetailPage extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const OrderDetailPage({super.key, required this.orderData});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  String currentStatus = '';
  String? userImageUrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.orderData['status'] as String;
    _loadUserImage();
  }

  Future<void> _loadUserImage() async {
    try {
      final user =
          await UserService.getUserById(widget.orderData['userId'] as int);
      setState(() {
        userImageUrl = user.image;
      });
    } catch (e) {
      print('Error loading user image: $e');
    }
  }

  Future<void> _updateOrderStatus(String newStatus) async {
    setState(() {
      isLoading = true;
    });

    try {
      final success = await OrderService.updateOrderStatus(
        widget.orderData['orderId'].toString(),
        newStatus,
      );

      if (success) {
        setState(() {
          currentStatus = newStatus;
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to update order status');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update order status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatRupiah(int amount) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    return 'Rp. ${formatter.format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.orderData['price'] as num;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Detail Order",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info section
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: _buildUserImage(
                              userImageUrl, widget.orderData['name'] as String),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.orderData['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(currentStatus),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          currentStatus,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Order details section
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildOrderImage(
                            widget.orderData['image'] as String),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.orderData['title'] as String,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Quantity: ${widget.orderData['quantity']}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total: ${_formatRupiah(total.toInt())}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1450A3),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Order metadata
                  Text('Order ID: ${widget.orderData['orderId']}'),
                  const SizedBox(height: 4),
                  Text(
                      'Order Date: ${_formatDate(widget.orderData['date'] as String)}'),
                  const SizedBox(height: 4),
                  Text('Ticket ID: ${widget.orderData['ticketId']}'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Action buttons
            if (currentStatus == 'PENDING') ...[
              ElevatedButton(
                onPressed:
                    isLoading ? null : () => _updateOrderStatus('CONFIRMED'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Confirm Order',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed:
                    isLoading ? null : () => _updateOrderStatus('CANCELLED'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C6881),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Cancel Order',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getStatusColor(currentStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getStatusColor(currentStatus)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      currentStatus == 'CONFIRMED'
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: _getStatusColor(currentStatus),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Order ${currentStatus.toLowerCase()}',
                      style: TextStyle(
                        color: _getStatusColor(currentStatus),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserImage(String? imageUrl, String userName) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      // Handle both HTTP URLs and base64 data URLs
      if (imageUrl.startsWith('data:image')) {
        try {
          final base64String = imageUrl.split(',')[1];
          final bytes = base64Decode(base64String);
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            width: 36,
            height: 36,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultUserAvatar(userName);
            },
          );
        } catch (e) {
          return _buildDefaultUserAvatar(userName);
        }
      } else if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: 36,
          height: 36,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultUserAvatar(userName);
          },
        );
      } else {
        final fullUrl = '${dotenv.env['API_URL']}$imageUrl';
        return Image.network(
          fullUrl,
          fit: BoxFit.cover,
          width: 36,
          height: 36,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultUserAvatar(userName);
          },
        );
      }
    }

    return _buildDefaultUserAvatar(userName);
  }

  Widget _buildDefaultUserAvatar(String userName) {
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF1450A3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return _buildImagePlaceholder();
    }

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImagePlaceholder();
        },
      );
    } else {
      final fullUrl = '${dotenv.env['API_URL']}$imageUrl';
      return Image.network(
        fullUrl,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImagePlaceholder();
        },
      );
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
        size: 30,
      ),
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
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}

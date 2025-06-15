import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:travel_app/services/review_service.dart';
import 'review.dart';

class AddReviewPage extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic>? orderDetails;
  final Map<String, dynamic>? userDetails;

  const AddReviewPage({
    super.key,
    required this.orderId,
    this.orderDetails,
    this.userDetails,
  });

  @override
  State<AddReviewPage> createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _orderDetails;
  Map<String, dynamic>? _userDetails;

  @override
  void initState() {
    super.initState();
    _orderDetails = widget.orderDetails;
    _userDetails = widget.userDetails;
    // Jika data tidak diberikan, Anda bisa fetch dari API di sini
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);

        // Check file size (max 2MB)
        final fileSize = await file.length();
        if (fileSize > 2 * 1024 * 1024) {
          _showErrorDialog('Ukuran gambar maksimal 2MB');
          return;
        }

        setState(() {
          _imageFile = file;
        });
      }
    } catch (error) {
      _showErrorDialog('Gagal memilih gambar: $error');
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
    });
  }

  Future<Map<String, dynamic>?> _getUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');
      if (userString != null) {
        return jsonDecode(userString);
      }
    } catch (error) {
      print('Error getting user from storage: $error');
    }
    return null;
  }

  Future<void> _submitReview() async {
    // Validasi input
    if (_rating == 0) {
      _showErrorDialog('Silakan berikan rating');
      return;
    }

    if (_reviewController.text.trim().isEmpty) {
      _showErrorDialog('Silakan tulis komentar');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get user dari storage
      final user = await _getUserFromStorage();
      if (user == null || user['userId'] == null) {
        _showErrorDialog('Silakan login untuk memberikan review');
        return;
      }

      // Convert image to base64 if exists
      String? base64Image;
      if (_imageFile != null) {
        base64Image = await ReviewService.convertFileToBase64(_imageFile!);
        // Add data URL prefix for base64 image
        base64Image = 'data:image/jpeg;base64,$base64Image';
      }

      // Submit review
      final result = await ReviewService.postReview(
        userId: user['userId'],
        orderId: widget.orderId,
        ticketId: _orderDetails?['ticketId'] ?? 0,
        rating: _rating,
        comment: _reviewController.text.trim(),
        image: base64Image,
      );

      if (result != null) {
        _showSuccessDialog();
      } else {
        _showErrorDialog('Gagal mengirim review. Silakan coba lagi.');
      }
    } catch (error) {
      _showErrorDialog('Gagal mengirim review: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Berhasil'),
        content: const Text('Review berhasil dikirim!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Navigate to detail page or back
              if (_orderDetails?['ticketId'] != null) {
                Navigator.pushReplacementNamed(
                  context,
                  '/detail/${_orderDetails!['ticketId']}',
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ReviewPage()),
                );
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button and title
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.orange),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Review Order",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1450A3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Order Detail Card
              if (_orderDetails != null) ...[
                Container(
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
                        child: _orderDetails!['ticket']?['image'] != null
                            ? Image.network(
                                _orderDetails!['ticket']['image'],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/images/placeholder.jpg',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : Image.asset(
                                'assets/images/placeholder.jpg',
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
                              _orderDetails!['ticket']?['name'] ??
                                  'Unknown Destination',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _orderDetails!['ticket']?['location'] ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ReviewDetailRow(
                              title: "No Pesanan",
                              value: _orderDetails!['orderId'] ?? 'N/A',
                            ),
                            const SizedBox(height: 8),
                            ReviewDetailRow(
                              title: "Waktu Pemesanan",
                              value: _formatDate(_orderDetails!['date']),
                            ),
                            const SizedBox(height: 8),
                            ReviewDetailRow(
                              title: "Waktu Pembayaran",
                              value: _formatDate(_orderDetails!['updatedAt']),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Review Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Info
                    if (_userDetails != null) ...[
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: _userDetails!['image'] != null
                                ? NetworkImage(_userDetails!['image'])
                                : const AssetImage(
                                        'assets/images/default-user.jpg')
                                    as ImageProvider,
                            radius: 24,
                            onBackgroundImageError: (_, __) {},
                            child: _userDetails!['image'] == null
                                ? const Icon(Icons.person, size: 24)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userDetails!['name'] ?? 'Unknown User',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '@${_userDetails!['username'] ?? 'unknown'}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Star Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () {
                            setState(() {
                              _rating = index + 1;
                            });
                          },
                          icon: Icon(
                            Icons.star,
                            color:
                                _rating > index ? Colors.orange : Colors.grey,
                            size: 32,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),

                    // Text Field
                    TextField(
                      controller: _reviewController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Tell others about your experience",
                        filled: true,
                        fillColor: Colors.blue.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Add Photos Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _pickImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.photo, color: Colors.white),
                        label: Text(
                          _imageFile != null ? "Photo Added" : "Add photos",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

                    // Preview uploaded image
                    if (_imageFile != null) ...[
                      const SizedBox(height: 16),
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _imageFile!,
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: _removeImage,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Post Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Post",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }
}

class ReviewDetailRow extends StatelessWidget {
  final String title;
  final String value;

  const ReviewDetailRow({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

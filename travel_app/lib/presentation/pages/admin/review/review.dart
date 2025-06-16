import 'package:flutter/material.dart';
import 'package:travel_app/services/review_admin_service.dart'; // Import the service
import 'package:travel_app/services/user_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class ReviewManagementPage extends StatefulWidget {
  const ReviewManagementPage({super.key});

  @override
  State<ReviewManagementPage> createState() => _ReviewManagementPageState();
}

class _ReviewManagementPageState extends State<ReviewManagementPage> {
  String selectedTab = 'All';
  int? selectedRating;
  String searchQuery = '';
  List<Map<String, dynamic>> reviews = [];
  List<Map<String, dynamic>> filteredReviews = [];
  String? errorMessage;
  String? successMessage;
  Map<int, TextEditingController> responseControllers = {};
  int? editResponseId;
  TextEditingController editResponseController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in responseControllers.values) {
      controller.dispose();
    }
    editResponseController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final reviewsData = await ReviewService.fetchAllReviews();
      setState(() {
        reviews = reviewsData;
        _applyFilters();
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Failed to load reviews. Please try again.';
        isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(reviews);

    // Apply Search Filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((review) {
        final userName =
            (review['user']?['name'] ?? '').toString().toLowerCase();
        final ticketName =
            (review['ticket']?['name'] ?? '').toString().toLowerCase();
        final comment = (review['comment'] ?? '').toString().toLowerCase();
        return userName.contains(searchQuery) ||
            ticketName.contains(searchQuery) ||
            comment.contains(searchQuery);
      }).toList();
    }

    // Apply Status Filter
    if (selectedTab == 'Not Replied') {
      filtered = filtered.where((review) {
        final responses = review['responses'] as List?;
        return responses == null || responses.isEmpty;
      }).toList();
    }

    // Apply Rating Filter
    if (selectedRating != null) {
      filtered = filtered.where((review) {
        final rating = review['rating'];
        return rating == selectedRating;
      }).toList();
    }

    setState(() {
      filteredReviews = filtered;
    });
  }

  void _onTabChanged(String tab) {
    setState(() {
      selectedTab = tab;
    });
    _applyFilters();
  }

  void _onRatingChanged(int? rating) {
    setState(() {
      selectedRating = rating;
    });
    _applyFilters();
  }

  Future<void> _addResponse(int reviewId) async {
    final controller = responseControllers[reviewId];
    if (controller == null || controller.text.trim().isEmpty) {
      _showMessage('Please enter a response before submitting.', isError: true);
      return;
    }

    try {
      await ReviewService.postResponse(reviewId, controller.text);
      controller.clear();
      await _loadReviews();
      _showMessage('Response added successfully!');
    } catch (error) {
      _showMessage('Failed to add response. Please try again.', isError: true);
    }
  }

  Future<void> _deleteResponse(int responseId) async {
    final confirmed = await _showConfirmDialog(
        'Are you sure you want to delete this response?');
    if (!confirmed) return;

    try {
      final success = await ReviewService.deleteResponse(responseId);
      if (success) {
        await _loadReviews();
        _showMessage('Response deleted successfully!');
      } else {
        _showMessage('Failed to delete response. Please try again.',
            isError: true);
      }
    } catch (error) {
      _showMessage('Failed to delete response. Please try again.',
          isError: true);
    }
  }

  Future<void> _deleteReview(int reviewId) async {
    final confirmed = await _showConfirmDialog(
        'Are you sure you want to delete this review?');
    if (!confirmed) return;

    try {
      final success = await ReviewService.deleteReview(reviewId);
      if (success) {
        await _loadReviews();
        _showMessage('Review deleted successfully!');
      } else {
        _showMessage('Failed to delete review. Please try again.',
            isError: true);
      }
    } catch (error) {
      _showMessage('Failed to delete review. Please try again.', isError: true);
    }
  }

  void _startEditResponse(int responseId, String currentText) {
    setState(() {
      editResponseId = responseId;
      editResponseController.text = currentText;
    });
  }

  Future<void> _saveEditResponse(int responseId) async {
    if (editResponseController.text.trim().isEmpty) {
      _showMessage('Please enter a response before saving.', isError: true);
      return;
    }

    try {
      await ReviewService.editResponse(responseId, editResponseController.text);
      setState(() {
        editResponseId = null;
        editResponseController.clear();
      });
      await _loadReviews();
      _showMessage('Response updated successfully!');
    } catch (error) {
      _showMessage('Failed to edit response. Please try again.', isError: true);
    }
  }

  void _cancelEdit() {
    setState(() {
      editResponseId = null;
      editResponseController.clear();
    });
  }

  void _showMessage(String message, {bool isError = false}) {
    setState(() {
      if (isError) {
        errorMessage = message;
        successMessage = null;
      } else {
        successMessage = message;
        errorMessage = null;
      }
    });

    // Auto-hide success messages
    if (!isError) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            successMessage = null;
          });
        }
      });
    }
  }

  Future<bool> _showConfirmDialog(String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
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
            width: 48,
            height: 48,
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
          width: 48,
          height: 48,
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
          width: 48,
          height: 48,
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
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF1450A3),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildReviewImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      // Handle both HTTP URLs and base64 data URLs
      if (imageUrl.startsWith('data:image')) {
        // It's a base64 data URL
        try {
          final base64String = imageUrl.split(',')[1];
          final bytes = base64Decode(base64String);
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              bytes,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Error loading base64 review image: $error');
                return _buildImagePlaceholder();
              },
            ),
          );
        } catch (e) {
          print('Error decoding base64 review image: $e');
          return _buildImagePlaceholder();
        }
      } else if (imageUrl.startsWith('http')) {
        // It's a regular HTTP URL
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading network review image: $error');
              return _buildImagePlaceholder();
            },
          ),
        );
      } else {
        // It might be a relative path, try with API URL
        final fullUrl = '${dotenv.env['API_URL']}$imageUrl';
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            fullUrl,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading relative path review image: $error');
              return _buildImagePlaceholder();
            },
          ),
        );
      }
    }

    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              color: Colors.grey,
              size: 40,
            ),
            SizedBox(height: 8),
            Text(
              'Image not available',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: ['All', 'Not Replied'].map((tab) {
          final isSelected = selectedTab == tab;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton(
                onPressed: () => _onTabChanged(tab),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isSelected ? const Color(0xFFFFA500) : Colors.white,
                  foregroundColor:
                      isSelected ? Colors.white : const Color(0xFF1A4D8F),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFFFFA500)
                        : Colors.grey.shade300,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: isSelected ? 4 : 1,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  tab,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRatingFilter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // All button
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_border, size: 16),
                    SizedBox(width: 4),
                    Text('All'),
                  ],
                ),
                selected: selectedRating == null,
                onSelected: (selected) => _onRatingChanged(null),
                selectedColor: const Color(0xFF1A4D8F).withOpacity(0.2),
                checkmarkColor: const Color(0xFF1A4D8F),
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: selectedRating == null
                      ? const Color(0xFF1A4D8F)
                      : Colors.grey.shade300,
                ),
              ),
            ),
            // Rating buttons 1-5
            ...List.generate(5, (i) {
              final rating = i + 1;
              final isSelected = selectedRating == rating;
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$rating'),
                      const SizedBox(width: 2),
                      const Icon(Icons.star, size: 16, color: Colors.orange),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) =>
                      _onRatingChanged(isSelected ? null : rating),
                  selectedColor: Colors.orange.withOpacity(0.2),
                  checkmarkColor: Colors.orange,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? Colors.orange : Colors.grey.shade300,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final reviewId = review['reviewId'] ?? review['id'];
    final responses = review['responses'] as List<dynamic>? ?? [];
    final hasResponse = responses.isNotEmpty;
    final userId = review['user']?['userId'] ?? 0;

    // Ensure controller exists for this review
    if (!responseControllers.containsKey(reviewId)) {
      responseControllers[reviewId] = TextEditingController();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Review header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.shade50,
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                FutureBuilder<String?>(
                  future: _getUserImage(userId),
                  builder: (context, snapshot) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: _buildUserImage(
                          snapshot.data,
                          review['user']?['name'] ?? 'Anonymous',
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review['user']?['name'] ?? 'Anonymous',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1A4D8F),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        review['ticket']?['name'] ?? 'Unknown Ticket',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFA500), Color(0xFFFF8C00)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${review['rating']}/5',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: () => _deleteReview(reviewId),
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red.shade600,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Review content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Review comment
                if (review['comment'] != null &&
                    review['comment'].toString().isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      review['comment'],
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Review image
                if (review['image'] != null) ...[
                  _buildReviewImage(review['image']),
                  const SizedBox(height: 12),
                ],

                // Existing responses
                if (hasResponse) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade50, Colors.blue.shade100],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.admin_panel_settings,
                              color: Colors.blue.shade700,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Admin Response:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...responses.map((response) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade100),
                              ),
                              child: editResponseId == response['responseId']
                                  ? Column(
                                      children: [
                                        TextField(
                                          controller: editResponseController,
                                          decoration: InputDecoration(
                                            hintText: 'Edit your response...',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                  color: Colors.blue.shade400),
                                            ),
                                          ),
                                          maxLines: 3,
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            ElevatedButton(
                                              onPressed: () =>
                                                  _saveEditResponse(
                                                      response['responseId']),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                              ),
                                              child: const Text('Save'),
                                            ),
                                            const SizedBox(width: 8),
                                            TextButton(
                                              onPressed: _cancelEdit,
                                              child: const Text('Cancel'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                response['response'] ?? '',
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () =>
                                                  _startEditResponse(
                                                response['responseId'],
                                                response['response'] ?? '',
                                              ),
                                              icon: Icon(
                                                Icons.edit_outlined,
                                                size: 18,
                                                color: Colors.blue.shade600,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () => _deleteResponse(
                                                  response['responseId']),
                                              icon: Icon(
                                                Icons.delete_outline,
                                                size: 18,
                                                color: Colors.red.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (response['createdAt'] != null)
                                          Text(
                                            DateTime.parse(
                                                    response['createdAt'])
                                                .toLocal()
                                                .toString()
                                                .substring(0, 16),
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 11,
                                            ),
                                          ),
                                      ],
                                    ),
                            )),
                      ],
                    ),
                  ),
                ] else ...[
                  // Add response section
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.reply,
                              color: Colors.grey.shade600,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Write Response:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: responseControllers[reviewId],
                          decoration: InputDecoration(
                            hintText: 'Write your response...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: Color(0xFF1A4D8F)),
                            ),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => _addResponse(reviewId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A4D8F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.send, size: 16),
                              SizedBox(width: 8),
                              Text('Submit Response'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Response status indicator
                if (hasResponse) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.green.shade600,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Response has been added to this review.',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header with gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1450A3), Color(0xFF1A4D8F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.rate_review_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Review Management",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFA500),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${filteredReviews.length} reviews',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                        });
                        _applyFilters();
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by user, ticket, or comment...',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon:
                            Icon(Icons.search, color: Colors.grey.shade600),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear,
                                    color: Colors.grey.shade600),
                                onPressed: () {
                                  setState(() {
                                    searchQuery = '';
                                  });
                                  _applyFilters();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab selector
            _buildTabSelector(),

            // Rating filter
            _buildRatingFilter(),

            // Success/Error messages
            if (successMessage != null) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        successMessage!,
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (errorMessage != null) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: Colors.red.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          errorMessage = null;
                        });
                      },
                      icon: Icon(Icons.close,
                          color: Colors.red.shade600, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],

            // Content area
            Expanded(
              child: isLoading
                  ? _buildLoadingState()
                  : filteredReviews.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadReviews,
                          color: const Color(0xFF1450A3),
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(0, 8, 0, 20),
                            itemCount: filteredReviews.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final review = filteredReviews[index];
                              return _buildReviewCard(review);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1450A3)),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading reviews...',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1450A3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.rate_review_outlined,
                    size: 48,
                    color: Color(0xFF1450A3),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'No Reviews Found',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A4D8F),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  searchQuery.isNotEmpty
                      ? 'No reviews match your search criteria.'
                      : selectedTab == 'Not Replied'
                          ? 'All reviews have been responded to.'
                          : 'No reviews available at the moment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _loadReviews,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1450A3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1450A3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        selectedItemColor: const Color(0xFFFFA500),
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/admin/ticket');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/admin/order');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_outlined),
            activeIcon: Icon(Icons.confirmation_number),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rate_review_outlined),
            activeIcon: Icon(Icons.rate_review),
            label: 'Reviews',
          ),
        ],
      ),
    );
  }
}

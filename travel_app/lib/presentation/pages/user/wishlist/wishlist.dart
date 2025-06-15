import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../widgets/wishlist_card.dart';
import 'package:travel_app/presentation/pages/user/home/destination_detail_page.dart';
import 'package:travel_app/services/wishlist_service.dart';
import 'package:travel_app/services/ticket_service.dart';
import 'package:intl/intl.dart';

const kPrimaryBlue = Color(0xFF154BCB);
const kSecondaryOrange = Color(0xFFFF8500);
const kCardBgColor = Color(0xFFF1F5FE);
const kBorderColor = Color(0xFFD8E0F2);
const kLightGrey = Color(0xFFE8E8E8);
const kTextGrey = Color(0xFF757575);

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<Map<String, dynamic>> wishlistItems = [];
  List<Map<String, dynamic>> filteredWishlistItems = [];
  int? userId;
  bool isLoading = true;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserAndFetchWishlist();
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
      _filterWishlist();
    });
  }

  void _filterWishlist() {
    if (searchQuery.isEmpty) {
      filteredWishlistItems = List.from(wishlistItems);
    } else {
      filteredWishlistItems = wishlistItems.where((item) {
        final ticket = item['ticket'];
        final name = (ticket['name'] ?? '').toString().toLowerCase();
        final location = (ticket['location'] ?? '').toString().toLowerCase();
        final query = searchQuery.toLowerCase();

        return name.contains(query) || location.contains(query);
      }).toList();
    }
  }

  String _formatPrice(dynamic price) {
    if (price == null) return 'Rp. 0';

    try {
      final numPrice = price is String ? int.parse(price) : price as int;
      final formatter = NumberFormat('#,##0', 'id_ID');
      return 'Rp. ${formatter.format(numPrice)}';
    } catch (e) {
      return 'Rp. $price';
    }
  }

  Future<void> _loadUserAndFetchWishlist() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getInt('userId');
    print("Stored userId in wishlist page: $storedUserId");

    if (storedUserId != null) {
      userId = storedUserId;
      await _fetchWishlist();
    } else {
      print("No userId found in SharedPreferences");
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchWishlist() async {
    if (userId == null) {
      print("UserId is null, cannot fetch wishlist");
      return;
    }

    try {
      print("Fetching wishlist for userId: $userId");
      final data = await WishlistService.getUserWishlist(userId!);
      print("Wishlist data received: $data");

      final mapped = data.map<Map<String, dynamic>>((item) {
        print("Processing wishlist item: $item");
        return {
          "wishlistId": item['wishlistId'],
          "ticketId": item['ticketId'],
          "ticket": item['ticket'],
        };
      }).toList();

      print("Mapped wishlist items: $mapped");

      setState(() {
        wishlistItems = mapped;
        _filterWishlist();
      });
    } catch (e) {
      print("Error fetching wishlist: $e");
      setState(() {
        wishlistItems = [];
        filteredWishlistItems = [];
      });
    }
  }

  Future<void> removeFromWishlist(int index) async {
    if (userId == null) return;

    final item = filteredWishlistItems[index];
    final ticketId = item['ticketId'];
    final ticketName = item['ticket']['name'] ?? 'item';

    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: kSecondaryOrange, size: 24),
            const SizedBox(width: 8),
            const Text('Hapus dari Wishlist', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "$ticketName" dari wishlist?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: kTextGrey,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Batal', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Hapus', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );

    if (shouldRemove != true) return;

    try {
      await WishlistService.removeFromWishlist(userId!, ticketId);

      // Find and remove from original list
      wishlistItems.removeWhere(
          (originalItem) => originalItem['ticketId'] == item['ticketId']);

      setState(() {
        _filterWishlist();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text("$ticketName dihapus dari wishlist"),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      print("Error removing from wishlist: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text("Gagal menghapus dari wishlist"),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
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
          hintText: 'Cari destinasi atau lokasi...',
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
              isSearching ? Icons.search_off : Icons.favorite_border,
              size: 64,
              color: kTextGrey,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isSearching ? "Tidak ada hasil pencarian" : "Belum ada wishlist",
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
                : "Tambahkan destinasi favorit Anda",
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
          "Wishlist",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: kPrimaryBlue,
          ),
        ),
        centerTitle: true,
        actions: [
          if (wishlistItems.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: kPrimaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${filteredWishlistItems.length}',
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
                          valueColor:
                              AlwaysStoppedAnimation<Color>(kPrimaryBlue),
                        ),
                      )
                    : filteredWishlistItems.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            itemCount: filteredWishlistItems.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final item = filteredWishlistItems[index];
                              final ticket = item["ticket"];

                              if (ticket == null) {
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text("Error: Ticket data not found"),
                                  ),
                                );
                              }

                              return Container(
                                decoration: BoxDecoration(
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
                                child: WishlistCard(
                                  imageUrl: ticket["image"] ?? "",
                                  title: ticket["name"] ?? "Unknown",
                                  location:
                                      ticket["location"] ?? "Unknown location",
                                  price: _formatPrice(ticket["price"]),
                                  onRemove: () => removeFromWishlist(index),
                                  onTap: () {
                                    final ticketData = item["ticket"];
                                    final ticketObject = Ticket(
                                      ticketId: ticketData["ticketId"] ?? 0,
                                      name: ticketData["name"] ?? "",
                                      price: ticketData["price"] ?? 0,
                                      capacity: ticketData["capacity"] ?? 0,
                                      description:
                                          ticketData["description"] ?? "",
                                      image: ticketData["image"] ?? "",
                                      location: ticketData["location"] ?? "",
                                      latitude: (ticketData["latitude"] ?? 0.0)
                                          .toDouble(),
                                      longitude:
                                          (ticketData["longitude"] ?? 0.0)
                                              .toDouble(),
                                      createdAt: ticketData["createdAt"] ?? "",
                                      updatedAt: ticketData["updatedAt"] ?? "",
                                    );

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DestinationDetailPage(
                                          ticket: ticketObject,
                                        ),
                                      ),
                                    );
                                  },
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

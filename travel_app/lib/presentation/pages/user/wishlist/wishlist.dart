import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../widgets/wishlist_card.dart';
import 'package:travel_app/presentation/pages/user/home/destination_detail_page.dart';
import '../../../widgets/search_bar.dart';
import 'package:travel_app/services/wishlist_service.dart';
import 'package:travel_app/services/ticket_service.dart';
// or wherever your Ticket class is defined

const kPrimaryBlue = Color(0xFF154BCB);
const kSecondaryOrange = Color(0xFFFF8500);
const kCardBgColor = Color(0xFFF1F5FE);
const kBorderColor = Color(0xFFD8E0F2);

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<Map<String, dynamic>> wishlistItems = [];
  int? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserAndFetchWishlist();
  }

  Future<void> _loadUserAndFetchWishlist() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();

    // Ambil userId langsung dari SharedPreferences
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
          "ticketId": item['ticketId'], // Tambahkan ini untuk referensi
          "ticket": item['ticket'], // simpan objek ticket utuh
        };
      }).toList();

      print("Mapped wishlist items: $mapped");

      setState(() {
        wishlistItems = mapped;
      });
    } catch (e) {
      print("Error fetching wishlist: $e");
      setState(() {
        wishlistItems = [];
      });
    }
  }

  Future<void> removeFromWishlist(int index) async {
    if (userId == null) return;

    final item = wishlistItems[index];
    final ticketId = item['ticketId'];
    final ticketName = item['ticket']['name'] ?? 'item';

    // Show confirmation dialog
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus dari Wishlist'),
        content: Text(
            'Apakah Anda yakin ingin menghapus "$ticketName" dari wishlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldRemove != true) return;

    try {
      // Hapus dari server
      await WishlistService.removeFromWishlist(userId!, ticketId);

      // Hapus dari UI
      setState(() {
        wishlistItems.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$ticketName dihapus dari wishlist")),
      );
    } catch (e) {
      print("Error removing from wishlist: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menghapus dari wishlist")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Center(
                    child: Text(
                      "Wishlist",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const SearchBarWidget(),
              const SizedBox(height: 16),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : wishlistItems.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.favorite_border,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "No wishlist items",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: wishlistItems.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = wishlistItems[index];
                              final ticket = item["ticket"];

                              if (ticket == null) {
                                return const Card(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text("Error: Ticket data not found"),
                                  ),
                                );
                              }

                              return WishlistCard(
                                imageUrl: ticket["image"] ?? "",
                                title: ticket["name"] ?? "Unknown",
                                location:
                                    ticket["location"] ?? "Unknown location",
                                price: "Rp. ${ticket["price"] ?? 0}",
                                onRemove: () => removeFromWishlist(index),
                                onTap: () {
                                  // Convert Map to Ticket object
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
                                    longitude: (ticketData["longitude"] ?? 0.0)
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

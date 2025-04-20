import 'package:flutter/material.dart';
import '../../../widgets/wishlist_card.dart';
import 'package:travel_app/presentation/pages/user/home/destination_detail_page.dart';

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
  List<Map<String, String>> wishlistItems = [
    {
      "imageUrl":
          "https://www.mongabay.co.id/wp-content/uploads/2022/04/iwan-dento-02-768x512.jpeg",
      "title": "Taman Margasatwa",
      "location": "Jakarta Selatan, Indonesia",
      "price": "Rp. 250.000"
    },
    {
      "imageUrl":
          "https://www.mongabay.co.id/wp-content/uploads/2022/04/iwan-dento-02-768x512.jpeg",
      "title": "Taman Hutan Raya",
      "location": "Bandung, Indonesia",
      "price": "Rp. 150.000"
    },
  ];

  void removeFromWishlist(int index) {
    setState(() {
      wishlistItems.removeAt(index);
    });
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Center(
  child: Text(
    "Wishlist",
    style: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: kPrimaryBlue,
    ),
  ),
                  ),
                ]
              ),
                                 

              const SizedBox(height: 16),

              // ✅ Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: kBorderColor),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search wishlist",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ✅ Wishlist Items
              Expanded(
                child: wishlistItems.isEmpty
                    ? const Center(child: Text("No wishlist items"))
                    : ListView.separated(
                        itemCount: wishlistItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = wishlistItems[index];
                          return WishlistCard(
                            imageUrl: item["imageUrl"]!,
                            title: item["title"]!,
                            location: item["location"]!,
                            price: item["price"]!,
                            onRemove: () => removeFromWishlist(index),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DestinationDetailPage(
                                    title: item["title"]!,
                                    location: item["location"]!,
                                    price: item["price"]!,
                                    rating: 4.5,
                                    imageUrl: item["imageUrl"]!,
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

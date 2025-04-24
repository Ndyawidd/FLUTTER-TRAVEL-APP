import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import '../../../widgets/wishlist_card.dart';
import 'package:travel_app/presentation/pages/user/home/destination_detail_page.dart';
import '../../../widgets/search_bar.dart';

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
  List<Map<String, dynamic>> wishlistItems = [
    {
      "imageUrl": "assets/images/labuanbajo.jpg",
      "title": "Labuan Bajo",
      "location": "Labuan Bajo, Indonesia",
      "price": "Rp. 500.000",
      "rating": 4.5,
      "details":
          "Liburan ke Laboan Bajo dengan fasilitas lengkap dan pemandangan indah.",
      "locLang": LatLng(-6.313800, 106.813400),
    },
    {
      "imageUrl": "assets/images/karimunjawa.jpg",
      "title": "Karimun Jawa",
      "location": "Karimun Jawa, Indonesia",
      "price": "Rp. 750.000",
      "rating": 4.2,
      "details": "Menjelajah pulau Karimun Jawa yang eksotis dan tenang.",
      "locLang": LatLng(-6.313800, 106.813400),
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
                                    title: item['title'],
                                    location: item['location'],
                                    price: item['price'],
                                    rating: item['rating'],
                                    imageUrl: item['imageUrl'],
                                    details: item['details'],
                                    locLang: item['locLang'],
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

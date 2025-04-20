import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../widgets/search_bar.dart';
import '../../../widgets/destination_tabbar.dart';
import '../../../widgets/destination_card.dart';
import '../wishlist/wishlist.dart';
import '../history/history.dart';
import '../profile/profile.dart';
import 'destination_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditampilkan sesuai indeks navbar
  final List<Widget> _pages = [
    const HomeContent(), // halaman home
    const WishlistPage(), // halaman wishlist
    const HistoryPage(), // halaman history
    const ProfilePage(), // halaman profile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFFE38E49),
        unselectedItemColor: Colors.grey,
        backgroundColor: Color(0xFF1F509A),
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: "Wishlist"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    // List of destinations with their details
    final List<Map<String, dynamic>> destinations = [
      {
        "title": "Ragunan Zoo",
        "location": "Jakarta Selatan, Indonesia",
        "price": "Rp 250.000",
        "rating": 4.5,
        "imageUrl":
            "https://www.mongabay.co.id/wp-content/uploads/2022/04/iwan-dento-02-768x512.jpeg",
        "details":
            "Ragunan Zoological Park is a large zoo in Jakarta featuring various animal species, including mammals, reptiles, and birds. It’s a great place for family visits and educational purposes.",
        "locLang": LatLng(-6.313800, 106.813400),
      },
      {
        "title": "Ragunan Zoo",
        "location": "Jakarta Selatan, Indonesia",
        "price": "Rp 250.000",
        "rating": 4.5,
        "imageUrl":
            "https://www.mongabay.co.id/wp-content/uploads/2022/04/iwan-dento-02-768x512.jpeg",
        "details":
            "Ragunan Zoological Park is a large zoo in Jakarta featuring various animal species, including mammals, reptiles, and birds. It’s a great place for family visits and educational purposes.",
        "locLang": LatLng(-6.313800, 106.813400),
      },
      {
        "title": "Ragunan Zoo",
        "location": "Jakarta Selatan, Indonesia",
        "price": "Rp 250.000",
        "rating": 4.5,
        "imageUrl":
            "https://www.mongabay.co.id/wp-content/uploads/2022/04/iwan-dento-02-768x512.jpeg",
        "details":
            "Ragunan Zoological Park is a large zoo in Jakarta featuring various animal species, including mammals, reptiles, and birds. It’s a great place for family visits and educational purposes.",
        "locLang": LatLng(-6.313800, 106.813400),
      },
      {
        "title": "Ragunan Zoo",
        "location": "Jakarta Selatan, Indonesia",
        "price": "Rp 250.000",
        "rating": 4.5,
        "imageUrl":
            "https://www.mongabay.co.id/wp-content/uploads/2022/04/iwan-dento-02-768x512.jpeg",
        "details":
            "Ragunan Zoological Park is a large zoo in Jakarta featuring various animal species, including mammals, reptiles, and birds. It’s a great place for family visits and educational purposes.",
        "locLang": LatLng(-6.313800, 106.813400),
      },
      {
        "title": "Ragunan Zoo",
        "location": "Jakarta Selatan, Indonesia",
        "price": "Rp 250.000",
        "rating": 4.5,
        "imageUrl":
            "https://www.mongabay.co.id/wp-content/uploads/2022/04/iwan-dento-02-768x512.jpeg",
        "details":
            "Ragunan Zoological Park is a large zoo in Jakarta featuring various animal species, including mammals, reptiles, and birds. It’s a great place for family visits and educational purposes.",
        "locLang": LatLng(-6.313800, 106.813400),
      },
      {
        "title": "Ragunan Zoo",
        "location": "Jakarta Selatan, Indonesia",
        "price": "Rp 250.000",
        "rating": 4.5,
        "imageUrl":
            "https://www.mongabay.co.id/wp-content/uploads/2022/04/iwan-dento-02-768x512.jpeg",
        "details":
            "Ragunan Zoological Park is a large zoo in Jakarta featuring various animal species, including mammals, reptiles, and birds. It’s a great place for family visits and educational purposes.",
        "locLang": LatLng(-6.313800, 106.813400),
      },
      {
        "title": "Ragunan Zoo",
        "location": "Jakarta Selatan, Indonesia",
        "price": "Rp 250.000",
        "rating": 4.5,
        "imageUrl":
            "https://www.mongabay.co.id/wp-content/uploads/2022/04/iwan-dento-02-768x512.jpeg",
        "details":
            "Ragunan Zoological Park is a large zoo in Jakarta featuring various animal species, including mammals, reptiles, and birds. It’s a great place for family visits and educational purposes.",
        "locLang": LatLng(-6.313800, 106.813400),
      },
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Halo, User !",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const SearchBarWidget(),
            const SizedBox(height: 20),
            const DestinationTabBar(),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                itemCount:
                    destinations.length, // Use the length of destinations list
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (context, index) {
                  var destination = destinations[
                      index]; // Get the specific destination details
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DestinationDetailPage(
                            title: destination['title'],
                            location: destination['location'],
                            price: destination['price'],
                            rating: destination['rating'],
                            imageUrl: destination['imageUrl'],
                            details: destination['details'],
                            locLang: destination['locLang'], // Pass LatLng here
                          ),
                        ),
                      );
                    },
                    child: DestinationCard(
                      title: destination['title'],
                      location: destination['location'],
                      price: destination['price'],
                      rating: destination['rating'],
                      imageUrl: destination['imageUrl'],
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

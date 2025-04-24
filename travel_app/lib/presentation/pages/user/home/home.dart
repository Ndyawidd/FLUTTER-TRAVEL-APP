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

  final List<Widget> _pages = [
    const HomeContent(),
    const WishlistPage(),
    const HistoryPage(),
    const ProfilePage(),
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
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFFFA500),
        unselectedItemColor: Colors.white,
        backgroundColor: const Color(0xFF1450A3),
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
        "title": "Labuan Bajo",
        "location": "Jakarta Selatan, Indonesia",
        "price": "Rp 250.000",
        "rating": 4.5,
        "imageUrl": 'assets/images/labuanbajo.jpg',
        "details":
            "Labuan Bajo is a fishing town located at the western end of the large island of Flores in the East Nusa Tenggara province of Indonesia. It is in Komodo District. It is the capital of the West Manggarai Regency, one of the eight regencies on Flores Island.",
        "locLang": LatLng(-6.313800, 106.813400),
      },
      {
        "title": "Labuan Bajo",
        "location": "Jakarta Selatan, Indonesia",
        "price": "Rp 250.000",
        "rating": 4.5,
        "imageUrl": 'assets/images/labuanbajo.jpg',
        "details":
            "Labuan Bajo is a fishing town located at the western end of the large island of Flores in the East Nusa Tenggara province of Indonesia. It is in Komodo District. It is the capital of the West Manggarai Regency, one of the eight regencies on Flores Island.",
        "locLang": LatLng(-6.313800, 106.813400),
      },
      {
        "title": "Labuan Bajo",
        "location": "Jakarta Selatan, Indonesia",
        "price": "Rp 250.000",
        "rating": 4.5,
        "imageUrl": 'assets/images/labuanbajo.jpg',
        "details":
            "Labuan Bajo is a fishing town located at the western end of the large island of Flores in the East Nusa Tenggara province of Indonesia. It is in Komodo District. It is the capital of the West Manggarai Regency, one of the eight regencies on Flores Island.",
        "locLang": LatLng(-6.313800, 106.813400),
      },
      {
        "title": "Labuan Bajo",
        "location": "Jakarta Selatan, Indonesia",
        "price": "Rp 250.000",
        "rating": 4.5,
        "imageUrl": 'assets/images/labuanbajo.jpg',
        "details":
            "Labuan Bajo is a fishing town located at the western end of the large island of Flores in the East Nusa Tenggara province of Indonesia. It is in Komodo District. It is the capital of the West Manggarai Regency, one of the eight regencies on Flores Island.",
        "locLang": LatLng(-6.313800, 106.813400),
      },
      {
        "title": "Labuan Bajo",
        "location": "Jakarta Selatan, Indonesia",
        "price": "Rp 250.000",
        "rating": 4.5,
        "imageUrl": 'assets/images/labuanbajo.jpg',
        "details":
            "Labuan Bajo is a fishing town located at the western end of the large island of Flores in the East Nusa Tenggara province of Indonesia. It is in Komodo District. It is the capital of the West Manggarai Regency, one of the eight regencies on Flores Island.",
        "locLang": LatLng(-6.313800, 106.813400),
      },
      {
        "title": "Labuan Bajo",
        "location": "Jakarta Selatan, Indonesia",
        "price": "Rp 250.000",
        "rating": 4.5,
        "imageUrl": 'assets/images/labuanbajo.jpg',
        "details":
            "Labuan Bajo is a fishing town located at the western end of the large island of Flores in the East Nusa Tenggara province of Indonesia. It is in Komodo District. It is the capital of the West Manggarai Regency, one of the eight regencies on Flores Island.",
        "locLang": LatLng(-6.313800, 106.813400),
      },
      {
        "title": "Labuan Bajo",
        "location": "Jakarta Selatan, Indonesia",
        "price": "Rp 250.000",
        "rating": 4.5,
        "imageUrl": 'assets/images/labuanbajo.jpg',
        "details":
            "Labuan Bajo is a fishing town located at the western end of the large island of Flores in the East Nusa Tenggara province of Indonesia. It is in Komodo District. It is the capital of the West Manggarai Regency, one of the eight regencies on Flores Island.",
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
                itemCount: destinations.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (context, index) {
                  var destination = destinations[index];
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

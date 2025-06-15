import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../widgets/search_bar.dart';
import '../../../widgets/destination_tabbar.dart';
import '../../../widgets/destination_card.dart';
import '../wishlist/wishlist.dart';
import '../history/history.dart';
import '../profile/profile.dart';
import 'destination_detail_page.dart';
import 'package:travel_app/services/ticket_service.dart';
import 'package:travel_app/services/wishlist_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<Ticket> _tickets = [];
  bool _isLoading = true;

  Set<int> _wishlistIds = {};

  @override
  void initState() {
    super.initState();
    loadTickets();
    loadWishlist(); // ini
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('userId');
    print("userId dari SharedPreferences: $id"); // Tambahkan ini
    return id;
  }

  // Ganti method toggleWishlist di _HomeContentState dengan ini:

  Future<void> toggleWishlist(int ticketId) async {
    final userId = await getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User belum login.")),
      );
      return;
    }

    try {
      if (_wishlistIds.contains(ticketId)) {
        print("Menghapus ticketId $ticketId dari wishlist");
        await WishlistService.removeFromWishlist(userId, ticketId);
        setState(() {
          _wishlistIds.remove(ticketId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Dihapus dari wishlist.")),
        );
      } else {
        print("Menambahkan ticketId $ticketId ke wishlist");
        await WishlistService.addToWishlist(userId, ticketId);
        setState(() {
          _wishlistIds.add(ticketId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ditambahkan ke wishlist.")),
        );
      }
    } catch (e) {
      print("Wishlist toggle error: $e");

      // Refresh wishlist state dari server untuk memastikan sinkronisasi
      await loadWishlist();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: ${e.toString()}")),
      );
    }
  }

  Future<void> loadTickets() async {
    final tickets = await TicketService.fetchTickets();
    setState(() {
      _tickets = tickets;
      _isLoading = false;
    });
  }

  // Ganti method loadWishlist di _HomeContentState dengan ini:

  Future<void> loadWishlist() async {
    final userId = await getUserId();
    if (userId == null) return;

    try {
      final wishlist = await WishlistService.getUserWishlist(userId);
      print("Fetched wishlist: $wishlist");

      setState(() {
        // Setiap item dalam wishlist adalah Map<String, dynamic>
        // Kita perlu mengakses nilai 'ticketId' dari map tersebut
        _wishlistIds = wishlist
            .map((item) => item['ticketId'] as int?)
            .where((ticketId) => ticketId != null)
            .cast<int>()
            .toSet();
      });

      print("Processed wishlist IDs: $_wishlistIds");
    } catch (e) {
      print("Error loading wishlist: $e");
      // Jika error, set empty set
      setState(() {
        _wishlistIds = <int>{};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      itemCount: _tickets.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemBuilder: (context, index) {
                        final ticket = _tickets[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DestinationDetailPage(ticket: ticket),
                              ),
                            );
                          },
                          child: DestinationCard(
                            title: ticket.name,
                            location: ticket.location,
                            price: 'Rp ${ticket.price}',
                            rating: 4.5,
                            imageUrl: ticket.image,
                            isWishlisted:
                                _wishlistIds.contains(ticket.ticketId),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DestinationDetailPage(ticket: ticket),
                                ),
                              );
                            },
                            onWishlistToggle: () {
                              toggleWishlist(ticket.ticketId);
                            },
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

import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
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
import 'package:geolocator/geolocator.dart';

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
  List<Ticket> _sortedTickets = [];
  bool _isLoading = true;
  String _selectedSort = "Popular"; // Default sort
  String _searchQuery = "";
  String _userName = '';

  Set<int> _wishlistIds = {};

  @override
  void initState() {
    super.initState();
    loadTickets();
    loadWishlist();
    loadUserName();
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('userId');
    print("userId dari SharedPreferences: $id");
    return id;
  }

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
      await loadWishlist();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: ${e.toString()}")),
      );
    }
  }

  Future<void> loadTickets() async {
    setState(() {
      _isLoading = true;
    });

    final tickets = await TicketService.fetchTickets();
    setState(() {
      _tickets = tickets;
      _isLoading = false;
    });

    // Apply current sorting after loading tickets
    applySorting(_selectedSort);
  }

  Future<void> loadWishlist() async {
    final userId = await getUserId();
    if (userId == null) return;

    try {
      final wishlist = await WishlistService.getUserWishlist(userId);
      print("Fetched wishlist: $wishlist");

      setState(() {
        _wishlistIds = wishlist
            .map((item) => item['ticketId'] as int?)
            .where((ticketId) => ticketId != null)
            .cast<int>()
            .toSet();
      });

      print("Processed wishlist IDs: $_wishlistIds");
    } catch (e) {
      print("Error loading wishlist: $e");
      setState(() {
        _wishlistIds = <int>{};
      });
    }
  }

  void loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('userName');
    if (name != null && name.isNotEmpty) {
      setState(() {
        _userName = name;
      });
    }
  }

  void applySorting(String sortType) {
    setState(() {
      _selectedSort = sortType;
      List<Ticket> tickets = List.from(_tickets);

      switch (sortType) {
        case "Popular":
          _sortedTickets = tickets;
          break;

        case "New":
          tickets.sort((a, b) {
            // Jika ada field createdAt atau dateAdded di model Ticket
            // return b.createdAt.compareTo(a.createdAt);

            // Untuk sementara, urutkan berdasarkan ticketId (asumsi ID lebih besar = lebih baru)
            return b.ticketId.compareTo(a.ticketId);
          });
          _sortedTickets = tickets;
          break;

        case "Price":
          // Sort by rating (tertinggi dulu)
          tickets.sort((a, b) {
            // Jika ada field rating di model Ticket
            // return b.rating.compareTo(a.rating);

            // Untuk sementara, karena rating belum ada di model,
            // kita bisa sort berdasarkan price (asumsi harga tinggi = rating tinggi)
            // atau random sort untuk demo
            return b.price.compareTo(a.price);
          });
          _sortedTickets = tickets;
          break;

        case "Near You":
          // Sort by distance (jika ada koordinat)
          // Untuk sementara, sama dengan Popular

          _sortByDistance(tickets);
          break;

        default:
          _sortedTickets = tickets;
      }

      // Apply search filter if there's a search query
      if (_searchQuery.isNotEmpty) {
        applySearchFilter(_searchQuery);
      }
    });
  }

  void _sortByDistance(List<Ticket> tickets) async {
    try {
      // Pastikan izin lokasi aktif
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Layanan lokasi tidak aktif.")),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Izin lokasi ditolak secara permanen.")),
          );
          return;
        }
      }

      // Ambil posisi pengguna
      final Position userPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Hitung jarak untuk setiap tiket dan urutkan
      tickets.sort((a, b) {
        final double distanceA = Geolocator.distanceBetween(
          userPosition.latitude,
          userPosition.longitude,
          a.latitude,
          a.longitude,
        );

        final double distanceB = Geolocator.distanceBetween(
          userPosition.latitude,
          userPosition.longitude,
          b.latitude,
          b.longitude,
        );

        return distanceA.compareTo(distanceB); // ascending
      });

      setState(() {
        _sortedTickets = tickets;
      });

      // Kalau ada query pencarian, filter ulang
      if (_searchQuery.isNotEmpty) {
        applySearchFilter(_searchQuery);
      }
    } catch (e) {
      print("Gagal sort berdasarkan lokasi: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menentukan lokasi.")),
      );
    }
  }

  void applySearchFilter(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
      } else {
        _sortedTickets = _sortedTickets.where((ticket) {
          return ticket.name.toLowerCase().contains(query.toLowerCase()) ||
              ticket.location.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void onSortSelected(String sortType) {
    applySorting(sortType);
  }

  void onSearchChanged(String query) {
    applySorting(_selectedSort);
    applySearchFilter(query);
  }

  Future<void> onRefresh() async {
    await loadTickets();
    await loadWishlist();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, $_userName !',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SearchBarWidget(
                onSearchChanged: onSearchChanged,
              ),
              const SizedBox(height: 20),
              DestinationTabBar(
                selectedSort: _selectedSort,
                onSortSelected: onSortSelected,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      _getSortIcon(_selectedSort),
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Menampilkan: $_selectedSort${_searchQuery.isNotEmpty ? ' - "${_searchQuery}"' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_sortedTickets.length} destinasi',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _sortedTickets.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'Tidak ada destinasi ditemukan untuk "${_searchQuery}"'
                                      : 'Tidak ada destinasi tersedia',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (_searchQuery.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () => onSearchChanged(''),
                                    child: const Text('Hapus filter pencarian'),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : GridView.builder(
                            itemCount: _sortedTickets.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.72,
                            ),
                            itemBuilder: (context, index) {
                              final ticket = _sortedTickets[index];
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
                                            DestinationDetailPage(
                                                ticket: ticket),
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
      ),
    );
  }

  IconData _getSortIcon(String sortType) {
    switch (sortType) {
      case "Popular":
        return Icons.trending_up;
      case "New":
        return Icons.new_releases;
      case "Price":
        return Icons.price_change;
      case "Near You":
        return Icons.location_on;
      default:
        return Icons.explore;
    }
  }
}

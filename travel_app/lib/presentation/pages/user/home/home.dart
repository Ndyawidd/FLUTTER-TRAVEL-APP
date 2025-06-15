import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../widgets/search_bar.dart';
import '../../../widgets/destination_tabbar.dart';
import '../../../widgets/destination_card.dart';
import '../wishlist/wishlist.dart';
import '../history/history.dart';
import '../profile/profile.dart';
import 'destination_detail_page.dart';
import 'package:intl/intl.dart';
import 'package:travel_app/services/ticket_service.dart';
import 'package:travel_app/services/wishlist_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_app/services/review_service.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

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
  Map<int, double> _ticketRatings = {};
  Map<int, int> _ticketReviewCounts = {};

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

  Future<void> loadTicketRatings() async {
    Map<int, double> ratings = {};
    Map<int, int> reviewCounts = {};

    for (Ticket ticket in _tickets) {
      try {
        double avgRating =
            await ReviewService.getAverageRating(ticket.ticketId);
        final reviews =
            await ReviewService.getReviewsByTicketId(ticket.ticketId);

        ratings[ticket.ticketId] = avgRating;
        reviewCounts[ticket.ticketId] = reviews.length;
      } catch (e) {
        print("Error loading rating for ticket ${ticket.ticketId}: $e");
        ratings[ticket.ticketId] = 0.0;
        reviewCounts[ticket.ticketId] = 0;
      }
    }

    setState(() {
      _ticketRatings = ratings;
      _ticketReviewCounts = reviewCounts;
    });
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

    await loadTicketRatings();
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

        case "Top Rated":
          tickets.sort((a, b) {
            double ratingA = _ticketRatings[a.ticketId] ?? 0.0;
            double ratingB = _ticketRatings[b.ticketId] ?? 0.0;

            int result = ratingB.compareTo(ratingA);

            // Jika rating sama, sort berdasarkan nama
            if (result == 0) {
              return a.name.compareTo(b.name);
            }

            return result;
          });
          _sortedTickets = tickets;
          break;

        case "Near You":
          _sortByDistance(tickets);
          break;

        default:
          _sortedTickets = tickets;
      }

      if (_searchQuery.isNotEmpty) {
        applySearchFilter(_searchQuery);
      }
    });
  }

  void _sortByDistance(List<Ticket> tickets) async {
    try {
      // 1. Cek apakah location service aktif
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Layanan lokasi tidak aktif. Silakan aktifkan GPS di pengaturan."),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      // 2. Cek dan request permission dengan handling yang lebih baik
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // Request permission pertama kali
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text("Izin akses lokasi diperlukan untuk fitur 'Near You'."),
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permission ditolak permanen, arahkan ke settings
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                "Izin lokasi ditolak permanen. Silakan aktifkan di pengaturan aplikasi."),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Pengaturan',
              onPressed: () async {
                await Geolocator.openAppSettings();
              },
            ),
          ),
        );
        return;
      }

      // 3. Tampilkan loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text("Mengambil lokasi Anda..."),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // 4. Ambil posisi dengan timeout
      final Position userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15), // Timeout 15 detik
      );

      print(
          "User position: ${userPosition.latitude}, ${userPosition.longitude}");

      // 5. Hitung jarak dan urutkan
      List<TicketWithDistance> ticketsWithDistance = tickets.map((ticket) {
        final double distance = Geolocator.distanceBetween(
          userPosition.latitude,
          userPosition.longitude,
          ticket.latitude,
          ticket.longitude,
        );

        return TicketWithDistance(ticket: ticket, distance: distance);
      }).toList();

      // Sort berdasarkan jarak (ascending)
      ticketsWithDistance.sort((a, b) => a.distance.compareTo(b.distance));

      // Extract tickets yang sudah diurutkan
      List<Ticket> sortedTickets =
          ticketsWithDistance.map((item) => item.ticket).toList();

      setState(() {
        _sortedTickets = sortedTickets;
      });

      // 6. Tampilkan feedback sukses
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text("Menampilkan ${sortedTickets.length} destinasi terdekat"),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // 7. Apply search filter jika ada
      if (_searchQuery.isNotEmpty) {
        applySearchFilter(_searchQuery);
      }
    } on LocationServiceDisabledException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Layanan lokasi dinonaktifkan. Silakan aktifkan GPS."),
          duration: Duration(seconds: 3),
        ),
      );
    } on PermissionDeniedException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Izin akses lokasi ditolak."),
          duration: Duration(seconds: 3),
        ),
      );
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Timeout saat mengambil lokasi. Coba lagi."),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print("Error saat sort berdasarkan lokasi: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal mengambil lokasi: ${e.toString()}"),
          duration: const Duration(seconds: 3),
        ),
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
                                  ticketId: ticket.ticketId,
                                  title: ticket.name,
                                  location: ticket.location,
                                  price:
                                      'Rp ${NumberFormat('#,##0', 'id_ID').format(ticket.price)}',
                                  imageUrl: ticket.image,
                                  isWishlisted:
                                      _wishlistIds.contains(ticket.ticketId),
                                  // Pass rating data dari parent ke child
                                  averageRating:
                                      _ticketRatings[ticket.ticketId] ?? 0.0,
                                  reviewCount:
                                      _ticketReviewCounts[ticket.ticketId] ?? 0,
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
      case "Top Rated":
        return Icons.star;
      case "Near You":
        return Icons.location_on;
      default:
        return Icons.explore;
    }
  }
}

// Helper class untuk menyimpan ticket dengan jarak
class TicketWithDistance {
  final Ticket ticket;
  final double distance;

  TicketWithDistance({required this.ticket, required this.distance});
}

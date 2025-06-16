// lib/presentation/pages/user/home/home.dart
import 'package:flutter/material.dart';
// import 'package:Maps_flutter/Maps_flutter.dart';
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
import '../../../widgets/alert_utils.dart';

const kPrimaryBlue = Color(0xFF154BCB);
const kSecondaryOrange = Color(0xFFFF8500);
const kCardBgColor = Color(0xFFF1F5FE);
const kBorderColor = Color(0xFFD8E0F2);
const kLightGrey = Color(0xFFE8E8E8);
const kTextGrey = Color(0xFF757575);
const kBackgroundColor = Color(0xFFFAFAFA);

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
        selectedItemColor: kSecondaryOrange,
        unselectedItemColor: Colors.white,
        backgroundColor: kPrimaryBlue,
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
  String _selectedSort = "Popular";
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
      DialogUtils.showErrorDialog(
        context: context,
        title: "Login Diperlukan",
        message: "Silakan login terlebih dahulu untuk menambahkan ke wishlist.",
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
        DialogUtils.showSuccessDialog(
          context: context,
          title: "Berhasil",
          message: "Destinasi berhasil dihapus dari wishlist.",
          autoDismissAfter: const Duration(seconds: 2),
        );
      } else {
        print("Menambahkan ticketId $ticketId ke wishlist");
        await WishlistService.addToWishlist(userId, ticketId);
        setState(() {
          _wishlistIds.add(ticketId);
        });
        DialogUtils.showSuccessDialog(
          context: context,
          title: "Berhasil",
          message: "Destinasi berhasil ditambahkan ke wishlist.",
          autoDismissAfter: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      print("Wishlist toggle error: $e");
      await loadWishlist();
      DialogUtils.showErrorDialog(
        context: context,
        title: "Terjadi Kesalahan",
        message: "Gagal memperbarui wishlist: ${e.toString()}",
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

    try {
      final tickets = await TicketService.fetchTickets();
      final availableTickets =
          tickets.where((ticket) => ticket.capacity > 0).toList();
      setState(() {
        _tickets = availableTickets;
        _isLoading = false;
      });

      await loadTicketRatings();
      applySorting(_selectedSort);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _tickets = [];
        _sortedTickets = [];
      });
      DialogUtils.showErrorDialog(
        context: context,
        title: "Gagal Memuat Destinasi",
        message: "Terjadi kesalahan saat memuat destinasi: ${e.toString()}",
      );
    }
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
            return b.ticketId.compareTo(a.ticketId);
          });
          _sortedTickets = tickets;
          break;

        case "Top Rated":
          tickets.sort((a, b) {
            double ratingA = _ticketRatings[a.ticketId] ?? 0.0;
            double ratingB = _ticketRatings[b.ticketId] ?? 0.0;

            int result = ratingB.compareTo(ratingA);

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
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        DialogUtils.showWarningDialog(
          context: context,
          title: "GPS Tidak Aktif",
          message:
              "Layanan lokasi tidak aktif. Silakan aktifkan GPS di pengaturan untuk menggunakan fitur 'Near You'.",
          confirmText: "Pengaturan",
          cancelText: "Batal",
          onConfirm: () async {
            await Geolocator.openLocationSettings();
          },
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          DialogUtils.showWarningDialog(
            context: context,
            title: "Izin Lokasi Diperlukan",
            message:
                "Aplikasi memerlukan izin akses lokasi untuk menampilkan destinasi terdekat dengan Anda.",
            confirmText: "Coba Lagi",
            cancelText: "Batal",
            onConfirm: () {
              _sortByDistance(tickets);
            },
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        DialogUtils.showWarningDialog(
          context: context,
          title: "Izin Lokasi Ditolak",
          message:
              "Izin lokasi ditolak permanen. Silakan aktifkan izin lokasi melalui pengaturan aplikasi untuk menggunakan fitur ini.",
          confirmText: "Buka Pengaturan",
          cancelText: "Batal",
          onConfirm: () async {
            await Geolocator.openAppSettings();
          },
        );
        return;
      }

      DialogUtils.showLoadingDialog(
        context: context,
        message: "Mengambil lokasi Anda...",
      );

      final Position userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      print(
          "User position: ${userPosition.latitude}, ${userPosition.longitude}");

      List<TicketWithDistance> ticketsWithDistance = tickets.map((ticket) {
        final double distance = Geolocator.distanceBetween(
          userPosition.latitude,
          userPosition.longitude,
          ticket.latitude,
          ticket.longitude,
        );

        return TicketWithDistance(ticket: ticket, distance: distance);
      }).toList();

      ticketsWithDistance.sort((a, b) => a.distance.compareTo(b.distance));

      List<Ticket> sortedTickets =
          ticketsWithDistance.map((item) => item.ticket).toList();

      setState(() {
        _sortedTickets = sortedTickets;
      });

      if (mounted) {
        DialogUtils.dismissDialog(context);
      }

      if (_searchQuery.isNotEmpty) {
        applySearchFilter(_searchQuery);
      }
    } on LocationServiceDisabledException {
      DialogUtils.dismissDialog(context);
      DialogUtils.showWarningDialog(
        context: context,
        title: "GPS Tidak Aktif",
        message:
            "Layanan lokasi dinonaktifkan. Silakan aktifkan GPS untuk menggunakan fitur ini.",
        confirmText: "Pengaturan",
        cancelText: "Batal",
        onConfirm: () async {
          await Geolocator.openLocationSettings();
        },
      );
    } on PermissionDeniedException {
      DialogUtils.dismissDialog(context);
      DialogUtils.showErrorDialog(
        context: context,
        title: "Izin Ditolak",
        message:
            "Izin akses lokasi ditolak. Fitur 'Near You' tidak dapat digunakan.",
      );
    } on TimeoutException {
      DialogUtils.dismissDialog(context);
      DialogUtils.showWarningDialog(
        context: context,
        title: "Timeout",
        message:
            "Gagal mengambil lokasi dalam waktu yang ditentukan. Pastikan Anda berada di area dengan sinyal GPS yang baik.",
        confirmText: "Coba Lagi",
        cancelText: "Batal",
        onConfirm: () {
          _sortByDistance(tickets);
        },
      );
    } catch (e) {
      print("Error saat sort berdasarkan lokasi: $e");
      DialogUtils.dismissDialog(context);
      DialogUtils.showErrorDialog(
        context: context,
        title: "Gagal Mengambil Lokasi",
        message: "Terjadi kesalahan saat mengambil lokasi: ${e.toString()}",
      );
    }
  }

  void applySearchFilter(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        applySorting(_selectedSort);
      } else {
        _sortedTickets = _tickets.where((ticket) {
          return ticket.name.toLowerCase().contains(query.toLowerCase()) ||
              ticket.location.toLowerCase().contains(query.toLowerCase());
        }).toList();

        List<Ticket> tempFilteredTickets = List.from(_sortedTickets);
        switch (_selectedSort) {
          case "Popular":
            break;
          case "New":
            tempFilteredTickets
                .sort((a, b) => b.ticketId.compareTo(a.ticketId));
            break;
          case "Top Rated":
            tempFilteredTickets.sort((a, b) {
              double ratingA = _ticketRatings[a.ticketId] ?? 0.0;
              double ratingB = _ticketRatings[b.ticketId] ?? 0.0;
              int result = ratingB.compareTo(ratingA);
              if (result == 0) {
                return a.name.compareTo(b.name);
              }
              return result;
            });
            break;
          case "Near You":
            break;
        }
        _sortedTickets = tempFilteredTickets;
      }
    });
  }

  void onSortSelected(String sortType) {
    applySorting(sortType);
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    applySorting(_selectedSort);
  }

  Future<void> onRefresh() async {
    await loadTickets();
    await loadWishlist();
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kPrimaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.waving_hand,
              color: kSecondaryOrange,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, $_userName!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: kCardBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(
            _getSortIcon(_selectedSort),
            size: 16,
            color: kPrimaryBlue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Menampilkan: $_selectedSort${_searchQuery.isNotEmpty ? ' - "${_searchQuery}"' : ''}',
              style: const TextStyle(
                fontSize: 13,
                color: kPrimaryBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: kPrimaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_sortedTickets.length}',
              style: const TextStyle(
                fontSize: 12,
                color: kPrimaryBlue,
                fontWeight: FontWeight.w600,
              ),
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kCardBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.explore_off,
              size: 64,
              color: kTextGrey,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isNotEmpty
                ? 'Tidak ada destinasi ditemukan'
                : 'Tidak ada destinasi tersedia',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'untuk "${_searchQuery}"'
                : 'Coba lagi nanti',
            style: TextStyle(
              fontSize: 16,
              color: kTextGrey,
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => onSearchChanged(''),
              icon: const Icon(Icons.clear),
              label: const Text('Hapus filter pencarian'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: onRefresh,
          color: kPrimaryBlue,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeHeader(),
                const SizedBox(height: 20),
                SearchBarWidget(
                  onSearchChanged: onSearchChanged,
                ),
                const SizedBox(height: 20),
                DestinationTabBar(
                  selectedSort: _selectedSort,
                  onSortSelected: onSortSelected,
                ),
                const SizedBox(height: 16),
                _buildStatsInfo(),
                const SizedBox(height: 8),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(kPrimaryBlue),
                          ),
                        )
                      : _sortedTickets.isEmpty
                          ? _buildEmptyState()
                          : GridView.builder(
                              itemCount: _sortedTickets.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
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
                                            DestinationDetailPage(
                                                ticket: ticket),
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
                                    averageRating:
                                        _ticketRatings[ticket.ticketId] ?? 0.0,
                                    reviewCount:
                                        _ticketReviewCounts[ticket.ticketId] ??
                                            0,
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

class TicketWithDistance {
  final Ticket ticket;
  final double distance;

  TicketWithDistance({required this.ticket, required this.distance});
}

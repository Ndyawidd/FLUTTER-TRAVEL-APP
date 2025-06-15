import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'booking_page.dart';
import 'map_page.dart';
import 'package:travel_app/services/ticket_service.dart';
import 'package:travel_app/services/review_service.dart';

class DestinationDetailPage extends StatefulWidget {
  final Ticket ticket;

  const DestinationDetailPage({super.key, required this.ticket});

  @override
  State<DestinationDetailPage> createState() => _DestinationDetailPageState();
}

class _DestinationDetailPageState extends State<DestinationDetailPage> {
  List<Review> reviews = [];
  double averageRating = 0.0;
  bool isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      isLoadingReviews = true;
    });

    try {
      final fetchedReviews =
          await ReviewService.getReviewsByTicketId(widget.ticket.ticketId);
      final avgRating =
          await ReviewService.getAverageRating(widget.ticket.ticketId);

      setState(() {
        reviews = fetchedReviews;
        averageRating = avgRating;
        isLoadingReviews = false;
      });
    } catch (e) {
      setState(() {
        isLoadingReviews = false;
      });
      print('Error loading reviews: $e');
    }
  }

  String _formatPrice(dynamic price) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Handle different price types
    if (price is String) {
      final numPrice = double.tryParse(price) ?? 0;
      return formatter.format(numPrice);
    } else if (price is num) {
      return formatter.format(price);
    }
    return 'Rp 0';
  }

  String _getStarDisplay(int rating) {
    return '⭐' * rating + '☆' * (5 - rating);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Destination Detail"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.ticket.image,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 100),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Judul dan Harga
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.ticket.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  "Rp ${widget.ticket.price}",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
              ],
            ),

            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                Expanded(
                  child: Text(widget.ticket.location,
                      style: const TextStyle(color: Colors.grey)),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Info box dengan rating dinamis
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFFE7F1F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(children: [
                    const Icon(Icons.star),
                    Text(
                      "${averageRating.toStringAsFixed(1)}\n${reviews.length} Reviews",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    )
                  ]),
                  Column(children: const [
                    Icon(Icons.favorite),
                    Text("123\nWishlists",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12))
                  ]),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Text(
              widget.ticket.description,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Reviews",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (!isLoadingReviews)
                  TextButton(
                    onPressed: _loadReviews,
                    child: const Text("Refresh"),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Reviews section
            if (isLoadingReviews)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (reviews.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFFE7F1F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    "Belum ada review untuk destinasi ini",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Column(
                children: [
                  // Tampilkan maksimal 4 review pertama
                  ...reviews.take(4).map((review) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFFE7F1F6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "${_getStarDisplay(review.rating)} ${review.rating}/5 - ${review.userName}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  _formatDate(review.createdAt),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              review.comment,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      )),

                  // Tombol lihat semua review jika ada lebih dari 4
                  if (reviews.length > 4)
                    TextButton(
                      onPressed: () {
                        _showAllReviews(context);
                      },
                      child: Text("Lihat semua ${reviews.length} review"),
                    ),
                ],
              ),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapPage(
                            locLang: LatLng(widget.ticket.latitude,
                                widget.ticket.longitude),
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: Color(0xFF1F509A), width: 2.0),
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xFF1F509A),
                    ),
                    child: const Text("Map"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BookingPage(ticketId: widget.ticket.ticketId),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1F509A),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Book Ticket"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAllReviews(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                "Semua Review",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFFE7F1F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  "${_getStarDisplay(review.rating)} ${review.rating}/5 - ${review.userName}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                _formatDate(review.createdAt),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(review.comment),
                        ],
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

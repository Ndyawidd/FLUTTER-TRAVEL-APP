import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'booking_page.dart';
import 'map_page.dart';
import 'reviews_list.dart';
import 'package:travel_app/services/ticket_service.dart';
import 'package:travel_app/services/review_service.dart';

const kPrimaryBlue = Color(0xFF154BCB);
const kSecondaryOrange = Color(0xFFFF8500);
const kCardBgColor = Color(0xFFF8F9FA);
const kBorderColor = Color(0xFFE5E7EB);
const kTextGrey = Color(0xFF6B7280);

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
    setState(() => isLoadingReviews = true);

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
      setState(() => isLoadingReviews = false);
      print('Error loading reviews: $e');
    }
  }

  String _formatPrice(dynamic price) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    if (price is String) {
      return formatter.format(double.tryParse(price) ?? 0);
    } else if (price is num) {
      return formatter.format(price);
    }
    return 'Rp 0';
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ...List.generate(
                      5,
                      (index) => Icon(
                            index < review.rating
                                ? Icons.star
                                : Icons.star_border,
                            size: 14,
                            color: kSecondaryOrange,
                          )),
                  const SizedBox(width: 8),
                  Text(
                    review.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Text(
                DateFormat('dd/MM/yy').format(review.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: kTextGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            review.comment,
            style: const TextStyle(fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Detail Destinasi",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: kPrimaryBlue,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.ticket.image,
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 140,
                      color: kCardBgColor,
                      child: Icon(Icons.broken_image, color: kTextGrey),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.ticket.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  size: 12, color: kTextGrey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.ticket.location,
                                  style:
                                      TextStyle(color: kTextGrey, fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatPrice(widget.ticket.price),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: kSecondaryOrange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kCardBgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.star,
                                  color: kSecondaryOrange, size: 16),
                              const SizedBox(width: 4),
                              isLoadingReviews
                                  ? const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 1.5),
                                    )
                                  : Text(
                                      "${averageRating.toStringAsFixed(1)} (${reviews.length})",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 20, color: kBorderColor),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.group, color: kPrimaryBlue, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                "${widget.ticket.capacity} orang",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Deskripsi",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.ticket.description,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Review",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if (reviews.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReviewsListPage(
                                  ticketId: widget.ticket.ticketId,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            "Lihat Semua",
                            style: TextStyle(
                              color: kPrimaryBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (isLoadingReviews)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else if (reviews.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kCardBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          "Belum ada review",
                          style: TextStyle(color: kTextGrey, fontSize: 13),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: reviews.take(3).map(_buildReviewCard).toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapPage(
                          locLang: LatLng(
                              widget.ticket.latitude, widget.ticket.longitude),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: const Text("Peta", style: TextStyle(fontSize: 14)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: kBorderColor),
                    foregroundColor: Colors.black87,
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
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
                    backgroundColor: kPrimaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Pesan Tiket",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'booking_page.dart';
import 'map_page.dart';

class DestinationDetailPage extends StatelessWidget {
  final String title;
  final String location;
  final String price;
  final double rating;
  final String imageUrl;
  final String details;
  final LatLng locLang;

  const DestinationDetailPage({
    super.key,
    required this.title,
    required this.location,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.details,
    required this.locLang,
  });

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
                child: Image.asset(
                  imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Judul dan Harga
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  price,
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
                Text(location, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),

            // Info box
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
                    Text("$rating\nReviews", textAlign: TextAlign.center)
                  ]),
                  Column(children: const [
                    Icon(Icons.favorite),
                    Text("123\nWishlists", textAlign: TextAlign.center)
                  ]),
                ],
              ),
            ),

            const SizedBox(height: 16),
            // Display detailed information about the destination
            Text(
              details, // Display the detailed string here
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),

            const SizedBox(height: 16),
            const Text("Comments",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFE7F1F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: const [
                        Text("⭐ 4/5 - Lee Haechan",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("Tempatnya asik untuk pergi bersama keluarga"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFE7F1F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: const [
                        Text("⭐ 4/5 - Lee Haechan",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("Tempatnya asik untuk pergi bersama keluarga"),
                      ],
                    ),
                  ),
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
                            locLang:
                                locLang, // Pass the LatLng coordinates to the MapPage
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: Color(0xFF1F509A), width: 2.0), // Border color
                      backgroundColor:
                          Colors.white, // Background color of the button
                      foregroundColor:
                          Color(0xFF1F509A), // Text color (for Map button)
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
                          builder: (context) => BookingPage(
                            destination:
                                title, // Pass only the destination title
                            date: "", // You can leave the date empty initially
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color(0xFF1F509A), // Background color of the button
                      foregroundColor:
                          Colors.white, // Text color (for Book Ticket button)
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
}

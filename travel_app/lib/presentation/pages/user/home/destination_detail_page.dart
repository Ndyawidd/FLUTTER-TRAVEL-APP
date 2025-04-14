import 'package:flutter/material.dart';
import 'booking_page.dart';

class DestinationDetailPage extends StatelessWidget {
  final String title;
  final String location;
  final String price;
  final double rating;
  final String imageUrl;

  const DestinationDetailPage({
    super.key,
    required this.title,
    required this.location,
    required this.price,
    required this.rating,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Destination Detail"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(imageUrl),
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(children: const [
                    Icon(Icons.calendar_today),
                    Text("Open\nEveryday", textAlign: TextAlign.center)
                  ]),
                  Column(children: [
                    const Icon(Icons.star),
                    Text("$rating\nreviews", textAlign: TextAlign.center)
                  ]),
                  Column(children: const [
                    Icon(Icons.favorite),
                    Text("123\nWishlists", textAlign: TextAlign.center)
                  ]),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              "Ragunan Zoological Park...",
              style: TextStyle(fontSize: 14, color: Colors.black87),
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
                      color: Colors.yellow.shade100,
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
                      color: Colors.red.shade100,
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
                    onPressed: () {},
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
                          builder: (context) => const BookingPage(
                            destination: "Taman Margasatwa",
                            date: "Wednesday, 28 March 2025",
                          ),
                        ),
                      );
                    },
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

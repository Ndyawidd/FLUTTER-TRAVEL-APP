// import 'package:flutter/material.dart';

// class TicketDetailPage extends StatelessWidget {
//   final String name;
//   final String capacity;
//   final String price;
//   final String image;
//   final String description;

//   const TicketDetailPage({
//     super.key,
//     required this.name,
//     required this.capacity,
//     required this.price,
//     required this.image,
//     required this.description,
//   });

//   @override
//   Widget build(BuildContext context) {
//     print('Detail image URL: $image\n\n\n\n');
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFFFFA500)),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         elevation: 0,
//         title: const Text(
//           'Ticket Details',
//           style: TextStyle(
//             color: Color(0xFF1450A3),
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Show network image instead of asset image
//             Center(
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.network(
//                   image,
//                   width: double.infinity,
//                   height: 200,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) {
//                     return Image.asset(
//                       'assets/images/placeholder.jpg',
//                       width: double.infinity,
//                       height: 200,
//                       fit: BoxFit.cover,
//                     );
//                   },
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             buildInfoItem("Name", name),
//             buildInfoItem("Capacity", capacity),
//             buildInfoItem("Price", price),
//             buildInfoItem("Description", description),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildInfoItem(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               color: Color(0xFF1450A3),
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: const TextStyle(
//               color: Colors.black87,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_page.dart';

class TicketDetailPage extends StatelessWidget {
  final String name;
  final String capacity;
  final String price;
  final String image;
  final String description;
  final double latitude;
  final double longitude;

  const TicketDetailPage({
    super.key,
    required this.name,
    required this.capacity,
    required this.price,
    required this.image,
    required this.description,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    print('Detail image URL: $image\n\n\n\n');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFA500)),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        title: const Text(
          'Ticket Details',
          style: TextStyle(
            color: Color(0xFF1450A3),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  image,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/placeholder.jpg',
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            buildInfoItem("Name", name),
            buildInfoItem("Capacity", capacity),
            buildInfoItem("Price", price),
            buildInfoItem("Description", description),

            const SizedBox(height: 20),
            const Text(
              "Map Location",
              style: TextStyle(
                color: Color(0xFF1450A3),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapPage(
                      locLang: LatLng(latitude, longitude),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.map),
              label: const Text("See on Map"
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1450A3),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1450A3),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

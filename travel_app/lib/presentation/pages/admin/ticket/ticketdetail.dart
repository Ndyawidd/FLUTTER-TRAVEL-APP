import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

class TicketDetailPage extends StatelessWidget {
  final String title;
  final String quota;
  final String price;
  final String image;
  final String time;
  final String description;
  // final double latitude;  // Tambahkan koordinat
  // final double longitude;

  const TicketDetailPage({
    super.key,
    required this.title,
    required this.quota,
    required this.price,
    required this.image,
    required this.time,
    required this.description,
    // required this.latitude,
    // required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFA500)),
          onPressed: () {
            Navigator.pop(context);
          },
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
                child: Image.asset(
                  image,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            buildInfoItem("Name", title),
            buildInfoItem("Capacity", quota),
            buildInfoItem("Price", price),
            buildInfoItem("Operational Time", time),
            buildInfoItem("Description", description),
            // const SizedBox(height: 24),
            // Container(
            //   height: 250,
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(16),
            //     border: Border.all(color: Color(0xFF1450A3)),
            //   ),
            //   child: ClipRRect(
            //     borderRadius: BorderRadius.circular(16),
            //     child: GoogleMap(
            //       initialCameraPosition: _initialPosition,
            //       markers: {
            //         Marker(
            //           markerId: const MarkerId('destination'),
            //           position: LatLng(latitude, longitude),
            //           infoWindow: InfoWindow(title: title),
            //         ),
            //       },
            //       zoomControlsEnabled: false,
            //     ),
            //   ),
            // ),
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

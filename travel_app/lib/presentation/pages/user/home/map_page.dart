import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import LatLng

class MapPage extends StatefulWidget {
  final LatLng locLang;

  const MapPage({super.key, required this.locLang});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;

  // Fungsi untuk menangani peta ketika siap
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map Location"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: widget.locLang, // Menggunakan koordinat yang diteruskan
          zoom: 12.0, // Zoom level untuk tampilan awal peta
        ),
        markers: {
          Marker(
            markerId: MarkerId('destination'),
            position: widget.locLang, // Menandakan lokasi pada peta
            infoWindow: InfoWindow(
                title: 'Destination'), // Menampilkan teks pada marker
          ),
        },
      ),
    );
  }
}

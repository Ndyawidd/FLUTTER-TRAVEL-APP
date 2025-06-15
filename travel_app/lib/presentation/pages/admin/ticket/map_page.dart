import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatelessWidget {
  final LatLng locLang;

  const MapPage({Key? key, required this.locLang}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lokasi di Peta'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: locLang,
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('selected-location'),
            position: locLang,
          ),
        },
      ),
    );
  }
}

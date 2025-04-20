import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search place",
              hintStyle: TextStyle(color: Color(0xFF1F509A)),
              prefixIcon: Icon(
                Icons.search,
                color: Color(0xFF1F509A), // Ganti warna ikon pencarian di sini
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: Color(0xFF1F509A), // Ganti warna border di sini
                  width: 2.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: Color(0xFFE38E49), // Warna border saat fokus
                  width: 2.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: Color(0xFF1F509A), // Warna border saat tidak fokus
                  width: 2.0,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xFF1F509A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.tune,
            color: Color(0xFFE38E49), // Ganti warna ikon filter di sini
          ),
        )
      ],
    );
  }
}

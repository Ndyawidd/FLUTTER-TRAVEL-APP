import 'package:flutter/material.dart';

// Gunakan warna konsisten dari palette
const kSecondaryOrange = Color(0xFFFF8500);
const kBorderColor = Color(0xFFD8E0F2);

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 🔍 Search field
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: kBorderColor),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search place",
                hintStyle: const TextStyle(fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // ⚙️ Filter icon
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: kSecondaryOrange,
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: () {
              // Tambahkan logika filter di sini
            },
          ),
        )
      ],
    );
  }
}

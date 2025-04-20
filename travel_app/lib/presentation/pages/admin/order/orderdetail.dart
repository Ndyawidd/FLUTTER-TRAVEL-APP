import 'package:flutter/material.dart';

class OrderDetailPage extends StatelessWidget {
  final Map<String, dynamic> orderData;

  // Menambahkan parameter 'orderData' pada konstruktor
  const OrderDetailPage({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    final total = (orderData['price'] as int) * (orderData['quantity'] as int);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Detail Order", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
                        radius: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        orderData['name'] as String, // Menggunakan orderData
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          orderData['image'] as String, // Menggunakan orderData
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(orderData['title'] as String, // Menggunakan orderData
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('x${orderData['quantity']}',
                                style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text('Rp. ${(orderData['price'] as int).toString()}'),
                            const SizedBox(height: 4),
                            Text(
                              'Total Pesanan: Rp. ${total.toString()}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text('No Pesanan: TPMT250412001'),
                  const Text('Waktu Pemesanan: 12 Apr 2025 16:54'),
                  const Text('Waktu Pembayaran: 12 Apr 2025 16:54'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text(
    'Confirm Order',
    style: TextStyle(color: Colors.white), // ✅ warna teks putih
  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C6881),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text(
    'Cancel Order',
    style: TextStyle(color: Colors.white), // ✅ warna teks putih
  ),
            ),
          ],
        ),
      ),
    );
  }
}

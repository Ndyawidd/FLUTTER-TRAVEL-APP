import 'package:flutter/material.dart';
import 'orderdetail.dart'; // Pastikan file ini ada dan sesuai

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = [
      {
        'name': 'Nadya Widdy Astuti',
        'title': 'Labuan Bajo',
        'image': 'assets/images/labuanbajo.jpg',
        'price': 500000,
        'quantity': 2,
        'status': 'Pending',
      },
      {
        'name': 'Nadya Widdy Astuti',
        'title': 'Bali',
        'image': 'assets/images/labuanbajo.jpg',
        'price': 700000,
        'quantity': 1,
        'status': 'In Progress',
      },
      {
        'name': 'Nadya Widdy Astuti',
        'title': 'Raja Ampat',
        'image': 'assets/images/labuanbajo.jpg',
        'price': 800000,
        'quantity': 3,
        'status': 'Done',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Order Management'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Order\n',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1450A3),
                    ),
                  ),
                  TextSpan(
                    text: 'Management',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1450A3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search, color: Colors.orange),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Color(0xFF1450A3)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                buildFilterButton('ALL', true),
                const SizedBox(width: 8),
                buildFilterButton('Pending', false),
                const SizedBox(width: 8),
                buildFilterButton('In Progress', false),
                const SizedBox(width: 8),
                buildFilterButton('Done', false),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final total = (order['price'] as int) * (order['quantity'] as int);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderDetailPage(orderData: order),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF1450A3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage(order['image'] as String),
                            radius: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(order['name'] as String,
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        order['image'] as String,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(order['title'] as String,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Rp. ${(order['price'] as int).toStringAsFixed(0)}',
                                                style: const TextStyle(fontWeight: FontWeight.w500),
                                              ),
                                              Text('x${order['quantity']}'),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Total Pesanan: Rp. ${total.toStringAsFixed(0)}',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            children: [
                              Text(order['status'] as String,
                                  style: const TextStyle(fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                                child: const Text('Confirm Order'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF1450A3),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: 'Ticket',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.reviews),
            label: 'Review',
          ),
        ],
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/admin/ticket');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/admin/review');
          }
        },
      ),
    );
  }

  Widget buildFilterButton(String label, bool isActive) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          backgroundColor: isActive ? const Color(0xFF1450A3) : Colors.white,
          side: const BorderSide(color: Color(0xFF1450A3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : const Color(0xFF1450A3),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'orderdetail.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String selectedFilter = 'ALL';

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

  @override
  Widget build(BuildContext context) {
    final filteredOrders = selectedFilter == 'ALL'
        ? orders
        : orders.where((order) => order['status'] == selectedFilter).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Order Management',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1450A3),
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
              SizedBox(
                height: 40,
                child: Row(
                  children: [
                    buildFilterButton('ALL'),
                    const SizedBox(width: 8),
                    buildFilterButton('Pending'),
                    const SizedBox(width: 8),
                    buildFilterButton('In Progress', isWide: true),
                    const SizedBox(width: 8),
                    buildFilterButton('Done'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: filteredOrders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    final total =
                        (order['price'] as int) * (order['quantity'] as int);

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
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFF1450A3)),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
  backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
                                  radius: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  order['name'] as String,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                const Spacer(),
                                Text(
                                  order['status'] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
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
                                      Text(
                                        order['title'] as String,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Rp. ${(order['price'] as int).toStringAsFixed(0)} x${order['quantity']}',
                                        style: const TextStyle(
                                            color: Colors.black87),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Total: Rp. ${total.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  child: const Text(
                                    'Confirm',
                                    style: TextStyle(color: Colors.white), // ✅ warna teks putih
                                  ),
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1450A3),
        selectedItemColor: const Color(0xFFFFA500),
        unselectedItemColor: Colors.white,
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/admin/ticket');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/admin/review');
          }
        },
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
      ),
    );
  }

  Widget buildFilterButton(String label, {bool isWide = false}) {
    final bool isActive = selectedFilter == label;

    return SizedBox(
      width: isWide ? 130 : null,
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            selectedFilter = label;
          });
        },
        style: OutlinedButton.styleFrom(
          backgroundColor:
              isActive ? const Color(0xFF1450A3) : Colors.white,
          side: const BorderSide(color: Color(0xFF1450A3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : const Color(0xFF1450A3),
          ),
        ),
      ),
    );
  }
}

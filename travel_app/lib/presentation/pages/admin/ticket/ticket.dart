import 'package:flutter/material.dart';
// import 'addticket.dart';
import 'ticketdetail.dart';

class TicketPage extends StatelessWidget {
  const TicketPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tickets = [
      {
        'title': 'Labuan Bajo',
        'quota': '20 Tiket',
        'price': 'Rp. 500.000',
        'image': 'assets/images/labuanbajo.jpg',
        'time': '3 Hari 2 Malam',
        'description':
            'Liburan ke Labuan Bajo dengan fasilitas lengkap dan pemandangan indah.',
      },
      {
        'title': 'Karimun Jawa',
        'quota': '3 Tiket',
        'price': 'Rp. 750.000',
        'image': 'assets/images/karimunjawa.jpg',
        'time': '2 Hari 1 Malam',
        'description': 'Menjelajah pulau Karimun Jawa yang eksotis dan tenang.',
      },
      {
        'title': 'Curug Pelangi',
        'quota': '20 Orang',
        'price': 'Rp. 500.000',
        'image': 'assets/images/curugpelangi.jpg',
        'time': '1 Hari',
        'description':
            'Wisata alam di Curug Pelangi dengan udara segar dan pemandangan air terjun.',
      },
      {
        'title': 'Labuan Bajo',
        'quota': '20 Orang',
        'price': 'Rp. 500.000',
        'image': 'assets/images/labuanbajo.jpg',
        'time': '3 Hari 2 Malam',
        'description':
            'Liburan ke Labuan Bajo dengan fasilitas lengkap dan pemandangan indah.',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Ticket\nManagement',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1450A3),
                      ),
                    ),
                  ),
                  // Container(
                  //   decoration: const BoxDecoration(
                  //     color: Color(0xFFFFA500),
                  //     shape: BoxShape.circle,
                  //   ),
                  //   child: IconButton(
                  //     icon: const Icon(Icons.add, color: Colors.white),
                  //     onPressed: () {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (context) => const AddTicketPage(),
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TicketDetailPage(
                              title: ticket['title']!,
                              quota: ticket['quota']!,
                              price: ticket['price']!,
                              image: ticket['image']!,
                              time: ticket['time']!,
                              description: ticket['description']!,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF1450A3)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                ticket['image']!,
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
                                    ticket['title']!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFFA500),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(ticket['quota']!),
                                  const SizedBox(height: 4),
                                  Text(
                                    ticket['price']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 18,
                              color: Colors.grey,
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
        selectedItemColor: const Color(0xFFFFA500),
        unselectedItemColor: Colors.white,
        backgroundColor: const Color(0xFF1450A3),
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/admin/order');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/admin/review');
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
}

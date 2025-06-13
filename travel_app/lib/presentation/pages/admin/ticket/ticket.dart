import 'package:flutter/material.dart';
import '../../../../services/ticket_service.dart';
import 'ticketdetail.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TicketPage extends StatelessWidget {
  const TicketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Ticket Management",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A4D8F),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Color(0xFF1A4D8F)),
                    onPressed: () async {
                      // Hapus token dari SharedPreferences
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('token');

                      // Navigasi ke halaman login
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    tooltip: 'Logout',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<Ticket>>(
                  future:
                      TicketService.fetchTickets(), // Fetch tickets from API
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(
                          child: Text('Error fetching tickets'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No tickets available'));
                    }

                    final tickets = snapshot.data!;
                    return ListView.builder(
                      itemCount: tickets.length,
                      itemBuilder: (context, index) {
                        final ticket = tickets[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TicketDetailPage(
                                  name: ticket.name,
                                  capacity:
                                      '${ticket.ticketId} Tickets', // Adjust if capacity is a separate field
                                  price:
                                      'Rp. ${ticket.price.toStringAsFixed(0)}',
                                  image:
                                      '${dotenv.env['API_URL']}${ticket.image}', // Prepend API_URL for image
                                  description: ticket.description ??
                                      'No description available',
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: const Color(0xFF1450A3)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    '${dotenv.env['API_URL']}${ticket.image}', // Prepend API_URL
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/images/placeholder.jpg',
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ticket.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFFA500),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                          '${ticket.ticketId} Tickets'), // Adjust if capacity is a separate field
                                      const SizedBox(height: 4),
                                      Text(
                                        'Rp. ${ticket.price.toStringAsFixed(0)}',
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

import 'package:flutter/material.dart';

class TicketCard extends StatelessWidget {
  final String title;
  final String destination;
  final String date;

  const TicketCard({
    super.key,
    required this.title,
    required this.destination,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text('$destination • $date'),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          // bisa lanjut ke BookingPage
        },
      ),
    );
  }
}

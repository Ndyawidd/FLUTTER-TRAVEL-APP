import 'package:flutter/material.dart';
import '../../widgets/ticket_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cari Tiket")),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => TicketCard(
          title: 'Tiket ${index + 1}',
          destination: 'Tujuan ${index + 1}',
          date: '20 April 2025',
        ),
      ),
    );
  }
}

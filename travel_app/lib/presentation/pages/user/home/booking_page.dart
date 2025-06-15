import 'package:flutter/material.dart';
import 'package:travel_app/services/ticket_service.dart';
import 'payment.dart';
import 'package:intl/intl.dart';

class BookingPage extends StatefulWidget {
  final int ticketId;

  const BookingPage({
    super.key,
    required this.ticketId,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  Ticket? ticket;
  int quantity = 1;
  String selectedDate = "";

  @override
  void initState() {
    super.initState();
    fetchTicket();
  }

  Future<void> fetchTicket() async {
    final fetchedTicket = await TicketService.fetchTicketById(widget.ticketId);
    setState(() {
      ticket = fetchedTicket;
    });
  }

  void increaseQuantity() {
    setState(() {
      quantity++;
    });
  }

  void decreaseQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025, 12, 31),
    );

    if (picked != null) {
      setState(() {
        selectedDate =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void proceedToPayment() {
    if (selectedDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please select a date before proceeding.")),
      );
      return;
    }

    if (ticket != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentPage(
            ticketId: ticket!.ticketId,
            date: selectedDate,
            quantity: quantity,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ticket == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final totalPrice = quantity * ticket!.price;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            buildRowWithIcon("Destination", ticket!.name, Icons.location_on),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context),
              child: buildRowWithIcon(
                  "Date",
                  selectedDate.isEmpty ? "Select a date" : selectedDate,
                  Icons.calendar_today),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Ticket Quantity",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                      onPressed: decreaseQuantity,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text("$quantity",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: increaseQuantity,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            Text("Total Price", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Rp ${NumberFormat('#,##0', 'id_ID').format(totalPrice)}",
                style: TextStyle(fontSize: 20, color: Colors.green)),
            const Spacer(),
            ElevatedButton(
              onPressed: proceedToPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade800,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text("Proceed to Payment",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }

  Widget buildRowWithIcon(String title, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.grey),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

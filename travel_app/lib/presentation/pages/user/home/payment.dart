import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_app/services/ticket_service.dart';
import 'package:travel_app/services/user_service.dart';
import 'home.dart';
import 'top_up.dart';
import 'package:travel_app/services/order_service.dart';

class PaymentPage extends StatefulWidget {
  final int ticketId;
  final String date;
  final int quantity;

  const PaymentPage({
    super.key,
    required this.ticketId,
    required this.date,
    this.quantity = 1,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  Ticket? ticket;
  double balance = 0.0;
  double subtotal = 0.0;
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadTicketData();
    _loadUserBalance();
  }

  Future<void> _loadUserBalance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getInt('userId');
      if (storedUserId != null) {
        userId = storedUserId;
        final user = await UserService.getUserById(userId!);
        setState(() {
          balance = user.balance;
        });
      } else {
        print("User ID not found");
      }
    } catch (e) {
      print("Failed to load user balance: $e");
    }
  }

  Future<void> _loadTicketData() async {
    final fetchedTicket = await TicketService.fetchTicketById(widget.ticketId);
    if (fetchedTicket != null) {
      setState(() {
        ticket = fetchedTicket;
        subtotal = fetchedTicket.price * widget.quantity.toDouble();
      });
    }
  }

  void _handlePayNow() async {
    if (userId == null) return;

    if (subtotal > balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Insufficient balance."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newBalance = balance - subtotal;

    try {
      // Update saldo dulu
      await UserService.updateUserBalance(userId!, newBalance);

      // Simpan order ke database
      final order = Order(
        orderId: "",
        userName: "",
        ticketTitle: "",
        image: "",
        quantity: widget.quantity,
        totalPrice: subtotal,
        status: "PENDING",
        userId: userId!, // Pass as int, not string
        ticketId: widget.ticketId, // Pass as int, not string
        date: widget.date,
      );

      print("DEBUG ticketId: ${widget.ticketId}");
      print("DEBUG userId: $userId");
      print("DEBUG order object: ${order.toJson()}");

      final orderSaved = await OrderService.createOrder(order);

      if (orderSaved == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal menyimpan data pesanan."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        balance = newBalance;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment Successful!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      print("Failed to update balance or create order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment failed."),
          backgroundColor: Colors.red,
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.orange),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Complete Your Payment',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Countdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Complete Payment In",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "57:01",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Ticket Info
              buildRowWithIcon("Destination", ticket!.name, Icons.location_on),
              buildRowWithIcon("Date", widget.date, Icons.calendar_today),
              buildRowWithIcon("Ticket", "${widget.quantity} pax",
                  Icons.confirmation_number),

              const SizedBox(height: 24),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "Payment Method",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F1F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Balance",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Rp ${balance.toStringAsFixed(0)}",
                          style: const TextStyle(fontSize: 16),
                        ),
                        TextButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const TopUpPage()),
                            );
                            if (result != null && context.mounted) {
                              _loadUserBalance(); // Refresh saldo
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Saldo berhasil diupdate!"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          child: const Text("Top Up",
                              style: TextStyle(color: Colors.orange)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Subtotal",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Rp ${subtotal.toStringAsFixed(0)}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F509A),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: _handlePayNow,
                  child: const Text("Pay Now",
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRowWithIcon(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

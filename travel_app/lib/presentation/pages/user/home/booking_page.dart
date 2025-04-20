import 'package:flutter/material.dart';
import 'payment.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes the debug banner
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: BookingPage(
        destination: 'Your Destination',
        date: 'Select a Date',
      ),
    );
  }
}

class BookingPage extends StatefulWidget {
  final String destination;
  final String date;

  const BookingPage({
    super.key,
    required this.destination,
    required this.date,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int personCount = 2;
  late String selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.date.isNotEmpty
        ? widget.date
        : "Select a Date"; // Ensure it is not empty
  }

  void increasePerson() {
    setState(() {
      personCount++;
    });
  }

  void decreasePerson() {
    if (personCount > 1) {
      setState(() {
        personCount--;
      });
    }
  }

  // Function to show the date picker dialog with error handling
  Future<void> _selectDate(BuildContext context) async {
    try {
      // Show date picker
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1999),
        lastDate: DateTime(2025, 12, 31), // Update lastDate to a valid range
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              primaryColor: Colors.indigo,
              colorScheme: ColorScheme.light().copyWith(
                secondary:
                    Colors.indigo, // Use secondary instead of accentColor
              ),
              buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
            ),
            child: child!,
          );
        },
      );

      if (picked != null && picked != DateTime.now()) {
        setState(() {
          selectedDate =
              "${picked.day}/${picked.month}/${picked.year}"; // Formatting the date
        });
      }
    } catch (error) {
      // Log or show error message
      print("Error occurred while selecting the date: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick a date: $error")),
      );
    }
  }

  // Navigate to PaymentPage
  void goToPaymentPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          destination: widget.destination,
          date: selectedDate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Complete Your Booking'),
        titleTextStyle: TextStyle(fontSize: 20),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true, // Center the title in the AppBar
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Destination Section
              buildRowWithIcon(
                  "Destination", widget.destination, Icons.location_on),

              const SizedBox(height: 16),

              // Date Section with DatePicker
              Material(
                color: Colors.transparent, // Ensure the tap is handled
                child: InkWell(
                  onTap: () => _selectDate(context),
                  child: buildRowWithIcon(
                      "Date", selectedDate, Icons.calendar_today),
                ),
              ),

              const SizedBox(height: 16),

              // Person Count Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Person",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      IconButton(
                        onPressed: decreasePerson,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        "$personCount",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      IconButton(
                        onPressed: increasePerson,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              // Proceed Button (Next)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade800,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: () {
                    goToPaymentPage(context); // Navigate to PaymentPage
                  },
                  child: const Text("Proceed to Payment",
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build row with text and icon for Destination, Date, and other sections
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
        const SizedBox(height: 16),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class EditTicketPage extends StatefulWidget {
  final String title;
  final String quota;
  final String price;
  final String time;
  final String description;
  final String image;

  const EditTicketPage({
    super.key,
    required this.title,
    required this.quota,
    required this.price,
    required this.time,
    required this.description,
    required this.image,
  });

  @override
  State<EditTicketPage> createState() => _EditTicketPageState();
}

class _EditTicketPageState extends State<EditTicketPage> {
  late TextEditingController titleController;
  late TextEditingController quotaController;
  late TextEditingController priceController;
  late TextEditingController timeController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.title);
    quotaController = TextEditingController(text: widget.quota);
    priceController = TextEditingController(text: widget.price);
    timeController = TextEditingController(text: widget.time);
    descriptionController = TextEditingController(text: widget.description);
  }

  @override
  void dispose() {
    titleController.dispose();
    quotaController.dispose();
    priceController.dispose();
    timeController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Ticket"),
        backgroundColor: const Color(0xFFFFA500),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildTextField("Name", titleController),
            buildTextField("Quota", quotaController),
            buildTextField("Price", priceController),
            buildTextField("Operational Time", timeController),
            buildTextField("Description", descriptionController, maxLines: 3),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Simulasi penyimpanan data
                Navigator.pop(context, {
                  'title': titleController.text,
                  'quota': quotaController.text,
                  'price': priceController.text,
                  'time': timeController.text,
                  'description': descriptionController.text,
                  'image': widget.image,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1450A3),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text("Save Ticket", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

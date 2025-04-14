import 'package:flutter/material.dart';
import 'edit_ticket.dart';

class TicketDetailPage extends StatelessWidget {
  final String title;
  final String quota;
  final String price;
  final String image;
  final String time;
  final String description;

  const TicketDetailPage({
    super.key,
    required this.title,
    required this.quota,
    required this.price,
    required this.image,
    required this.time,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFA500)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        title: const Text(
          'Detail Ticket',
          style: TextStyle(
            color: Color(0xFF1450A3),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                image,
                width: 200,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            infoText("Name", title),
            infoText("Capacity", quota),
            infoText("Price", price),
            infoText("Operational Time", time),
            infoText("Description", description),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA500),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditTicketPage(
        title: title,
        quota: quota,
        price: price,
        time: time,
        description: description,
        image: image,
      ),
    ),
  );

  if (result != null) {
    // Update state atau show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ticket updated successfully')),
    );
  }
},

                    child: const Text("Edit Ticket"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1450A3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Delete Ticket"),
      content: const Text("Are you sure you want to delete this ticket?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            // Di sini bisa hapus dari database/list
            Navigator.pop(context); // tutup dialog
            Navigator.pop(context); // kembali ke halaman sebelumnya
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Ticket deleted")),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text("Delete"),
        ),
      ],
    ),
  );
},

                    child: const Text("Delete Ticket", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget infoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label\n',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1450A3),
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

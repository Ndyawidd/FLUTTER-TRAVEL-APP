// import 'package:flutter/material.dart';

// class EditTicketPage extends StatefulWidget {
//   final String title;
//   final String quota;
//   final String price;
//   final String time;
//   final String description;
//   final String image;

//   const EditTicketPage({
//     super.key,
//     required this.title,
//     required this.quota,
//     required this.price,
//     required this.time,
//     required this.description,
//     required this.image,
//   });

//   @override
//   State<EditTicketPage> createState() => _EditTicketPageState();
// }

// class _EditTicketPageState extends State<EditTicketPage> {
//   late TextEditingController titleController;
//   late TextEditingController quotaController;
//   late TextEditingController priceController;
//   late TextEditingController timeController;
//   late TextEditingController descriptionController;

//   @override
//   void initState() {
//     super.initState();
//     titleController = TextEditingController(text: widget.title);
//     quotaController = TextEditingController(text: widget.quota);
//     priceController = TextEditingController(text: widget.price);
//     timeController = TextEditingController(text: widget.time);
//     descriptionController = TextEditingController(text: widget.description);
//   }

//   @override
//   void dispose() {
//     titleController.dispose();
//     quotaController.dispose();
//     priceController.dispose();
//     timeController.dispose();
//     descriptionController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Edit Ticket"),
//         backgroundColor: const Color(0xFFFFA500),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             buildTextField("Name", titleController),
//             buildTextField("Quota", quotaController),
//             buildTextField("Price", priceController),
//             buildTextField("Operational Time", timeController),
//             buildTextField("Description", descriptionController, maxLines: 3),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // Simulasi penyimpanan data
//                 Navigator.pop(context, {
//                   'title': titleController.text,
//                   'quota': quotaController.text,
//                   'price': priceController.text,
//                   'time': timeController.text,
//                   'description': descriptionController.text,
//                   'image': widget.image,
//                 });
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF1450A3),
//                 padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//               ),
//               child: const Text("Save Ticket", style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 15),
//       child: TextField(
//         controller: controller,
//         maxLines: maxLines,
//         decoration: InputDecoration(
//           labelText: label,
//           border: const OutlineInputBorder(),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

class EditTicketPage extends StatefulWidget {
  final String name;
  final String capacity;
  final String price;
  final String image;
  final String description;
  final double latitude;
  final double longitude;

  const EditTicketPage({
    super.key,
    required this.name,
    required this.capacity,
    required this.price,
    required this.image,
    required this.description,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<EditTicketPage> createState() => _EditTicketPageState();
}

class _EditTicketPageState extends State<EditTicketPage> {
  late TextEditingController _nameController;
  late TextEditingController _capacityController;
  late TextEditingController _priceController;
  late TextEditingController _imageController;
  late TextEditingController _descriptionController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _capacityController = TextEditingController(text: widget.capacity);
    _priceController = TextEditingController(text: widget.price);
    _imageController = TextEditingController(text: widget.image);
    _descriptionController = TextEditingController(text: widget.description);
    _latitudeController = TextEditingController(text: widget.latitude.toString());
    _longitudeController = TextEditingController(text: widget.longitude.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final updatedData = {
      "name": _nameController.text,
      "capacity": _capacityController.text,
      "price": _priceController.text,
      "image": _imageController.text,
      "description": _descriptionController.text,
      "latitude": double.tryParse(_latitudeController.text) ?? 0.0,
      "longitude": double.tryParse(_longitudeController.text) ?? 0.0,
    };

    // TODO: Call ticket update service here
    print("Updated Ticket Data: $updatedData");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Perubahan berhasil disimpan")),
    );

    Navigator.pop(context); // Kembali ke halaman sebelumnya
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Ticket"),
        backgroundColor: const Color(0xFF1450A3),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildTextField("Nama", _nameController),
            buildTextField("Kapasitas", _capacityController, keyboardType: TextInputType.number),
            buildTextField("Harga", _priceController, keyboardType: TextInputType.number),
            buildTextField("Gambar (URL)", _imageController),
            buildTextField("Deskripsi", _descriptionController, maxLines: 3),
            buildTextField("Latitude", _latitudeController, keyboardType: TextInputType.number),
            buildTextField("Longitude", _longitudeController, keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saveChanges,
              icon: const Icon(Icons.save),
              label: const Text("Simpan Perubahan"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

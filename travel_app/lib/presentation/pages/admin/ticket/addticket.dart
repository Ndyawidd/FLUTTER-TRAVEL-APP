import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddTicketPage extends StatefulWidget {
  const AddTicketPage({super.key});

  @override
  State<AddTicketPage> createState() => _AddTicketPageState();
}

class _AddTicketPageState extends State<AddTicketPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController operationalTimeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Back & Title
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Color(0xFFFFA500)),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Add Ticket",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1450A3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  /// Image Picker
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F1F1),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _image == null
                          ? const Center(
                              child: Icon(Icons.image_outlined, size: 48, color: Colors.grey),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _image!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  /// Form Inputs
                  buildLabel("Name"),
                  buildInputField(nameController, "Insert Destination Name"),

                  buildLabel("Capacity"),
                  buildInputField(capacityController, "Insert Ticket Capacity"),

                  buildLabel("Price"),
                  buildInputField(priceController, "Insert Ticket Price", keyboardType: TextInputType.number),

                  buildLabel("Operational Time"),
                  buildInputField(operationalTimeController, "Insert Operational Time"),

                  buildLabel("Description"),
                  buildInputField(descriptionController, "Insert Destination Description", maxLines: 3),

                  const SizedBox(height: 24),

                  /// Add Ticket Button
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Simpan data tiket di sini
                        }
                      },
                      child: const Text("Add Ticket", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  /// Cancel Button
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8FA7C9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF1450A3),
        ),
      ),
    );
  }

  Widget buildInputField(
    TextEditingController controller,
    String hintText, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontStyle: FontStyle.italic),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontStyle: FontStyle.italic),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Field cannot be empty";
        }
        return null;
      },
    );
  }
}

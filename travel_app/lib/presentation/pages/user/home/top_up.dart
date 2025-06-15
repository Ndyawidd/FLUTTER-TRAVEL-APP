import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Tambahkan import ini
import 'package:travel_app/services/user_service.dart';

class TopUpPage extends StatefulWidget {
  const TopUpPage({super.key});

  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  final TextEditingController _controller = TextEditingController();
  int? userId;
  double currentBalance = 0; // Ubah ke double untuk konsistensi

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getInt('userId'); // langsung ambil int

      print('UserId from SharedPreferences: $storedUserId');

      if (storedUserId != null) {
        setState(() {
          userId = storedUserId;
        });

        final user = await UserService.getUserById(userId!);
        setState(() {
          currentBalance = user.balance;
        });
      } else {
        print('No userId found in SharedPreferences.');
        // Tambahkan alert/snackbar/redirect kalau perlu
      }
    } catch (e) {
      print('Gagal memuat user: $e');
    }
  }

  String _formatRupiah(String value) {
    if (value.isEmpty) return '';
    final number = int.tryParse(value) ?? 0;
    return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  Future<void> _handleTopUp() async {
    final rawAmount = _controller.text.replaceAll(RegExp(r'\D'), '');
    final amount = int.tryParse(rawAmount);

    // Debug print untuk troubleshooting
    print('userId: $userId');
    print('rawAmount: $rawAmount');
    print('amount: $amount');
    print('currentBalance: $currentBalance');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User tidak ditemukan')),
      );
      return;
    }

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah saldo tidak valid')),
      );
      return;
    }

    final newBalance = currentBalance + amount;

    try {
      await UserService.updateUserBalance(userId!, newBalance);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saldo berhasil ditambahkan!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      print('Gagal top up: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menambahkan saldo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Top Up Saldo',
          style:
              TextStyle(color: Color(0xFF1F509A), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Saldo Sekarang',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                'Rp ${_formatRupiah(currentBalance.toInt().toString())}',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE38E49)),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  final onlyNumbers = val.replaceAll(RegExp(r'\D'), '');
                  _controller.value = TextEditingValue(
                    text: _formatRupiah(onlyNumbers),
                    selection: TextSelection.collapsed(
                        offset: _formatRupiah(onlyNumbers).length),
                  );
                },
                decoration: InputDecoration(
                  hintText: 'Masukkan jumlah saldo',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleTopUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F509A),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tambahkan Saldo',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

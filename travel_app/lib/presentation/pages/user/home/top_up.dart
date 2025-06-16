import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_app/services/user_service.dart';

class TopUpPage extends StatefulWidget {
  const TopUpPage({super.key});

  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  final TextEditingController _controller = TextEditingController();
  int? userId;
  double currentBalance = 0;
  int? selectedAmount;

  // Daftar nominal top up yang tersedia
  final List<int> quickAmounts = [
    50000,
    100000,
    200000,
    500000,
    1000000,
    2000000,
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getInt('userId');

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
      }
    } catch (e) {
      print('Gagal memuat user: $e');
    }
  }

  String _formatRupiah(int value) {
    return value.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  void _selectAmount(int amount) {
    setState(() {
      selectedAmount = amount;
      _controller.text = _formatRupiah(amount);
    });
  }

  void _clearSelection() {
    setState(() {
      selectedAmount = null;
      _controller.clear();
    });
  }

  Future<void> _handleTopUp() async {
    int? amount;

    if (selectedAmount != null) {
      amount = selectedAmount;
    } else {
      final rawAmount = _controller.text.replaceAll(RegExp(r'\D'), '');
      amount = int.tryParse(rawAmount);
    }

    print('userId: $userId');
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
        const SnackBar(
            content: Text('Pilih atau masukkan jumlah saldo yang valid')),
      );
      return;
    }

    if (amount < 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal top up Rp 10.000')),
      );
      return;
    }

    if (amount > 10000000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maksimal top up Rp 10.000.000')),
      );
      return;
    }

    final newBalance = currentBalance + amount;

    try {
      await UserService.updateUserBalance(userId!, newBalance);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Berhasil menambahkan saldo Rp ${_formatRupiah(amount)}!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Gagal top up: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menambahkan saldo. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildQuickAmountCard(int amount) {
    final isSelected = selectedAmount == amount;
    return GestureDetector(
      onTap: () => _selectAmount(amount),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1F509A) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF1F509A) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Rp ${_formatRupiah(amount)}',
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Top Up Saldo',
          style: TextStyle(
            color: Color(0xFF1F509A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF1F509A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1F509A), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1F509A).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Saldo Sekarang',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${_formatRupiah(currentBalance.toInt())}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Quick Amount Selection
            const Text(
              'Pilih Nominal',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F509A),
              ),
            ),
            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: quickAmounts.length,
              itemBuilder: (context, index) {
                return _buildQuickAmountCard(quickAmounts[index]);
              },
            ),

            const SizedBox(height: 24),

            // Custom Amount Input
            Row(
              children: [
                const Text(
                  'Atau Masukkan Nominal Lain',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F509A),
                  ),
                ),
                const Spacer(),
                if (selectedAmount != null || _controller.text.isNotEmpty)
                  TextButton(
                    onPressed: _clearSelection,
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        color: Color(0xFFE38E49),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  setState(() {
                    selectedAmount = null; // Clear selected amount when typing
                  });

                  final onlyNumbers = val.replaceAll(RegExp(r'\D'), '');
                  if (onlyNumbers.isNotEmpty) {
                    _controller.value = TextEditingValue(
                      text: _formatRupiah(int.parse(onlyNumbers)),
                      selection: TextSelection.collapsed(
                        offset: _formatRupiah(int.parse(onlyNumbers)).length,
                      ),
                    );
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Contoh: 150.000',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixText: 'Rp ',
                  prefixStyle: const TextStyle(
                    color: Color(0xFF1F509A),
                    fontWeight: FontWeight.w600,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info Text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Minimal top up Rp 10.000, Maksimal Rp 10.000.000',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Top Up Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleTopUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F509A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Tambahkan Saldo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

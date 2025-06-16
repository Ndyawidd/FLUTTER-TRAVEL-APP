import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_app/services/ticket_service.dart';
import 'package:travel_app/services/user_service.dart';
import 'package:intl/intl.dart';
import 'home.dart';
import 'top_up.dart';
import 'package:travel_app/services/order_service.dart';
import '../../../widgets/alert_utils.dart';

const kPrimaryBlue = Color(0xFF154BCB);
const kSecondaryOrange = Color(0xFFFF8500);
const kLightGrey = Color(0xFFF8F8F8);
const kTextGrey = Color(0xFF666666);
const kBorderColor = Color(0xFFE0E0E0);

class PaymentPage extends StatefulWidget {
  final int ticketId;
  final String date;
  final int quantity;
  final int currentCapacity;

  const PaymentPage({
    super.key,
    required this.ticketId,
    required this.date,
    this.quantity = 1,
    required this.currentCapacity,
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
        if (mounted) {
          DialogUtils.showErrorDialog(
            context: context,
            title: 'Error',
            message: 'User ID tidak ditemukan. Silakan login kembali.',
            onPressed: () {
              Navigator.of(context).pop();
            },
          );
        }
      }
    } catch (e) {
      print("Failed to load user balance: $e");
      if (mounted) {
        DialogUtils.showErrorDialog(
          context: context,
          title: 'Error',
          message: 'Gagal memuat saldo pengguna. Silakan coba lagi.',
        );
      }
    }
  }

  Future<void> _loadTicketData() async {
    try {
      final fetchedTicket =
          await TicketService.fetchTicketById(widget.ticketId);
      if (fetchedTicket != null) {
        setState(() {
          ticket = fetchedTicket;
          subtotal = fetchedTicket.price * widget.quantity.toDouble();
        });
      } else {
        if (mounted) {
          DialogUtils.showErrorDialog(
            context: context,
            title: 'Error',
            message: 'Tiket tidak ditemukan. Silakan kembali dan coba lagi.',
            onPressed: () {
              Navigator.of(context).pop();
            },
          );
        }
      }
    } catch (e) {
      print("Failed to load ticket data: $e");
      if (mounted) {
        DialogUtils.showErrorDialog(
          context: context,
          title: 'Error',
          message: 'Gagal memuat data tiket. Silakan coba lagi.',
        );
      }
    }
  }

  void _handlePayNow() async {
    if (userId == null) return;
    if (subtotal > balance) {
      DialogUtils.showErrorDialog(
        context: context,
        title: 'Saldo Tidak Mencukupi',
        message:
            'Saldo Anda tidak mencukupi untuk melakukan pembayaran ini. Silakan top up terlebih dahulu.',
        buttonText: 'Top Up Sekarang',
        onPressed: () async {
          Navigator.of(context).pop();
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TopUpPage()),
          );
          if (result != null && context.mounted) {
            _loadUserBalance();
          }
        },
      );
      return;
    }

    if (widget.quantity > widget.currentCapacity) {
      DialogUtils.showErrorDialog(
        context: context,
        title: 'Kapasitas Tidak Mencukupi',
        message:
            'Jumlah tiket yang Anda pesan (${widget.quantity}) melebihi kapasitas yang tersedia (${widget.currentCapacity}).',
      );
      return;
    }

    final confirmPayment = await DialogUtils.showWarningDialog(
      context: context,
      title: 'Konfirmasi Pembayaran',
      message:
          'Apakah Anda yakin ingin melanjutkan pembayaran sebesar ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(subtotal)}?',
      confirmText: 'Bayar',
      cancelText: 'Batal',
    );

    if (confirmPayment != true) return;

    final newBalance = balance - subtotal;
    final newTicketCapacity = widget.currentCapacity - widget.quantity;

    DialogUtils.showLoadingDialog(
      context: context,
      message: 'Memproses pembayaran...',
    );

    try {
      await UserService.updateUserBalance(userId!, newBalance);

      print(
          "DEBUG: Updating ticket capacity from ${widget.currentCapacity} to $newTicketCapacity");
      final bool capacityUpdateSuccess =
          await TicketService.updateTicketCapacity(
        widget.ticketId,
        newTicketCapacity,
      );

      if (!capacityUpdateSuccess) {
        await UserService.updateUserBalance(userId!, balance);

        if (mounted) DialogUtils.dismissDialog(context);

        DialogUtils.showErrorDialog(
          context: context,
          title: 'Pembayaran Gagal',
          message: 'Gagal memperbarui kapasitas tiket. Pembayaran dibatalkan.',
        );
        return;
      }

      final order = Order(
        orderId: "",
        userName: "",
        ticketTitle: ticket!.name,
        image: ticket!.image,
        quantity: widget.quantity,
        totalPrice: subtotal,
        status: "PENDING",
        userId: userId!,
        ticketId: widget.ticketId,
        date: widget.date,
      );

      print("DEBUG ticketId: ${widget.ticketId}");
      print("DEBUG userId: $userId");
      print("DEBUG order object: ${order.toJson()}");

      final orderSaved = await OrderService.createOrder(order);

      if (orderSaved == null) {
        await UserService.updateUserBalance(userId!, balance);
        await TicketService.updateTicketCapacity(
            widget.ticketId, widget.currentCapacity);

        if (mounted) DialogUtils.dismissDialog(context);

        DialogUtils.showErrorDialog(
          context: context,
          title: 'Pembayaran Gagal',
          message:
              'Gagal menyimpan data pesanan. Semua perubahan telah dibatalkan.',
        );
        return;
      }

      setState(() {
        balance = newBalance;
      });

      if (mounted) DialogUtils.dismissDialog(context);

      DialogUtils.showSuccessDialog(
        context: context,
        title: 'Pembayaran Berhasil!',
        message:
            'Tiket Anda telah berhasil dibeli. Terima kasih atas pembelian Anda!',
        buttonText: 'Kembali ke Beranda',
        onPressed: () {
          Navigator.of(context).pop();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        },
      );
    } catch (e) {
      print("Failed to process payment: $e");

      if (mounted) DialogUtils.dismissDialog(context);

      DialogUtils.showErrorDialog(
        context: context,
        title: 'Pembayaran Gagal',
        message:
            'Terjadi kesalahan saat memproses pembayaran. Silakan coba lagi.',
      );
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ticket == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kPrimaryBlue),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Payment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: kPrimaryBlue,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kLightGrey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detail Pesanan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow('Destinasi', ticket!.name),
                        _buildDetailRow('Tanggal', _formatDate(widget.date)),
                        _buildDetailRow('Jumlah', '${widget.quantity} tiket'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Saldo Anda',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: kBorderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Saldo E-Wallet',
                              style: TextStyle(
                                fontSize: 14,
                                color: kTextGrey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rp ${NumberFormat('#,##0', 'id_ID').format(balance)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: kPrimaryBlue,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const TopUpPage()),
                            );
                            if (result != null && context.mounted) {
                              _loadUserBalance();
                              DialogUtils.showSuccessDialog(
                                context: context,
                                title: 'Top Up Berhasil',
                                message:
                                    'Saldo Anda telah berhasil diperbarui!',
                                autoDismissAfter: const Duration(seconds: 2),
                              );
                            }
                          },
                          child: const Text(
                            'Top Up',
                            style: TextStyle(
                              color: kSecondaryOrange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kLightGrey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Pembayaran',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Rp ${NumberFormat('#,##0', 'id_ID').format(subtotal)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: kBorderColor, width: 1),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handlePayNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Bayar Sekarang",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: kTextGrey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

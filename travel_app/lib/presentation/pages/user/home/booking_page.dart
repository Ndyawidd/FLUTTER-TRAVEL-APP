import 'package:flutter/material.dart';
import 'package:travel_app/services/ticket_service.dart';
import 'payment.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../widgets/alert_utils.dart';

const kPrimaryBlue = Color(0xFF154BCB);
const kSecondaryOrange = Color(0xFFFF8500);
const kLightGrey = Color(0xFFF8F8F8);
const kTextGrey = Color(0xFF666666);
const kBorderColor = Color(0xFFE0E0E0);

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
  bool isLoading = true;
  bool _localeInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    try {
      await initializeDateFormatting('id_ID', null);
      setState(() {
        _localeInitialized = true;
      });
      fetchTicket();
    } catch (e) {
      setState(() {
        _localeInitialized = true;
      });
      fetchTicket();
    }
  }

  Future<void> fetchTicket() async {
    setState(() {
      isLoading = true;
    });

    try {
      final fetchedTicket =
          await TicketService.fetchTicketById(widget.ticketId);
      setState(() {
        ticket = fetchedTicket;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        DialogUtils.showErrorDialog(
          context: context,
          title: "Gagal Memuat Data",
          message:
              "Terjadi kesalahan saat memuat data tiket. Silakan coba lagi.",
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        );
      }
    }
  }

  void increaseQuantity() {
    setState(() {
      if (ticket != null && quantity < ticket!.capacity) {
        quantity++;
      } else if (ticket != null && quantity >= ticket!.capacity) {
        DialogUtils.showWarningDialog(
          context: context,
          title: "Batas Maksimal Tiket",
          message:
              "Maksimal ${ticket!.capacity} tiket dapat dibeli untuk destinasi ini.",
          confirmText: "Mengerti",
          cancelText: null,
          onConfirm: () {},
        );
      }
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: kPrimaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> proceedToPayment() async {
    DialogUtils.showLoadingDialog(
      context: context,
      message: "Memproses data booking...",
    );

    await Future.delayed(Duration(seconds: 1));

    if (mounted) {
      DialogUtils.dismissDialog(context);
    }

    if (mounted) {
      try {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentPage(
              ticketId: ticket!.ticketId,
              date: selectedDate,
              quantity: quantity,
              currentCapacity: ticket!.capacity,
            ),
          ),
        );

        if (result != null && result == 'success') {
          DialogUtils.showSuccessDialog(
            context: context,
            title: "Booking Berhasil",
            message: "Pemesanan tiket Anda telah berhasil diproses.",
            autoDismissAfter: Duration(seconds: 3),
          );
        }
      } catch (e) {
        DialogUtils.showErrorDialog(
          context: context,
          title: "Gagal Memproses",
          message:
              "Terjadi kesalahan saat memproses booking. Silakan coba lagi.",
        );
      }
    }
  }

  String _formatDisplayDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      if (_localeInitialized) {
        try {
          return DateFormat('dd MMM yyyy', 'id_ID').format(date);
        } catch (e) {
          return DateFormat('dd MMM yyyy').format(date);
        }
      } else {
        return DateFormat('dd MMM yyyy').format(date);
      }
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _handleBookingProcess() async {
    if (selectedDate.isEmpty) {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Tanggal Belum Dipilih",
        message:
            "Silakan pilih tanggal kunjungan terlebih dahulu sebelum melanjutkan ke pembayaran.",
        confirmText: "Pilih Tanggal",
        cancelText: "Batal",
        onConfirm: () {
          Future.delayed(Duration(milliseconds: 300), () {
            _selectDate(context);
          });
        },
      );
      return;
    }

    if (ticket == null) {
      DialogUtils.showErrorDialog(
        context: context,
        title: "Error",
        message: "Data tiket tidak tersedia. Silakan coba lagi.",
      );
      return;
    }

    final bool? confirmed = await DialogUtils.showWarningDialog(
      context: context,
      title: "Konfirmasi Booking",
      message: "Apakah Anda yakin ingin melanjutkan booking untuk:\n\n"
          "Destinasi: ${ticket?.name}\n"
          "Tanggal: ${_formatDisplayDate(selectedDate)}\n"
          "Jumlah: $quantity tiket\n"
          "Total: Rp ${NumberFormat('#,##0', 'id_ID').format(quantity * (ticket?.price ?? 0))}",
      confirmText: "Ya, Lanjutkan",
      cancelText: "Batal",
    );

    if (confirmed == true) {
      proceedToPayment();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || !_localeInitialized) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kPrimaryBlue),
          ),
        ),
      );
    }

    if (ticket == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            "Booking",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: kPrimaryBlue,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: kTextGrey,
              ),
              const SizedBox(height: 16),
              const Text(
                "Gagal memuat data",
                style: TextStyle(
                  fontSize: 16,
                  color: kTextGrey,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: fetchTicket,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryBlue,
                  foregroundColor: Colors.white,
                ),
                child: Text("Coba Lagi"),
              ),
            ],
          ),
        ),
      );
    }

    final totalPrice = quantity * ticket!.price;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Booking",
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
                        Text(
                          ticket!.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kapasitas: ${ticket!.capacity} orang',
                          style: const TextStyle(
                            fontSize: 14,
                            color: kTextGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Tanggal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: kBorderColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedDate.isEmpty
                                ? 'Pilih tanggal'
                                : _formatDisplayDate(selectedDate),
                            style: TextStyle(
                              fontSize: 14,
                              color: selectedDate.isEmpty
                                  ? kTextGrey
                                  : Colors.black,
                            ),
                          ),
                          Icon(Icons.calendar_today,
                              size: 20, color: kTextGrey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Jumlah Tiket',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color:
                                  quantity > 1 ? kPrimaryBlue : kBorderColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: quantity > 1 ? decreaseQuantity : null,
                          icon: Icon(
                            Icons.remove,
                            color: quantity > 1 ? kPrimaryBlue : kTextGrey,
                            size: 18,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$quantity',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: ticket != null && quantity < ticket!.capacity
                                ? kPrimaryBlue
                                : kBorderColor,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed:
                              ticket != null && quantity < ticket!.capacity
                                  ? increaseQuantity
                                  : null,
                          icon: Icon(
                            Icons.add,
                            color: ticket != null && quantity < ticket!.capacity
                                ? kPrimaryBlue
                                : kTextGrey,
                            size: 18,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kLightGrey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Rp ${NumberFormat('#,##0', 'id_ID').format(ticket!.price)} x $quantity',
                              style: const TextStyle(
                                fontSize: 14,
                                color: kTextGrey,
                              ),
                            ),
                            Text(
                              'Rp ${NumberFormat('#,##0', 'id_ID').format(totalPrice)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: kPrimaryBlue,
                              ),
                            ),
                          ],
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
                onPressed: _handleBookingProcess,
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
                  "Lanjut Bayar",
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
}

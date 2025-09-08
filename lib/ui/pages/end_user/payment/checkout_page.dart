import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:bank_sha/services/payment_gateway_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final int _amount = 150000; // Contoh nominal pembayaran
  String _selectedPaymentMethod = 'QRIS';
  
  String _formatAmount(int amount) {
    final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return 'Rp ${amount.toString().replaceAllMapped(formatter, (Match m) => '${m[1]}.')}';
  }
  
  void _selectPaymentMethod() async {
    final result = await Navigator.pushNamed(context, '/payment-methods');
    
    if (result != null && result is String) {
      setState(() {
        _selectedPaymentMethod = result;
      });
    }
  }
  
  String _getPaymentIcon() {
    switch (_selectedPaymentMethod) {
      case 'ShopeePay':
        return 'assets/ic_wallet.png';
      case 'GoPay':
        return 'assets/ic_wallet.png';
      case 'DANA':
        return 'assets/ic_wallet.png';
      case 'Bank BCA':
        return 'assets/img_bank_bca.png';
      case 'Bank BNI':
        return 'assets/img_bank_bni.png';
      case 'Bank Mandiri':
        return 'assets/img_bank_mandiri.png';
      default:
        return 'assets/ic_wallet.png';
    }
  }
  
  String _getPaymentDescription() {
    switch (_selectedPaymentMethod) {
      case 'QRIS':
        return 'Bayar dengan QRIS (Semua e-wallet & mobile banking)';
      case 'ShopeePay':
        return 'Bayar dengan ShopeePay';
      case 'GoPay':
        return 'Bayar dengan GoPay';
      case 'DANA':
        return 'Bayar dengan DANA';
      case 'Bank BCA':
        return 'Transfer Bank BCA';
      case 'Bank BNI':
        return 'Transfer Bank BNI';
      case 'Bank Mandiri':
        return 'Transfer Bank Mandiri';
      default:
        return 'Pilih metode pembayaran';
    }
  }

  void _goToPaymentPage() async {
    // Buat ID transaksi unik menggunakan UUID
    final uuid = Uuid();
    final transactionId = uuid.v4();
    
    if (_selectedPaymentMethod == 'QRIS') {
      Navigator.pushNamed(
        context,
        '/qris-payment',
        arguments: {
          'amount': _amount,
          'transactionId': transactionId,
          'description': 'Pembayaran Layanan Gerobaks',
        },
      );
    } else {
      // Metode sederhana dan langsung: tampilkan dialog dan langsung buka browser
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Membuka Halaman Pembayaran',
              style: blackTextStyle.copyWith(
                fontSize: 18,
                fontWeight: semiBold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                CircularProgressIndicator(color: greenColor),
                const SizedBox(height: 20),
                Text(
                  'Membuka halaman pembayaran $_selectedPaymentMethod...\nJangan tutup aplikasi ini.',
                  style: greyTextStyle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );

      // Tunggu sebentar agar dialog terlihat
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Langsung buka website pembayaran
      bool success = await PaymentGatewayService.openPaymentApp(_selectedPaymentMethod);
      
      // Tutup dialog
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      
      if (success) {
        // Tampilkan notifikasi bahwa pembayaran sedang diproses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lanjutkan pembayaran di browser'),
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Tanyakan kepada pengguna apakah pembayaran sudah selesai
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Konfirmasi Pembayaran',
                style: blackTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: semiBold,
                ),
              ),
              content: Text(
                'Apakah pembayaran di $_selectedPaymentMethod sudah selesai?',
                style: greyTextStyle,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // tutup dialog
                  },
                  child: Text(
                    'Belum',
                    style: blackTextStyle,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // tutup dialog
                    // Navigasi ke halaman sukses
                    Navigator.pushNamed(
                      context, 
                      '/payment-success',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: greenColor,
                  ),
                  child: Text(
                    'Sudah',
                    style: whiteTextStyle,
                  ),
                ),
              ],
            );
          },
        );
      } else {
        // Tampilkan pesan error jika gagal membuka browser
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuka halaman pembayaran. Coba metode lain.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: blackTextStyle.copyWith(
            fontSize: 18,
            fontWeight: semiBold,
          ),
        ),
        centerTitle: true,
        backgroundColor: whiteColor,
        elevation: 0.5,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: blackColor,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Konten checkout
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Detail layanan
                    Text(
                      'Detail Layanan',
                      style: blackTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: semiBold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Item layanan
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: greyColor.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: greenColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.delete_outline,
                                color: greenColor,
                                size: 30,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Layanan Pengangkutan Sampah',
                                  style: blackTextStyle.copyWith(
                                    fontSize: 16,
                                    fontWeight: semiBold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Paket Bulanan - 4x Pengambilan',
                                  style: greyTextStyle.copyWith(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _formatAmount(_amount),
                            style: greeTextStyle.copyWith(
                              fontSize: 16,
                              fontWeight: semiBold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Metode pembayaran
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Metode Pembayaran',
                          style: blackTextStyle.copyWith(
                            fontSize: 16,
                            fontWeight: semiBold,
                          ),
                        ),
                        TextButton(
                          onPressed: _selectPaymentMethod,
                          child: Text(
                            'Ubah',
                            style: greeTextStyle.copyWith(
                              fontSize: 14,
                              fontWeight: semiBold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Selected payment method
                    InkWell(
                      onTap: _selectPaymentMethod,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: greenColor,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: greyColor.withOpacity(0.2),
                                ),
                              ),
                              child: Center(
                                child: _selectedPaymentMethod.contains('QRIS') 
                                ? Text(
                                    'QRIS',
                                    style: blackTextStyle.copyWith(
                                      fontSize: 14,
                                      fontWeight: semiBold,
                                    ),
                                  ) 
                                : Image.asset(
                                    _getPaymentIcon(),
                                    height: 30,
                                    fit: BoxFit.contain,
                                  ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _getPaymentDescription(),
                                style: blackTextStyle.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: greenColor,
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom payment summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: blackTextStyle.copyWith(
                          fontSize: 16,
                          fontWeight: semiBold,
                        ),
                      ),
                      Text(
                        _formatAmount(_amount),
                        style: greeTextStyle.copyWith(
                          fontSize: 16,
                          fontWeight: semiBold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomFilledButton(
                    title: 'Bayar Sekarang',
                    onPressed: _goToPaymentPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

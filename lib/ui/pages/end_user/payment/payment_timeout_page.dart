import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:flutter/material.dart';

class PaymentTimeoutPage extends StatelessWidget {
  const PaymentTimeoutPage({super.key});

  String _formatAmount(int amount) {
    final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return 'Rp ${amount.toString().replaceAllMapped(formatter, (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final int amount = args?['amount'] as int? ?? 0;
    final String transactionId = args?['transactionId'] as String? ?? '';
    
    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Timeout Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: redcolor.withOpacity(0.1),
                ),
                child: Center(
                  child: Icon(
                    Icons.timer_off,
                    size: 60,
                    color: redcolor,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Timeout Text
              Text(
                'Waktu Pembayaran Habis',
                style: blackTextStyle.copyWith(
                  fontSize: 20,
                  fontWeight: bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Amount
              Text(
                _formatAmount(amount),
                style: blackTextStyle.copyWith(
                  fontSize: 28,
                  fontWeight: bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Transaction ID
              Text(
                'ID: $transactionId',
                style: greyTextStyle.copyWith(
                  fontSize: 14,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Silakan coba lagi untuk membuat pembayaran baru.',
                  style: greyTextStyle.copyWith(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Buttons
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    CustomFilledButton(
                      title: 'Coba Lagi',
                      onPressed: () {
                        Navigator.pop(context); // Kembali ke halaman sebelumnya
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomFilledButton(
                      title: 'Kembali ke Beranda',
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

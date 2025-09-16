import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:flutter/material.dart';

class PaymentSuccessPage extends StatelessWidget {
  const PaymentSuccessPage({super.key});

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
              // Success Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: greenColor.withOpacity(0.1),
                ),
                child: Center(
                  child: Icon(
                    Icons.check_circle,
                    size: 60,
                    color: greenColor,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Success Text
              Text(
                'Pembayaran Berhasil!',
                style: blackTextStyle.copyWith(
                  fontSize: 20,
                  fontWeight: bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Amount
              Text(
                _formatAmount(amount),
                style: greenTextStyle.copyWith(
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
              
              const SizedBox(height: 40),
              
              // Back to Home Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: CustomFilledButton(
                  title: 'Kembali ke Beranda',
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

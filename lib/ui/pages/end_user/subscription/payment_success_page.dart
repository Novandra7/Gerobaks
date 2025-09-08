import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/models/subscription_model.dart';
import 'package:intl/intl.dart';

class PaymentSuccessPage extends StatelessWidget {
  final UserSubscription subscription;
  final bool isFromSignup;

  const PaymentSuccessPage({
    super.key,
    required this.subscription,
    this.isFromSignup = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: uicolor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: greenColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: whiteColor,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Pembayaran Berhasil!',
                      style: blackTextStyle.copyWith(
                        fontSize: 24,
                        fontWeight: bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Selamat! Langganan ${subscription.planName} Anda telah aktif.',
                      style: greyTextStyle.copyWith(
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    _buildSubscriptionDetails(),
                  ],
                ),
              ),
              _buildBottomActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow('Paket Langganan', subscription.planName),
          const SizedBox(height: 12),
          _buildDetailRow('ID Transaksi', subscription.transactionId ?? '-'),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Mulai Aktif',
            DateFormat('dd MMMM yyyy', 'id_ID').format(subscription.startDate),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Berakhir',
            DateFormat('dd MMMM yyyy', 'id_ID').format(subscription.endDate),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Total Pembayaran',
            'Rp ${subscription.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
            isHighlight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: greyTextStyle.copyWith(
            fontSize: 14,
            fontWeight: medium,
          ),
        ),
        Text(
          value,
          style: (isHighlight ? blackTextStyle : greyTextStyle).copyWith(
            fontSize: 14,
            fontWeight: isHighlight ? semiBold : medium,
            color: isHighlight ? greenColor : null,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              if (!isFromSignup) {
                // Return true to indicate successful payment
                Navigator.pop(context, true);
              } else {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/sign-in',
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: greenColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              !isFromSignup ? 'Lanjutkan' : 'Kembali ke Sign In',
              style: whiteTextStyle.copyWith(
                fontSize: 16,
                fontWeight: semiBold,
              ),
            ),
          ),
        ),
        if (isFromSignup) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/my-subscription');
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: greenColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Lihat Langganan Saya',
                style: blackTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: semiBold,
                  color: greenColor,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

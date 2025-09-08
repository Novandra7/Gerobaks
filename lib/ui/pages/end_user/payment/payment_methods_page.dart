import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/payment/payment_method_tile.dart';
import 'package:bank_sha/services/payment_gateway_service.dart';

class PaymentMethodsPage extends StatelessWidget {
  final VoidCallback? onPaymentSelected;

  const PaymentMethodsPage({
    super.key,
    this.onPaymentSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackgroundColor,
      appBar: AppBar(
        backgroundColor: greenColor,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/img_gerobakss.png',
              height: 30,
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Pilih Metode Pembayaran',
            style: blackTextStyle.copyWith(
              fontSize: 20,
              fontWeight: semiBold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih metode pembayaran yang tersedia untuk melanjutkan pembayaran',
            style: greyTextStyle.copyWith(
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // E-Wallet Section
          _buildSectionTitle('E-Wallet'),
          const SizedBox(height: 12),
          
          PaymentMethodTile(
            name: 'ShopeePay',
            imageAsset: 'assets/ic_wallet.png',
            onTap: () async {
              // Tampilkan loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: greenColor),
                        const SizedBox(height: 20),
                        Text(
                          'Membuka ShopeePay...',
                          style: greyTextStyle,
                        ),
                      ],
                    ),
                  );
                },
              );
              
              // Import payment service dynamically
              final success = await PaymentGatewayService.openPaymentApp('ShopeePay');
              
              // Close loading dialog and return to previous screen
              if (context.mounted && Navigator.canPop(context)) {
                Navigator.of(context).pop();
                Navigator.pop(context, 'ShopeePay');
              }
              
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tidak dapat membuka aplikasi ShopeePay. Coba metode lain.'),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
              
              if (onPaymentSelected != null) {
                onPaymentSelected!();
              }
            },
          ),
          
          PaymentMethodTile(
            name: 'GoPay',
            imageAsset: 'assets/ic_wallet.png',
            onTap: () async {
              // Tampilkan loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: greenColor),
                        const SizedBox(height: 20),
                        Text(
                          'Membuka GoPay...',
                          style: greyTextStyle,
                        ),
                      ],
                    ),
                  );
                },
              );
              
              // Import payment service dynamically
              final success = await PaymentGatewayService.openPaymentApp('GoPay');
              
              // Close loading dialog and return to previous screen
              if (context.mounted && Navigator.canPop(context)) {
                Navigator.of(context).pop();
                Navigator.pop(context, 'GoPay');
              }
              
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tidak dapat membuka aplikasi GoPay. Coba metode lain.'),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
              
              if (onPaymentSelected != null) {
                onPaymentSelected!();
              }
            },
          ),
          
          PaymentMethodTile(
            name: 'DANA',
            imageAsset: 'assets/ic_wallet.png',
            onTap: () async {
              // Tampilkan loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: greenColor),
                        const SizedBox(height: 20),
                        Text(
                          'Membuka DANA...',
                          style: greyTextStyle,
                        ),
                      ],
                    ),
                  );
                },
              );
              
              // Import payment service dynamically
              final success = await PaymentGatewayService.openPaymentApp('DANA');
              
              // Close loading dialog and return to previous screen
              if (context.mounted && Navigator.canPop(context)) {
                Navigator.of(context).pop();
                Navigator.pop(context, 'DANA');
              }
              
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tidak dapat membuka aplikasi DANA. Coba metode lain.'),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
              
              if (onPaymentSelected != null) {
                onPaymentSelected!();
              }
            },
          ),

          const SizedBox(height: 24),

          // Bank Transfer Section
          _buildSectionTitle('Bank Transfer'),
          const SizedBox(height: 12),
          
          PaymentMethodTile(
            name: 'Bank BCA',
            imageAsset: 'assets/img_bank_bca.png',
            onTap: () async {
              // Tampilkan loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: greenColor),
                        const SizedBox(height: 20),
                        Text(
                          'Membuka Bank BCA...',
                          style: greyTextStyle,
                        ),
                      ],
                    ),
                  );
                },
              );
              
              final success = await PaymentGatewayService.openPaymentApp('Bank BCA');
              
              // Close loading dialog and return to previous screen
              if (context.mounted && Navigator.canPop(context)) {
                Navigator.of(context).pop();
                Navigator.pop(context, 'Bank BCA');
              }
              
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tidak dapat membuka aplikasi Bank BCA. Coba metode lain.'),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
              
              if (onPaymentSelected != null) {
                onPaymentSelected!();
              }
            },
          ),
          
          PaymentMethodTile(
            name: 'Bank BNI',
            imageAsset: 'assets/img_bank_bni.png',
            onTap: () async {
              // Tampilkan loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: greenColor),
                        const SizedBox(height: 20),
                        Text(
                          'Membuka Bank BNI...',
                          style: greyTextStyle,
                        ),
                      ],
                    ),
                  );
                },
              );
              
              final success = await PaymentGatewayService.openPaymentApp('Bank BNI');
              
              // Close loading dialog and return to previous screen
              if (context.mounted && Navigator.canPop(context)) {
                Navigator.of(context).pop();
                Navigator.pop(context, 'Bank BNI');
              }
              
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tidak dapat membuka aplikasi Bank BNI. Coba metode lain.'),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
              
              if (onPaymentSelected != null) {
                onPaymentSelected!();
              }
            },
          ),
          
          PaymentMethodTile(
            name: 'Bank Mandiri',
            imageAsset: 'assets/img_bank_mandiri.png',
            onTap: () async {
              // Tampilkan loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: greenColor),
                        const SizedBox(height: 20),
                        Text(
                          'Membuka Bank Mandiri...',
                          style: greyTextStyle,
                        ),
                      ],
                    ),
                  );
                },
              );
              
              final success = await PaymentGatewayService.openPaymentApp('Bank Mandiri');
              
              // Close loading dialog and return to previous screen
              if (context.mounted && Navigator.canPop(context)) {
                Navigator.of(context).pop();
                Navigator.pop(context, 'Bank Mandiri');
              }
              
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tidak dapat membuka aplikasi Bank Mandiri. Coba metode lain.'),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
              
              if (onPaymentSelected != null) {
                onPaymentSelected!();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Image.asset(
          'assets/img_gerobakss.png',
          height: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: blackTextStyle.copyWith(
            fontSize: 16,
            fontWeight: semiBold,
          ),
        ),
      ],
    );
  }
}

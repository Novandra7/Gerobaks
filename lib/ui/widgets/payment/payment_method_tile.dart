import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/services/payment_gateway_service.dart';

class PaymentMethodTile extends StatelessWidget {
  final String name;
  final String imageAsset;
  final VoidCallback? onTap;
  final bool isActive;

  const PaymentMethodTile({
    super.key,
    required this.name,
    required this.imageAsset,
    this.onTap,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isActive ? () async {
            if (onTap != null) {
              // Show a brief "processing" indicator
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Memilih metode pembayaran: $name'),
                  duration: const Duration(milliseconds: 500),
                ),
              );
              
              onTap!();
            } else {
              // Show loading indicator
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
                          'Membuka $name...',
                          style: greyTextStyle,
                        ),
                      ],
                    ),
                  );
                },
              );
              
              // Default behavior is to open the payment app
              final success = await PaymentGatewayService.openPaymentApp(name);
              
              // Close loading dialog
              if (context.mounted && Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
              
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tidak dapat membuka aplikasi $name. Coba metode lain.'),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            }
          } : null,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: isActive ? whiteColor : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive ? Colors.grey.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
                width: 1,
              ),
              boxShadow: isActive ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 20,
              ),
              child: Row(
                children: [
                  // Payment Icon
                  Container(
                    width: 50,
                    height: 50,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      imageAsset,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: blackTextStyle.copyWith(
                            fontSize: 16,
                            fontWeight: semiBold,
                            color: isActive ? Colors.black : Colors.grey,
                          ),
                        ),
                        Text(
                          'Tap untuk membuka aplikasi',
                          style: greyTextStyle.copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isActive ? greenColor : Colors.grey,
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

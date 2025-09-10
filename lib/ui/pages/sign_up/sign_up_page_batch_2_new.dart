import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:flutter/material.dart';

class SignUpBatch2Page extends StatefulWidget {
  const SignUpBatch2Page({super.key});

  @override
  State<SignUpBatch2Page> createState() => _SignUpBatch2PageState();
}

class _SignUpBatch2PageState extends State<SignUpBatch2Page> {
  final _formKey = GlobalKey<FormState>();
  
  @override
  void initState() {
    super.initState();
    
    // Tunggu sejenak kemudian lanjut ke langkah berikutnya
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        if (arguments != null) {
          // Lanjut ke batch 3 dengan data yang sama dan OTP dummy
          Navigator.pushReplacementNamed(
            context,
            '/sign-up-batch-3',
            arguments: {
              ...arguments,
              'otpCode': 'skip_verification', // Tambahkan dummy OTP untuk kompatibilitas
            },
          );
        } else {
          // Jika tidak ada data, kembali ke langkah 1
          Navigator.pushReplacementNamed(context, '/sign-up-batch-1');
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(greenColor),
              ),
              const SizedBox(height: 24),
              Text(
                'Melanjutkan ke langkah berikutnya...',
                style: blackTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: medium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:bank_sha/shared/theme.dart';
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
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _canResend = false;
    _countDown = 120;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countDown > 0) {
          _countDown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  String get _formattedTime {
    int minutes = _countDown ~/ 60;
    int seconds = _countDown % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  // Send OTP via notification
  Future<void> _sendOTP(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      return;
    }
    
    try {
      await _otpService.sendOTP(phoneNumber);
      
      // Show a toast or snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Kode OTP telah dikirim ke $phoneNumber',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal mengirim OTP: ${e.toString()}',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final phone = arguments?['phone'] ?? '';

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
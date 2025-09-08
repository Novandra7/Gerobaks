import 'dart:async';
import 'package:bank_sha/services/qris_service.dart';
import 'package:bank_sha/services/subscription_service.dart';
import 'package:bank_sha/models/subscription_model.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:bank_sha/ui/pages/end_user/subscription/payment_success_page.dart';
import 'package:flutter/material.dart';

class QRISPaymentPage extends StatefulWidget {
  final int amount;
  final String transactionId;
  final String description;
  final Map<String, dynamic>? returnData;

  const QRISPaymentPage({
    super.key,
    required this.amount,
    required this.transactionId,
    required this.description,
    this.returnData,
  });

  @override
  State<QRISPaymentPage> createState() => _QRISPaymentPageState();
}

class _QRISPaymentPageState extends State<QRISPaymentPage> {
  final QRISService _qrisService = QRISService();
  bool _isVerifying = false;
  bool _isPaymentCompleted = false;
  Timer? _verificationTimer;
  int _countDown = 300; // 5 menit (dalam detik)

  @override
  void initState() {
    super.initState();
    _startVerificationTimer();
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    super.dispose();
  }

  void _startVerificationTimer() {
    _verificationTimer?.cancel();
    _verificationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countDown > 0) {
          _countDown--;
        } else {
          _verificationTimer?.cancel();
          _navigateToTimeout();
        }
      });
    });

    // Mulai polling verifikasi pembayaran
    _startPaymentVerification();
  }

  Future<void> _startPaymentVerification() async {
    // Polling setiap 5 detik untuk memeriksa status pembayaran
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_isPaymentCompleted) {
        timer.cancel();
        return;
      }

      final isVerified = await _qrisService.validatePayment(widget.transactionId);
      
      if (isVerified) {
        setState(() {
          _isPaymentCompleted = true;
        });
        timer.cancel();
        _verificationTimer?.cancel();
        
        // Navigasi ke halaman sukses setelah delay singkat
        Future.delayed(const Duration(seconds: 1), () {
          _navigateToSuccess();
        });
      }
    });
  }

  void _navigateToSuccess() {
    Navigator.pushReplacementNamed(
      context, 
      '/payment-success',
      arguments: {
        'amount': widget.amount,
        'transactionId': widget.transactionId,
      }
    );
  }

  void _navigateToTimeout() {
    Navigator.pushReplacementNamed(
      context, 
      '/payment-timeout',
      arguments: {
        'amount': widget.amount,
        'transactionId': widget.transactionId,
      }
    );
  }

  void _checkPaymentManually() async {
    setState(() {
      _isVerifying = true;
    });

    try {
      // Untuk pengembangan, langsung arahkan ke halaman sukses tanpa verifikasi
      setState(() {
        _isPaymentCompleted = true;
      });
      _verificationTimer?.cancel();
      
      // Cek apakah pembayaran ini untuk langganan
      if (widget.returnData != null && 
          widget.returnData!.containsKey('plan') && 
          widget.returnData!.containsKey('paymentMethod')) {
        
        // Proses langganan
        await _processSubscriptionPayment();
      } else {
        // Pembayaran normal
        _navigateToSuccess();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Terjadi kesalahan saat verifikasi pembayaran: ${e.toString()}',
            style: whiteTextStyle.copyWith(fontSize: 14),
          ),
          backgroundColor: redcolor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }
  
  Future<void> _processSubscriptionPayment() async {
    try {
      // Import subscription service
      final subscriptionService = SubscriptionService();
      await subscriptionService.initialize();
      
      final plan = widget.returnData!['plan'] as SubscriptionPlan;
      final paymentMethod = widget.returnData!['paymentMethod'] as PaymentMethod;
      final isFromSignup = widget.returnData!['isFromSignup'] as bool? ?? false;
      
      final subscription = await subscriptionService.processPayment(
        plan, 
        paymentMethod,
      );
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessPage(
              subscription: subscription,
              isFromSignup: isFromSignup,
            ),
          ),
        );
      }
    } catch (e) {
      throw Exception('Proses pembayaran langganan gagal: ${e.toString()}');
    }
  }

  String get _formattedTime {
    int minutes = _countDown ~/ 60;
    int seconds = _countDown % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get _formattedAmount {
    final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return 'Rp ${widget.amount.toString().replaceAllMapped(formatter, (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: Text(
          'Pembayaran QRIS',
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header information
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                color: greyColor.withOpacity(0.1),
                child: Column(
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: greyTextStyle.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formattedAmount,
                      style: blackTextStyle.copyWith(
                        fontSize: 24,
                        fontWeight: bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      style: greyTextStyle.copyWith(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // QR Code
              Container(
                padding: const EdgeInsets.all(16.0),
                width: 280,
                height: 320,
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 250,
                      width: 250,
                      child: _qrisService.generateQRCodeWidget(widget.amount),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ID: ${widget.transactionId}',
                      style: greyTextStyle.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Timer
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Selesaikan pembayaran dalam',
                      style: greyTextStyle.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formattedTime,
                      style: blackTextStyle.copyWith(
                        fontSize: 22,
                        fontWeight: semiBold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              
              // Instructions
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cara Pembayaran:',
                      style: blackTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: semiBold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInstructionItem(
                      '1',
                      'Buka aplikasi e-wallet atau m-banking Anda',
                    ),
                    _buildInstructionItem(
                      '2',
                      'Pilih menu Scan QRIS atau Scan QR Code',
                    ),
                    _buildInstructionItem(
                      '3',
                      'Scan QR Code di atas',
                    ),
                    _buildInstructionItem(
                      '4',
                      'Konfirmasi dan selesaikan pembayaran',
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Check payment button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CustomFilledButton(
                  title: 'Cek Status Pembayaran',
                  isLoading: _isVerifying,
                  onPressed: _checkPaymentManually,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Cancel payment button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CustomTextButton(
                  title: 'Batalkan',
                  onPressed: () {
                    _verificationTimer?.cancel();
                    
                    // Jika dari halaman gateway, kembalikan ke halaman tersebut
                    if (widget.returnData != null) {
                      Navigator.pop(context);
                    } else {
                      // Kembali ke halaman checkout
                      Navigator.pushReplacementNamed(context, '/checkout');
                    }
                  },
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInstructionItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: greenColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: whiteTextStyle.copyWith(
                  fontWeight: semiBold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: blackTextStyle.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

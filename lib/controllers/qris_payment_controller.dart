import 'dart:async';
import 'package:bank_sha/ui/pages/end_user/payment/qris_payment_page.dart';
import 'package:bank_sha/services/qris_webview_service.dart';
import 'package:flutter/material.dart';

/// Controller untuk menangani pembayaran QRIS
class QRISPaymentController {
  static final QRISPaymentController _instance =
      QRISPaymentController._internal();
  factory QRISPaymentController() => _instance;
  QRISPaymentController._internal();

  final QRISWebviewService _qrisService = QRISWebviewService();

  /// Inisialisasi service QRIS
  Future<void> initialize() async {
    await _qrisService.initialize();
  }

  /// Buka halaman pembayaran QRIS
  Future<bool> startPayment({
    required BuildContext context,
    required int amount,
    required String orderId,
  }) async {
    final completer = Completer<bool>();

    // Navigasi ke halaman pembayaran
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QRISPaymentPage(
          amount: amount,
          orderId: orderId,
          onPaymentComplete: (success) {
            // Selesaikan completer dengan hasil pembayaran
            completer.complete(success);
            Navigator.of(context).pop();
          },
        ),
      ),
    );

    // Tunggu hasil pembayaran
    return completer.future;
  }

  /// Generate kode QRIS dan mengembalikan hasil sebagai Base64
  Future<String> generateQRIS(int amount) async {
    return await _qrisService.generateQRIS(amount);
  }

  /// Widget QR code untuk ditampilkan
  Widget buildQRWidget(int amount, {double size = 300}) {
    return _qrisService.buildQRWidget(amount, size: size);
  }
}

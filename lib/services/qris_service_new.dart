import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../config/qris_config.dart';

/// Service untuk mengelola pembayaran QRIS
///
/// Service ini mendukung:
/// - Pembuatan kode QRIS dinamis berdasarkan jumlah
/// - Menampilkan QR code sebagai widget Flutter
/// - Mengkonversi QR code ke format Base64 untuk integrasi dengan sistem lain
/// - Validasi pembayaran melalui simulasi atau API payment gateway
class QRISService {
  static final QRISService _instance = QRISService._internal();
  
  /// Singleton factory
  factory QRISService() => _instance;
  
  QRISService._internal();

  /// Generate QRIS code dengan jumlah tertentu
  /// 
  /// [amount] adalah jumlah pembayaran dalam format integer (Rp)
  String generate(int amount) {
    final payload = _buildQrisPayload(amount);
    final crc = _calculateCRC16(payload);
    return payload + crc;
  }
  
  /// Membangun QRIS payload berdasarkan spesifikasi QRIS
  String _buildQrisPayload(int amount) {
    // Format jumlah dengan 2 desimal
    String amountStr = amount.toStringAsFixed(2);
    
    // Format standar QRIS:
    // 000201 = Format Indicator & QR Code Version (fixed)
    // 010211 = Initiation Point Method (fixed for static)
    // 2606 = Merchant Account Information prefix + length + value
    // 52xxxx = Category Code + Merchant ID
    // 53xx = Currency Code (360 for IDR)
    // 54xxxx = Amount
    // 5802ID = Country Code
    // 59xx = Merchant Name
    // 60xx = Merchant City
    // 61xx = Postal Code
    // 6304 = CRC (akan ditambahkan terpisah)
    
    Map<String, String> qrisTags = {
      '00': '01', // Payload Format Indicator (01 = QR Code)
      '01': '11', // Point of Initiation Method (11 = static, 12 = dynamic)
      '26': QrisConfig.merchantAccountInformation, // Merchant Account Information
      '52': '0000', // Merchant Category Code (MCC)
      '53': '360', // Transaction Currency (360 = IDR)
      '54': amountStr, // Transaction Amount
      '58': 'ID', // Country Code
      '59': QrisConfig.merchantName, // Merchant Name
      '60': QrisConfig.city, // Merchant City
      '61': QrisConfig.postalCode, // Postal Code
    };
    
    // Build the QRIS payload
    StringBuffer qrisCode = StringBuffer();
    qrisTags.forEach((key, value) {
      // Add tag + length (2 digits) + value
      final length = value.length.toString().padLeft(2, '0');
      qrisCode.write('$key$length$value');
    });
    
    return qrisCode.toString();
  }
  
  /// Implementasi CRC16 untuk QRIS
  String _calculateCRC16(String payload) {
    // CRC16 CCITT implementation
    final data = utf8.encode('${payload}6304');
    int crc = 0xFFFF;
    
    for (int byte in data) {
      crc ^= byte << 8;
      for (int i = 0; i < 8; i++) {
        if ((crc & 0x8000) != 0) {
          crc = ((crc << 1) ^ 0x1021) & 0xFFFF;
        } else {
          crc = (crc << 1) & 0xFFFF;
        }
      }
    }
    
    // Format as 4 character hex
    return crc.toRadixString(16).padLeft(4, '0').toUpperCase();
  }

  /// Generate QR Code sebagai widget Flutter
  /// 
  /// [amount] adalah jumlah pembayaran dalam format integer (Rp)
  /// [size] adalah ukuran QR code dalam pixel (default 300)
  Widget generateQRCodeWidget(int amount, {double size = 300}) {
    final String qrisCode = generate(amount);
    
    return QrImageView(
      data: qrisCode,
      version: QrVersions.auto,
      size: size,
      backgroundColor: Colors.white,
      errorStateBuilder: (ctx, err) {
        return Container(
          width: size,
          height: size,
          color: Colors.white,
          child: Center(
            child: Text(
              "Error generating QR Code",
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
      },
    );
  }
  
  /// Generate QR Code sebagai image Base64
  /// 
  /// [amount] adalah jumlah pembayaran dalam format integer (Rp)
  /// [size] adalah ukuran QR code dalam pixel (default 300)
  /// 
  /// Returns: String dalam format data:image/png;base64,...
  Future<String> generateBase64(int amount, {double size = 300}) async {
    try {
      final String qrisCode = generate(amount);
      
      // Create a QR painting
      final qrPainter = QrPainter(
        data: qrisCode,
        version: QrVersions.auto,
        color: Colors.black,
        emptyColor: Colors.white,
        gapless: true,
      );

      // Convert to image
      final picSize = Size(size, size);
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawColor(Colors.white, BlendMode.src);
      qrPainter.paint(canvas, picSize);
      
      final picture = recorder.endRecording();
      final img = await picture.toImage(size.toInt(), size.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) return "";
      
      final bytes = byteData.buffer.asUint8List();
      final base64 = base64Encode(bytes);
      
      return "data:image/png;base64,$base64";
    } catch (e) {
      print("Error generating QRIS Base64: $e");
      return "";
    }
  }
  
  /// Metode untuk memvalidasi pembayaran
  /// 
  /// [transactionId] adalah ID transaksi yang perlu divalidasi
  /// 
  /// Dalam implementasi nyata, ini akan memanggil API payment gateway
  /// Saat ini ini adalah simulasi dengan delay 2 detik dan selalu sukses
  Future<bool> validatePayment(String transactionId) async {
    try {
      // Implementasi validasi pembayaran
      // Biasanya melibatkan API call ke payment gateway
      
      // Dummy implementation
      await Future.delayed(Duration(seconds: 2));
      return true;
    } catch (e) {
      print("Error validating payment: $e");
      return false;
    }
  }
}

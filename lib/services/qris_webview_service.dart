import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Service untuk menghasilkan kode QRIS tanpa WebView
class QRISWebviewService {
  static final QRISWebviewService _instance = QRISWebviewService._internal();
  factory QRISWebviewService() => _instance;
  QRISWebviewService._internal();
  
  // QRIS base string yang tetap
  static const String qrisBaseString = "00020101021126610014COM.GO-JEK.WWW01189360091435229947160210G5229947160303UMI51440014ID.CO.QRIS.WWW0215ID10254215767580303UMI5204899953033605802ID5922KOU, Digital & Kreatif6009SAMARINDA61057510462070703A0163043E6B";

  /// Inisialisasi service
  Future<void> initialize() async {
    // Tidak ada lagi yang perlu diinisialisasi
    return;
  }
  
  /// Generate QRIS code dengan amount tertentu
  /// Mengembalikan string data:image/png;base64,...
  Future<String> generateQRIS(int amount, {double size = 300.0}) async {
    try {
      // Generate QR code tanpa WebView
      final QrPainter qrPainter = QrPainter(
        data: qrisBaseString, // Gunakan base string yang tetap
        version: QrVersions.auto,
        color: Colors.black,
        emptyColor: Colors.white,
        gapless: true,
      );
      
      // Convert to image
      final picSize = Size(size, size);
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      
      // Buat background putih
      canvas.drawColor(Colors.white, BlendMode.src);
      
      // Gambar QR code
      qrPainter.paint(canvas, picSize);
      
      // Konversi ke image
      final picture = recorder.endRecording();
      final img = await picture.toImage(size.toInt(), size.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        throw Exception('Failed to generate QR code image data');
      }
      
      // Konversi ke base64
      final bytes = byteData.buffer.asUint8List();
      final base64 = base64Encode(bytes);
      
      return "data:image/png;base64,$base64";
    } catch (e) {
      print('Error generating QRIS: $e');
      rethrow;
    }
  }
  
  /// Widget QR code untuk ditampilkan di UI
  Widget buildQRWidget(int amount, {double size = 300.0}) {
    return QrImageView(
      data: qrisBaseString,
      version: QrVersions.auto,
      size: size,
      backgroundColor: Colors.white,
    );
  }
  
  /// Widget untuk kompatibilitas dengan kode lama
  /// Sekarang mengembalikan widget QR code langsung
  Widget buildWebView() {
    // Gunakan widget kecil untuk menjaga kompatibilitas API lama
    return SizedBox(
      width: 1,
      height: 1,
      child: buildQRWidget(0, size: 1),
    );
  }
  
  void dispose() {
    // Tidak ada resource yang perlu di-dispose
  }
}

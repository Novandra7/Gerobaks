import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class PaymentGatewayService {
  /// Langsung membuka halaman web dari aplikasi pembayaran
  static Future<bool> openPaymentApp(String paymentMethod) async {
    debugPrint('Membuka payment website untuk: $paymentMethod');
    
    // URL-URL yang valid untuk masing-masing metode pembayaran
    String url;
    
    switch (paymentMethod.toLowerCase()) {
      case 'shopeepay':
        url = 'https://shopee.co.id/shopeepay-homepage';
        break;
      
      case 'gopay':
        url = 'https://www.gojek.com/gopay/';
        break;
      
      case 'dana':
        url = 'https://www.dana.id/';
        break;

      case 'bank bca':
        url = 'https://m.klikbca.com/';
        break;
        
      case 'bank bni':
        url = 'https://www.bni.co.id/id-id/';
        break;
        
      case 'bank mandiri':
        url = 'https://ibank.bankmandiri.co.id/';
        break;
        
      default:
        url = 'https://www.google.com/search?q=$paymentMethod+payment';
        break;
    }
    
    debugPrint('Membuka URL: $url');
    
    // Menggunakan versi URL yang lebih simpel
    try {
      final Uri uri = Uri.parse(url);
      
      // Tampilkan di browser external untuk pengalaman yang lebih baik
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Error membuka URL: $e');
      
      // Fallback ke platform default browser
      try {
        final Uri uri = Uri.parse(url);
        return await launchUrl(uri);
      } catch (e) {
        debugPrint('Fallback gagal: $e');
        return false;
      }
    }
  }
}

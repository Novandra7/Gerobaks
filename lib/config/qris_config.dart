import 'package:flutter_dotenv/flutter_dotenv.dart';

class QrisConfig {
  // Dapatkan nilai dari .env atau gunakan default
  static String get idTag26 => dotenv.env['QRIS_ID_TAG_26'] ?? 'ID10220000000000098765432101';
  static String get merchantName => dotenv.env['QRIS_MERCHANT_NAME'] ?? 'GEROBAKS';
  static String get city => dotenv.env['QRIS_CITY'] ?? 'JAKARTA';
  static String get postalCode => dotenv.env['QRIS_POSTAL_CODE'] ?? '12345';
  
  // Format tipe ID untuk QRIS dynamic
  static String get merchantAccountInformation => '2605$idTag26';
  
  // Informasi tambahan untuk QRIS
  static String getMerchantInfo() {
    return '$merchantName - $city ($postalCode)';
  }
}

import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';

/// Kelas helper untuk menampilkan toast/snackbar tanpa menganggu FAB
class ToastHelper {
  /// Menampilkan toast di bagian bawah layar
  /// 
  /// [context] Context dari widget
  /// [message] Pesan yang akan ditampilkan
  /// [isSuccess] Jika true, toast akan berwarna hijau, jika false akan berwarna merah
  /// [duration] Durasi toast ditampilkan
  static void showToast({
    required BuildContext context,
    required String message,
    bool isSuccess = true,
    Duration duration = const Duration(seconds: 2),
  }) {
    final ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Tutup snackbar yang sedang ditampilkan (jika ada)
    scaffoldMessenger.hideCurrentSnackBar();
    
    // Tampilkan snackbar baru
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: whiteTextStyle.copyWith(
            fontSize: 14,
            fontWeight: medium,
          ),
        ),
        backgroundColor: isSuccess ? greenColor : redcolor,
        behavior: SnackBarBehavior.floating,  // Changed from fixed to floating to allow margin
        margin: EdgeInsets.only(
          left: 16, 
          right: 16, 
          bottom: 80 // Memberikan ruang untuk FAB
        ),
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  /// Menampilkan toast dengan ikon
  /// 
  /// [context] Context dari widget
  /// [message] Pesan yang akan ditampilkan
  /// [icon] Ikon yang akan ditampilkan di sebelah kiri pesan
  /// [backgroundColor] Warna latar belakang toast
  /// [duration] Durasi toast ditampilkan
  static void showIconToast({
    required BuildContext context,
    required String message,
    required IconData icon,
    Color backgroundColor = Colors.black87,
    Duration duration = const Duration(seconds: 2),
  }) {
    final ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Tutup snackbar yang sedang ditampilkan (jika ada)
    scaffoldMessenger.hideCurrentSnackBar();
    
    // Tampilkan snackbar baru dengan ikon
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: whiteTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: medium,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

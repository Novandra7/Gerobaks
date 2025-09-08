import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';

/// Custom dialog widget dengan tema putih-hijau untuk Gerobaks
/// 
/// Contoh penggunaan:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (BuildContext context) => CustomDialog(
///     title: 'Judul Dialog',
///     content: 'Konten dialog yang ingin ditampilkan...',
///     positiveButtonText: 'Setuju',
///     negativeButtonText: 'Batal',
///     onPositivePressed: () {
///       // Handling saat tombol positif ditekan
///     },
///     onNegativePressed: () {
///       // Optional: handling saat tombol negatif ditekan
///       Navigator.pop(context);
///     },
///     icon: Icons.info_outline, // Optional: ikon untuk ditampilkan
///   ),
/// );
/// ```
class CustomDialog extends StatelessWidget {
  /// Judul dialog yang akan ditampilkan
  final String title;
  
  /// Konten/pesan dialog
  final String content;
  
  /// Teks untuk tombol positif (primary action)
  final String positiveButtonText;
  
  /// Teks untuk tombol negatif (secondary action), opsional
  final String? negativeButtonText;
  
  /// Function yang akan dipanggil saat tombol positif ditekan
  final VoidCallback onPositivePressed;
  
  /// Function yang akan dipanggil saat tombol negatif ditekan, opsional
  final VoidCallback? onNegativePressed;
  
  /// Ikon opsional untuk ditampilkan di atas judul dialog
  final IconData? icon;
  
  /// Widget konten kustom sebagai alternatif konten text
  final Widget? customContent;
  
  /// Boolean untuk menampilkan loading indicator pada tombol positif
  final bool isLoading;

  const CustomDialog({
    super.key,
    required this.title,
    required this.content,
    required this.positiveButtonText,
    required this.onPositivePressed,
    this.negativeButtonText,
    this.onNegativePressed,
    this.icon,
    this.customContent,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          // Border tipis untuk efek lebih elegan
          border: Border.all(
            color: greenColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon jika ada
            if (icon != null) ...[
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: greenColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: greenColor,
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Judul dengan styling hijau
            Text(
              title,
              style: blackTextStyle.copyWith(
                fontSize: 18,
                fontWeight: semiBold,
                color: greenColor, // Judul berwarna hijau
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Konten dialog
            customContent ?? Text(
              content,
              style: greyTextStyle.copyWith(
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Tombol dengan styling sesuai tema
            Row(
              children: [
                // Tombol negatif jika ada
                if (negativeButtonText != null) ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onNegativePressed ?? () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.withOpacity(0.1),
                        foregroundColor: greyColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        negativeButtonText!,
                        style: greyTextStyle.copyWith(
                          fontWeight: semiBold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                
                // Tombol positif (primary action)
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onPositivePressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: greenColor,
                      foregroundColor: whiteColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // Disable button saat loading
                      disabledBackgroundColor: greenColor.withOpacity(0.6),
                      disabledForegroundColor: whiteColor.withOpacity(0.8),
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(whiteColor),
                            ),
                          )
                        : Text(
                            positiveButtonText,
                            style: whiteTextStyle.copyWith(
                              fontWeight: semiBold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog konfirmasi yang lebih simpel dengan tema putih-hijau
class CustomConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final IconData? icon;
  final bool isDestructiveAction; // Untuk aksi berbahaya seperti delete

  const CustomConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Ya',
    this.cancelText = 'Batal',
    required this.onConfirm,
    this.onCancel,
    this.icon,
    this.isDestructiveAction = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color actionColor = isDestructiveAction ? Colors.red : greenColor;
    
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: actionColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon jika ada
            if (icon != null) ...[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: actionColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: actionColor,
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Judul
            Text(
              title,
              style: blackTextStyle.copyWith(
                fontSize: 18,
                fontWeight: semiBold,
                color: actionColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Pesan
            Text(
              message,
              style: greyTextStyle.copyWith(
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Tombol
            Row(
              children: [
                // Tombol batal
                Expanded(
                  child: ElevatedButton(
                    onPressed: onCancel ?? () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      foregroundColor: greyColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      cancelText,
                      style: greyTextStyle.copyWith(
                        fontWeight: semiBold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Tombol confirm
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: actionColor,
                      foregroundColor: whiteColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      confirmText,
                      style: whiteTextStyle.copyWith(
                        fontWeight: semiBold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog alert simpel dengan tema putih-hijau
class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isError;

  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'OK',
    this.onPressed,
    this.icon,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color themeColor = isError ? Colors.red : greenColor;
    
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: themeColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon jika ada
            if (icon != null) ...[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: themeColor,
                ),
              ),
              const SizedBox(height: 16),
            ] else if (isError) ...[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 28,
                  color: themeColor,
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Judul
            Text(
              title,
              style: blackTextStyle.copyWith(
                fontSize: 18,
                fontWeight: semiBold,
                color: themeColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Pesan
            Text(
              message,
              style: greyTextStyle.copyWith(
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Tombol OK
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed ?? () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: whiteColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: whiteTextStyle.copyWith(
                    fontWeight: semiBold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

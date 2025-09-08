import 'package:flutter/material.dart';
import 'custom_dialog.dart';

/// Utility class untuk menampilkan dialog dengan lebih mudah
class DialogHelper {
  /// Menampilkan dialog informasi umum
  static Future<void> showInfoDialog({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
    IconData icon = Icons.info_outline,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) => CustomAlertDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        onPressed: onPressed,
        icon: icon,
      ),
    );
  }

  /// Menampilkan dialog sukses
  static Future<void> showSuccessDialog({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) => CustomAlertDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        onPressed: onPressed,
        icon: Icons.check_circle_outline,
      ),
    );
  }

  /// Menampilkan dialog error
  static Future<void> showErrorDialog({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) => CustomAlertDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        onPressed: onPressed,
        isError: true,
        icon: Icons.error_outline,
      ),
    );
  }

  /// Menampilkan dialog konfirmasi yang mengembalikan boolean
  static Future<bool> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Ya',
    String cancelText = 'Batal',
    IconData? icon,
    bool isDestructiveAction = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => CustomConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
        isDestructiveAction: isDestructiveAction,
        onConfirm: () {
          Navigator.of(context).pop(true);
        },
        onCancel: () {
          Navigator.of(context).pop(false);
        },
      ),
    );
    
    return result ?? false;
  }

  /// Menampilkan dialog untuk aksi berbahaya (seperti hapus)
  static Future<bool> showDeleteConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Hapus',
    String cancelText = 'Batal',
  }) async {
    return showConfirmDialog(
      context: context,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      icon: Icons.delete_outline,
      isDestructiveAction: true,
    );
  }

  /// Menampilkan dialog loading
  static Future<void> showLoadingDialog({
    required BuildContext context,
    required String message,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Menutup dialog loading
  static void closeDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
  
  /// Menampilkan dialog custom dengan content widget kustom
  static Future<void> showCustomDialog({
    required BuildContext context,
    required String title,
    required String positiveButtonText,
    required VoidCallback onPositivePressed,
    String? negativeButtonText,
    VoidCallback? onNegativePressed,
    IconData? icon,
    Widget? customContent,
    bool isLoading = false,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        title: title,
        content: '', // Content string kosong karena menggunakan customContent
        positiveButtonText: positiveButtonText,
        onPositivePressed: onPositivePressed,
        negativeButtonText: negativeButtonText,
        onNegativePressed: onNegativePressed,
        icon: icon,
        customContent: customContent,
        isLoading: isLoading,
      ),
    );
  }
}

import 'package:bank_sha/ui/widgets/shared/custom_dialog.dart';
import 'package:bank_sha/ui/widgets/shared/dialog_helper.dart';
import 'package:flutter/material.dart';

/// Mixin to provide consistent dialog methods across the app
mixin AppDialogMixin<T extends StatefulWidget> on State<T> {
  
  /// Show a standard information dialog
  Future<void> showAppInfoDialog({
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    return DialogHelper.showInfoDialog(
      context: context,
      title: title,
      message: message,
      buttonText: buttonText,
      onPressed: onPressed ?? () {
        Navigator.of(context).pop();
      },
    );
  }
  
  /// Show a success dialog
  Future<void> showAppSuccessDialog({
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    return DialogHelper.showSuccessDialog(
      context: context,
      title: title,
      message: message,
      buttonText: buttonText,
      onPressed: onPressed ?? () {
        Navigator.of(context).pop();
      },
    );
  }
  
  /// Show an error dialog
  Future<void> showAppErrorDialog({
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    return DialogHelper.showErrorDialog(
      context: context,
      title: title,
      message: message,
      buttonText: buttonText,
      onPressed: onPressed ?? () {
        Navigator.of(context).pop();
      },
    );
  }
  
  /// Show a confirmation dialog
  Future<bool> showAppConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Ya',
    String cancelText = 'Batal',
    IconData? icon,
  }) {
    return DialogHelper.showConfirmDialog(
      context: context,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      icon: icon,
    );
  }
  
  /// Show a loading dialog
  Future<void> showAppLoadingDialog({
    required String message,
  }) {
    return DialogHelper.showLoadingDialog(
      context: context,
      message: message,
    );
  }
  
  /// Show a custom dialog
  Future<T?> showAppCustomDialog<T>({
    required String title,
    required String content,
    required String positiveButtonText,
    required VoidCallback onPositivePressed,
    String? negativeButtonText,
    VoidCallback? onNegativePressed,
    IconData? icon,
    Widget? customContent,
    bool isLoading = false,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => CustomDialog(
        title: title,
        content: content,
        positiveButtonText: positiveButtonText,
        onPositivePressed: onPositivePressed,
        negativeButtonText: negativeButtonText,
        onNegativePressed: onNegativePressed ?? () {
          Navigator.of(context).pop();
        },
        icon: icon,
        customContent: customContent,
        isLoading: isLoading,
      ),
    );
  }
}

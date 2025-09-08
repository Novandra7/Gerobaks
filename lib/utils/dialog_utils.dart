import 'package:bank_sha/ui/widgets/shared/dialog_helper.dart';
import 'package:flutter/material.dart';

class DialogUtils {
  /// Function to convert a standard AlertDialog to our custom dialog
  static Future<T?> showCustomDialogFromAlert<T>({
    required BuildContext context,
    required AlertDialog alertDialog,
    bool barrierDismissible = true,
  }) {
    // Get the title and content from the AlertDialog
    String title = 'Information';
    if (alertDialog.title is Text) {
      title = (alertDialog.title as Text).data ?? title;
    }
    
    String message = '';
    if (alertDialog.content is Text) {
      message = (alertDialog.content as Text).data ?? message;
    }
    
    // Get button text from actions if available
    String buttonText = 'OK';
    if (alertDialog.actions != null && alertDialog.actions!.isNotEmpty) {
      if (alertDialog.actions![0] is TextButton) {
        final textButton = alertDialog.actions![0] as TextButton;
        if (textButton.child is Text) {
          buttonText = (textButton.child as Text).data ?? buttonText;
        }
      }
    }
    
    // Use our custom dialog helper
    return DialogHelper.showInfoDialog(
      context: context,
      title: title,
      message: message,
      buttonText: buttonText,
      onPressed: () {
        Navigator.of(context).pop();
      },
    ) as Future<T?>;
  }
  
  /// Shows a standard error dialog using our custom dialog
  static Future<void> showErrorDialog({
    required BuildContext context,
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
      onPressed: onPressed,
    );
  }
  
  /// Shows a standard success dialog using our custom dialog
  static Future<void> showSuccessDialog({
    required BuildContext context,
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
      onPressed: onPressed,
    );
  }
}

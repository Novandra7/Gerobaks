# Custom Dialog Integration Documentation

## Overview

This document outlines the changes made to implement custom dialogs throughout the Gerobaks application, replacing standard Flutter dialogs with custom, branded dialogs that match the app's design language.

## Custom Dialog Components

### 1. CustomDialog
- Located in `lib/ui/widgets/shared/custom_dialog.dart`
- Used for complex dialogs requiring multiple buttons and/or custom content
- Features:
  - Title with optional icon
  - Content text or custom widget
  - Primary and secondary buttons
  - Loading state for buttons
  - Consistent styling with app's theme

### 2. CustomAlertDialog
- Located in `lib/ui/widgets/shared/custom_dialog.dart`
- Used for simple alerts with a single button
- Features:
  - Title with optional icon
  - Message text
  - Single button with customizable text
  - Support for error styling

### 3. CustomConfirmDialog
- Located in `lib/ui/widgets/shared/custom_dialog.dart`
- Used for confirmation dialogs with confirm/cancel actions
- Features:
  - Title with optional icon
  - Message text
  - Confirm and cancel buttons
  - Destructive action styling option

### 4. RescheduleDialog
- Located in `lib/ui/widgets/shared/reschedule_dialog.dart`
- Specialized dialog for date and time selection
- Features:
  - Date picker with custom styling
  - Time picker with custom styling
  - Confirm and cancel buttons

## DialogHelper Utility

- Located in `lib/ui/widgets/shared/dialog_helper.dart`
- Provides easy access to common dialog types:
  - `showInfoDialog()`: Informational dialogs
  - `showSuccessDialog()`: Success messages
  - `showErrorDialog()`: Error messages
  - `showConfirmDialog()`: Confirmation with yes/no options
  - `showDeleteConfirmDialog()`: Confirmation specifically for delete actions
  - `showLoadingDialog()`: Loading indicators
  - `showCustomDialog()`: For custom content dialogs

## Implementation Changes

### Files Updated:

1. **subscription_guard.dart**
   - Replaced standard AlertDialog with CustomDialog for subscription notifications
   - Added appropriate imports for DialogHelper and theme

2. **activity_detail_modal.dart**
   - Replaced standard AlertDialog with RescheduleDialog for schedule modifications
   - Removed duplicate formatting methods
   - Updated imports to include reschedule_dialog.dart

3. **sign_up_page_batch_5.dart**
   - Replaced confirmation AlertDialog with DialogHelper.showConfirmDialog
   - Replaced success AlertDialog with DialogHelper.showSuccessDialog
   - Fixed syntax errors and improved code structure

## Best Practices for Custom Dialog Usage

1. **Use DialogHelper methods** whenever possible rather than directly using showDialog()
2. **Be consistent with icons**:
   - Info dialogs: `Icons.info_outline`
   - Success dialogs: `Icons.check_circle_outline`
   - Error dialogs: `Icons.error_outline`
   - Warning/Confirm dialogs: `Icons.help_outline` or context-specific
   - Delete confirmations: `Icons.delete_outline`

3. **Button Text Conventions**:
   - Success/Info buttons: "OK", "Mengerti", "Lanjutkan"
   - Confirm buttons: "Ya", "Konfirmasi", "Simpan"
   - Cancel buttons: "Tidak", "Batal", "Kembali"
   - Delete confirm: "Hapus"

4. **Color Usage**:
   - Success/Info: Green (greenColor)
   - Errors: Red (Colors.red)
   - Warning/Confirm: Orange or context-appropriate

## How to Add More Custom Dialogs

To convert remaining standard dialogs to custom dialogs:

1. Search for `showDialog` and `AlertDialog` usage in files
2. Determine the appropriate DialogHelper method based on the dialog's purpose
3. Replace the standard dialog with the appropriate DialogHelper method
4. Update imports if necessary
5. Test to ensure functionality is preserved

## Known Issues

- Some dialogs might still use default styling when using third-party packages
- Date and time picker internal dialogs still use default Flutter styling (Material Design)

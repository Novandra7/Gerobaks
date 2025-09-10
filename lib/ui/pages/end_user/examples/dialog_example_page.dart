import 'package:flutter/material.dart';
import 'package:bank_sha/ui/widgets/shared/dialog_helper.dart';
import 'package:bank_sha/ui/widgets/shared/custom_dialog.dart';

class DialogExamplePage extends StatelessWidget {
  const DialogExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Dialog Examples'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contoh Dialog Putih-Hijau',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Basic Alert Dialog
            _buildExampleButton(
              context: context,
              title: 'Info Dialog',
              onPressed: () {
                DialogHelper.showInfoDialog(
                  context: context,
                  title: 'Informasi',
                  message: 'Ini adalah contoh dialog informasi dengan tema putih-hijau yang sesuai dengan brand Gerobaks.',
                  buttonText: 'Mengerti',
                );
              },
            ),
            
            // Success Dialog
            _buildExampleButton(
              context: context,
              title: 'Success Dialog',
              onPressed: () {
                DialogHelper.showSuccessDialog(
                  context: context,
                  title: 'Berhasil!',
                  message: 'Operasi telah berhasil dilakukan. Anda bisa melanjutkan ke langkah selanjutnya.',
                  buttonText: 'Lanjutkan',
                );
              },
            ),
            
            // Error Dialog
            _buildExampleButton(
              context: context,
              title: 'Error Dialog',
              onPressed: () {
                DialogHelper.showErrorDialog(
                  context: context,
                  title: 'Terjadi Kesalahan',
                  message: 'Maaf, terjadi kesalahan saat memproses permintaan Anda. Silakan coba lagi.',
                  buttonText: 'Coba Lagi',
                );
              },
            ),
            
            // Confirmation Dialog
            _buildExampleButton(
              context: context,
              title: 'Confirmation Dialog',
              onPressed: () {
                DialogHelper.showConfirmDialog(
                  context: context,
                  title: 'Konfirmasi',
                  message: 'Apakah Anda yakin ingin melanjutkan proses ini?',
                  confirmText: 'Ya, Lanjutkan',
                  cancelText: 'Tidak',
                ).then((confirmed) {
                  if (confirmed) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Proses dilanjutkan')),
                    );
                  }
                });
              },
            ),
            
            // Delete Confirmation Dialog
            _buildExampleButton(
              context: context,
              title: 'Delete Confirmation Dialog',
              onPressed: () {
                DialogHelper.showDeleteConfirmDialog(
                  context: context,
                  title: 'Hapus Data?',
                  message: 'Data yang dihapus tidak dapat dikembalikan. Apakah Anda yakin?',
                  confirmText: 'Ya, Hapus',
                  cancelText: 'Batal',
                ).then((confirmed) {
                  if (confirmed) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data dihapus')),
                    );
                  }
                });
              },
            ),
            
            // Loading Dialog
            _buildExampleButton(
              context: context,
              title: 'Loading Dialog',
              onPressed: () async {
                DialogHelper.showLoadingDialog(
                  context: context,
                  message: 'Memproses...',
                );
                
                // Simulate loading time
                await Future.delayed(const Duration(seconds: 2));
                
                // Close loading dialog
                if (context.mounted) {
                  DialogHelper.closeDialog(context);
                  
                  // Show success dialog after loading
                  DialogHelper.showSuccessDialog(
                    context: context,
                    title: 'Proses Selesai',
                    message: 'Data berhasil diproses!',
                  );
                }
              },
            ),
            
            // Custom Dialog with More Options
            _buildExampleButton(
              context: context,
              title: 'Custom Dialog (Manual)',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => CustomDialog(
                    title: 'Custom Dialog',
                    content: 'Ini adalah contoh dialog yang langsung menggunakan widget CustomDialog tanpa helper. Anda bisa menyesuaikan lebih banyak parameter disini.',
                    positiveButtonText: 'OK',
                    negativeButtonText: 'Batal',
                    icon: Icons.design_services,
                    onPositivePressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tombol OK ditekan')),
                      );
                    },
                    onNegativePressed: () {
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
            
            // Custom Dialog with Loading State
            _buildExampleButton(
              context: context,
              title: 'Dialog with Loading',
              onPressed: () {
                _showDialogWithLoading(context);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildExampleButton({
    required BuildContext context,
    required String title,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(title),
      ),
    );
  }
  
  void _showDialogWithLoading(BuildContext context) {
    bool isLoading = false;
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return CustomDialog(
              title: 'Simpan Perubahan',
              content: 'Simpan perubahan yang sudah Anda lakukan?',
              positiveButtonText: 'Simpan',
              negativeButtonText: 'Batal',
              icon: Icons.save_outlined,
              isLoading: isLoading,
              onPositivePressed: () async {
                // Set loading state
                setState(() {
                  isLoading = true;
                });
                
                // Simulate loading time
                await Future.delayed(const Duration(seconds: 2));
                
                // Close dialog
                Navigator.pop(dialogContext);
                
                if (context.mounted) {
                  // Show success dialog
                  DialogHelper.showSuccessDialog(
                    context: context,
                    title: 'Tersimpan',
                    message: 'Perubahan berhasil disimpan.',
                  );
                }
              },
              onNegativePressed: () {
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}

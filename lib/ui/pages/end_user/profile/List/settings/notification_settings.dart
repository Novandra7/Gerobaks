import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';
import 'package:bank_sha/services/notification_service.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  final NotificationService _notificationService = NotificationService();
  bool _routinePantunEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final isEnabled = await _notificationService.isRoutinePantunEnabled();
      if (mounted) {
        setState(() {
          _routinePantunEnabled = isEnabled;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleRoutinePantun(bool value) async {
    setState(() {
      _routinePantunEnabled = value;
    });

    try {
      if (value) {
        await _notificationService.enableRoutinePantun();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Notifikasi pantun rutin telah diaktifkan'),
              backgroundColor: greenColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        await _notificationService.disableRoutinePantun();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Notifikasi pantun rutin telah dinonaktifkan'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      // Rollback if error
      setState(() {
        _routinePantunEnabled = !value;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengubah pengaturan: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: uicolor,
      appBar: const CustomAppNotif(
        title: 'Pengaturan Notifikasi',
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: greenColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.notifications_active,
                                color: greenColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Notifikasi Aplikasi',
                                    style: blackTextStyle.copyWith(
                                      fontSize: 18,
                                      fontWeight: semiBold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Kelola pengaturan notifikasi Gerobaks',
                                    style: greyTextStyle.copyWith(
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Routine Pantun Settings
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _routinePantunEnabled 
                                    ? greenColor.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.auto_stories,
                                color: _routinePantunEnabled ? greenColor : Colors.grey,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pantun Motivasi Rutin',
                                    style: blackTextStyle.copyWith(
                                      fontSize: 16,
                                      fontWeight: semiBold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Terima pantun motivasi setiap 30-60 menit untuk mengingatkan Anda menggunakan aplikasi',
                                    style: greyTextStyle.copyWith(
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _routinePantunEnabled,
                              onChanged: _toggleRoutinePantun,
                              activeThumbColor: greenColor,
                            ),
                          ],
                        ),
                        
                        if (_routinePantunEnabled) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: greenColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: greenColor.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: greenColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Informasi Pantun Rutin',
                                      style: TextStyle(
                                        color: greenColor,
                                        fontSize: 14,
                                        fontWeight: semiBold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '• Pantun akan muncul secara acak setiap 30-60 menit\n'
                                  '• Notifikasi akan tetap berjalan meskipun aplikasi ditutup\n'
                                  '• Berisi motivasi seputar pengelolaan sampah dan lingkungan\n'
                                  '• Dapat dinonaktifkan kapan saja',
                                  style: TextStyle(
                                    color: greenColor.withOpacity(0.8),
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Test button for immediate notification
                  if (_routinePantunEnabled)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Uji Coba Notifikasi',
                            style: blackTextStyle.copyWith(
                              fontSize: 16,
                              fontWeight: semiBold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Kirim pantun motivasi sekarang untuk melihat bagaimana notifikasinya akan tampil',
                            style: greyTextStyle.copyWith(
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                try {
                                  // Show test notification immediately
                                  await _notificationService.showTestRoutinePantun();
                                  
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Pantun uji coba telah dikirim!'),
                                        backgroundColor: greenColor,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Gagal mengirim pantun: $e'),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: greenColor,
                                foregroundColor: whiteColor,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.send,
                                    size: 18,
                                    color: whiteColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Kirim Pantun Sekarang',
                                    style: whiteTextStyle.copyWith(
                                      fontSize: 14,
                                      fontWeight: semiBold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

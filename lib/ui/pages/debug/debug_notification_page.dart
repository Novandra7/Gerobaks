import 'package:flutter/material.dart';
import 'package:bank_sha/services/in_app_notification_service.dart';
import 'package:bank_sha/services/schedule_notification_popup.dart';

/// Debug page untuk test notification banner dan popup
class DebugNotificationPage extends StatelessWidget {
  const DebugNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Notification Banner'),
        backgroundColor: const Color(0xFF1A73E8),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Test In-App Notification Banner & Popup',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Test 2 jenis notifikasi: Banner (atas) dan Popup (tengah)',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // === POP-UP NOTIFICATIONS ===
              const Text(
                '🎯 POP-UP DIALOG (Tengah Layar)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Success Popup
              _TestButton(
                title: '🎉 Test Success Popup',
                subtitle: 'Jadwal Diterima (Dialog)',
                color: const Color(0xFF10B981),
                onPressed: () {
                  print('\n🧪 [DEBUG] Testing SUCCESS POPUP...');
                  ScheduleNotificationPopup.show(
                    context: context,
                    title: 'Jadwal Diterima! 🎉',
                    message:
                        'Mitra Ahmad Kurniawan telah menerima jadwal penjemputan Anda',
                    subtitle: 'Sabtu, 15 Nov 2025 • 14:00',
                    type: ScheduleNotificationPopupType.accepted,
                  );
                },
              ),

              const SizedBox(height: 12),

              // On The Way Popup
              _TestButton(
                title: '🚛 Test On The Way Popup',
                subtitle: 'Mitra Dalam Perjalanan (Dialog)',
                color: const Color(0xFF3B82F6),
                onPressed: () {
                  print('\n🧪 [DEBUG] Testing ON THE WAY POPUP...');
                  ScheduleNotificationPopup.show(
                    context: context,
                    title: 'Mitra Dalam Perjalanan 🚛',
                    message: 'Mitra sedang menuju ke lokasi Anda',
                    subtitle: 'Sabtu, 15 Nov 2025 • 14:00',
                    type: ScheduleNotificationPopupType.onTheWay,
                  );
                },
              ),

              const SizedBox(height: 12),

              // Arrived Popup
              _TestButton(
                title: '📍 Test Arrived Popup',
                subtitle: 'Mitra Sudah Tiba (Dialog)',
                color: const Color(0xFFF59E0B),
                onPressed: () {
                  print('\n🧪 [DEBUG] Testing ARRIVED POPUP...');
                  ScheduleNotificationPopup.show(
                    context: context,
                    title: 'Mitra Sudah Tiba! 📍',
                    message: 'Mitra sudah sampai di lokasi penjemputan',
                    subtitle: 'Sabtu, 15 Nov 2025 • 14:00',
                    type: ScheduleNotificationPopupType.arrived,
                  );
                },
              ),

              const SizedBox(height: 12),

              // Completed Popup
              _TestButton(
                title: '✅ Test Completed Popup',
                subtitle: 'Penjemputan Selesai (Dialog)',
                color: const Color(0xFF059669),
                onPressed: () {
                  print('\n🧪 [DEBUG] Testing COMPLETED POPUP...');
                  ScheduleNotificationPopup.show(
                    context: context,
                    title: 'Penjemputan Selesai! ✅',
                    message: 'Terima kasih telah menggunakan layanan kami',
                    subtitle: '5.5 kg • +55 poin',
                    type: ScheduleNotificationPopupType.completed,
                  );
                },
              ),

              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),

              // === BANNER NOTIFICATIONS ===
              const Text(
                '📋 BANNER (Dari Atas)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Success Banner
              _TestButton(
                title: '🎉 Test Success Banner',
                subtitle: 'Jadwal Diterima (Banner)',
                color: const Color(0xFF10B981).withOpacity(0.7),
                onPressed: () {
                  print('\n🧪 [DEBUG] Testing SUCCESS banner...');
                  InAppNotificationService.show(
                    context: context,
                    title: 'Jadwal Diterima! 🎉',
                    message:
                        'Mitra Ahmad Kurniawan telah menerima jadwal penjemputan Anda',
                    subtitle: 'Sabtu, 15 Nov 2025 • 14:00',
                    type: InAppNotificationType.success,
                    duration: const Duration(seconds: 5),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Info Banner
              _TestButton(
                title: '🚛 Test Info Banner',
                subtitle: 'Mitra On The Way (Banner)',
                color: const Color(0xFF3B82F6).withOpacity(0.7),
                onPressed: () {
                  print('\n🧪 [DEBUG] Testing INFO banner...');
                  InAppNotificationService.show(
                    context: context,
                    title: 'Mitra Dalam Perjalanan 🚛',
                    message: 'Mitra sedang menuju ke lokasi Anda',
                    subtitle: 'Sabtu, 15 Nov 2025 • 14:00',
                    type: InAppNotificationType.info,
                    duration: const Duration(seconds: 5),
                  );
                },
              ),

              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '📝 Instructions:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '🎯 POPUP (Dialog):\n'
                      '  • Muncul di tengah layar\n'
                      '  • Untuk notifikasi penting (jadwal diterima, dll)\n'
                      '  • Auto-dismiss setelah 5 detik\n'
                      '  • Tap atau klik tombol untuk dismiss\n\n'
                      '📋 BANNER (From Top):\n'
                      '  • Muncul dari atas layar\n'
                      '  • Untuk notifikasi ringan\n'
                      '  • Auto-dismiss setelah 5 detik\n'
                      '  • Swipe up atau tap untuk dismiss',
                      style: TextStyle(fontSize: 13, height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                '🔍 Check Console Logs',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TestButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onPressed;

  const _TestButton({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

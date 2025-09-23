import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulasi data notifikasi
    final List<Map<String, dynamic>> notifications = [
      {
        'icon': Icons.eco,
        'title': 'Pengambilan Sampah Organik',
        'message': 'Hari ini pengambilan sampah organik!',
        'time': 'Hari ini, 06:00',
        'color': greenColor,
      },
      {
        'icon': Icons.schedule,
        'title': 'Jadwal Pengangkutan',
        'message': 'Petugas akan datang besok pukul 07.00 pagi.',
        'time': '1 jam yang lalu',
        'color': Colors.blue,
      },
      {
        'icon': Icons.check_circle,
        'title': 'Berhasil Beralangganan',
        'message': 'Berhasil langganan 1 bulan berhasil',
        'time': 'Hari ini, 07:20',
        'color': Colors.green,
      },
    ];
    return Scaffold(
      appBar: const CustomAppNotif(title: 'Notifikasi', showBackButton: true),
      backgroundColor: uicolor,
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada notifikasi baru.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to add schedule page if it's organic waste notification
                    if (notif['title'] == 'Pengambilan Sampah Organik') {
                      Navigator.pushNamed(context, '/add-schedule');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: notif['color'].withOpacity(0.1),
                          child: Icon(
                            notif['icon'],
                            color: notif['color'],
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notif['title'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: notif['color'],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notif['message'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                notif['time'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Add arrow icon for organic waste notification
                        if (notif['title'] == 'Pengambilan Sampah Organik')
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey[400],
                            size: 16,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

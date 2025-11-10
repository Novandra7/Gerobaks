import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/dashboard/dashboard_background.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // Dummy data untuk notifikasi - dalam aplikasi nyata ini akan dari API
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Jadwal Pengambilan Hari Ini',
      'message':
          'Anda memiliki 3 jadwal pengambilan sampah hari ini. Jangan lupa untuk mempersiapkan truk dan peralatan.',
      'time': '08:30',
      'date': 'Hari ini',
      'type': 'schedule',
      'isRead': false,
      'icon': Icons.schedule,
      'color': greenColor,
    },
    {
      'id': '2',
      'title': 'Pembayaran Berhasil',
      'message':
          'Pembayaran untuk layanan premium telah berhasil diproses. Terima kasih!',
      'time': '14:20',
      'date': 'Kemarin',
      'type': 'payment',
      'isRead': false,
      'icon': Icons.payment,
      'color': blueColor,
    },
    {
      'id': '3',
      'title': 'Rating Baru dari Pelanggan',
      'message':
          'Anda mendapat rating 5 bintang dari pelanggan di Jl. Sudirman. Kerja bagus!',
      'time': '16:45',
      'date': 'Kemarin',
      'type': 'rating',
      'isRead': true,
      'icon': Icons.star,
      'color': const Color(0xFFFF8A00),
    },
    {
      'id': '4',
      'title': 'Update Aplikasi Tersedia',
      'message':
          'Versi terbaru aplikasi Gerobaks sudah tersedia. Update sekarang untuk fitur-fitur terbaru.',
      'time': '10:15',
      'date': '2 hari lalu',
      'type': 'update',
      'isRead': true,
      'icon': Icons.system_update,
      'color': purpleColor,
    },
    {
      'id': '5',
      'title': 'Bonus Poin Bulanan',
      'message':
          'Selamat! Anda mendapat bonus 500 poin untuk performa terbaik bulan ini.',
      'time': '09:00',
      'date': '3 hari lalu',
      'type': 'reward',
      'isRead': true,
      'icon': Icons.card_giftcard,
      'color': greenColor,
    },
    {
      'id': '6',
      'title': 'Reminder Pembersihan Truk',
      'message':
          'Jangan lupa untuk membersihkan truk setiap selesai operasional. Kebersihan adalah prioritas.',
      'time': '17:30',
      'date': '1 minggu lalu',
      'type': 'reminder',
      'isRead': true,
      'icon': Icons.cleaning_services,
      'color': blueColor,
    },
  ];

  // Filter untuk menampilkan notifikasi berdasarkan kategori
  String _selectedFilter = 'Semua';
  final List<String> _filterOptions = [
    'Semua',
    'Belum Dibaca',
    'Jadwal',
    'Pembayaran',
    'Rating',
  ];

  List<Map<String, dynamic>> get _filteredNotifications {
    switch (_selectedFilter) {
      case 'Belum Dibaca':
        return _notifications.where((notif) => !notif['isRead']).toList();
      case 'Jadwal':
        return _notifications
            .where((notif) => notif['type'] == 'schedule')
            .toList();
      case 'Pembayaran':
        return _notifications
            .where((notif) => notif['type'] == 'payment')
            .toList();
      case 'Rating':
        return _notifications
            .where((notif) => notif['type'] == 'rating')
            .toList();
      default:
        return _notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications
        .where((notif) => !notif['isRead'])
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FFF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: blackColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifikasi',
              style: blackTextStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (unreadCount > 0)
              Text(
                '$unreadCount belum dibaca',
                style: greyTextStyle.copyWith(fontSize: 12),
              ),
          ],
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Tandai Semua',
                style: greenColor == Colors.green
                    ? TextStyle(
                        color: greenColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      )
                    : TextStyle(
                        color: greenColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: DashboardBackground(
        child: Column(
          children: [
            // Filter Tabs
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _filterOptions.length,
                itemBuilder: (context, index) {
                  final isSelected = _filterOptions[index] == _selectedFilter;
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: _buildFilterButton(
                      _filterOptions[index],
                      isSelected,
                    ),
                  );
                },
              ),
            ),

            // Notification List
            Expanded(
              child: _filteredNotifications.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filteredNotifications.length,
                      itemBuilder: (context, index) {
                        final notification = _filteredNotifications[index];
                        return _buildNotificationCard(notification, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    final isRead = notification['isRead'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isRead
            ? null
            : Border.all(color: greenColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _onNotificationTap(notification),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: notification['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    notification['icon'],
                    color: notification['color'],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification['title'],
                              style: blackTextStyle.copyWith(
                                fontSize: 16,
                                fontWeight: isRead
                                    ? FontWeight.w500
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: greenColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification['message'],
                        style: greyTextStyle.copyWith(
                          fontSize: 14,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: greyColor),
                          const SizedBox(width: 4),
                          Text(
                            '${notification['time']} • ${notification['date']}',
                            style: greyTextStyle.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: greyColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 40,
              color: greyColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tidak ada notifikasi',
            style: blackTextStyle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'Semua'
                ? 'Belum ada notifikasi masuk'
                : 'Tidak ada notifikasi untuk kategori $_selectedFilter',
            style: greyTextStyle.copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _onNotificationTap(Map<String, dynamic> notification) {
    if (!notification['isRead']) {
      setState(() {
        notification['isRead'] = true;
      });
    }

    // Handle different notification types
    switch (notification['type']) {
      case 'schedule':
        _showSnackbar('Membuka jadwal pengambilan...', greenColor);
        // Navigate to schedule page
        break;
      case 'payment':
        _showSnackbar('Membuka riwayat pembayaran...', blueColor);
        // Navigate to payment history
        break;
      case 'rating':
        _showSnackbar('Membuka detail rating...', const Color(0xFFFF8A00));
        // Navigate to rating details
        break;
      case 'update':
        _showSnackbar('Membuka update aplikasi...', purpleColor);
        // Handle app update
        break;
      case 'reward':
        _showSnackbar('Membuka halaman rewards...', greenColor);
        // Navigate to rewards page
        break;
      case 'reminder':
        _showSnackbar('Reminder telah dibaca', blueColor);
        break;
      default:
        _showSnackbar('Notifikasi dibuka', greenColor);
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
    _showSnackbar('Semua notifikasi telah ditandai sebagai dibaca', greenColor);
  }

  Widget _buildFilterButton(String title, bool isSelected) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedFilter = title;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? greenColor : Colors.white,
          foregroundColor: isSelected ? Colors.white : blackColor,
          elevation: isSelected ? 2 : 0,
          side: BorderSide(
            color: isSelected ? greenColor : Colors.grey[300]!,
            width: 1,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : blackColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

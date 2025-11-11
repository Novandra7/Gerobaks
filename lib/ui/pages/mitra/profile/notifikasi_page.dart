import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bank_sha/shared/theme.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  // Notification settings
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = true;
  bool _scheduleReminders = true;
  bool _paymentAlerts = true;
  bool _newsUpdates = false;
  bool _promotionalOffers = true;

  // Dummy notification data
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 'NOTIF-001',
      'title': 'Jadwal Pengambilan Baru',
      'message': 'Anda mendapat jadwal pengambilan di Jl. Sudirman No. 123',
      'type': 'schedule',
      'time': '2 jam lalu',
      'isRead': false,
    },
    {
      'id': 'NOTIF-002',
      'title': 'Pembayaran Berhasil',
      'message': 'Komisi sebesar Rp 25.000 telah ditransfer ke rekening Anda',
      'type': 'payment',
      'time': '5 jam lalu',
      'isRead': true,
    },
    {
      'id': 'NOTIF-003',
      'title': 'Update Aplikasi',
      'message': 'Versi terbaru aplikasi telah tersedia di Play Store',
      'type': 'update',
      'time': '1 hari lalu',
      'isRead': false,
    },
    {
      'id': 'NOTIF-004',
      'title': 'Bonus Bulanan',
      'message': 'Selamat! Anda mendapat bonus performa bulan ini',
      'type': 'bonus',
      'time': '2 hari lalu',
      'isRead': true,
    },
    {
      'id': 'NOTIF-005',
      'title': 'Pengingat Jadwal',
      'message': 'Jangan lupa jadwal pengambilan sampah hari ini pukul 14:00',
      'type': 'reminder',
      'time': '3 hari lalu',
      'isRead': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: blackColor,
              size: 20,
            ),
          ),
        ),
        title: Text(
          'Notifikasi',
          style: blackTextStyle.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showSettingsBottomSheet,
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(Icons.settings_rounded, color: blackColor, size: 20),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan statistik
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [greenColor, greenColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: greenColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.notifications_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notifikasi Anda',
                            style: whiteTextStyle.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_notifications.where((n) => !n['isRead']).length} notifikasi belum dibaca',
                            style: whiteTextStyle.copyWith(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _markAllAsRead,
                      child: Text(
                        'Baca Semua',
                        style: whiteTextStyle.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Notifications List
              ...(_notifications.map(
                (notification) => _buildNotificationCard(notification),
              )),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: notification['isRead']
            ? null
            : Border.all(color: greenColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _markAsRead(notification['id']),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getNotificationColor(
                      notification['type'],
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getNotificationIcon(notification['type']),
                    color: _getNotificationColor(notification['type']),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
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
                                fontWeight: notification['isRead']
                                    ? FontWeight.w600
                                    : FontWeight.w700,
                              ),
                            ),
                          ),
                          if (!notification['isRead'])
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
                      const SizedBox(height: 4),
                      Text(
                        notification['message'],
                        style: greyTextStyle.copyWith(
                          fontSize: 14,
                          fontWeight: notification['isRead']
                              ? FontWeight.w400
                              : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification['time'],
                        style: greyTextStyle.copyWith(fontSize: 12),
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

  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: greyColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.settings_rounded, color: greenColor, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Pengaturan Notifikasi',
                    style: blackTextStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // Settings List
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildSettingItem(
                      'Push Notifications',
                      'Terima notifikasi langsung di perangkat',
                      Icons.notifications_rounded,
                      _pushNotifications,
                      (value) => setState(() => _pushNotifications = value),
                    ),
                    _buildSettingItem(
                      'Email Notifications',
                      'Terima notifikasi via email',
                      Icons.email_rounded,
                      _emailNotifications,
                      (value) => setState(() => _emailNotifications = value),
                    ),
                    _buildSettingItem(
                      'SMS Notifications',
                      'Terima notifikasi via SMS',
                      Icons.sms_rounded,
                      _smsNotifications,
                      (value) => setState(() => _smsNotifications = value),
                    ),
                    const Divider(height: 32),
                    _buildSettingItem(
                      'Pengingat Jadwal',
                      'Notifikasi untuk jadwal pengambilan',
                      Icons.schedule_rounded,
                      _scheduleReminders,
                      (value) => setState(() => _scheduleReminders = value),
                    ),
                    _buildSettingItem(
                      'Alert Pembayaran',
                      'Notifikasi status pembayaran',
                      Icons.payment_rounded,
                      _paymentAlerts,
                      (value) => setState(() => _paymentAlerts = value),
                    ),
                    _buildSettingItem(
                      'Berita & Update',
                      'Informasi terbaru aplikasi',
                      Icons.newspaper_rounded,
                      _newsUpdates,
                      (value) => setState(() => _newsUpdates = value),
                    ),
                    _buildSettingItem(
                      'Penawaran Promosi',
                      'Notifikasi promo dan bonus',
                      Icons.local_offer_rounded,
                      _promotionalOffers,
                      (value) => setState(() => _promotionalOffers = value),
                    ),
                  ],
                ),
              ),
            ),

            // Save Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _saveNotificationSettings();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: greenColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Simpan Pengaturan',
                    style: whiteTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: greenColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: greenColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: blackTextStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(subtitle, style: greyTextStyle.copyWith(fontSize: 12)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: greenColor),
        ],
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'schedule':
        return const Color(0xFF3B82F6);
      case 'payment':
        return greenColor;
      case 'update':
        return const Color(0xFF8B5CF6);
      case 'bonus':
        return const Color(0xFFF59E0B);
      case 'reminder':
        return const Color(0xFFEF4444);
      default:
        return greyColor;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'schedule':
        return Icons.schedule_rounded;
      case 'payment':
        return Icons.payment_rounded;
      case 'update':
        return Icons.system_update_rounded;
      case 'bonus':
        return Icons.card_giftcard_rounded;
      case 'reminder':
        return Icons.alarm_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  void _markAsRead(String notificationId) {
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        _notifications[index]['isRead'] = true;
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Semua notifikasi telah ditandai sebagai dibaca',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: greenColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _saveNotificationSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Pengaturan notifikasi berhasil disimpan',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: greenColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

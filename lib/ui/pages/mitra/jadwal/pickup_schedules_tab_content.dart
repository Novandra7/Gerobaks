import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../models/mitra_pickup_schedule.dart';
import '../../../../services/chat_service.dart';
import '../../../../services/mitra_api_service.dart';
import '../../../../services/location_service.dart';
import '../chat/mitra_chat_detail_page.dart';

/// Tab content for "Pickup" tab — shows only `assigned` schedules
class PickupSchedulesTabContent extends StatefulWidget {
  /// Listened to by this widget. When the value changes, data is reloaded.
  final ValueNotifier<int>? refreshNotifier;
  final VoidCallback? onJourneyStarted;

  const PickupSchedulesTabContent({
    super.key,
    this.refreshNotifier,
    this.onJourneyStarted,
  });

  @override
  State<PickupSchedulesTabContent> createState() =>
      _PickupSchedulesTabContentState();
}

class _PickupSchedulesTabContentState extends State<PickupSchedulesTabContent>
    with AutomaticKeepAliveClientMixin {
  static const Set<String> _chatActiveStatuses = {
    'assigned',
    'accepted',
    'on_the_way',
    'arrived',
  };
  static const Set<String> _chatReadOnlyStatuses = {
    'completed',
    'cancelled',
    'canceled',
  };

  final MitraApiService _apiService = MitraApiService();
  final LocationService _locationService = LocationService();
  final ChatService _chatService = ChatService();
  List<MitraPickupSchedule> _schedules = [];
  bool _isLoading = false;
  bool _initialized = false;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.refreshNotifier?.addListener(_onRefreshRequested);
    _initializeService();
  }

  @override
  void dispose() {
    widget.refreshNotifier?.removeListener(_onRefreshRequested);
    super.dispose();
  }

  void _onRefreshRequested() {
    if (!_initialized || !mounted) return;
    _loadSchedules();
  }

  Future<void> _initializeService() async {
    await _apiService.initialize();
    if (!mounted) return;
    _initialized = true;
    await _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    if (!mounted) return;
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final all = await _apiService.getMyActiveSchedules();
      if (!mounted) return;
      setState(() {
        _schedules = all.where((s) => s.isAssigned).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _viewDetail(MitraPickupSchedule schedule) async {
    final result = await Navigator.pushNamed(
      context,
      '/mitra/schedule-detail',
      arguments: schedule,
    );
    if (result == true) {
      _loadSchedules();
    }
  }

  Future<void> _openGoogleMaps(MitraPickupSchedule schedule) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${schedule.latitude},${schedule.longitude}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka Google Maps')),
        );
      }
    }
  }

  Future<void> _callUser(MitraPickupSchedule schedule) async {
    final url = Uri.parse('tel:${schedule.userPhone}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  bool _isChatAvailableForStatus(String status) {
    final normalized = status.toLowerCase();
    return _chatActiveStatuses.contains(normalized) ||
        _chatReadOnlyStatuses.contains(normalized);
  }

  bool _isChatReadOnlyStatus(String status) {
    return _chatReadOnlyStatuses.contains(status.toLowerCase());
  }

  Future<void> _openScheduleChat(MitraPickupSchedule schedule) async {
    if (!_isChatAvailableForStatus(schedule.status)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chat belum tersedia untuk status jadwal ini'),
        ),
      );
      return;
    }

    final isReadOnly = _isChatReadOnlyStatus(schedule.status);
    final conversationId = await _chatService.getOrCreatePickupConversationFast(
      pickupScheduleId: schedule.id,
      counterpartName: schedule.userName,
    );

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MitraChatDetailPage(
          conversationId: conversationId,
          customTitle: schedule.userName,
          isReadOnly: isReadOnly,
          readOnlyMessage: isReadOnly
              ? 'Pickup sudah ${schedule.statusDisplay.toLowerCase()}, chat hanya dapat dibaca.'
              : null,
        ),
      ),
    );
  }

  Future<void> _startJourney(MitraPickupSchedule schedule) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Mulai Perjalanan'),
        content: Text(
          'Konfirmasi bahwa Anda akan berangkat menuju lokasi ${schedule.userName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: greenColor),
            child: const Text(
              'Berangkat',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final position = await _locationService.getCurrentPosition();
      await _apiService.startJourney(
        schedule.id,
        currentLatitude: position?.latitude,
        currentLongitude: position?.longitude,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '🚗 Perjalanan dimulai, pindah ke tab Berjalan',
            ),
            backgroundColor: greenColor,
          ),
        );
        widget.onJourneyStarted?.call();
        _loadSchedules();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memulai perjalanan: $e'),
            backgroundColor: redcolor,
          ),
        );
      }
    }
  }

  Future<void> _releaseSchedule(MitraPickupSchedule schedule) async {
    final reasonController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: orangeColor, size: 28),
            const SizedBox(width: 8),
            const Text('Lepaskan Jadwal?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anda yakin ingin melepas assignment pickup untuk ${schedule.userName} agar kembali ke pending?',
              style: greyTextStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Masukkan alasan melepas jadwal...',
                hintStyle: greyTextStyle.copyWith(fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: orangeColor),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Kembali', style: greyTextStyle),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Alasan pelepasan wajib diisi'),
                    backgroundColor: orangeColor,
                  ),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: orangeColor,
              foregroundColor: whiteColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Lepaskan'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _apiService.releaseSchedule(
        schedule.id,
        reasonController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Jadwal berhasil dikembalikan ke pending'),
            backgroundColor: greenColor,
          ),
        );
        _loadSchedules();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal melepas jadwal: $e'),
            backgroundColor: redcolor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildBody();
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSchedules,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: greyColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_shipping_outlined,
                size: 64,
                color: greyColor.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tidak ada jadwal pickup',
              style: greyTextStyle.copyWith(fontSize: 16, fontWeight: medium),
            ),
            const SizedBox(height: 8),
            Text(
              'Jadwal yang sudah ditugaskan akan muncul di sini',
              style: greyTextStyle.copyWith(fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSchedules,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _schedules.length,
        itemBuilder: (context, index) {
          final schedule = _schedules[index];
          return _PickupScheduleCard(
            schedule: schedule,
            onTap: () => _viewDetail(schedule),
            onNavigate: () => _openGoogleMaps(schedule),
            onCall: () => _callUser(schedule),
            onChat: () => _openScheduleChat(schedule),
            onAccept: () => _startJourney(schedule),
            onCancel: () => _releaseSchedule(schedule),
          );
        },
      ),
    );
  }
}

class _PickupScheduleCard extends StatelessWidget {
  final MitraPickupSchedule schedule;
  final VoidCallback onTap;
  final VoidCallback onNavigate;
  final VoidCallback onCall;
  final VoidCallback onChat;
  final VoidCallback onAccept;
  final VoidCallback onCancel;

  const _PickupScheduleCard({
    required this.schedule,
    required this.onTap,
    required this.onNavigate,
    required this.onCall,
    required this.onChat,
    required this.onAccept,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shadowColor: blueColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: blueColor.withOpacity(0.1), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [whiteColor, lightBackgroundColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info + Status
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: greenColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: greenColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        (schedule.userName.trim().isNotEmpty
                                ? schedule.userName.trim()[0]
                                : '?')
                            .toUpperCase(),
                        style: TextStyle(
                          color: greenColor,
                          fontSize: 20,
                          fontWeight: bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            schedule.userName,
                            style: blackTextStyle.copyWith(
                              fontWeight: bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            schedule.userPhone,
                            style: greyTextStyle.copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: schedule.statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: schedule.statusColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            schedule.statusIcon,
                            size: 16,
                            color: schedule.statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            schedule.statusDisplay,
                            style: TextStyle(
                              color: schedule.statusColor,
                              fontWeight: semiBold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Divider(height: 24, color: greyColor.withOpacity(0.3)),
                const SizedBox(height: 12),

                // Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on, size: 20, color: redcolor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        schedule.pickupAddress,
                        style: blackTextStyle.copyWith(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Schedule Time
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: blueColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: blueColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, size: 20, color: blueColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              schedule.scheduleDay,
                              style: blackTextStyle.copyWith(
                                fontSize: 14,
                                fontWeight: semiBold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${schedule.pickupTimeStart} - ${schedule.pickupTimeEnd}',
                              style: greyTextStyle.copyWith(
                                fontSize: 13,
                                fontWeight: medium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Waste Types & Weights
                if (schedule.wasteSummary.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: orangeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: orangeColor.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: orangeColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                schedule.wasteSummary,
                                style: blackTextStyle.copyWith(
                                  fontSize: 14,
                                  fontWeight: medium,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Scheduled weight for main waste type
                        if (schedule.scheduledWeight != '0.00') ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const SizedBox(width: 28),
                              Text(
                                '${schedule.wasteTypeScheduled}: ${schedule.scheduledWeight} kg',
                                style: greyTextStyle.copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                        ],

                        // Additional wastes
                        if (schedule.additionalWastes != null &&
                            schedule.additionalWastes!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          ...schedule.additionalWastes!.map((w) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Row(
                                children: [
                                  const SizedBox(width: 28),
                                  Text(
                                    '${w.type}: ~${w.estimatedWeight} kg (tambahan)',
                                    style: greyTextStyle.copyWith(fontSize: 12),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Action buttons
                Column(
                  children: [
                    // Primary action: Konfirmasi
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onAccept,
                        icon: const Icon(
                          Icons.check_circle_outline,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Mulai Berangkat',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: greenColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: onChat,
                        icon: Icon(
                          Icons.chat_outlined,
                          size: 18,
                          color: greenColor,
                        ),
                        label: Text(
                          'Chat User',
                          style: TextStyle(
                            color: greenColor,
                            fontSize: 13,
                            fontWeight: semiBold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: greenColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Secondary actions: Lepaskan & Navigasi
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onCancel,
                            icon: Icon(
                              Icons.undo_rounded,
                              size: 18,
                              color: orangeColor,
                            ),
                            label: Text(
                              'Lepaskan',
                              style: TextStyle(
                                color: orangeColor,
                                fontSize: 13,
                                fontWeight: semiBold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: orangeColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onNavigate,
                            icon: Icon(
                              Icons.navigation,
                              size: 18,
                              color: blueColor,
                            ),
                            label: Text(
                              'Navigasi',
                              style: blueTextStyle.copyWith(
                                fontSize: 13,
                                fontWeight: semiBold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: blueColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

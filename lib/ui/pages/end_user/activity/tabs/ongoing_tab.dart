import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/services/chat_service.dart';
import 'package:bank_sha/ui/widgets/skeleton/skeleton_items.dart';
import 'package:bank_sha/services/end_user_api_service.dart';
import 'package:bank_sha/ui/pages/end_user/chat/chat_detail_page.dart';
import 'package:bank_sha/ui/pages/end_user/activity/widgets/ongoing_activity_card.dart';

/// Tab untuk schedule dengan status: assigned, on_the_way, arrived
/// Menampilkan jadwal yang sedang berlangsung
/// Fitur: GPS Tracking, Mitra Info, Contact Mitra, ETA Display
class OngoingTab extends StatefulWidget {
  final DateTime? selectedDate;
  final String? searchQuery;

  const OngoingTab({super.key, this.selectedDate, this.searchQuery});

  @override
  State<OngoingTab> createState() => _OngoingTabState();
}

class _OngoingTabState extends State<OngoingTab>
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

  @override
  bool get wantKeepAlive => true;

  bool _isLoading = true;
  bool _isFirstLoad = true;
  List<Map<String, dynamic>> _schedules = [];
  final ChatService _chatService = ChatService();
  late EndUserApiService _apiService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _apiService = EndUserApiService();
    await _apiService.initialize();
    await _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    if (_isFirstLoad) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final schedules = await _apiService.getUserPickupSchedules();
      final activeSchedules = schedules.where((schedule) {
        final deletedAt = schedule['deleted_at'];
        if (deletedAt == null) return true;
        if (deletedAt is String && deletedAt.trim().isEmpty) return true;
        return false;
      }).toList();

      if (mounted) {
        setState(() {
          _schedules = activeSchedules;
          _isLoading = false;
          _isFirstLoad = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _schedules = [];
          _isLoading = false;
          _isFirstLoad = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredActivities() {
    // Filter status: assigned, on_the_way, arrived, on_progress, accepted
    final ongoingSchedules = _schedules.where((schedule) {
      final status = schedule['status']?.toString().toLowerCase();
      return status == 'assigned' ||
          status == 'on_the_way' ||
          status == 'arrived' ||
          status == 'on_progress' ||
          status == 'accepted';
    }).toList();

    // Filter berdasarkan tanggal jika ada
    if (widget.selectedDate != null) {
      return ongoingSchedules.where((schedule) {
        try {
          DateTime scheduledDate;
          if (schedule['schedule_date'] != null &&
              schedule['pickup_time_start'] != null) {
            final dateStr = schedule['schedule_date'].toString();
            final timeStr = schedule['pickup_time_start'].toString();

            final dateParts = dateStr.split('-');
            final year = int.parse(dateParts[0]);
            final month = int.parse(dateParts[1]);
            final day = int.parse(dateParts[2]);

            final timeParts = timeStr.split(':');
            final hour = int.parse(timeParts[0]);
            final minute = int.parse(timeParts[1]);

            scheduledDate = DateTime(year, month, day, hour, minute);
          } else if (schedule['scheduled_at'] != null) {
            scheduledDate = DateTime.parse(schedule['scheduled_at']);
          } else {
            return false;
          }

          return scheduledDate.year == widget.selectedDate!.year &&
              scheduledDate.month == widget.selectedDate!.month &&
              scheduledDate.day == widget.selectedDate!.day;
        } catch (e) {
          return false;
        }
      }).toList();
    }

    // Filter berdasarkan pencarian
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      final query = widget.searchQuery!.toLowerCase();
      return ongoingSchedules.where((schedule) {
        final address = schedule['pickup_address']?.toString() ?? '';
        final notes = schedule['notes']?.toString() ?? '';
        final wasteSummary = schedule['waste_summary']?.toString() ?? '';
        return address.toLowerCase().contains(query) ||
            notes.toLowerCase().contains(query) ||
            wasteSummary.toLowerCase().contains(query);
      }).toList();
    }

    return ongoingSchedules;
  }

  bool _isChatAvailableForStatus(String status) {
    final normalized = status.toLowerCase();
    return _chatActiveStatuses.contains(normalized) ||
        _chatReadOnlyStatuses.contains(normalized);
  }

  bool _isChatReadOnlyStatus(String status) {
    return _chatReadOnlyStatuses.contains(status.toLowerCase());
  }

  Future<void> _openScheduleChat(Map<String, dynamic> schedule) async {
    final status = schedule['status']?.toString() ?? '';
    if (!_isChatAvailableForStatus(status)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chat belum tersedia untuk status jadwal ini'),
        ),
      );
      return;
    }

    final pickupScheduleIdRaw = schedule['id'];
    final pickupScheduleId = pickupScheduleIdRaw is int
        ? pickupScheduleIdRaw
        : int.tryParse(pickupScheduleIdRaw?.toString() ?? '');
    if (pickupScheduleId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pickup tidak valid, chat tidak dapat dibuka'),
        ),
      );
      return;
    }

    final mitraName =
        schedule['assigned_mitra']?['name']?.toString().trim().isNotEmpty ==
            true
        ? schedule['assigned_mitra']['name'].toString().trim()
        : 'Mitra Pickup';
    final isReadOnly = _isChatReadOnlyStatus(status);

    final conversationId = await _chatService.getOrCreatePickupConversationFast(
      pickupScheduleId: pickupScheduleId,
      counterpartName: mitraName,
    );

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailPage(
          conversationId: conversationId,
          customTitle: mitraName,
          isReadOnly: isReadOnly,
          readOnlyMessage: isReadOnly
              ? 'Pickup sudah ${status.replaceAll('_', ' ')}, chat hanya dapat dibaca.'
              : null,
        ),
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: SkeletonItems.card(height: 200),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    String title = 'Tidak ada pickup berlangsung';
    String subtitle = 'Pickup yang sedang diproses akan muncul di sini';

    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      title = 'Tidak ditemukan';
      subtitle = 'Coba kata kunci pencarian lain';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_shipping, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              title,
              style: blackTextStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: greyTextStyle.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshIndicator(
      onRefresh: _loadSchedules,
      child: _isLoading
          ? _buildSkeletonLoading()
          : _getFilteredActivities().isEmpty
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: _buildEmptyState(),
                        ),
                      ],
                    );
                  },
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  itemCount: _getFilteredActivities().length,
                  itemBuilder: (context, index) {
                    final filteredSchedules = _getFilteredActivities();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: OngoingActivityCard(
                        schedule: filteredSchedules[index],
                        onRefresh: _loadSchedules,
                        onChat: () => _openScheduleChat(filteredSchedules[index]),
                      ),
                    );
                  },
                ),
    );
  }
}

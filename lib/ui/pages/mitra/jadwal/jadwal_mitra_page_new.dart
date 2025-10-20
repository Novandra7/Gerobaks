import 'package:bank_sha/models/schedule_api_model.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/services/schedule_api_service.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/pages/mitra/jadwal/jadwal_mitra_page_map_view.dart';
import 'package:bank_sha/ui/pages/mitra/pengambilan/detail_pickup.dart';
import 'package:bank_sha/ui/widgets/mitra/jadwal_mitra_header.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class JadwalMitraPageNew extends StatefulWidget {
  const JadwalMitraPageNew({super.key});

  @override
  State<JadwalMitraPageNew> createState() => _JadwalMitraPageNewState();
}

class _JadwalMitraPageNewState extends State<JadwalMitraPageNew>
    with TickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  String? _driverId;
  bool _isLoading = false;
  String _selectedFilter = "semua";
  late TabController _tabController;
  final ScheduleApiService _scheduleApiService = ScheduleApiService();
  List<ScheduleApiModel> _schedules = [];
  String? _errorMessage;
  final Set<int> _updatingScheduleIds = <int>{};

  // Stats data
  int _locationCount = 0;
  int _pendingCount = 0;
  int _completedCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          switch (_tabController.index) {
            case 0:
              _selectedFilter = "semua";
              break;
            case 1:
              _selectedFilter = "pending";
              break;
            case 2:
              _selectedFilter = "in_progress";
              break;
            case 3:
              _selectedFilter = "completed";
              break;
          }
        });
      }
    });

    // Initialize data
    _initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await initializeDateFormatting("id_ID", null);

      // Ambil ID driver dari local storage
      final LocalStorageService localStorageService =
          await LocalStorageService.getInstance();
      final userData = await localStorageService.getUserData();

      if (userData != null && userData["id"] != null) {
        _driverId = userData["id"] as String;
      } else {
        throw Exception("ID driver tidak ditemukan");
      }

      // Load schedules
      await _loadSchedules();
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memuat jadwal: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(left: 16, right: 16, bottom: 80),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadSchedules() async {
    if (_driverId == null || _driverId!.isEmpty) {
      throw Exception("ID driver tidak ditemukan");
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final assignedTo = int.tryParse(_driverId!);
      final result = await _scheduleApiService.listSchedules(
        assignedTo: assignedTo,
        perPage: 100,
      );

      final schedules = List<ScheduleApiModel>.from(result.items)
        ..sort((a, b) {
          final aDate = a.scheduledAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.scheduledAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return aDate.compareTo(bDate);
        });

      if (!mounted) return;

      setState(() {
        _applySchedules(schedules);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memuat jadwal: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(left: 16, right: 16, bottom: 80),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applySchedules(List<ScheduleApiModel> schedules) {
    _schedules = schedules;
    _sortSchedules();
    _recalculateStats();
  }

  void _recalculateStats() {
    _locationCount = _schedules.length;
    _pendingCount = _schedules
        .where((s) => _normalizeStatus(s.status) == 'pending')
        .length;
    _completedCount = _schedules
        .where((s) => _normalizeStatus(s.status) == 'completed')
        .length;
  }

  void _sortSchedules() {
    _schedules.sort((a, b) {
      final aDate = a.scheduledAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.scheduledAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aDate.compareTo(bDate);
    });
  }

  Future<void> _handleScheduleAction(ScheduleApiModel schedule) async {
    final normalizedStatus = _normalizeStatus(schedule.status);

    if (normalizedStatus == 'pending') {
      final confirmed = await _showStatusConfirmation(
        title: 'Mulai Pengambilan',
        message:
            'Status jadwal akan diubah menjadi Diproses dan tampil di daftar tugas aktif.',
        confirmLabel: 'Mulai',
      );
      if (confirmed) {
        await _updateScheduleStatus(
          schedule,
          'in_progress',
          successMessage: 'Pengambilan ditandai sedang diproses.',
        );
      }
      return;
    }

    if (normalizedStatus == 'in_progress') {
      final confirmed = await _showStatusConfirmation(
        title: 'Selesaikan Pengambilan',
        message:
            'Pastikan sampah sudah diambil. Status akan ditandai sebagai selesai.',
        confirmLabel: 'Selesai',
      );
      if (confirmed) {
        await _updateScheduleStatus(
          schedule,
          'completed',
          successMessage: 'Pengambilan selesai dicatat.',
        );
      }
      return;
    }

    if (normalizedStatus == 'cancelled') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Jadwal ini telah dibatalkan oleh sistem.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
        ),
      );
    }
  }

  Future<void> _updateScheduleStatus(
    ScheduleApiModel schedule,
    String newStatus, {
    String? successMessage,
  }) async {
    if (_updatingScheduleIds.contains(schedule.id)) return;

    setState(() {
      _updatingScheduleIds.add(schedule.id);
    });

    try {
      final updated = await _scheduleApiService.updateScheduleStatus(
        schedule.id,
        newStatus,
      );

      if (!mounted) return;

      setState(() {
        final index = _schedules.indexWhere((item) => item.id == schedule.id);
        if (index != -1) {
          _schedules[index] = updated;
        } else {
          _schedules.insert(0, updated);
        }
        _sortSchedules();
        _recalculateStats();
        _updatingScheduleIds.remove(schedule.id);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage ?? 'Status jadwal diperbarui.'),
          backgroundColor: greenColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _updatingScheduleIds.remove(schedule.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui status: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
        ),
      );
    }
  }

  Future<bool> _showStatusConfirmation({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title, style: blackTextStyle.copyWith(fontWeight: bold)),
          content: Text(message, style: blackTextStyle.copyWith(fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Batal',
                style: blackTextStyle.copyWith(color: Colors.red),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: greenColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Widget? _buildActionButton(
    ScheduleApiModel schedule,
    String normalizedStatus,
    bool isSmallScreen,
  ) {
    String? actionLabel;

    switch (normalizedStatus) {
      case 'pending':
        actionLabel = 'Mulai Pengambilan';
        break;
      case 'in_progress':
        actionLabel = 'Tandai Selesai';
        break;
      default:
        actionLabel = null;
        break;
    }

    if (actionLabel == null) return null;

    final isProcessing = _updatingScheduleIds.contains(schedule.id);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: greenColor,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: isProcessing ? null : () => _handleScheduleAction(schedule),
        child: isProcessing
            ? SizedBox(
                height: isSmallScreen ? 14 : 16,
                width: isSmallScreen ? 14 : 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(greenColor),
                ),
              )
            : Text(
                actionLabel,
                style: blackTextStyle.copyWith(
                  fontSize: isSmallScreen ? 11 : 13,
                  fontWeight: semiBold,
                  color: greenColor,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: lightBackgroundColor,
      body: Column(
        children: [
          // Using the updated JadwalMitraHeader component
          JadwalMitraHeader(
            locationCount: _locationCount,
            pendingCount: _pendingCount,
            completedCount: _completedCount,
            onChatPressed: () {
              // Handle chat press
            },
            onNotificationPressed: () {
              // Handle notification press
            },
          ),

          // Body content
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: greenColor))
                : _buildBody(context, isSmallScreen),
          ),
        ],
      ),
    );
  }

  // We've removed the _buildHeader, _buildJadwalTitle, and _buildStatCard methods
  // since we're now using the JadwalMitraHeader component

  Widget _buildBody(BuildContext context, bool isSmallScreen) {
    return Column(
      children: [
        // Filter tabs - responsive layout
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: isSmallScreen ? 4 : 6,
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildFilterTab("Semua", _selectedFilter == "semua", () {
                  setState(() {
                    _selectedFilter = "semua";
                    _tabController.animateTo(0);
                  });
                }, isSmallScreen),
              ),
              SizedBox(width: isSmallScreen ? 4 : 8),
              Expanded(
                child: _buildFilterTab(
                  "Menunggu",
                  _selectedFilter == "pending",
                  () {
                    setState(() {
                      _selectedFilter = "pending";
                      _tabController.animateTo(1);
                    });
                  },
                  isSmallScreen,
                ),
              ),
              SizedBox(width: isSmallScreen ? 4 : 8),
              Expanded(
                child: _buildFilterTab(
                  "Diproses",
                  _selectedFilter == "in_progress",
                  () {
                    setState(() {
                      _selectedFilter = "in_progress";
                      _tabController.animateTo(2);
                    });
                  },
                  isSmallScreen,
                ),
              ),
              SizedBox(width: isSmallScreen ? 4 : 8),
              Expanded(
                child: _buildFilterTab(
                  "Selesai",
                  _selectedFilter == "completed",
                  () {
                    setState(() {
                      _selectedFilter = "completed";
                      _tabController.animateTo(3);
                    });
                  },
                  isSmallScreen,
                ),
              ),
            ],
          ),
        ),

        // Section indicators based on selected filter
        Padding(
          padding: EdgeInsets.fromLTRB(
            isSmallScreen ? 12 : 16,
            isSmallScreen ? 8 : 12,
            isSmallScreen ? 12 : 16,
            isSmallScreen ? 4 : 6,
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: greenColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 8),
              Text(
                _selectedFilter == "semua"
                    ? 'Prioritas Terdekat'
                    : _selectedFilter == "pending"
                    ? 'Terjadwal'
                    : _selectedFilter == "in_progress"
                    ? 'Dalam Proses'
                    : 'Pengambilan Selesai',
                style: blackTextStyle.copyWith(
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: bold,
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: _openMapView,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8 : 10,
                    vertical: isSmallScreen ? 3 : 5,
                  ),
                  decoration: BoxDecoration(
                    color: greenColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.map,
                        color: Colors.white,
                        size: isSmallScreen ? 12 : 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Lihat Peta",
                        style: whiteTextStyle.copyWith(
                          fontSize: isSmallScreen ? 9 : 11,
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

        // Schedule list
        Expanded(
          child: RefreshIndicator(
            color: greenColor,
            onRefresh: _loadSchedules,
            child: Builder(
              builder: (context) {
                final filteredSchedules = _getFilteredSchedules();

                if (filteredSchedules.isEmpty) {
                  final message = _errorMessage;
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 24 : 32,
                      vertical: isSmallScreen ? 40 : 56,
                    ),
                    children: [
                      Icon(
                        message == null
                            ? Icons.event_available_outlined
                            : Icons.error_outline,
                        size: isSmallScreen ? 56 : 72,
                        color: message == null ? greenColor : Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        message ?? 'Tidak ada jadwal untuk ditampilkan.',
                        style: blackTextStyle.copyWith(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: medium,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        message == null
                            ? 'Tarik ke bawah untuk memperbarui daftar.'
                            : 'Tarik ke bawah untuk mencoba memuat ulang.',
                        style: greyTextStyle.copyWith(
                          fontSize: isSmallScreen ? 12 : 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16,
                  ),
                  itemCount: filteredSchedules.length,
                  itemBuilder: (context, index) {
                    final schedule = filteredSchedules[index];
                    return _buildScheduleCard(schedule, isSmallScreen);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTab(
    String label,
    bool isSelected,
    VoidCallback onTap,
    bool isSmallScreen,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 4 : 6),
        decoration: BoxDecoration(
          color: isSelected ? greenColor : Color(0xFFEAFBEF),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: (isSelected ? whiteTextStyle : greenTextStyle).copyWith(
            fontSize: isSmallScreen ? 10 : 12,
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleCard(ScheduleApiModel schedule, bool isSmallScreen) {
    final normalizedStatus = _normalizeStatus(schedule.status);
    final scheduledAt = schedule.scheduledAt;
    final timeLabel = scheduledAt != null
        ? '${DateFormat('dd MMM yyyy', 'id_ID').format(scheduledAt)} • ${DateFormat('HH:mm', 'id_ID').format(scheduledAt)}'
        : 'Jadwal belum ditentukan';
    final customerName = schedule.title.isNotEmpty
        ? schedule.title
        : 'Jadwal ${schedule.id}';
    final address = schedule.description ?? 'Alamat tidak tersedia';
    final List<String> infoChips = ['ID #${schedule.id}'];
    final trackings = schedule.trackingsCount ?? 0;
    if (trackings > 0) {
      infoChips.add('$trackings tracking');
    }
    final assignedName = schedule.assignedUser?.name;
    if (assignedName != null && assignedName.isNotEmpty) {
      infoChips.add('Mitra: $assignedName');
    }
    final assignedPhone = schedule.assignedUser?.phone;
    if (assignedPhone != null && assignedPhone.isNotEmpty) {
      infoChips.add('Kontak: $assignedPhone');
    }
    final actionButton = _buildActionButton(
      schedule,
      normalizedStatus,
      isSmallScreen,
    );

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DetailPickupPage(scheduleId: schedule.id.toString()),
          ),
        );
        if (mounted) {
          await _loadSchedules();
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 10 : 12,
                vertical: isSmallScreen ? 6 : 8,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: isSmallScreen ? 12 : 14,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: isSmallScreen ? 3 : 4),
                      Text(
                        timeLabel,
                        style: blackTextStyle.copyWith(
                          fontWeight: bold,
                          fontSize: isSmallScreen ? 10 : 12,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 6 : 8,
                      vertical: isSmallScreen ? 3 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        normalizedStatus,
                      ).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Text(
                      _getStatusText(normalizedStatus),
                      style: TextStyle(
                        color: _getStatusColor(normalizedStatus),
                        fontWeight: semiBold,
                        fontSize: isSmallScreen ? 9 : 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF37DE7A), Color(0xFF00A643)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customerName,
                    style: whiteTextStyle.copyWith(
                      fontSize: isSmallScreen ? 13 : 15,
                      fontWeight: bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isSmallScreen ? 4 : 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: Colors.white,
                        size: isSmallScreen ? 12 : 14,
                      ),
                      SizedBox(width: isSmallScreen ? 3 : 4),
                      Expanded(
                        child: Text(
                          address,
                          style: whiteTextStyle.copyWith(
                            fontSize: isSmallScreen ? 11 : 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (infoChips.isNotEmpty) ...[
                    SizedBox(height: isSmallScreen ? 6 : 8),
                    Wrap(
                      spacing: isSmallScreen ? 6 : 8,
                      runSpacing: 4,
                      children: infoChips
                          .map((chip) => _buildInfoChip(chip, isSmallScreen))
                          .toList(),
                    ),
                  ],
                  if (actionButton != null) ...[
                    SizedBox(height: isSmallScreen ? 8 : 12),
                    actionButton,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 6 : 8,
        vertical: isSmallScreen ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Text(
        label,
        style: whiteTextStyle.copyWith(
          fontSize: isSmallScreen ? 9 : 10,
          fontWeight: medium,
        ),
      ),
    );
  }

  String _normalizeStatus(String? status) {
    final sanitized = status?.toLowerCase().trim() ?? '';
    if (sanitized.isEmpty) return 'pending';

    if (sanitized == 'pending' ||
        sanitized == 'assigned' ||
        sanitized == 'scheduled') {
      return 'pending';
    }
    if (sanitized == 'in_progress' ||
        sanitized == 'on_progress' ||
        sanitized == 'processing') {
      return 'in_progress';
    }
    if (sanitized == 'completed' ||
        sanitized == 'done' ||
        sanitized == 'finished') {
      return 'completed';
    }
    if (sanitized == 'cancelled' || sanitized == 'canceled') {
      return 'cancelled';
    }

    return sanitized;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'in_progress':
        return 'Diproses';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Unknown';
    }
  }

  List<ScheduleApiModel> _getFilteredSchedules() {
    final baseList = List<ScheduleApiModel>.from(_schedules);

    if (_selectedFilter == 'semua') {
      return baseList;
    }

    return baseList
        .where(
          (schedule) => _normalizeStatus(schedule.status) == _selectedFilter,
        )
        .toList();
  }

  // Method to open the map view
  void _openMapView() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => JadwalMitraMapView()),
    );
  }
}

// Green text style
final TextStyle greenTextStyle = TextStyle(
  color: Color(0xFF00A643),
  fontFamily: 'Inter',
);

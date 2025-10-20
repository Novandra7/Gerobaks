import 'package:bank_sha/models/schedule_api_model.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/services/schedule_api_service.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/pages/mitra/jadwal/jadwal_mitra_page_map_view.dart';
import 'package:bank_sha/ui/pages/mitra/pengambilan/detail_pickup.dart';
import 'package:bank_sha/ui/widgets/mitra/jadwal_mitra_header.dart';
import 'package:bank_sha/ui/widgets/shared/filter_tab.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

class JadwalMitraPage extends StatefulWidget {
  const JadwalMitraPage({super.key});

  @override
  State<JadwalMitraPage> createState() => _JadwalMitraPageNewState();
}

class _JadwalMitraPageNewState extends State<JadwalMitraPage>
    with TickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  String? _driverId;
  bool _isLoading = false;
  String _selectedFilter = "semua";
  late TabController _tabController;
  final ScheduleApiService _scheduleApiService = ScheduleApiService();
  List<ScheduleApiModel> _schedules = [];
  String? _errorMessage;

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
        _driverId = userData["id"].toString();
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
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final driverId = int.tryParse(_driverId ?? '');
      final result = await _scheduleApiService.listSchedules(
        assignedTo: driverId,
        perPage: 100,
      );

      final schedules = List<ScheduleApiModel>.from(result.items)
        ..sort((a, b) {
          final aDate = a.scheduledAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.scheduledAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return aDate.compareTo(bDate);
        });

      final pending = schedules
          .where((s) => _normalizeStatus(s.status) == 'pending')
          .length;
      final completed = schedules
          .where((s) => _normalizeStatus(s.status) == 'completed')
          .length;

      if (mounted) {
        setState(() {
          _schedules = schedules;
          _locationCount = schedules.length;
          _pendingCount = pending;
          _completedCount = completed;
        });
      }
    } catch (e) {
      _errorMessage = e.toString();
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

  @override
  Widget build(BuildContext context) {
    // Menghitung ukuran berdasarkan golden ratio
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: lightBackgroundColor,
      body: SafeArea(
        top: false, // We'll handle the top padding in our custom header
        child: Column(
          children: [
            // Custom Header matching the design
            _buildHeader(context, isSmallScreen),

            // Body content
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: greenColor))
                  : _buildBody(context, isSmallScreen),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isSmallScreen) {
    return JadwalMitraHeader(
      locationCount: _locationCount,
      pendingCount: _pendingCount,
      completedCount: _completedCount,
      onChatPressed: () {
        // Navigate to chat
      },
      onNotificationPressed: () {
        // Navigate to notifications
      },
    );
  }

  Widget _buildBody(BuildContext context, bool isSmallScreen) {
    // Menghitung ukuran berdasarkan golden ratio
    final screenWidth = MediaQuery.of(context).size.width;
    final basePadding =
        screenWidth / 25; // Base padding yang proporsional dengan layar
    final spacingSmall =
        basePadding / 1.618; // Spacing kecil berdasarkan golden ratio
    final spacingMedium = basePadding; // Spacing sedang
    final chipRadius = basePadding * 0.6; // Chip radius proporsional

    // Font sizes berdasarkan golden ratio
    final titleFontSize = basePadding * 0.7;
    final subtitleFontSize = basePadding * 0.55;

    return Column(
      children: [
        // Filter tabs - responsive layout
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: spacingMedium,
            vertical: spacingSmall,
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildFilterTab(
                  "Semua",
                  _selectedFilter == "semua",
                  () {
                    setState(() {
                      _selectedFilter = "semua";
                      _tabController.animateTo(0);
                    });
                  },
                  isSmallScreen,
                  basePadding,
                ),
              ),
              SizedBox(width: spacingSmall),
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
                  basePadding,
                ),
              ),
              SizedBox(width: spacingSmall),
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
                  basePadding,
                ),
              ),
              SizedBox(width: spacingSmall),
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
                  basePadding,
                ),
              ),
            ],
          ),
        ),

        // Prioritas Terdekat heading
        Padding(
          padding: EdgeInsets.fromLTRB(
            spacingMedium,
            spacingMedium,
            spacingMedium,
            spacingSmall,
          ),
          child: Row(
            children: [
              Container(
                width: basePadding * 0.2,
                height: basePadding * 1.0,
                decoration: BoxDecoration(
                  color: greenColor,
                  borderRadius: BorderRadius.circular(basePadding * 0.1),
                ),
              ),
              SizedBox(width: spacingSmall),
              Text(
                'Prioritas Terdekat',
                style: blackTextStyle.copyWith(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: _openMapView,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacingMedium * 0.6,
                    vertical: spacingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: greenColor,
                    borderRadius: BorderRadius.circular(chipRadius),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.map,
                        color: Colors.white,
                        size: subtitleFontSize * 1.2,
                      ),
                      SizedBox(width: spacingSmall * 0.5),
                      Text(
                        "Lihat Peta",
                        style: whiteTextStyle.copyWith(
                          fontSize: subtitleFontSize,
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
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: spacingMedium,
                      vertical: spacingMedium * 2,
                    ),
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.format_list_bulleted,
                              size: basePadding * 2,
                              color: greenColor.withOpacity(0.3),
                            ),
                            SizedBox(height: spacingMedium),
                            Text(
                              _errorMessage != null
                                  ? 'Gagal memuat jadwal. Tarik untuk mencoba lagi.'
                                  : 'Belum ada jadwal untuk ditampilkan.',
                              style: blackTextStyle.copyWith(
                                fontSize: basePadding * 0.6,
                                fontWeight: medium,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: spacingMedium),
                  itemCount: filteredSchedules.length,
                  itemBuilder: (context, index) {
                    final schedule = filteredSchedules[index];
                    return _buildScheduleCard(
                      schedule,
                      index,
                      isSmallScreen,
                      basePadding,
                    );
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
    bool isSmallScreen, [
    double? basePadding,
  ]) {
    return FilterTab(
      label: label,
      isSelected: isSelected,
      onTap: onTap,
      selectedColor: greenColor,
      unselectedColor: Color(0xFFEAFBEF),
      selectedTextColor: Colors.white,
      unselectedTextColor: greenColor,
    );
  }

  Widget _buildScheduleCard(
    ScheduleApiModel schedule,
    int index,
    bool isSmallScreen, [
    double? basePadding,
  ]) {
    bool isEven = index % 2 == 0;

    // Menghitung ukuran berdasarkan golden ratio
    final bp = basePadding ?? (isSmallScreen ? 15.0 : 20.0);
    final cardRadius = bp * 0.8;
    final spacingSmall = bp / 1.618;
    final spacingMedium = bp;
    final iconSize = bp * 0.6;

    // Font sizes dengan golden ratio
    final titleFontSize = bp * 0.7;
    final subtitleFontSize = bp * 0.55;
    final statusFontSize = bp * 0.5;
    final chipFontSize = bp * 0.45;

    return GestureDetector(
      onTap: () {
        // Navigate to detail page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DetailPickupPage(scheduleId: schedule.id.toString()),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: bp * 0.6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: bp * 0.4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Time and status
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: spacingMedium,
                vertical: spacingSmall,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(cardRadius),
                  topRight: Radius.circular(cardRadius),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: iconSize,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: spacingSmall * 0.5),
                      Text(
                        schedule.formattedTime,
                        style: blackTextStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: subtitleFontSize,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacingSmall * 1.2,
                      vertical: spacingSmall * 0.4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(schedule.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(bp * 0.6),
                    ),
                    child: Text(
                      _getStatusText(schedule.status),
                      style: TextStyle(
                        color: _getStatusColor(schedule.status),
                        fontWeight: FontWeight.bold,
                        fontSize: statusFontSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Customer info
            Container(
              padding: EdgeInsets.all(spacingMedium),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isEven
                        ? Color(0xFF76DE8D)
                        : Color(0xFF76DE8D).withOpacity(0.9),
                    greenColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(cardRadius),
                  bottomRight: Radius.circular(cardRadius),
                ),
                boxShadow: [
                  BoxShadow(
                    color: greenColor.withOpacity(0.2),
                    blurRadius: bp * 0.3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        schedule.title,
                        style: whiteTextStyle.copyWith(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      // Add distance indicator
                      Text(
                        schedule.formattedDate,
                        style: whiteTextStyle.copyWith(
                          fontSize: chipFontSize,
                          fontWeight: medium,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacingSmall * 0.5),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: iconSize,
                      ),
                      SizedBox(width: spacingSmall * 0.5),
                      Expanded(
                        child: Text(
                          schedule.description ?? 'Alamat belum tersedia',
                          style: whiteTextStyle.copyWith(
                            fontSize: subtitleFontSize,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacingSmall),
                  Row(
                    children: [
                      _buildWasteTypeChip(
                        schedule.assignedUser?.name == null
                            ? 'Petugas belum ditetapkan'
                            : 'Petugas: ${schedule.assignedUser!.name}',
                        isSmallScreen,
                        bp,
                      ),
                      SizedBox(width: spacingSmall),
                      _buildWasteWeightChip(
                        'Tracking: ${schedule.trackingsCount ?? 0}',
                        isSmallScreen,
                        bp,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWasteTypeChip(
    String wasteType,
    bool isSmallScreen, [
    double? basePadding,
  ]) {
    final bp = basePadding ?? (isSmallScreen ? 15.0 : 20.0);
    final chipPaddingH = bp * 0.6;
    final chipPaddingV = bp * 0.25;
    final fontSize = bp * 0.45;
    final borderRadius = bp * 0.8;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: chipPaddingH,
        vertical: chipPaddingV,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        wasteType,
        style: whiteTextStyle.copyWith(fontSize: fontSize),
      ),
    );
  }

  Widget _buildWasteWeightChip(
    String wasteWeight,
    bool isSmallScreen, [
    double? basePadding,
  ]) {
    final bp = basePadding ?? (isSmallScreen ? 15.0 : 20.0);
    final chipPaddingH = bp * 0.6;
    final chipPaddingV = bp * 0.25;
    final fontSize = bp * 0.45;
    final borderRadius = bp * 0.8;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: chipPaddingH,
        vertical: chipPaddingV,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        wasteWeight,
        style: whiteTextStyle.copyWith(fontSize: fontSize),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (_normalizeStatus(status)) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    switch (_normalizeStatus(status)) {
      case 'pending':
        return 'Menunggu';
      case 'in_progress':
        return 'Diproses';
      case 'completed':
        return 'Selesai';
      default:
        return 'Tidak diketahui';
    }
  }

  List<ScheduleApiModel> _getFilteredSchedules() {
    if (_selectedFilter == "semua") {
      return List<ScheduleApiModel>.from(_schedules);
    }

    final filtered = _schedules
        .where(
          (schedule) => _normalizeStatus(schedule.status) == _selectedFilter,
        )
        .toList();
    filtered.sort((a, b) {
      final aDate = a.scheduledAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.scheduledAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aDate.compareTo(bDate);
    });
    return filtered;
  }

  String _normalizeStatus(String? status) => status?.toLowerCase() ?? 'unknown';

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

// Font weight constants

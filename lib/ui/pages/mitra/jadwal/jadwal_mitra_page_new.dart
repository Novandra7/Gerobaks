import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/pages/mitra/jadwal/jadwal_mitra_page_map_view.dart';
import 'package:bank_sha/ui/pages/mitra/pengambilan/detail_pickup.dart';
import 'package:bank_sha/ui/widgets/mitra/jadwal_mitra_header.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

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

  // Stats data
  int _locationCount = 7;
  int _pendingCount = 5;
  int _completedCount = 2;

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
    setState(() {
      _isLoading = true;
    });

    try {
      if (_driverId != null) {
        // Simulate loading
        await Future.delayed(const Duration(seconds: 1));

        // Update stats
        setState(() {
          _locationCount = 7;
          _pendingCount = 5;
          _completedCount = 2;
        });
      } else {
        throw Exception("ID driver tidak ditemukan");
      }
    } catch (e) {
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
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
            itemCount: _getFilteredSchedules().length,
            itemBuilder: (context, index) {
              final schedule = _getFilteredSchedules()[index];
              return _buildScheduleCard(schedule, index, isSmallScreen);
            },
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

  Widget _buildScheduleCard(
    Map<String, dynamic> schedule,
    int index,
    bool isSmallScreen,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigate to detail page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPickupPage(scheduleId: schedule["id"]),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 1),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // Time and status
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 10 : 12,
                vertical: isSmallScreen ? 6 : 8,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.only(
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
                        Icons.access_time_rounded,
                        size: isSmallScreen ? 12 : 14,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: isSmallScreen ? 3 : 4),
                      Text(
                        schedule["time"],
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
                        schedule["status"],
                      ).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Text(
                      _getStatusText(schedule["status"]),
                      style: TextStyle(
                        color: _getStatusColor(schedule["status"]),
                        fontWeight: semiBold,
                        fontSize: isSmallScreen ? 9 : 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Customer info
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF37DE7A), const Color(0xFF00A643)],
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          schedule["customer_name"],
                          style: whiteTextStyle.copyWith(
                            fontSize: isSmallScreen ? 13 : 15,
                            fontWeight: bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Distance and time indicators with icons
                      Row(
                        children: [
                          Icon(
                            Icons.directions_walk,
                            color: Colors.white,
                            size: isSmallScreen ? 10 : 12,
                          ),
                          SizedBox(width: 2),
                          Text(
                            schedule["estimatedDistance"],
                            style: whiteTextStyle.copyWith(
                              fontSize: isSmallScreen ? 9 : 10,
                              fontWeight: medium,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.access_time,
                            color: Colors.white,
                            size: isSmallScreen ? 10 : 12,
                          ),
                          SizedBox(width: 2),
                          Text(
                            schedule["estimatedTime"],
                            style: whiteTextStyle.copyWith(
                              fontSize: isSmallScreen ? 9 : 10,
                              fontWeight: medium,
                            ),
                          ),
                        ],
                      ),
                    ],
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
                          schedule["address"],
                          style: whiteTextStyle.copyWith(
                            fontSize: isSmallScreen ? 11 : 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  Row(
                    children: [
                      _buildWasteTypeChip(
                        schedule["waste_type"],
                        isSmallScreen,
                      ),
                      SizedBox(width: isSmallScreen ? 6 : 8),
                      _buildWasteWeightChip(
                        schedule["waste_weight"],
                        isSmallScreen,
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

  Widget _buildWasteTypeChip(String wasteType, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 5 : 7,
        vertical: isSmallScreen ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Text(
        wasteType,
        style: whiteTextStyle.copyWith(
          fontSize: isSmallScreen ? 8 : 9,
          fontWeight: medium,
        ),
      ),
    );
  }

  Widget _buildWasteWeightChip(String wasteWeight, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 5 : 7,
        vertical: isSmallScreen ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Text(
        wasteWeight,
        style: whiteTextStyle.copyWith(
          fontSize: isSmallScreen ? 8 : 9,
          fontWeight: medium,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
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

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'in_progress':
        return 'Diproses';
      case 'completed':
        return 'Selesai';
      default:
        return 'Unknown';
    }
  }

  List<Map<String, dynamic>> _getFilteredSchedules() {
    // Data dummy untuk pengujian
    final List<Map<String, dynamic>> schedules = [
      {
        "id": "001",
        "customer_name": "Wahyu Indra",
        "address": "Jl. Muso Salim B, Kota Samarinda, Kalimantan Timur",
        "time": "09:00 - 11:00",
        "waste_type": "Organik",
        "waste_weight": "3 kg",
        "status": "pending",
        "estimatedDistance": "500m",
        "estimatedTime": "10 menit",
        "priority": 1,
      },
      {
        "id": "002",
        "customer_name": "Siti Rahayu",
        "address": "Perumahan Indah Blok B, Kota Samarinda",
        "time": "09:00 - 11:00",
        "waste_type": "Anorganik",
        "waste_weight": "1.5 kg",
        "status": "completed",
        "estimatedDistance": "800m",
        "estimatedTime": "15 menit",
        "priority": 3,
      },
      {
        "id": "003",
        "customer_name": "Ahmad Rizal",
        "address": "Jl. Juanda No. 45, Kota Samarinda",
        "time": "09:00 - 11:00",
        "waste_type": "Organik",
        "waste_weight": "3 kg",
        "status": "in_progress",
        "estimatedDistance": "1.2km",
        "estimatedTime": "20 menit",
        "priority": 2,
      },
      {
        "id": "004",
        "customer_name": "Wahyu Indra",
        "address": "Jl. Muso Salim B, Kota Samarinda",
        "time": "09:00 - 11:00",
        "waste_type": "Organik",
        "waste_weight": "2 kg",
        "status": "pending",
        "estimatedDistance": "1.5km",
        "estimatedTime": "25 menit",
        "priority": 4,
      },
    ];

    // Filter jadwal sesuai dengan tab yang dipilih
    List<Map<String, dynamic>> filtered;
    if (_selectedFilter == "semua") {
      filtered = schedules;
    } else {
      filtered = schedules
          .where((s) => s["status"] == _selectedFilter)
          .toList();
    }

    // Sort by priority (in a real app, this would be based on time or distance)
    filtered.sort((a, b) => a["priority"].compareTo(b["priority"]));

    return filtered;
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

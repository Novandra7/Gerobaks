import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/pages/mitra/jadwal/jadwal_mitra_page_map_view.dart';
import 'package:bank_sha/ui/pages/mitra/pengambilan/detail_pickup.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

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
    // Menghitung ukuran berdasarkan golden ratio
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
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
    // Menghitung ukuran berdasarkan golden ratio
    final screenWidth = MediaQuery.of(context).size.width;
    final basePadding =
        screenWidth / 25; // Base padding yang proporsional dengan layar
    final spacingSmall =
        basePadding / 1.618; // Spacing kecil berdasarkan golden ratio
    final spacingMedium = basePadding; // Spacing sedang
    final spacingLarge =
        basePadding * 1.618; // Spacing besar berdasarkan golden ratio
    final iconSize = basePadding * 1.1; // Ukuran icon proporsional
    final borderRadius = basePadding * 1.2; // Border radius proporsional

    // Font sizes berdasarkan golden ratio
    final titleFontSize = basePadding * 1.1;
    final headerTitleFontSize = basePadding * 1.618;
    final statCountFontSize = basePadding * 1.1;
    final statLabelFontSize = basePadding * 0.65;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF37DE7A), Color(0xFF00A643)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 1.0],
          transform: GradientRotation(0.2),
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00A643).withOpacity(0.25),
            blurRadius: spacingLarge,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + spacingMedium * 1.2,
        bottom: spacingMedium * 1.5,
        left: spacingMedium,
        right: spacingMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Top bar with logo and notifications
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(iconSize * 0.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(spacingSmall * 0.5),
                    child: Image.asset(
                      'assets/img_logo.png',
                      width: iconSize * 1.8,
                      height: iconSize * 1.8,
                    ),
                  ),
                  SizedBox(width: spacingSmall),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GEROBAKS',
                        style: whiteTextStyle.copyWith(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Waste Management',
                        style: whiteTextStyle.copyWith(
                          fontSize: statLabelFontSize,
                          fontWeight: medium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Notification and chat icons
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Navigate to chat
                    },
                    child: Container(
                      padding: EdgeInsets.all(spacingSmall),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                          spacingMedium * 0.75,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.white,
                        size: iconSize,
                      ),
                    ),
                  ),
                  SizedBox(width: spacingSmall),
                  GestureDetector(
                    onTap: () {
                      // Navigate to notifications
                    },
                    child: Container(
                      padding: EdgeInsets.all(spacingSmall),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                          spacingMedium * 0.75,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Icon(
                            Icons.notifications_none,
                            color: Colors.white,
                            size: iconSize,
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: iconSize * 0.5,
                              height: iconSize * 0.5,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: spacingMedium * 1.2),

          // Jadwal Pengambilan Text with enhanced styling
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: spacingMedium,
              vertical: spacingSmall,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(borderRadius * 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.white,
                  size: iconSize * 0.9,
                ),
                SizedBox(width: spacingSmall),
                Text(
                  'Jadwal Pengambilan',
                  style: whiteTextStyle.copyWith(
                    fontSize: headerTitleFontSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: spacingMedium * 1.3),

          // Stats cards - responsive layout for different screen sizes
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(
                  icon: Icons.location_on_outlined,
                  label: 'Lokasi',
                  count: _locationCount,
                  isSmallScreen: isSmallScreen,
                  basePadding: basePadding,
                  iconSize: iconSize,
                  countFontSize: statCountFontSize,
                  labelFontSize: statLabelFontSize,
                  borderRadius: borderRadius * 0.8,
                ),
                SizedBox(width: spacingSmall),
                _buildStatCard(
                  icon: Icons.people_outline,
                  label: 'Menunggu',
                  count: _pendingCount,
                  isSmallScreen: isSmallScreen,
                  basePadding: basePadding,
                  iconSize: iconSize,
                  countFontSize: statCountFontSize,
                  labelFontSize: statLabelFontSize,
                  borderRadius: borderRadius * 0.8,
                ),
                SizedBox(width: spacingSmall),
                _buildStatCard(
                  icon: Icons.check_circle_outline,
                  label: 'Selesai',
                  count: _completedCount,
                  isSmallScreen: isSmallScreen,
                  basePadding: basePadding,
                  iconSize: iconSize,
                  countFontSize: statCountFontSize,
                  labelFontSize: statLabelFontSize,
                  borderRadius: borderRadius * 0.8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int count,
    required bool isSmallScreen,
    double? basePadding,
    double? iconSize,
    double? countFontSize,
    double? labelFontSize,
    double? borderRadius,
  }) {
    // Nilai default jika parameter tidak diberikan
    final defaultBasePadding = isSmallScreen ? 20.0 : 25.0;
    final bp = basePadding ?? defaultBasePadding;
    final is1 = iconSize ?? (isSmallScreen ? 20.0 : 24.0);
    final cf = countFontSize ?? (isSmallScreen ? 18.0 : 20.0);
    final lf = labelFontSize ?? (isSmallScreen ? 10.0 : 12.0);
    final br = borderRadius ?? 16.0;

    // Ukuran kartu berdasarkan golden ratio
    final cardWidth = bp * 3.2;
    final cardHeight = cardWidth * 1.1;
    final padding = bp * 0.4;
    final spacingVertical = bp * 0.25;

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(br),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: padding,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(padding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: is1),
          SizedBox(height: spacingVertical),
          Text(
            count.toString(),
            style: whiteTextStyle.copyWith(
              fontSize: cf,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: spacingVertical * 0.5),
          Text(label, style: whiteTextStyle.copyWith(fontSize: lf)),
        ],
      ),
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
    final spacingLarge =
        basePadding * 1.618; // Spacing besar berdasarkan golden ratio
    final borderRadius = basePadding * 0.8; // Border radius proporsional
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
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: spacingMedium),
            itemCount: _getFilteredSchedules().length,
            itemBuilder: (context, index) {
              final schedule = _getFilteredSchedules()[index];
              return _buildScheduleCard(
                schedule,
                index,
                isSmallScreen,
                basePadding,
              );
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
    bool isSmallScreen, [
    double? basePadding,
  ]) {
    final bp = basePadding ?? (isSmallScreen ? 15.0 : 20.0);
    final tabHeight = bp * 1.618;
    final fontSize = bp * 0.6;
    final cornerRadius = bp * 0.5;
    final paddingV = bp * 0.25;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: paddingV),
        decoration: BoxDecoration(
          color: isSelected ? greenColor : Color(0xFFEAFBEF),
          borderRadius: BorderRadius.circular(cornerRadius),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: greenColor.withOpacity(0.3),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: (isSelected ? whiteTextStyle : greenTextStyle).copyWith(
            fontSize: fontSize,
            fontWeight: isSelected ? semiBold : medium,
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleCard(
    Map<String, dynamic> schedule,
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
            builder: (context) => DetailPickupPage(scheduleId: schedule["id"]),
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
                        schedule["time"],
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
                      color: _getStatusColor(
                        schedule["status"],
                      ).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(bp * 0.6),
                    ),
                    child: Text(
                      _getStatusText(schedule["status"]),
                      style: TextStyle(
                        color: _getStatusColor(schedule["status"]),
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
                        schedule["customer_name"],
                        style: whiteTextStyle.copyWith(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      // Add distance indicator
                      Text(
                        schedule["estimatedDistance"],
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
                          schedule["address"],
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
                        schedule["waste_type"],
                        isSmallScreen,
                        bp,
                      ),
                      SizedBox(width: spacingSmall),
                      _buildWasteWeightChip(
                        schedule["waste_weight"],
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
        "estimatedDistance": "500m • 10 menit",
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
        "estimatedDistance": "800m • 15 menit",
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
        "estimatedDistance": "1.2km • 20 menit",
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
        "estimatedDistance": "1.5km • 25 menit",
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

// Font weight constants

import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/pages/mitra/jadwal/jadwal_mitra_page_new.dart';
import 'package:bank_sha/ui/pages/mitra/pengambilan/pengambilan_list_page.dart';
import 'package:bank_sha/ui/pages/mitra/laporan/laporan_mitra_page.dart';
import 'package:bank_sha/ui/pages/mitra/profile/profile_mitra_page.dart';
import 'package:bank_sha/ui/pages/mitra/dashboard/notification_page.dart';
import 'package:bank_sha/ui/pages/mitra/dashboard/dashboard_widgets.dart';
import 'package:bank_sha/ui/widgets/shared/notification_icon_with_badge.dart';
// import 'package:bank_sha/ui/pages/mitra/dashboard/dashboard_widgets_improved.dart';
import 'package:bank_sha/ui/pages/mitra/dashboard/widgets/dashboard_components.dart';
import 'package:bank_sha/ui/pages/mitra/dashboard/widgets/detail_pickup_card.dart';
import 'package:bank_sha/utils/user_data_mock.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/services/mitra_api_service.dart';
import 'package:bank_sha/ui/widgets/shared/navbar_mitra.dart';
import 'package:bank_sha/ui/widgets/dashboard/dashboard_background.dart';
import 'package:bank_sha/utils/responsive_helper.dart';
import 'package:flutter/material.dart';

class MitraDashboardPage extends StatefulWidget {
  const MitraDashboardPage({super.key});

  @override
  State<MitraDashboardPage> createState() => _MitraDashboardPageState();
}

class _MitraDashboardPageState extends State<MitraDashboardPage> {
  int _currentIndex = 0;
  Map<String, dynamic>? currentUser;

  final List<Widget> _pages = [
    const MitraDashboardContent(),
    const JadwalMitraPageNew(),
    const PengambilanListPage(),
    const LaporanMitraPage(),
    const ProfileMitraPage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final localStorage = await LocalStorageService.getInstance();
    final userData = await localStorage.getUserData();
    if (userData != null) {
      final userFuture = UserDataMock.getUserByEmail(userData['email']);
      final user = await userFuture;
      setState(() {
        currentUser = user;
      });
    }
  }

  bool _isOnline = false;

  void _togglePower() {
    setState(() {
      _isOnline = !_isOnline;
    });

    // Anda dapat menambahkan kode untuk mengirim status online ke backend di sini
    // Misalnya:
    // apiService.updateDriverStatus(currentUser?['id'], _isOnline);

    // Tampilkan notifikasi kepada pengguna
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isOnline
              ? 'Status Anda sekarang AKTIF'
              : 'Status Anda sekarang TIDAK AKTIF',
        ),
        backgroundColor: _isOnline ? greenColor : Colors.grey,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackgroundColor,
      floatingActionButton: Builder(
        builder: (context) {
          final media = MediaQuery.of(context);
          // Ukuran tombol yang lebih responsif untuk berbagai ukuran layar
          final double fabSize = ResponsiveHelper.getResponsiveWidth(
            context,
            68,
          );

          // Tinggi navbar yang lebih responsif
          final double navHeight = ResponsiveHelper.getResponsiveHeight(
            context,
            70,
          );

          // Posisi tombol yang disesuaikan
          final double fabBottom =
              navHeight - fabSize / 2 + media.padding.bottom + 6;

          return Positioned(
            bottom: fabBottom,
            left: (media.size.width - fabSize) / 2,
            child: Material(
              elevation: 6,
              shape: const CircleBorder(),
              color: Colors.transparent,
              child: InkWell(
                onTap: _togglePower,
                customBorder: const CircleBorder(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: fabSize,
                  height: fabSize,
                  decoration: BoxDecoration(
                    gradient: _isOnline
                        ? LinearGradient(
                            colors: [greenColor, const Color(0xFF0CAF60)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: _isOnline ? null : const Color(0xFFE0E0E0),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: fabSize * 0.12,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _isOnline
                            ? greenColor.withOpacity(0.3)
                            : Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.power_settings_new_rounded,
                      color: _isOnline ? Colors.white : Colors.grey[400],
                      size: fabSize * 0.5,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: CustomBottomNavBarMitra(
          currentIndex: _currentIndex,
          onTabTapped: (index) {
            setState(() {
              _currentIndex = index;
            });

            // Refresh dashboard statistics ketika kembali ke tab dashboard (index 0)
            if (index == 0) {
              print('🔄 Switching to dashboard - refreshing statistics...');
              // Trigger refresh pada dashboard content
              Future.delayed(const Duration(milliseconds: 300), () {
                final dashboardContent = context
                    .findAncestorStateOfType<_MitraDashboardContentState>();
                dashboardContent?._loadStatistics();
              });
            }
          },
          isOnline: _isOnline,
          onPowerToggle: (online) {
            setState(() {
              _isOnline = online;
            });
          },
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _pages[_currentIndex],
      ),
    );
  }
}

class MitraDashboardContent extends StatefulWidget {
  const MitraDashboardContent({super.key});

  @override
  State<MitraDashboardContent> createState() => _MitraDashboardContentState();
}

class _MitraDashboardContentState extends State<MitraDashboardContent>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  Map<String, dynamic>? currentUser;
  Map<String, dynamic>? statistics;
  bool _isLoadingStats = true;
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();
  final ScrollController _scrollController = ScrollController();
  final MitraApiService _apiService = MitraApiService();

  // AutomaticKeepAliveClientMixin requirement
  @override
  bool get wantKeepAlive => true;

  // Parent index untuk navigasi

  // Metode untuk update parent state
  void _updateParentIndex(int index) {
    final parent = context.findAncestorStateOfType<_MitraDashboardPageState>();
    if (parent != null) {
      parent.setState(() {
        parent._currentIndex = index;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCurrentUser();
    _loadStatistics();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  // Lifecycle callback - dipanggil ketika app kembali ke foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Auto-refresh ketika app kembali aktif
      print('📱 App resumed - refreshing dashboard statistics...');
      _loadStatistics();
    }
  }

  Future<void> _loadCurrentUser() async {
    final localStorage = await LocalStorageService.getInstance();
    final userData = await localStorage.getUserData();
    if (userData != null && mounted) {
      setState(() {
        currentUser = userData;
      });
    }
  }

  Future<void> _loadStatistics() async {
    if (!mounted) return;

    setState(() {
      _isLoadingStats = true;
    });

    try {
      await _apiService.initialize();

      // Method 1: Try to get from backend statistics API
      try {
        final stats = await _apiService.getStatistics();

        if (mounted) {
          setState(() {
            statistics = stats;
            _isLoadingStats = false;
          });

          print('✅ Statistics loaded from API:');
          print('   - Completed today: ${stats['completed_today']}');
          print('   - Available schedules: ${stats['available_schedules']}');
          print('   - Active hours: ${stats['active_hours']}');
          print('   - Pending pickups: ${stats['pending_pickups']}');
        }
        return; // Success, exit early
      } catch (apiError) {
        print('⚠️ Statistics API error: $apiError');
        print('🔄 Falling back to manual count from schedules...');
      }

      // Method 2: Fallback - Count manually from schedule APIs
      // This ensures count matches with actual jadwal data
      final availableResult = await _apiService.getAvailableSchedules(page: 1);
      final availableSchedules = availableResult['schedules'] as List? ?? [];

      // For completed and active, we'll use approximate count
      // (In real app, backend should provide proper count endpoints)

      if (mounted) {
        setState(() {
          statistics = {
            'completed_today': 0,
            'available_schedules': availableSchedules.length,
            'active_hours': 0,
            'pending_pickups': 0,
          };
          _isLoadingStats = false;
        });

        print('✅ Statistics fallback (partial data):');
        print('   - Available schedules: ${availableSchedules.length}');
        print(
          '   ⚠️ Other fields need API: completed_today, active_hours, pending_pickups',
        );
      }
    } catch (e) {
      print('❌ Error loading statistics: $e');
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
          // Set default values on error
          statistics ??= {
            'completed_today': 0,
            'available_schedules': 0,
            'active_hours': 0,
            'pending_pickups': 0,
          };
        });

        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat statistik: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Coba Lagi',
              textColor: Colors.white,
              onPressed: _loadStatistics,
            ),
          ),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    await Future.wait([_loadCurrentUser(), _loadStatistics()]);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Pagi';
    } else if (hour < 15) {
      return 'Siang';
    } else if (hour < 18) {
      return 'Sore';
    } else {
      return 'Malam';
    }
  }

  String _getCurrentDateString() {
    final now = DateTime.now();
    final days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${days[now.weekday % 7]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  // Quick Action untuk menu di header
  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        ResponsiveHelper.getResponsiveRadius(context, 10),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          ResponsiveHelper.getResponsiveSpacing(context, 4),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(
                ResponsiveHelper.getResponsiveSpacing(context, 10),
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: ResponsiveHelper.getResponsiveIconSize(context, 20),
              ),
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 6)),
            Text(
              label,
              style: whiteTextStyle.copyWith(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                fontWeight: medium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Stat Card untuk statistik - Redesign untuk mengatasi overflow
  Widget _buildStatCard({
    required String title,
    required String value,
    required Color backgroundColor,
    required Color valueColor,
    required IconData icon,
    String? suffix,
  }) {
    final bool isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    return Container(
      padding: EdgeInsets.all(
        ResponsiveHelper.getResponsiveSpacing(context, isSmallScreen ? 12 : 16),
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveRadius(context, 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title dan Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: whiteTextStyle.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      isSmallScreen ? 12 : 13,
                    ),
                    fontWeight: semiBold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                icon,
                color: whiteColor.withOpacity(0.9),
                size: ResponsiveHelper.getResponsiveIconSize(
                  context,
                  isSmallScreen ? 18 : 20,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Value
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: whiteTextStyle.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    isSmallScreen ? 32 : 36,
                  ),
                  fontWeight: bold,
                  height: 1,
                ),
              ),
              if (suffix != null && suffix.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 4),
                  child: Text(
                    suffix,
                    style: whiteTextStyle.copyWith(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        isSmallScreen ? 16 : 18,
                      ),
                      fontWeight: medium,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin

    // Get screen size for responsive design
    final bool isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    return DashboardBackground(
      backgroundColor: const Color(
        0xFFF9FFF8,
      ), // Warna dari vector XML (#F9FFF8)
      child: Scaffold(
        backgroundColor: Colors
            .transparent, // Transparent untuk menampilkan background dari parent
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0), // Hide default AppBar
          child: Container(),
        ),
        body: RefreshIndicator(
          key: _refreshKey,
          onRefresh: _refreshData,
          color: greenColor,
          backgroundColor: Colors.white,
          displacement: ResponsiveHelper.getResponsiveHeight(context, 40),
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan green background
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: greenColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(
                        ResponsiveHelper.getResponsiveRadius(context, 24),
                      ),
                      bottomRight: Radius.circular(
                        ResponsiveHelper.getResponsiveRadius(context, 24),
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    bottom: ResponsiveHelper.getResponsiveSpacing(context, 24),
                    left: ResponsiveHelper.getResponsiveSpacing(context, 20),
                    right: ResponsiveHelper.getResponsiveSpacing(context, 20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top bar with logo and notifications
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            'assets/img_gerobakss.png',
                            height: ResponsiveHelper.getResponsiveHeight(
                              context,
                              24,
                            ),
                            color: Colors.white,
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  // Implementasi untuk chat
                                },
                                icon: Icon(
                                  Icons.chat_outlined,
                                  color: Colors.white,
                                  size: ResponsiveHelper.getResponsiveIconSize(
                                    context,
                                    24,
                                  ),
                                ),
                                tooltip: 'Chat',
                                iconSize:
                                    ResponsiveHelper.getResponsiveIconSize(
                                      context,
                                      24,
                                    ),
                                padding: EdgeInsets.all(
                                  ResponsiveHelper.getResponsiveSpacing(
                                    context,
                                    8,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(
                                  ResponsiveHelper.getResponsiveSpacing(
                                    context,
                                    8,
                                  ),
                                ),
                                child: NotificationIconWithBadge(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const NotificationPage(),
                                      ),
                                    );
                                  },
                                  useAssetIcon: false,
                                  iconColor: Colors.white,
                                  iconSize:
                                      ResponsiveHelper.getResponsiveIconSize(
                                        context,
                                        24,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          16,
                        ),
                      ),

                      // Vehicle info
                      Row(
                        children: [
                          Icon(
                            Icons.local_shipping_outlined,
                            color: Colors.white.withOpacity(0.9),
                            size: ResponsiveHelper.getResponsiveIconSize(
                              context,
                              16,
                            ),
                          ),
                          SizedBox(
                            width: ResponsiveHelper.getResponsiveSpacing(
                              context,
                              6,
                            ),
                          ),
                          Text(
                            currentUser != null &&
                                    currentUser!['vehicle'] != null
                                ? currentUser!['vehicle']
                                : 'KT 777 WAN',
                            style: whiteTextStyle.copyWith(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                13,
                              ),
                              fontWeight: medium,
                            ),
                          ),
                          SizedBox(
                            width: ResponsiveHelper.getResponsiveSpacing(
                              context,
                              16,
                            ),
                          ),
                          Icon(
                            Icons.badge_outlined,
                            color: Colors.white.withOpacity(0.9),
                            size: ResponsiveHelper.getResponsiveIconSize(
                              context,
                              16,
                            ),
                          ),
                          SizedBox(
                            width: ResponsiveHelper.getResponsiveSpacing(
                              context,
                              6,
                            ),
                          ),
                          Text(
                            currentUser != null && currentUser!['id'] != null
                                ? 'DRV-${currentUser!['id']}'
                                : 'DRV-KTM-214',
                            style: whiteTextStyle.copyWith(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                13,
                              ),
                              fontWeight: medium,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          20,
                        ),
                      ),

                      // Greeting with name and date
                      Text(
                        'Selamat ${_getGreeting()},',
                        style: whiteTextStyle.copyWith(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            isSmallScreen ? 20 : 22,
                          ),
                          fontWeight: semiBold,
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          4,
                        ),
                      ),
                      Text(
                        currentUser != null && currentUser!['name'] != null
                            ? currentUser!['name'].split(' ')[0]
                            : 'Mitra',
                        style: whiteTextStyle.copyWith(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            isSmallScreen ? 24 : 28,
                          ),
                          fontWeight: bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Statistik Hari Ini
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.7,
                        children: [
                          buildStatCard(
                            'Pengambilan Selesai',
                            '12',
                            Colors.blue,
                          ),
                          buildStatCard(
                            'Jadwal Tersedia',
                            '8',
                            const Color(0xFFFBBF24),
                          ),
                          buildStatCard('Waktu Aktif', '7j', Colors.orange),
                          buildStatCard(
                            'Pengambilan Menunggu',
                            '17',
                            Colors.teal,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Jadwal Pengambilan (sudah dihandle oleh widget baru)

                // Quick Stats Title with Responsive Layout
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        height: 32,
                        width: 4,
                        decoration: BoxDecoration(
                          color: greenColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Selamat ${_getGreeting()}, ${currentUser != null ? currentUser!['name'].split(' ')[0] : 'Fulan bin Fulan'}',
                        style: whiteTextStyle.copyWith(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            isSmallScreen ? 20 : 22,
                          ),
                          fontWeight: semiBold,
                        ),
                      ),

                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          24,
                        ),
                      ),

                      // Quick Action buttons
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.getResponsiveSpacing(
                            context,
                            10,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            QuickActionButton(
                              icon: Icons.location_on_outlined,
                              label: 'Lokasi',
                              onTap: () {},
                              color: greenColor,
                            ),
                            QuickActionButton(
                              icon: Icons.list_alt_outlined,
                              label: 'Jadwal',
                              onTap: () {
                                _updateParentIndex(1);
                              },
                              color: greenColor,
                            ),
                            QuickActionButton(
                              icon: Icons.credit_card_outlined,
                              label: 'Bayar',
                              onTap: () {},
                              color: greenColor,
                            ),
                            QuickActionButton(
                              icon: Icons.help_outline_outlined,
                              label: 'Bantuan',
                              onTap: () {},
                              color: greenColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Statistik Hari Ini
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getResponsiveSpacing(
                      context,
                      20,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          24,
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: ResponsiveHelper.getResponsiveHeight(
                                  context,
                                  24,
                                ),
                                width: ResponsiveHelper.getResponsiveWidth(
                                  context,
                                  3,
                                ),
                                decoration: BoxDecoration(
                                  color: greenColor,
                                  borderRadius: BorderRadius.circular(
                                    ResponsiveHelper.getResponsiveRadius(
                                      context,
                                      2,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: ResponsiveHelper.getResponsiveSpacing(
                                  context,
                                  10,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Statistik Hari Ini',
                                    style: blackTextStyle.copyWith(
                                      fontSize:
                                          ResponsiveHelper.getResponsiveFontSize(
                                            context,
                                            isSmallScreen ? 16 : 18,
                                          ),
                                      fontWeight: semiBold,
                                    ),
                                  ),
                                  SizedBox(
                                    height:
                                        ResponsiveHelper.getResponsiveSpacing(
                                          context,
                                          2,
                                        ),
                                  ),
                                  Text(
                                    _getCurrentDateString(),
                                    style: greyTextStyle.copyWith(
                                      fontSize:
                                          ResponsiveHelper.getResponsiveFontSize(
                                            context,
                                            11,
                                          ),
                                      fontWeight: regular,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              _loadStatistics();
                            },
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getResponsiveRadius(context, 16),
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    ResponsiveHelper.getResponsiveSpacing(
                                      context,
                                      12,
                                    ),
                                vertical: ResponsiveHelper.getResponsiveSpacing(
                                  context,
                                  6,
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: greenColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  ResponsiveHelper.getResponsiveRadius(
                                    context,
                                    20,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.refresh_rounded,
                                    color: greenColor,
                                    size:
                                        ResponsiveHelper.getResponsiveIconSize(
                                          context,
                                          14,
                                        ),
                                  ),
                                  SizedBox(
                                    width:
                                        ResponsiveHelper.getResponsiveSpacing(
                                          context,
                                          4,
                                        ),
                                  ),
                                  Text(
                                    'Refresh',
                                    style: greentextstyle2.copyWith(
                                      fontSize:
                                          ResponsiveHelper.getResponsiveFontSize(
                                            context,
                                            12,
                                          ),
                                      fontWeight: medium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          20,
                        ),
                      ),
                    ],
                  ),
                ),

                // Responsive Grid Layout for Stats - 2x2 grid dengan layout baru
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getResponsiveSpacing(
                      context,
                      20,
                    ),
                  ),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: ResponsiveHelper.getResponsiveSpacing(
                      context,
                      8,
                    ), // Jarak lebih kecil
                    mainAxisSpacing: ResponsiveHelper.getResponsiveSpacing(
                      context,
                      8,
                    ), // Jarak lebih kecil
                    childAspectRatio: isSmallScreen
                        ? 1.0
                        : 1.1, // Rasio yang lebih tinggi untuk vertical layout
                    children: [
                      // 1. Selesai Hari Ini (Hijau) - completed_today
                      _buildStatCard(
                        title: 'Selesai Hari Ini',
                        value: _isLoadingStats
                            ? '-'
                            : (statistics?['completed_today']?.toString() ??
                                  '0'),
                        backgroundColor: const Color(0xFF22C55E), // Green
                        valueColor: Colors.white,
                        icon: Icons.check_circle_outline,
                      ),

                      // 2. Jadwal Tersedia (Kuning/Yellow) - available_schedules
                      _buildStatCard(
                        title: 'Jadwal Tersedia',
                        value: _isLoadingStats
                            ? '-'
                            : (statistics?['available_schedules']?.toString() ??
                                  '0'),
                        backgroundColor: const Color(0xFFFBBF24), // Yellow/Gold
                        valueColor: Colors.white,
                        icon: Icons.calendar_today_outlined,
                        suffix: '',
                      ),

                      // 3. Waktu Aktif (Biru) - active_hours
                      _buildStatCard(
                        title: 'Waktu Aktif',
                        value: _isLoadingStats
                            ? '-'
                            : (statistics?['active_hours']?.toString() ?? '0'),
                        backgroundColor: const Color(0xFF3B82F6), // Blue
                        valueColor: Colors.white,
                        icon: Icons.access_time_outlined,
                        suffix: _isLoadingStats ? '' : 'j',
                      ),

                      // 4. Sedang Berjalan (Orange) - pending_pickups
                      _buildStatCard(
                        title: 'Sedang Berjalan',
                        value: _isLoadingStats
                            ? '-'
                            : (statistics?['pending_pickups']?.toString() ??
                                  '0'),
                        backgroundColor: const Color(0xFFF97316), // Orange
                        valueColor: Colors.white,
                        icon: Icons.local_shipping_outlined,
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: ResponsiveHelper.getResponsiveSpacing(context, 30),
                ),

                // Jadwal Pengambilan
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getResponsiveSpacing(
                      context,
                      20,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardSectionHeader(
                        title: 'Jadwal Pengambilan',
                        trailing: Row(
                          children: [
                            Container(
                              width: ResponsiveHelper.getResponsiveWidth(
                                context,
                                8,
                              ),
                              height: ResponsiveHelper.getResponsiveHeight(
                                context,
                                8,
                              ),
                              decoration: BoxDecoration(
                                color: greenColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(
                              width: ResponsiveHelper.getResponsiveSpacing(
                                context,
                                5,
                              ),
                            ),
                            Container(
                              width: ResponsiveHelper.getResponsiveWidth(
                                context,
                                8,
                              ),
                              height: ResponsiveHelper.getResponsiveHeight(
                                context,
                                8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          16,
                        ),
                      ),

                      // Jadwal Card dengan komponen detail pickup baru
                      DetailPickupCard(
                        customerName: 'Wahyu Indra',
                        phoneNumber: '+62 812-3456-7890',
                        address:
                            'JL. Muso Salim B, Kota Samarinda, Kalimantan Timur',
                        pickupTime: '14:00 - 16:00',
                        wasteType: 'Organik',
                        estimatedWeight: '2 kg',
                        status: 'Menunggu',
                        statusColor: const Color(0xFFFFB74D),
                        onTap: () {
                          // Handle tap action
                        },
                      ),

                      // Backup jadwal card lama
                      // _buildJadwalCard(),
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          16,
                        ),
                      ),
                    ],
                  ),
                ),

                // Quick Actions - Responsive Design
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getResponsiveSpacing(
                      context,
                      20,
                    ),
                  ),
                  child: DashboardSectionHeader(title: 'Aksi Cepat'),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getResponsiveSpacing(
                      context,
                      20,
                    ),
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: ResponsiveHelper.getResponsiveSpacing(
                        context,
                        isSmallScreen ? 10 : 12,
                      ),
                      mainAxisSpacing: ResponsiveHelper.getResponsiveSpacing(
                        context,
                        isSmallScreen ? 10 : 12,
                      ),
                      childAspectRatio: isSmallScreen ? 1.2 : 1.3,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      List<Map<String, dynamic>> actions = [
                        {
                          'title': 'Lihat Jadwal',
                          'subtitle': 'Jadwal pengambilan hari ini',
                          'icon': Icons.schedule_rounded,
                          'color': const Color(0xFF3B82F6), // Vibrant blue
                          'onTap': () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const JadwalMitraPageNew(),
                              ),
                            );
                          },
                        },
                        {
                          'title': 'Mulai Pengambilan',
                          'subtitle': 'Mulai rute pengambilan',
                          'icon': Icons.play_arrow_rounded,
                          'color': greenColor, // Match green theme
                          'onTap': () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PengambilanListPage(),
                              ),
                            );
                          },
                        },
                        {
                          'title': 'Laporan',
                          'subtitle': 'Buat laporan harian',
                          'icon': Icons.assignment_rounded,
                          'color': const Color(0xFF6366F1), // Better purple
                          'onTap': () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LaporanMitraPage(),
                              ),
                            );
                          },
                        },
                        {
                          'title': 'Bantuan',
                          'subtitle': 'Hubungi support',
                          'icon': Icons.help_rounded,
                          'color': const Color(0xFFF97316), // Warmer orange
                          'onTap': () {
                            // Navigate to help
                          },
                        },
                      ];

                      final action = actions[index];

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            ResponsiveHelper.getResponsiveRadius(context, 16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                              spreadRadius: 0,
                            ),
                          ],
                          border: Border.all(
                            color: action['color'].withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            ResponsiveHelper.getResponsiveRadius(context, 16),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getResponsiveRadius(context, 16),
                            ),
                            onTap: action['onTap'],
                            splashColor: action['color'].withOpacity(0.1),
                            highlightColor: action['color'].withOpacity(0.05),
                            child: Padding(
                              padding: EdgeInsets.all(
                                ResponsiveHelper.getResponsiveSpacing(
                                  context,
                                  isSmallScreen ? 16 : 20,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(
                                      ResponsiveHelper.getResponsiveSpacing(
                                        context,
                                        12,
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      color: action['color'].withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(
                                        ResponsiveHelper.getResponsiveRadius(
                                          context,
                                          14,
                                        ),
                                      ),
                                    ),
                                    child: Icon(
                                      action['icon'],
                                      color: action['color'],
                                      size:
                                          ResponsiveHelper.getResponsiveIconSize(
                                            context,
                                            28,
                                          ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        action['title'],
                                        style: blackTextStyle.copyWith(
                                          fontSize:
                                              ResponsiveHelper.getResponsiveFontSize(
                                                context,
                                                isSmallScreen ? 14 : 16,
                                              ),
                                          fontWeight: bold,
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            ResponsiveHelper.getResponsiveSpacing(
                                              context,
                                              4,
                                            ),
                                      ),
                                      Text(
                                        action['subtitle'],
                                        style: greyTextStyle.copyWith(
                                          fontSize:
                                              ResponsiveHelper.getResponsiveFontSize(
                                                context,
                                                isSmallScreen ? 11 : 12,
                                              ),
                                          fontWeight: medium,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom spacing
                SizedBox(
                  height: ResponsiveHelper.getResponsiveSpacing(context, 80),
                ), // Extra space at bottom for the FAB
              ],
            ),
          ),
        ),
        // Back to top button
        floatingActionButton: FloatingActionButton.small(
          backgroundColor: Colors.white,
          elevation: 4,
          onPressed: () {
            // Scroll to top
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          child: Icon(
            Icons.arrow_upward_rounded,
            color: greenColor,
            size: ResponsiveHelper.getResponsiveIconSize(context, 20),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}

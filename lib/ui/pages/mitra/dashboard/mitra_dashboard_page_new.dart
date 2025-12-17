import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/shared/route_observer.dart';
import 'package:bank_sha/ui/pages/mitra/jadwal/jadwal_mitra_page_new.dart';
import 'package:bank_sha/ui/pages/mitra/profile/profile_mitra_page.dart';
import 'package:bank_sha/ui/pages/mitra/dashboard/notification_page.dart';
import 'package:bank_sha/utils/user_data_mock.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/services/mitra_api_service.dart';
import 'package:bank_sha/ui/widgets/dashboard/dashboard_background.dart';
import 'package:bank_sha/ui/widgets/mitra/statistics_grid.dart';
import 'package:bank_sha/ui/widgets/mitra/schedule_section.dart';
import 'package:bank_sha/ui/widgets/mitra/custom_bottom_navbar.dart';
import 'package:bank_sha/ui/widgets/shared/notification_icon_with_badge.dart';

/// ======== CUSTOM APPBAR (Hello David! style) ========
class DashboardGreetingAppBar extends StatelessWidget {
  final String name;
  final String? profileImage;
  final VoidCallback? onNotificationPressed;

  const DashboardGreetingAppBar({
    super.key,
    required this.name,
    this.profileImage,
    this.onNotificationPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // === PROFILE + GREETING ===
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage: profileImage != null
                      ? AssetImage(profileImage!)
                      : const AssetImage('assets/images/img_friend4.png'),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$name!',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // === NOTIFICATION ICON WITH DYNAMIC BADGE ===
            NotificationIconWithBadge(onTap: onNotificationPressed),
          ],
        ),
      ),
    );
  }
}

/// ================= DASHBOARD PAGE ===================
class MitraDashboardPageNew extends StatefulWidget {
  const MitraDashboardPageNew({super.key});

  @override
  State<MitraDashboardPageNew> createState() => _MitraDashboardPageNewState();
}

class _MitraDashboardPageNewState extends State<MitraDashboardPageNew> {
  int _currentIndex = 0;
  Map<String, dynamic>? currentUser;

  // GlobalKey untuk mengakses state dari dashboard content
  final GlobalKey<_MitraDashboardContentNewState> _dashboardKey =
      GlobalKey<_MitraDashboardContentNewState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();

    // Initialize pages with dashboard key
    _pages = [
      MitraDashboardContentNew(key: _dashboardKey),
      const JadwalMitraPageNew(),
      const ProfileMitraPage(),
    ];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackgroundColor,
      bottomNavigationBar: CustomBottomNavBarMitraNew(
        currentIndex: _currentIndex,
        onTabTapped: (index) {
          setState(() {
            _currentIndex = index;
          });

          // Refresh dashboard statistics ketika kembali ke tab dashboard (index 0)
          if (index == 0 && _dashboardKey.currentState != null) {
            print('🔄 Tab switched to dashboard - refreshing statistics...');
            _dashboardKey.currentState!._loadStatistics();
          }
        },
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

/// ================= DASHBOARD CONTENT ===================
class MitraDashboardContentNew extends StatefulWidget {
  const MitraDashboardContentNew({super.key});

  @override
  State<MitraDashboardContentNew> createState() =>
      _MitraDashboardContentNewState();
}

class _MitraDashboardContentNewState extends State<MitraDashboardContentNew>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver, RouteAware {
  Map<String, dynamic>? currentUser;
  Map<String, dynamic>? statistics;
  bool _isLoadingStats = false;
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();
  final ScrollController _scrollController = ScrollController();

  // Timer untuk periodic refresh
  Timer? _refreshTimer;
  DateTime? _lastRefreshTime;

  // AutomaticKeepAliveClientMixin requirement
  @override
  bool get wantKeepAlive => true;

  String getTodaySchedule() {
    final now = DateFormat('EEEE', 'id_ID').format(DateTime.now());
    switch (now.toLowerCase()) {
      case 'senin':
        return 'Organik';
      case 'selasa':
        return 'Anorganik';
      case 'rabu':
        return 'B3';
      case 'kamis':
      case 'jumat':
      case 'sabtu':
      case 'minggu':
        return 'Campuran';
      default:
        return '-';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCurrentUser();
    _loadStatistics();
    _startPeriodicRefresh();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  // RouteAware callbacks - dipanggil saat navigation changes
  @override
  void didPopNext() {
    // Called when user returns to this page from another page
    print('🔙 Returned to dashboard from another page - refreshing...');
    _loadStatistics();
    _startPeriodicRefresh(); // Restart timer
  }

  @override
  void didPush() {
    // Called when this route is pushed onto the navigator
    print('➡️ Dashboard page pushed');
  }

  @override
  void didPop() {
    // Called when this route is popped off the navigator
    print('⬅️ Dashboard page popped');
    _refreshTimer?.cancel();
  }

  @override
  void didPushNext() {
    // Called when a new route is pushed on top of this route
    print('⏸️ Dashboard paused - another page pushed on top');
    _refreshTimer?.cancel(); // Pause timer saat page lain di atas
  }

  // Lifecycle callback - refresh ketika app kembali ke foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      print('📱 App resumed - refreshing dashboard statistics...');
      _loadStatistics();
      _startPeriodicRefresh(); // Restart timer
    } else if (state == AppLifecycleState.paused) {
      _refreshTimer?.cancel(); // Stop timer saat app di background
    }
  }

  /// Start periodic refresh every 30 seconds
  void _startPeriodicRefresh() {
    _refreshTimer?.cancel(); // Cancel existing timer

    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        print('⏰ Periodic refresh triggered (every 30s)');
        _loadStatisticsQuietly(); // Silent refresh tanpa loading indicator
      }
    });
  }

  /// Load statistics tanpa loading indicator (untuk background refresh)
  Future<void> _loadStatisticsQuietly() async {
    // Skip jika sedang loading
    if (_isLoadingStats) return;

    // Skip jika baru saja refresh (< 10 detik)
    if (_lastRefreshTime != null &&
        DateTime.now().difference(_lastRefreshTime!) <
            const Duration(seconds: 10)) {
      print(
        '⏸️ Skipping refresh - too soon (${DateTime.now().difference(_lastRefreshTime!).inSeconds}s ago)',
      );
      return;
    }

    try {
      final apiService = MitraApiService();
      final stats = await apiService.getStatistics();

      if (mounted) {
        setState(() {
          statistics = stats;
          _lastRefreshTime = DateTime.now();
        });
        print('✅ Quiet refresh completed');
      }
    } catch (e) {
      print('⚠️ Quiet refresh error: $e');
      // Silent error - tidak update UI
    }
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoadingStats = true;
    });

    try {
      final apiService = MitraApiService();
      final stats = await apiService.getStatistics();

      if (mounted) {
        setState(() {
          statistics = stats;
          _isLoadingStats = false;
          _lastRefreshTime = DateTime.now();
        });
        print('✅ Statistics loaded at $_lastRefreshTime');
      }
    } catch (e) {
      print('❌ Error loading statistics: $e');
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
          statistics = {
            'completed_today': 0,
            'available_schedules': 0,
            'active_hours': 0,
            'pending_pickups': 0,
          };
        });
      }
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

  Future<void> _refreshData() async {
    await Future.wait([_loadCurrentUser(), _loadStatistics()]);
    return Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin

    final today = DateFormat('EEEE', 'id_ID').format(DateTime.now());
    final scheduleToday = getTodaySchedule();

    return DashboardBackground(
      backgroundColor: const Color(0xFFF9FFF8),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          toolbarHeight: 0,
        ),
        body: RefreshIndicator(
          key: _refreshKey,
          onRefresh: _refreshData,
          color: const Color(0xFF01A643),
          backgroundColor: Colors.white,
          displacement: 40,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ====== CUSTOM APPBAR ======
                DashboardGreetingAppBar(
                  name: currentUser != null
                      ? currentUser!['name'].split(' ')[0]
                      : 'Guest',
                  profileImage: 'assets/img_friend4.png',
                  onNotificationPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                /// ====== JADWAL HARI INI (DIPINDAH KE ATAS) ======
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          color: Color(0xFF01A643),
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Jadwal Pengambilan Hari Ini',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$today: $scheduleToday',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF01A643),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// ====== QUICK ACTION: MITRA PICKUP SYSTEM ======
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/mitra-pickup');
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF01A643), Color(0xFF00C853)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF01A643).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          // Icon Container
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.local_shipping_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Text Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Sistem Penjemputan Mitra',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Kelola jadwal penjemputan sampah',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Arrow Icon
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// ====== STATISTICS ======
                StatisticsGrid(
                  statistics: statistics,
                  isLoading: _isLoadingStats,
                  onRefresh: () {
                    _refreshKey.currentState?.show();
                  },
                ),

                const SizedBox(height: 24),

                /// ====== SCHEDULE SECTION LAMA ======
                const ScheduleSection(scheduleCards: []),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

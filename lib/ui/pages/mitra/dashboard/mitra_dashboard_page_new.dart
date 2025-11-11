import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/pages/mitra/jadwal/jadwal_mitra_page_new.dart';
import 'package:bank_sha/ui/pages/mitra/profile/profile_mitra_page.dart';
import 'package:bank_sha/ui/pages/mitra/dashboard/notification_page.dart';
import 'package:bank_sha/utils/user_data_mock.dart';
import 'package:bank_sha/services/local_storage_service.dart';
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

  final List<Widget> _pages = [
    const MitraDashboardContentNew(),
    const JadwalMitraPageNew(),
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

class _MitraDashboardContentNewState extends State<MitraDashboardContentNew> {
  Map<String, dynamic>? currentUser;
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();
  final ScrollController _scrollController = ScrollController();

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
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    await _loadCurrentUser();
    return Future.delayed(const Duration(milliseconds: 1500));
  }

  @override
  Widget build(BuildContext context) {
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

                /// ====== STATISTICS ======
                StatisticsGrid(
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

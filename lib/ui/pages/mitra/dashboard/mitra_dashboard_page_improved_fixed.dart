import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/pages/mitra/jadwal/jadwal_mitra_page.dart';
import 'package:bank_sha/ui/pages/mitra/pengambilan/pengambilan_list_page.dart';
import 'package:bank_sha/ui/pages/mitra/laporan/laporan_mitra_page.dart';
import 'package:bank_sha/ui/pages/mitra/profile/profile_mitra_page_fixed.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/utils/user_data_mock.dart';
import 'package:flutter/material.dart';

class MitraDashboardPageImproved extends StatefulWidget {
  const MitraDashboardPageImproved({super.key});

  @override
  State<MitraDashboardPageImproved> createState() => _MitraDashboardPageImprovedState();
}

class _MitraDashboardPageImprovedState extends State<MitraDashboardPageImproved> {
  int _currentIndex = 0;
  Map<String, dynamic>? currentUser;

  final List<Widget> _pages = [
    const MitraDashboardContent(),
    const JadwalMitraPage(),
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
      final user = UserDataMock.getUserByEmail(userData['email']);
      setState(() {
        currentUser = user;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: greenColor,
        unselectedItemColor: greyColor,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Pengambilan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Laporan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class MitraDashboardContent extends StatefulWidget {
  const MitraDashboardContent({super.key});

  @override
  State<MitraDashboardContent> createState() => _MitraDashboardContentState();
}

class _MitraDashboardContentState extends State<MitraDashboardContent> {
  Map<String, dynamic>? currentUser;
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();
  final ScrollController _scrollController = ScrollController();

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
    // Add additional refresh logic here as needed
    return Future.delayed(const Duration(milliseconds: 1500));
  }

  // Helper methods for date formatting
  String _getDayName(int day) {
    switch (day) {
      case 1:
        return 'Senin';
      case 2:
        return 'Selasa';
      case 3:
        return 'Rabu';
      case 4:
        return 'Kamis';
      case 5:
        return 'Jumat';
      case 6:
        return 'Sabtu';
      case 7:
        return 'Minggu';
      default:
        return '';
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Januari';
      case 2:
        return 'Februari';
      case 3:
        return 'Maret';
      case 4:
        return 'April';
      case 5:
        return 'Mei';
      case 6:
        return 'Juni';
      case 7:
        return 'Juli';
      case 8:
        return 'Agustus';
      case 9:
        return 'September';
      case 10:
        return 'Oktober';
      case 11:
        return 'November';
      case 12:
        return 'Desember';
      default:
        return '';
    }
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

  // Reusable widget for section headers
  Widget _buildSectionHeader(String title) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 360;
    
    return Row(
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
          title,
          style: blackTextStyle.copyWith(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: semiBold,
          ),
        ),
      ],
    );
  }

  // Tag Widget for items
  Widget _buildTag({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10, 
        vertical: 5
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: medium,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;

    // Get current date for greeting
    final DateTime now = DateTime.now();
    final String dateStr =
        '${_getDayName(now.weekday)}, ${now.day} ${_getMonthName(now.month)} ${now.year}';

    return Scaffold(
      backgroundColor: lightBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: greenColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Image.asset('assets/img_gerobakss.png', height: 32),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () {
                        // TODO: Implement notifications
                      },
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                      tooltip: 'Notifikasi',
                      splashRadius: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: _refreshData,
        color: greenColor,
        backgroundColor: Colors.white,
        displacement: 40,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16 : 20,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome banner with date
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Selamat ${_getGreeting()}, ',
                          style: blackTextStyle.copyWith(
                            fontSize: isSmallScreen ? 18 : 20,
                            fontWeight: semiBold,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            currentUser != null
                                ? currentUser!['name'].split(' ')[0]
                                : 'Mitra',
                            style: greentextstyle2.copyWith(
                              fontSize: isSmallScreen ? 18 : 20,
                              fontWeight: semiBold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: greyColor),
                        const SizedBox(width: 6),
                        Text(
                          dateStr,
                          style: greyTextStyle.copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Welcome Card with improved design
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      greenColor,
                      greenColor.withOpacity(0.85),
                      greenColor.withOpacity(0.75),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: greenColor.withOpacity(0.25),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: isSmallScreen ? 48 : 52,
                          width: isSmallScreen ? 48 : 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.8),
                              width: 2,
                            ),
                            image: DecorationImage(
                              image: AssetImage(
                                currentUser != null &&
                                        currentUser!['profile_picture'] != null
                                    ? currentUser!['profile_picture']
                                    : 'assets/img_friend1.png',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 12 : 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Area Kerja',
                                style: whiteTextStyle.copyWith(
                                  fontSize: isSmallScreen ? 13 : 14,
                                  fontWeight: medium,
                                  height: 1.2,
                                ),
                              ),
                              Text(
                                currentUser != null
                                    ? '${currentUser!['work_area']}'
                                    : 'Jakarta Selatan',
                                style: whiteTextStyle.copyWith(
                                  fontSize: isSmallScreen ? 18 : 20,
                                  fontWeight: bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: isSmallScreen ? 10 : 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.directions_car_outlined,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      currentUser != null
                                          ? '${currentUser!['vehicle']}'
                                          : 'Pickup - KT 1234 XY',
                                      style: whiteTextStyle,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: isSmallScreen ? 6 : 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'ID: DRV-2241',
                                  style: whiteTextStyle.copyWith(
                                    fontSize: 12,
                                    fontWeight: medium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                color: whiteColor.withOpacity(0.9),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Jam Kerja: 08:00 - 17:00',
                                style: whiteTextStyle.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Quick Stats Title with Responsive Layout
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    _buildSectionHeader('Statistik Hari Ini'),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        _refreshKey.currentState?.show();
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 10 : 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: greenColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.refresh_rounded,
                              color: greenColor,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Refresh',
                              style: greentextstyle2.copyWith(
                                fontWeight: medium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Responsive Grid Layout for Stats
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: isSmallScreen ? 12 : 16,
                  mainAxisSpacing: isSmallScreen ? 12 : 16,
                  childAspectRatio: isSmallScreen ? 1.2 : 1.3,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  List<Map<String, dynamic>> stats = [
                    {
                      'title': 'Pengambilan',
                      'value': currentUser != null
                          ? '${currentUser!['total_collections'] ~/ 100}'
                          : '12',
                      'icon': Icons.local_shipping_rounded,
                      'color': const Color(0xFF3B82F6), // Vibrant blue
                    },
                    {
                      'title': 'Selesai',
                      'value': '8',
                      'icon': Icons.check_circle_rounded,
                      'color': const Color(0xFF22C55E), // Vibrant green
                    },
                    {
                      'title': 'Pending',
                      'value': '4',
                      'icon': Icons.pending_rounded,
                      'color': const Color(0xFFF97316), // Vibrant orange
                    },
                    {
                      'title': 'Rating',
                      'value': currentUser != null
                          ? '${currentUser!['rating']}'
                          : '4.8',
                      'icon': Icons.star_rounded,
                      'color': const Color(0xFFEAB308), // Vibrant amber
                    },
                  ];

                  final stat = stats[index];

                  return Container(
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              stat['value'],
                              style: TextStyle(
                                fontSize: isSmallScreen ? 30 : 36,
                                fontWeight: bold,
                                color: stat['color'],
                              ),
                            ),
                            Icon(
                              stat['icon'],
                              color: stat['color'].withOpacity(0.7),
                              size: isSmallScreen ? 32 : 36,
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          stat['title'],
                          style: blackTextStyle.copyWith(
                            fontWeight: semiBold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Vehicle Information Card - Responsive
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: _buildSectionHeader('Informasi Kendaraan'),
              ),
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                      spreadRadius: 0,
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFF0F766E).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: isSmallScreen ? 56 : 64,
                      height: isSmallScreen ? 56 : 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F766E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.local_shipping_rounded,
                        size: 36,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 12 : 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUser != null
                                ? '${currentUser!['vehicle']}'
                                : 'Pickup - KT 1234 XY',
                            style: blackTextStyle.copyWith(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: semiBold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _buildTag(
                                label: 'Kapasitas: 500 kg',
                                color: const Color(0xFF0F766E),
                              ),
                              const SizedBox(width: 8),
                              _buildTag(
                                label: 'BBM: Solar',
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Quick Actions - Responsive Design
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: _buildSectionHeader('Aksi Cepat'),
              ),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: isSmallScreen ? 10 : 12,
                  mainAxisSpacing: isSmallScreen ? 10 : 12,
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
                            builder: (context) => const JadwalMitraPage(),
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
                            builder: (context) => const PengambilanListPage(),
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
                      borderRadius: BorderRadius.circular(16),
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
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: action['onTap'],
                        splashColor: action['color'].withOpacity(0.1),
                        highlightColor: action['color'].withOpacity(0.05),
                        child: Padding(
                          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: action['color'].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  action['icon'],
                                  color: action['color'],
                                  size: 28,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    action['title'],
                                    style: blackTextStyle.copyWith(
                                      fontSize: isSmallScreen ? 14 : 16,
                                      fontWeight: bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    action['subtitle'],
                                    style: greyTextStyle.copyWith(
                                      fontSize: isSmallScreen ? 11 : 12,
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

              // Bottom spacing
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
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
          size: 20,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

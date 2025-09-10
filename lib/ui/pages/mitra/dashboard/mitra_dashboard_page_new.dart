import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/pages/mitra/jadwal/jadwal_mitra_page.dart';
import 'package:bank_sha/ui/pages/mitra/pengambilan/pengambilan_list_page.dart';
import 'package:bank_sha/ui/pages/mitra/laporan/laporan_mitra_page.dart';
import 'package:bank_sha/ui/pages/mitra/profile/profile_mitra_page.dart';
import 'package:bank_sha/utils/user_data_mock.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/ui/widgets/dashboard/dashboard_background.dart';
import 'package:bank_sha/utils/responsive_helper.dart';

// Importing the new custom widgets
import 'package:bank_sha/ui/widgets/mitra/dashboard_header.dart';
import 'package:bank_sha/ui/widgets/mitra/statistics_section.dart';
import 'package:bank_sha/ui/widgets/mitra/schedule_section.dart';
import 'package:bank_sha/ui/widgets/mitra/custom_bottom_navbar.dart';

class MitraDashboardPageNew extends StatefulWidget {
  const MitraDashboardPageNew({super.key});

  @override
  State<MitraDashboardPageNew> createState() => _MitraDashboardPageNewState();
}

class _MitraDashboardPageNewState extends State<MitraDashboardPageNew> {
  int _currentIndex = 0;
  Map<String, dynamic>? currentUser;
  bool _isOnline = false;

  final List<Widget> _pages = [
    const MitraDashboardContentNew(),
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

  // Function intentionally removed to avoid linting warning

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
        isOnline: _isOnline,
        onPowerToggle: (online) {
          setState(() {
            _isOnline = online;
          });
          
          // Display snackbar for status change
          // Show status notification
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(online 
                ? 'Status Anda sekarang AKTIF' 
                : 'Status Anda sekarang TIDAK AKTIF'),
              backgroundColor: online ? const Color(0xFF01A643) : Colors.grey,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
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

class MitraDashboardContentNew extends StatefulWidget {
  const MitraDashboardContentNew({super.key});

  @override
  State<MitraDashboardContentNew> createState() => _MitraDashboardContentNewState();
}

class _MitraDashboardContentNewState extends State<MitraDashboardContentNew> {
  Map<String, dynamic>? currentUser;
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();
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

  // Show details of a pickup in a bottom sheet
  void _showPickupDetailsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              
              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detail Pengambilan',
                    style: blackTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: semiBold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Menunggu',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontWeight: medium,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Customer details
              _buildDetailItem(
                icon: Icons.person_outline,
                title: 'Pelanggan',
                value: 'Wahyu Indra',
              ),
              
              _buildDetailItem(
                icon: Icons.phone_outlined,
                title: 'Telepon',
                value: '+62 812-3456-7890',
              ),
              
              _buildDetailItem(
                icon: Icons.location_on_outlined,
                title: 'Alamat',
                value: 'JL. Muso Salim B, Kota Samarinda, Kalimantan Timur',
              ),
              
              _buildDetailItem(
                icon: Icons.access_time,
                title: 'Waktu Pengambilan',
                value: '14:00 - 16:00',
              ),
              
              _buildDetailItem(
                icon: Icons.delete_outline,
                title: 'Jenis Sampah',
                value: 'Organik',
              ),
              
              _buildDetailItem(
                icon: Icons.scale_outlined,
                title: 'Perkiraan Berat',
                value: '2 kg',
              ),
              
              const SizedBox(height: 20),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.navigation_outlined),
                      label: const Text('Navigasi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00A643),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Selesai'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF00A643),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: Color(0xFF00A643),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE4F9E8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFF00A643),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: greyTextStyle.copyWith(
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: blackTextStyle.copyWith(
                    fontWeight: medium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Update parent navigation index
  void _updateParentIndex(int index) {
    final parent = context.findAncestorStateOfType<_MitraDashboardPageNewState>();
    if (parent != null) {
      parent.setState(() {
        parent._currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Create sample schedule card
    final scheduleCard1 = ScheduleCard(
      time: '14:00 - 16:00',
      status: 'Menunggu',
      name: 'Wahyu Indra',
      address: 'JL. Muso Salim B, Kota Samarinda, Kalimantan Timur',
      tags: [
        ScheduleTag(
          label: 'Organik',
          backgroundColor: const Color(0xFF01A643).withOpacity(0.1),
          textColor: const Color(0xFF01A643),
        ),
        ScheduleTag(
          label: '2 kg',
          backgroundColor: Colors.grey.withOpacity(0.1),
          textColor: Colors.grey.shade700,
        ),
      ],
      onTap: () {
        // Navigate to detail page or show details
        _showPickupDetailsBottomSheet(context);
      },
    );
    
    final scheduleCard2 = ScheduleCard(
      time: '17:00 - 18:00',
      status: 'Menunggu',
      name: 'Ahmad Rizal',
      address: 'JL. Juanda No. 45, Kota Samarinda, Kalimantan Timur',
      tags: [
        ScheduleTag(
          label: 'Anorganik',
          backgroundColor: Colors.orange.withOpacity(0.1),
          textColor: Colors.orange.shade700,
        ),
        ScheduleTag(
          label: '3 kg',
          backgroundColor: Colors.grey.withOpacity(0.1),
          textColor: Colors.grey.shade700,
        ),
      ],
      onTap: () {
        // Navigate to detail page or show details
        _showPickupDetailsBottomSheet(context);
      },
    );

    // Create quick action items
    final List<QuickActionItem> quickActions = [
      QuickActionItem(
        icon: Icons.location_on_outlined,
        label: 'Lokasi',
        onTap: () {
          // Navigate to location page
        },
      ),
      QuickActionItem(
        icon: Icons.list_alt_outlined,
        label: 'Jadwal',
        onTap: () {
          _updateParentIndex(1);
        },
      ),
      QuickActionItem(
        icon: Icons.credit_card_outlined,
        label: 'Bayar',
        onTap: () {
          // Navigate to payment page
        },
      ),
      QuickActionItem(
        icon: Icons.help_outline_outlined,
        label: 'Bantuan',
        onTap: () {
          // Navigate to help page
        },
      ),
    ];

    return DashboardBackground(
      backgroundColor: const Color(0xFFF9FFF8), // Background color from design
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0), // Hide default AppBar
          child: Container(),
        ),
        body: RefreshIndicator(
          key: _refreshKey,
          onRefresh: _refreshData,
          color: const Color(0xFF01A643),
          backgroundColor: Colors.white,
          displacement: ResponsiveHelper.getResponsiveHeight(context, 40),
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                DashboardHeader(
                  name: currentUser != null ? currentUser!['name'].split(' ')[0] : 'Fulan bin Fulan',
                  vehicleNumber: 'KT 777 WAN',
                  driverId: 'DRV-KTM-214',
                  onChatPressed: () {
                    // Chat functionality
                  },
                  onNotificationPressed: () {
                    // Notification functionality
                  },
                  quickActions: quickActions,
                ),
                
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 20)),
                
                // Statistics Section
                StatisticsGrid(
                  onRefresh: () {
                    _refreshKey.currentState?.show();
                  },
                ),
                
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 24)),
                
                // Schedule Section
                ScheduleSection(
                  scheduleCards: [scheduleCard1, scheduleCard2],
                ),
                
                // Bottom spacing for floating action button
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 80)),
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
            color: const Color(0xFF01A643),
            size: ResponsiveHelper.getResponsiveIconSize(context, 20),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}

import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/utils/user_data_mock.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/ui/pages/sign_in/sign_in_page.dart';
import 'package:bank_sha/ui/widgets/dashboard/dashboard_background.dart';
import 'package:bank_sha/utils/responsive_helper.dart';
import 'package:flutter/material.dart';

class ProfileMitraPage extends StatefulWidget {
  const ProfileMitraPage({super.key});

  @override
  State<ProfileMitraPage> createState() => _ProfileMitraPageState();
}

class _ProfileMitraPageState extends State<ProfileMitraPage> {
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
    if (userData != null) {
      final user = UserDataMock.getUserByEmail(userData['email']);
      if (mounted) {
        setState(() {
          currentUser = user;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadCurrentUser();
    return Future.delayed(const Duration(milliseconds: 1500));
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

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final bool isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    return DashboardBackground(
      backgroundColor: const Color(0xFFF9FFF8), // Background color from design
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0), // Hide default AppBar
          child: Container(),
        ),
        body: currentUser == null
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
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
                      // Header dengan green background - sama seperti dashboard
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [greenColor, const Color(0xFF0CAF60)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(ResponsiveHelper.getResponsiveRadius(context, 24)),
                            bottomRight: Radius.circular(ResponsiveHelper.getResponsiveRadius(context, 24)),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: greenColor.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + ResponsiveHelper.getResponsiveSpacing(context, 12),
                          bottom: ResponsiveHelper.getResponsiveSpacing(context, 20),
                          left: ResponsiveHelper.getResponsiveSpacing(context, 20),
                          right: ResponsiveHelper.getResponsiveSpacing(context, 20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top bar with logo and edit button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset(
                                  'assets/img_gerobakss.png', 
                                  height: ResponsiveHelper.getResponsiveHeight(context, 28),
                                  color: Colors.white,
                                ),
                                IconButton(
                                  onPressed: () {
                                    // TODO: Implement edit profile
                                  },
                                  icon: Icon(
                                    Icons.edit_outlined,
                                    color: Colors.white,
                                    size: ResponsiveHelper.getResponsiveIconSize(context, 24),
                                  ),
                                  tooltip: 'Edit Profil',
                                ),
                              ],
                            ),

                            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 12)),

                            // Driver info dan greeting
                            Row(
                              children: [
                                Icon(
                                  Icons.badge_outlined, 
                                  color: Colors.white.withOpacity(0.9),
                                  size: ResponsiveHelper.getResponsiveIconSize(context, 16),
                                ),
                                SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 6)),
                                Text(
                                  currentUser!['employee_id'] ?? 'DRV-JKT-001',
                                  style: whiteTextStyle.copyWith(
                                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 13),
                                    fontWeight: medium,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 8)),

                            // Profile greeting
                            Text(
                              'Selamat ${_getGreeting()},',
                              style: whiteTextStyle.copyWith(
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 4)),
                            Text(
                              currentUser!['name'],
                              style: whiteTextStyle.copyWith(
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, isSmallScreen ? 24 : 28),
                                fontWeight: extraBold,
                              ),
                            ),

                            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 12)),

                            // Profile avatar and status
                            Row(
                              children: [
                                // Profile Picture - sesuai dengan desain gambar (simple white circle)
                                Container(
                                  width: ResponsiveHelper.getResponsiveWidth(context, 64),
                                  height: ResponsiveHelper.getResponsiveHeight(context, 64),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'A',  // Huruf pertama nama - sesuai dengan gambar
                                      style: TextStyle(
                                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 32),
                                        fontWeight: extraBold,
                                        color: greenColor,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 20)),

                                // Status badge - sesuai desain gambar
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: ResponsiveHelper.getResponsiveSpacing(context, 14),
                                      vertical: ResponsiveHelper.getResponsiveSpacing(context, 12),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.verified_rounded,
                                              size: ResponsiveHelper.getResponsiveIconSize(context, 20),
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 8)),
                                            Text(
                                              'Mitra Aktif',
                                              style: whiteTextStyle.copyWith(
                                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                                                fontWeight: semiBold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 4)),
                                        Row(
                                          children: [
                                            Text(
                                              'Rating: 4.8 ',
                                              style: whiteTextStyle.copyWith(
                                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 13),
                                              ),
                                            ),
                                            Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: ResponsiveHelper.getResponsiveIconSize(context, 16),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Content sections
                      Padding(
                        padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 20)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Statistics cards - sesuai dengan desain gambar (2 card saja)
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(right: ResponsiveHelper.getResponsiveSpacing(context, 6)),
                                    padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 16)),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 10)),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF4299E1).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Image.asset(
                                            'assets/ic_truck.png',
                                            width: 24,
                                            height: 24,
                                            color: const Color(0xFF4299E1),
                                          ),
                                        ),
                                        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 12)),
                                        Text(
                                          'Total Pengambilan',
                                          style: blackTextStyle.copyWith(
                                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                                            fontWeight: medium,
                                          ),
                                        ),
                                        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 4)),
                                        Text(
                                          '1250',
                                          style: TextStyle(
                                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 28),
                                            fontWeight: bold,
                                            color: const Color(0xFF4299E1),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(left: ResponsiveHelper.getResponsiveSpacing(context, 6)),
                                    padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 16)),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 10)),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF59E0B).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.star,
                                            size: 24,
                                            color: const Color(0xFFF59E0B),
                                          ),
                                        ),
                                        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 12)),
                                        Text(
                                          'Rating',
                                          style: blackTextStyle.copyWith(
                                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                                            fontWeight: medium,
                                          ),
                                        ),
                                        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 4)),
                                        Text(
                                          '4.8',
                                          style: TextStyle(
                                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 28),
                                            fontWeight: bold,
                                            color: const Color(0xFFF59E0B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 24)),

                            // Informasi Kendaraan - sesuai dengan desain gambar
                            Container(
                              padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 16)),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 8)),
                                        decoration: BoxDecoration(
                                          color: greenColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Image.asset(
                                          'assets/ic_truck.png',
                                          width: 24,
                                          height: 24,
                                          color: greenColor,
                                        ),
                                      ),
                                      SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 12)),
                                      Text(
                                        'Informasi Kendaraan',
                                        style: blackTextStyle.copyWith(
                                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                                          fontWeight: semiBold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 16)),
                                  // Jenis Kendaraan
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.local_shipping_rounded,
                                        size: 20,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 12)),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Jenis Kendaraan',
                                            style: greyTextStyle.copyWith(
                                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Truck Sampah',
                                            style: blackTextStyle.copyWith(
                                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                                              fontWeight: medium,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 12)),
                                  // Nomor Plat
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.confirmation_number_rounded,
                                        size: 20,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 12)),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Nomor Plat',
                                            style: greyTextStyle.copyWith(
                                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'B 1234 ABC',
                                            style: blackTextStyle.copyWith(
                                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                                              fontWeight: medium,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 12)),

                            // Work Information
                            _buildInfoSection(
                              title: 'Informasi Kerja',
                              icon: Icons.work_rounded,
                              items: [
                                _buildInfoItem(
                                  'Area Kerja',
                                  currentUser!['work_area'] ?? 'Samarinda Kota',
                                  Icons.location_on_rounded,
                                ),
                                _buildInfoItem(
                                  'Status',
                                  currentUser!['status'] ?? 'Aktif',
                                  Icons.verified_rounded,
                                ),
                              ],
                            ),

                            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 12)),

                            // Contact Information
                            _buildInfoSection(
                              title: 'Informasi Kontak',
                              icon: Icons.contact_phone_rounded,
                              items: [
                                _buildInfoItem(
                                  'Email',
                                  currentUser!['email'] ?? 'mitra@gerobaks.com',
                                  Icons.email_rounded,
                                ),
                                _buildInfoItem(
                                  'Nomor Telepon',
                                  currentUser!['phone'] ?? '+62 812-3456-7890',
                                  Icons.phone_rounded,
                                ),
                              ],
                            ),

                            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 20)),

                            // Action buttons grid - sama seperti dashboard
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: isSmallScreen ? 2 : 3,
                              crossAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, 12),
                              mainAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, 12),
                              childAspectRatio: isSmallScreen ? 2.2 : 2.8,
                              children: [
                                _buildActionCard(
                                  title: 'Edit Profil',
                                  icon: Icons.edit_outlined,
                                  color: const Color(0xFF3B82F6),
                                  onTap: () {
                                    // TODO: Edit profile
                                  },
                                ),
                                _buildActionCard(
                                  title: 'Ubah Password',
                                  icon: Icons.lock_outline_rounded,
                                  color: const Color(0xFF8B5CF6),
                                  onTap: () {
                                    // TODO: Change password
                                  },
                                ),
                                _buildActionCard(
                                  title: 'Pengaturan',
                                  icon: Icons.settings_outlined,
                                  color: const Color(0xFF06B6D4),
                                  onTap: () {
                                    // TODO: Settings
                                  },
                                ),
                                _buildActionCard(
                                  title: 'Logout',
                                  icon: Icons.logout_rounded,
                                  color: const Color(0xFFEF4444),
                                  onTap: () {
                                    _showLogoutDialog();
                                  },
                                ),
                                _buildActionCard(
                                  title: 'Bantuan',
                                  icon: Icons.help_outline_rounded,
                                  color: const Color(0xFFF59E0B),
                                  onTap: () {
                                    // TODO: Help
                                  },
                                ),
                                _buildActionCard(
                                  title: 'Tentang Kami',
                                  icon: Icons.info_outline_rounded,
                                  color: const Color(0xFF10B981),
                                  onTap: () {
                                    // TODO: About
                                  },
                                ),
                              ],
                            ),

                            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 20)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // Method tidak lagi digunakan - sudah diganti dengan tampilan yang langsung

  // Helper method untuk action card
  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final bool isSmallScreen = ResponsiveHelper.isSmallScreen(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getResponsiveSpacing(context, isSmallScreen ? 12 : 16),
          vertical: ResponsiveHelper.getResponsiveSpacing(context, isSmallScreen ? 10 : 14),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, isSmallScreen ? 8 : 10)),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 10)),
              ),
              child: Icon(
                icon,
                color: color,
                size: ResponsiveHelper.getResponsiveIconSize(context, isSmallScreen ? 20 : 24),
              ),
            ),
            SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 12)),
            Expanded(
              child: Text(
                title,
                style: blackTextStyle.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, isSmallScreen ? 14 : 16),
                  fontWeight: semiBold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method untuk info section
  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required List<Widget> items,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 16)),
            decoration: BoxDecoration(
              color: greenColor.withOpacity(0.05),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 8)),
                  decoration: BoxDecoration(
                    color: greenColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 10)),
                  ),
                  child: Icon(
                    icon,
                    color: greenColor,
                    size: ResponsiveHelper.getResponsiveIconSize(context, 20),
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 12)),
                Text(
                  title,
                  style: blackTextStyle.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                    fontWeight: semiBold,
                  ),
                ),
              ],
            ),
          ),
          // Items
          Padding(
            padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 16)),
            child: Column(
              children: items,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method untuk info item
  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveHelper.getResponsiveSpacing(context, 12)),
      child: Row(
        children: [
          Icon(
            icon,
            size: ResponsiveHelper.getResponsiveIconSize(context, 18),
            color: Colors.grey[600],
          ),
          SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: greyTextStyle.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                    fontWeight: medium,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 2)),
                Text(
                  value,
                  style: blackTextStyle.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                    fontWeight: semiBold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Logout dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
          ),
          title: Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: const Color(0xFFEF4444),
                size: ResponsiveHelper.getResponsiveIconSize(context, 24),
              ),
              SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 12)),
              Text(
                'Logout',
                style: blackTextStyle.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                  fontWeight: semiBold,
                ),
              ),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
            style: greyTextStyle.copyWith(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: greyTextStyle.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                  fontWeight: semiBold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final localStorage = await LocalStorageService.getInstance();
                await localStorage.logout();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignInPage(),
                    ),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 8)),
                ),
              ),
              child: Text(
                'Logout',
                style: whiteTextStyle.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                  fontWeight: semiBold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gerobaks/common/styles.dart';
import 'package:gerobaks/services/local_storage_service.dart';
import 'package:gerobaks/ui/pages/auth/sign_in_page.dart';
import 'package:gerobaks/utils/responsive_helper.dart';
import 'package:gerobaks/ui/widgets/shared/dashboard_background.dart';

class ProfileMitraPage extends StatefulWidget {
  const ProfileMitraPage({Key? key}) : super(key: key);

  @override
  State<ProfileMitraPage> createState() => _ProfileMitraPageState();
}

class _ProfileMitraPageState extends State<ProfileMitraPage> {
  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = ResponsiveHelper.isSmallScreen(context);
    
    return Scaffold(
      body: DashboardBackground(
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: ResponsiveHelper.getResponsiveHeight(context, 180),
                floating: false,
                pinned: true,
                snap: false,
                elevation: 0,
                backgroundColor: Colors.transparent,
                automaticallyImplyLeading: false,
                flexibleSpace: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final double displacement = ResponsiveHelper.getResponsiveHeight(context, 40);
                    final bool isCollapsed = constraints.biggest.height <= kToolbarHeight + displacement;
                    
                    return FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              greenColor,
                              greenColor.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(ResponsiveHelper.getResponsiveRadius(context, 24)),
                            bottomRight: Radius.circular(ResponsiveHelper.getResponsiveRadius(context, 24)),
                          ),
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: ResponsiveHelper.getResponsivePadding(
                              context,
                              horizontal: 20,
                              vertical: 16,
                            ),
                            child: Column(
                              children: [
                                // Header dengan back button dan title
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Container(
                                        padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 8)),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 12)),
                                        ),
                                        child: Icon(
                                          Icons.arrow_back_ios,
                                          color: whiteColor,
                                          size: ResponsiveHelper.getResponsiveIconSize(context, 20),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'Profil Mitra',
                                      style: whiteTextStyle.copyWith(
                                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
                                        fontWeight: semiBold,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(width: ResponsiveHelper.getResponsiveWidth(context, 44)), // Spacer untuk balance
                                  ],
                                ),
                                
                                if (!isCollapsed) ...[
                                  SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 24)),
                                  // Profile Info
                                  CircleAvatar(
                                    radius: ResponsiveHelper.getResponsiveRadius(context, 40),
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                    child: Icon(
                                      Icons.person,
                                      size: ResponsiveHelper.getResponsiveIconSize(context, 48),
                                      color: whiteColor,
                                    ),
                                  ),
                                  SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),
                                  Text(
                                    'Ahmad Mitra',
                                    style: whiteTextStyle.copyWith(
                                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 22),
                                      fontWeight: extraBold,
                                    ),
                                  ),
                                  SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 4)),
                                  Text(
                                    'Mitra Gerobaks',
                                    style: whiteTextStyle.copyWith(
                                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                                      fontWeight: medium,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ];
          },
          body: SingleChildScrollView(
            padding: ResponsiveHelper.getResponsivePadding(
              context,
              horizontal: 20,
              vertical: 24,
            ),
            child: Column(
              children: [
                // Statistics Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Total\nTransaksi',
                        value: '125',
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.getResponsiveWidth(context, 16)),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Poin\nTerkumpul',
                        value: '2,450',
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.getResponsiveWidth(context, 16)),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Rating\nMitra',
                        value: '4.8',
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 32)),

                // Quick Actions
                _buildInfoSection(
                  title: 'Aksi Cepat',
                  items: [
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isSmallScreen ? 2 : 3,
                      crossAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, 16),
                      mainAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, 16),
                      childAspectRatio: 1.0,
                      children: [
                        _buildActionCard(
                          title: 'Edit Profil',
                          icon: 'assets/ic_edit_profile.png',
                          onTap: () {},
                        ),
                        _buildActionCard(
                          title: 'Riwayat\nTransaksi',
                          icon: 'assets/ic_history.png',
                          onTap: () {},
                        ),
                        _buildActionCard(
                          title: 'My Rewards',
                          icon: 'assets/ic_my_rewards.png',
                          onTap: () {},
                        ),
                        _buildActionCard(
                          title: 'Pengaturan',
                          icon: 'assets/ic_setting.png',
                          onTap: () {},
                        ),
                        _buildActionCard(
                          title: 'Bantuan',
                          icon: 'assets/ic_help.png',
                          onTap: () {},
                        ),
                        _buildActionCard(
                          title: 'Tentang Kami',
                          icon: 'assets/ic_aboutus.png',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 24)),

                // Account Information
                _buildInfoSection(
                  title: 'Informasi Akun',
                  items: [
                    _buildInfoItem('Nama Lengkap', 'Ahmad Mitra', Icons.person),
                    _buildInfoItem('Email', 'ahmad.mitra@example.com', Icons.email),
                    _buildInfoItem('No. Telepon', '+62 812-3456-7890', Icons.phone),
                    _buildInfoItem('Alamat', 'Jl. Merdeka No. 123, Jakarta', Icons.location_on),
                    _buildInfoItem('Bergabung Sejak', '15 Januari 2023', Icons.calendar_today),
                  ],
                ),

                SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 24)),

                // Logout Button
                Container(
                  width: double.infinity,
                  padding: ResponsiveHelper.getResponsivePadding(
                    context,
                    horizontal: 20,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.logout,
                            color: const Color(0xFFEF4444),
                            size: ResponsiveHelper.getResponsiveIconSize(context, 24),
                          ),
                          SizedBox(width: ResponsiveHelper.getResponsiveWidth(context, 16)),
                          Text(
                            'Apakah Anda yakin ingin keluar?',
                            style: blackTextStyle.copyWith(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                              fontWeight: medium,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: greyColor),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 8)),
                                ),
                              ),
                              child: Text(
                                'Batal',
                                style: greyTextStyle.copyWith(
                                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                                  fontWeight: semiBold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: ResponsiveHelper.getResponsiveWidth(context, 16)),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _showLogoutDialog(),
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
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 32)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Konfirmasi Logout',
            style: blackTextStyle.copyWith(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
              fontWeight: semiBold,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
            style: greyTextStyle.copyWith(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: whiteTextStyle.copyWith(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 24),
              fontWeight: extraBold,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 4)),
          Text(
            title,
            style: whiteTextStyle.copyWith(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              fontWeight: medium,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 16)),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 12)),
              decoration: BoxDecoration(
                color: (color ?? greenColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 12)),
              ),
              child: Image.asset(
                icon,
                height: ResponsiveHelper.getResponsiveHeight(context, 32),
                width: ResponsiveHelper.getResponsiveWidth(context, 32),
                color: color ?? greenColor,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 12)),
            Text(
              title,
              style: blackTextStyle.copyWith(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                fontWeight: semiBold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 20)),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/img_gerobakss.png',
                height: ResponsiveHelper.getResponsiveHeight(context, 20),
              ),
              SizedBox(width: ResponsiveHelper.getResponsiveWidth(context, 8)),
              Text(
                title,
                style: blackTextStyle.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                  fontWeight: semiBold,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveHelper.getResponsiveHeight(context, 16)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 10)),
            decoration: BoxDecoration(
              color: greenColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 12)),
            ),
            child: Icon(
              icon,
              size: ResponsiveHelper.getResponsiveIconSize(context, 22),
              color: greenColor,
            ),
          ),
          SizedBox(width: ResponsiveHelper.getResponsiveWidth(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: greyTextStyle.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 4)),
                Text(
                  value,
                  style: blackTextStyle.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
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
}

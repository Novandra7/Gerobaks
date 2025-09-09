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
                // Mengurangi ukuran expandedHeight header yang terlalu besar
                expandedHeight: ResponsiveHelper.getResponsiveHeight(context, 140),
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
                              vertical: 12, // Mengurangi vertical padding
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
                                  SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)), // Mengurangi spacing
                                  
                                  // Redesign layout profile section - lebih compact
                                  Row(
                                    children: [
                                      // Memperkecil ukuran avatar
                                      CircleAvatar(
                                        radius: ResponsiveHelper.getResponsiveRadius(context, 30), // Mengurangi dari 40 ke 30
                                        backgroundColor: Colors.white.withOpacity(0.2),
                                        child: Icon(
                                          Icons.person,
                                          size: ResponsiveHelper.getResponsiveIconSize(context, 36), // Mengurangi ukuran ikon
                                          color: whiteColor,
                                        ),
                                      ),
                                      SizedBox(width: ResponsiveHelper.getResponsiveWidth(context, 16)),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // ID Karyawan dalam badge status yang lebih compact
                                            Container(
                                              padding: ResponsiveHelper.getResponsivePadding(
                                                context,
                                                horizontal: 10,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 20)),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.verified_user,
                                                    size: ResponsiveHelper.getResponsiveIconSize(context, 14),
                                                    color: whiteColor,
                                                  ),
                                                  SizedBox(width: ResponsiveHelper.getResponsiveWidth(context, 4)),
                                                  Text(
                                                    'ID: M230945 • Rating: 4.8 ★',
                                                    style: whiteTextStyle.copyWith(
                                                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                                                      fontWeight: medium,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 8)),
                                            Text(
                                              'Ahmad Mitra',
                                              style: whiteTextStyle.copyWith(
                                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18), // Mengurangi ukuran font
                                                fontWeight: extraBold,
                                              ),
                                            ),
                                            Text(
                                              'Selamat pagi, semangat bekerja!',
                                              style: whiteTextStyle.copyWith(
                                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                                                fontWeight: medium,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
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
                // Mengubah 3 Statistics Cards menjadi 2 card
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Total Pengambilan',
                        value: '125',
                        color: const Color(0xFF10B981),
                        icon: Icons.shopping_bag_outlined,
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.getResponsiveWidth(context, 16)),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Rating Mitra',
                        value: '4.8',
                        color: const Color(0xFFF59E0B),
                        icon: Icons.star_outline,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 24)),

                // Quick Actions dengan grid layout yang lebih responsif
                _buildInfoSection(
                  title: 'Aksi Cepat',
                  items: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isSmallScreen ? 2 : 3,
                        crossAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, 12),
                        mainAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, 12),
                        childAspectRatio: isSmallScreen ? 1.2 : 1.3, // Lebih proporsional
                      ),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        final actionItems = [
                          {
                            'title': 'Edit Profil',
                            'icon': 'assets/ic_edit_profile.png',
                            'onTap': () {},
                          },
                          {
                            'title': 'Riwayat',
                            'icon': 'assets/ic_history.png',
                            'onTap': () {},
                          },
                          {
                            'title': 'Rewards',
                            'icon': 'assets/ic_my_rewards.png',
                            'onTap': () {},
                          },
                          {
                            'title': 'Pengaturan',
                            'icon': 'assets/ic_setting.png',
                            'onTap': () {},
                          },
                          {
                            'title': 'Bantuan',
                            'icon': 'assets/ic_help.png',
                            'onTap': () {},
                          },
                          {
                            'title': 'Tentang Kami',
                            'icon': 'assets/ic_aboutus.png',
                            'onTap': () {},
                          },
                        ];
                        
                        return _buildActionCard(
                          title: actionItems[index]['title'] as String,
                          icon: actionItems[index]['icon'] as String,
                          onTap: actionItems[index]['onTap'] as VoidCallback,
                        );
                      },
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
    required IconData icon,
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
            color: color.withOpacity(0.2), // Mengurangi opacity shadow
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 10)),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 12)),
            ),
            child: Icon(
              icon,
              size: ResponsiveHelper.getResponsiveIconSize(context, 24),
              color: whiteColor,
            ),
          ),
          SizedBox(width: ResponsiveHelper.getResponsiveWidth(context, 12)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: whiteTextStyle.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 22),
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Action card yang lebih compact
  Widget _buildActionCard({
    required String title,
    required String icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 12)), // Mengurangi padding
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03), // Mengurangi opacity shadow
              blurRadius: 8,
              offset: const Offset(0, 2),
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
              padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 10)),
              decoration: BoxDecoration(
                color: (color ?? greenColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 12)),
              ),
              child: Image.asset(
                icon,
                height: ResponsiveHelper.getResponsiveHeight(context, 28), // Ukuran icon lebih kecil
                width: ResponsiveHelper.getResponsiveWidth(context, 28),
                color: color ?? greenColor,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 8)), // Mengurangi spacing
            Text(
              title,
              style: blackTextStyle.copyWith(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                fontWeight: semiBold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Section card yang lebih ringan
  Widget _buildInfoSection({
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 16)), // Mengurangi padding
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), // Mengurangi opacity shadow
            blurRadius: 8,
            offset: const Offset(0, 2),
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
              Container(
                padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 8)),
                decoration: BoxDecoration(
                  color: greenColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 8)),
                ),
                child: Image.asset(
                  'assets/img_gerobakss.png',
                  height: ResponsiveHelper.getResponsiveHeight(context, 16),
                ),
              ),
              SizedBox(width: ResponsiveHelper.getResponsiveWidth(context, 8)),
              Text(
                title,
                style: blackTextStyle.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                  fontWeight: semiBold,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 12)),
          ...items,
        ],
      ),
    );
  }

  // Info item yang lebih compact
  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveHelper.getResponsiveHeight(context, 12)), // Mengurangi bottom padding
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 8)), // Mengurangi padding
            decoration: BoxDecoration(
              color: greenColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 10)),
            ),
            child: Icon(
              icon,
              size: ResponsiveHelper.getResponsiveIconSize(context, 20), // Ukuran icon lebih kecil
              color: greenColor,
            ),
          ),
          SizedBox(width: ResponsiveHelper.getResponsiveWidth(context, 12)), // Mengurangi spacing
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: greyTextStyle.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 13), // Ukuran font lebih kecil
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 2)), // Mengurangi spacing
                Text(
                  value,
                  style: blackTextStyle.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 15), // Ukuran font lebih kecil
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

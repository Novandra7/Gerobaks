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
                      // Header dengan green background
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
                                // Profile image
                                Container(
                                  width: ResponsiveHelper.getResponsiveWidth(context, 60),
                                  height: ResponsiveHelper.getResponsiveHeight(context, 60),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    image: DecorationImage(
                                      image: AssetImage(currentUser?['profilePicture'] ?? 'assets/img_profile.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 12)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Selamat pagi/siang/sore/malam
                                      RichText(
                                        text: TextSpan(
                                          style: whiteTextStyle.copyWith(
                                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'Selamat ${_getGreeting()}, ',
                                            ),
                                            TextSpan(
                                              text: currentUser?['name'] ?? 'Pengguna',
                                              style: whiteTextStyle.copyWith(
                                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                                                fontWeight: semiBold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 4)),
                                      // Badge - ID dan Rating
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: ResponsiveHelper.getResponsiveSpacing(context, 8),
                                          vertical: ResponsiveHelper.getResponsiveSpacing(context, 4),
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 4)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.verified_rounded,
                                              color: Colors.white,
                                              size: ResponsiveHelper.getResponsiveIconSize(context, 14),
                                            ),
                                            SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 4)),
                                            Text(
                                              'ID: ${currentUser?['id'] ?? '000000'}',
                                              style: whiteTextStyle.copyWith(
                                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                                                fontWeight: medium,
                                              ),
                                            ),
                                            SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 6)),
                                            Icon(
                                              Icons.star_rounded,
                                              color: Colors.amber,
                                              size: ResponsiveHelper.getResponsiveIconSize(context, 14),
                                            ),
                                            SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 2)),
                                            Text(
                                              '${currentUser?['rating'] ?? '0.0'}',
                                              style: whiteTextStyle.copyWith(
                                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                                                fontWeight: medium,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Statistics Cards
                      Padding(
                        padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 16)),
                        child: Row(
                          children: [
                            // Card 1 - Jumlah Pengambilan
                            Expanded(
                              child: _buildStatCard(
                                title: 'Pengambilan',
                                value: currentUser?['pickups']?.toString() ?? '0',
                                icon: Icons.recycling_rounded,
                                backgroundColor: greenLight,
                                iconColor: greenColor,
                              ),
                            ),
                            SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 12)),
                            // Card 2 - Jumlah Poin
                            Expanded(
                              child: _buildStatCard(
                                title: 'Poin',
                                value: currentUser?['points']?.toString() ?? '0',
                                icon: Icons.star_rounded,
                                backgroundColor: const Color(0xFFFFF8E1),
                                iconColor: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Action shortcuts - GridView
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getResponsiveSpacing(context, 16)),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isSmallScreen ? 2 : 3,
                            mainAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, 12),
                            crossAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, 12),
                            childAspectRatio: isSmallScreen ? 1.4 : 1.6,
                          ),
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            final actions = [
                              {
                                'icon': Icons.edit_note_rounded,
                                'label': 'Edit Profil',
                                'onTap': () {
                                  // TODO: Edit profile
                                },
                              },
                              {
                                'icon': Icons.password_rounded,
                                'label': 'Ubah Password',
                                'onTap': () {
                                  // TODO: Change password
                                },
                              },
                              {
                                'icon': Icons.settings_rounded,
                                'label': 'Pengaturan',
                                'onTap': () {
                                  // TODO: Settings
                                },
                              },
                              {
                                'icon': Icons.logout_rounded,
                                'label': 'Keluar',
                                'onTap': () async {
                                  final confirm = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Keluar'),
                                      content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Batal'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: Text(
                                            'Keluar',
                                            style: TextStyle(color: redcolor),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  
                                  if (confirm == true) {
                                    final localStorage = await LocalStorageService.getInstance();
                                    await localStorage.clear();  // Using clear() method since clearUserData() doesn't exist
                                    if (mounted) {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(builder: (context) => const SignInPage()),
                                        (route) => false,
                                      );
                                    }
                                  }
                                },
                              },
                            ];
                            
                            return _buildActionCard(
                              icon: actions[index]['icon'] as IconData,
                              label: actions[index]['label'] as String,
                              onTap: actions[index]['onTap'] as Function(),
                            );
                          },
                        ),
                      ),
                      
                      SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 16)),
                      
                      // Informasi Akun Section
                      _buildInfoSection(
                        title: 'Informasi Akun',
                        icon: Icons.person_outline,
                        children: [
                          // Email
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 6)),
                                decoration: BoxDecoration(
                                  color: greenColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 8)),
                                ),
                                child: Icon(
                                  Icons.email_outlined,
                                  color: greenColor,
                                  size: ResponsiveHelper.getResponsiveIconSize(context, 16),
                                ),
                              ),
                              SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 10)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Email',
                                      style: blackTextStyle.copyWith(
                                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                                        fontWeight: medium,
                                      ),
                                    ),
                                    Text(
                                      currentUser?['email'] ?? 'Email belum diisi',
                                      style: greyTextStyle.copyWith(
                                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 16)),
                          
                          // Alamat
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 6)),
                                decoration: BoxDecoration(
                                  color: greenColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 8)),
                                ),
                                child: Icon(
                                  Icons.location_on_outlined,
                                  color: greenColor,
                                  size: ResponsiveHelper.getResponsiveIconSize(context, 16),
                                ),
                              ),
                              SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 10)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Alamat',
                                      style: blackTextStyle.copyWith(
                                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                                        fontWeight: medium,
                                      ),
                                    ),
                                    Text(
                                      currentUser?['address'] ?? 'Alamat belum diisi',
                                      style: greyTextStyle.copyWith(
                                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 16)),
                          
                          // Phone Number
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 6)),
                                decoration: BoxDecoration(
                                  color: greenColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 8)),
                                ),
                                child: Icon(
                                  Icons.phone_android_rounded,
                                  color: greenColor,
                                  size: ResponsiveHelper.getResponsiveIconSize(context, 16),
                                ),
                              ),
                              SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 10)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Nomor HP',
                                      style: blackTextStyle.copyWith(
                                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                                        fontWeight: medium,
                                      ),
                                    ),
                                    Text(
                                      currentUser?['phone'] ?? 'Nomor HP belum diisi',
                                      style: greyTextStyle.copyWith(
                                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      // Keamanan Section
                      _buildInfoSection(
                        title: 'Keamanan & Privasi',
                        icon: Icons.security_rounded,
                        children: [
                          _buildInfoItem(
                            icon: Icons.lock_outline_rounded,
                            title: 'Ubah Password',
                            onTap: () {
                              // TODO: Edit profile
                            },
                          ),
                          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 12)),
                          _buildInfoItem(
                            icon: Icons.verified_user_outlined,
                            title: 'Verifikasi Akun',
                            onTap: () {
                              // TODO: Edit profile
                            },
                          ),
                          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 12)),
                          _buildInfoItem(
                            icon: Icons.privacy_tip_outlined,
                            title: 'Kebijakan Privasi',
                            onTap: () {
                              // TODO: Edit profile
                            },
                          ),
                        ],
                      ),
                      
                      // Bantuan & Info Section
                      _buildInfoSection(
                        title: 'Bantuan & Informasi',
                        icon: Icons.info_outline_rounded,
                        children: [
                          _buildInfoItem(
                            icon: Icons.help_outline_rounded,
                            title: 'Bantuan',
                            onTap: () {
                              // TODO: Help
                            },
                          ),
                          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 12)),
                          _buildInfoItem(
                            icon: Icons.info_outline_rounded,
                            title: 'Tentang Kami',
                            onTap: () {
                              // TODO: About
                            },
                          ),
                        ],
                      ),
                      
                      SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 24)),
                      
                      // App version at bottom
                      Center(
                        child: Text(
                          'Gerobaks v1.0.0',
                          style: greyTextStyle.copyWith(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 24)),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
  
  // Helper widget for statistics cards
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 16)),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 8)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 8)),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: ResponsiveHelper.getResponsiveIconSize(context, 24),
            ),
          ),
          SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: greyTextStyle.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 2)),
                Text(
                  value,
                  style: blackTextStyle.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
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
  
  // Helper widget for action cards
  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Function onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
        child: Container(
          padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 12)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 10)),
                decoration: BoxDecoration(
                  color: greenui,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: greenColor,
                  size: ResponsiveHelper.getResponsiveIconSize(context, 24),
                ),
              ),
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 8)),
              Text(
                label,
                style: blackTextStyle.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                  fontWeight: medium,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper widget for information sections
  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getResponsiveSpacing(context, 16),
        vertical: ResponsiveHelper.getResponsiveSpacing(context, 8),
      ),
      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: greenColor,
                size: ResponsiveHelper.getResponsiveIconSize(context, 20),
              ),
              SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 8)),
              Text(
                title,
                style: blackTextStyle.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                  fontWeight: semiBold,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 16)),
          ...children,
        ],
      ),
    );
  }
  
  // Helper widget for information items
  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required Function onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 8)),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getResponsiveSpacing(context, 4)),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 6)),
                decoration: BoxDecoration(
                  color: greenColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 8)),
                ),
                child: Icon(
                  icon,
                  color: greenColor,
                  size: ResponsiveHelper.getResponsiveIconSize(context, 16),
                ),
              ),
              SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 12)),
              Expanded(
                child: Text(
                  title,
                  style: blackTextStyle.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                    fontWeight: medium,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: greyColor,
                size: ResponsiveHelper.getResponsiveIconSize(context, 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

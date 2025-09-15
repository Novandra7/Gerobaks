import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/ui/pages/sign_in/sign_in_page.dart';
import 'package:bank_sha/utils/responsive_helper.dart';
import 'package:bank_sha/ui/widgets/dashboard/dashboard_background.dart';
import 'package:bank_sha/ui/pages/mitra/profile/widgets/enhanced_profile_header.dart';

class ProfileMitraPage extends StatefulWidget {
  const ProfileMitraPage({super.key});

  @override
  State<ProfileMitraPage> createState() => _ProfileMitraPageState();
}

class _ProfileMitraPageState extends State<ProfileMitraPage> {
  late final LocalStorageService _localStorageService;
  
  // Define missing colors
  final Color orangeColor = const Color(0xFFFF8A00);
  final Color orangeui = const Color(0xFFFFF5E5);
  final Color redColor = const Color(0xFFFF0000);
  final Color blueui = const Color(0xFFE5F5FF);
  final Color purpleui = const Color(0xFFF0E5FF);
  
  // Golden ratio constant (1:1.618)
  final double phi = 1.618;
  
  @override
  void initState() {
    super.initState();
    _initLocalStorage();
  }
  
  Future<void> _initLocalStorage() async {
    _localStorageService = await LocalStorageService.getInstance();
  }
  
  // Dummy data - in real app, this would come from API or provider
  final Map<String, dynamic> _userData = {
    'name': 'Ahmad Sahroni',
    'email': 'ahmad.sahroni@gmail.com',
    'id': 'MITRA-12345',
    'role': 'Mitra Premium',
    'phone': '+62 812 3456 7890',
    'address': 'Jl. Raya Ciputat No. 123, Tangerang Selatan',
    'points': '2,500',
    'transactions': '56',
    'rating': '4.8',
  };

  @override
  Widget build(BuildContext context) {
    // Apply golden ratio for better visual harmony
    final double basePadding = 16.0;
    final double sectionSpacing = basePadding * phi; // Use golden ratio
    
    return Scaffold(
      body: DashboardBackground(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            children: [
              // Header with enhanced UX
              EnhancedProfileHeader(
                name: _userData['name'],
                email: _userData['email'],
                role: _userData['role'],
                id: _userData['id'],
                isVerified: true,
                statusText: 'Online',
                notificationCount: 3,
                onNotificationPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Anda memiliki 3 notifikasi baru'),
                      backgroundColor: greenColor,
                    ),
                  );
                },
                onEditPressed: () {
                  // Navigate to edit profile page
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Edit profil akan segera hadir!'),
                      backgroundColor: greenColor,
                    ),
                  );
                },
              ),
              
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, sectionSpacing)),
              
              // Stats Section with cards in modern horizontal layout
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsiveSpacing(context, basePadding),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistik Anda',
                      style: blackTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: semiBold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      height: 100, // Increased height to match new card height
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics(),
                        children: [
                          _buildStatCard(
                            context: context,
                            title: 'Poin Reward',
                            value: _userData['points'],
                            subtitle: 'Tukarkan sekarang',
                            icon: Icons.star_rounded,
                            backgroundColor: greenui,
                            iconColor: greenColor,
                            trendValue: '+5.2%',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Anda memiliki ${_userData['points']} poin yang bisa ditukarkan!'),
                                  backgroundColor: greenColor,
                                ),
                              );
                            },
                          ),
                          SizedBox(width: 14), // Increased spacing between cards
                          _buildStatCard(
                            context: context,
                            title: 'Transaksi',
                            value: _userData['transactions'],
                            subtitle: 'Bulan ini',
                            icon: Icons.receipt_long_rounded,
                            backgroundColor: blueui,
                            iconColor: blueColor,
                            trendValue: '+12.7%',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Anda memiliki ${_userData['transactions']} transaksi bulan ini'),
                                  backgroundColor: blueColor,
                                ),
                              );
                            },
                          ),
                          SizedBox(width: 14), // Increased spacing between cards
                          _buildStatCard(
                            context: context,
                            title: 'Rating',
                            value: _userData['rating'],
                            subtitle: 'Dari 120 ulasan',
                            icon: Icons.thumb_up_alt_rounded,
                            backgroundColor: orangeui,
                            iconColor: orangeColor,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Rating Anda ${_userData['rating']} dari 5.0'),
                                  backgroundColor: orangeColor,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, sectionSpacing * 1.2)), // Increased spacing
              
              // Quick Actions Section with modern grid layout
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsiveSpacing(context, basePadding),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aksi Cepat',
                      style: blackTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: semiBold,
                      ),
                    ),
                    SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10, // Increased spacing
                      mainAxisSpacing: 16, // Increased spacing
                      childAspectRatio: 0.75, // Adjusted for taller items
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        _buildQuickActionItem(
                          context: context,
                          icon: Icons.history_rounded,
                          label: 'Riwayat',
                          backgroundColor: blueui,
                          iconColor: blueColor,
                          hasNotification: true,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Riwayat transaksi Anda'),
                                backgroundColor: blueColor,
                              ),
                            );
                          },
                        ),
                        _buildQuickActionItem(
                          context: context,
                          icon: Icons.account_balance_wallet_rounded,
                          label: 'Saldo',
                          backgroundColor: greenui,
                          iconColor: greenColor,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Saldo Anda: Rp 2.450.000'),
                                backgroundColor: greenColor,
                              ),
                            );
                          },
                        ),
                        _buildQuickActionItem(
                          context: context,
                          icon: Icons.card_giftcard_rounded,
                          label: 'Rewards',
                          backgroundColor: purpleui,
                          iconColor: purpleColor,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Anda memiliki 3 hadiah yang bisa diambil!'),
                                backgroundColor: purpleColor,
                              ),
                            );
                          },
                        ),
                        _buildQuickActionItem(
                          context: context,
                          icon: Icons.help_outline_rounded,
                          label: 'Bantuan',
                          backgroundColor: orangeui,
                          iconColor: orangeColor,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Pusat bantuan Gerobaks'),
                                backgroundColor: orangeColor,
                              ),
                            );
                          },
                        ),
                        _buildQuickActionItem(
                          context: context,
                          icon: Icons.location_on_rounded,
                          label: 'Lokasi',
                          backgroundColor: blueui,
                          iconColor: blueColor,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lokasi pengambilan'),
                                backgroundColor: blueColor,
                              ),
                            );
                          },
                        ),
                        _buildQuickActionItem(
                          context: context,
                          icon: Icons.schedule_rounded,
                          label: 'Jadwal',
                          backgroundColor: greenui,
                          iconColor: greenColor,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Jadwal pengambilan'),
                                backgroundColor: greenColor,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, sectionSpacing)),
              
              // Personal Information Section - Modern card layout
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsiveSpacing(context, basePadding),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Informasi Pribadi',
                          style: blackTextStyle.copyWith(
                            fontSize: 18,
                            fontWeight: semiBold,
                          ),
                        ),
                        Icon(
                          Icons.info_outline_rounded,
                          color: greenColor,
                          size: 20,
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildProfileInfoItem(
                            icon: Icons.phone_android_rounded,
                            title: 'Nomor Telepon',
                            value: _userData['phone'],
                            badgeText: 'Terverifikasi',
                            badgeColor: greenColor,
                            showBorder: true,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Edit nomor telepon'),
                                  backgroundColor: greenColor,
                                ),
                              );
                            },
                          ),
                          _buildProfileInfoItem(
                            icon: Icons.location_on_rounded,
                            title: 'Alamat',
                            value: _userData['address'],
                            iconColor: orangeColor,
                            showBorder: true,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Edit alamat'),
                                  backgroundColor: orangeColor,
                                ),
                              );
                            },
                          ),
                          _buildProfileInfoItem(
                            icon: Icons.email_outlined,
                            title: 'Email',
                            value: _userData['email'],
                            iconColor: blueColor,
                            badgeText: 'Terverifikasi',
                            badgeColor: blueColor,
                            showBorder: false,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Edit email'),
                                  backgroundColor: blueColor,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, sectionSpacing)),
              
              // Settings Section - Modern card layout
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsiveSpacing(context, basePadding),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pengaturan & Informasi',
                          style: blackTextStyle.copyWith(
                            fontSize: 18,
                            fontWeight: semiBold,
                          ),
                        ),
                        Icon(
                          Icons.settings_outlined,
                          color: greenColor,
                          size: 20,
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildSettingsItem(
                            icon: Icons.person_outline_rounded,
                            title: 'Edit Profil',
                            subtitle: 'Perbarui informasi',
                            iconColor: greenColor,
                            showBadge: true,
                            badgeText: 'Baru',
                            showBorder: true,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Halaman edit profil akan segera hadir!'),
                                  backgroundColor: greenColor,
                                ),
                              );
                            },
                          ),
                          _buildSettingsItem(
                            icon: Icons.notifications_none_rounded,
                            title: 'Notifikasi',
                            subtitle: 'Preferensi notifikasi',
                            iconColor: orangeColor,
                            showBadge: true,
                            badgeText: '3',
                            showBorder: true,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Pengaturan notifikasi'),
                                  backgroundColor: orangeColor,
                                ),
                              );
                            },
                          ),
                          _buildSettingsItem(
                            icon: Icons.lock_outline_rounded,
                            title: 'Keamanan',
                            subtitle: 'Keamanan akun',
                            iconColor: redColor,
                            showBorder: true,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Pengaturan keamanan'),
                                  backgroundColor: redColor,
                                ),
                              );
                            },
                          ),
                          _buildSettingsItem(
                            icon: Icons.language_rounded,
                            title: 'Bahasa',
                            subtitle: 'Bahasa aplikasi',
                            iconColor: blueColor,
                            showBorder: true,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Pengaturan bahasa'),
                                  backgroundColor: blueColor,
                                ),
                              );
                            },
                          ),
                          _buildSettingsItem(
                            icon: Icons.info_outline_rounded,
                            title: 'Tentang',
                            subtitle: 'Informasi aplikasi',
                            iconColor: greenColor,
                            showBorder: true,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Tentang Gerobaks'),
                                  backgroundColor: greenColor,
                                ),
                              );
                            },
                          ),
                          _buildSettingsItem(
                            icon: Icons.headset_mic_outlined,
                            title: 'Bantuan',
                            subtitle: 'Hubungi kami',
                            iconColor: orangeColor,
                            showBadge: true, 
                            badgeText: 'Baru',
                            showBorder: false,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Kontak Gerobaks'),
                                  backgroundColor: orangeColor,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, sectionSpacing * 1.15)),
              
              // Modern Logout Button
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsiveSpacing(context, basePadding),
                  vertical: ResponsiveHelper.getResponsiveSpacing(context, basePadding / phi),
                ),
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [redColor.withOpacity(0.9), redColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: redColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        await _localStorageService.fullLogout();
                        if (!mounted) return;
                        
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const SignInPage()), 
                          (route) => false,
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Keluar dari Akun',
                            style: whiteTextStyle.copyWith(
                              fontSize: 16,
                              fontWeight: semiBold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, sectionSpacing)),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper method to build stat card - redesigned with better proportions
  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color backgroundColor,
    Color? iconColor,
    String? trendValue,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170, // Wider card
        height: 100, // Taller card for better proportions
        padding: EdgeInsets.all(14), // More padding for elegance
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top row with icon and trend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? greenColor,
                    size: 18,
                  ),
                ),
                if (trendValue != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      trendValue,
                      style: blackTextStyle.copyWith(
                        fontSize: 11,
                        fontWeight: medium,
                        color: greenColor,
                      ),
                    ),
                  ),
              ],
            ),
            
            // Title
            Text(
              title,
              style: blackTextStyle.copyWith(
                fontSize: 12,
                fontWeight: medium,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            
            // Value in larger font
            Text(
              value,
              style: blackTextStyle.copyWith(
                fontSize: 20,
                fontWeight: semiBold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            
            // Subtitle
            Text(
              subtitle,
              style: greyTextStyle.copyWith(
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper method to build quick action item - adjusted to balance with stat cards
  Widget _buildQuickActionItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color iconColor,
    bool hasNotification = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 52, // Larger size for better proportion
                height: 52, // Larger size for better proportion
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 26, // Larger icon
                ),
              ),
              if (hasNotification)
                Positioned(
                  top: -3,
                  right: -3,
                  child: Container(
                    width: 12, // Slightly larger badge
                    height: 12, // Slightly larger badge
                    decoration: BoxDecoration(
                      color: redColor,
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
          SizedBox(height: 8), // More spacing
          Text(
            label,
            style: blackTextStyle.copyWith(
              fontSize: 12, // Slightly larger text
              fontWeight: medium,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  // Helper method to build profile info item - improved styling
  Widget _buildProfileInfoItem({
    required IconData icon,
    required String title,
    required String value,
    Color? iconColor,
    String? badgeText,
    Color? badgeColor,
    bool showBorder = true,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: showBorder ? null : BorderRadius.vertical(bottom: Radius.circular(16)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18), // More vertical padding
        decoration: BoxDecoration(
          border: showBorder ? Border(
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40, // Slightly larger
              height: 40, // Slightly larger
              decoration: BoxDecoration(
                color: (iconColor ?? greenColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: iconColor ?? greenColor,
                size: 22, // Slightly larger
              ),
            ),
            SizedBox(width: 14), // More spacing
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: blackTextStyle.copyWith(
                      fontSize: 15, // Larger font
                      fontWeight: medium,
                    ),
                  ),
                  SizedBox(height: 3), // Slightly more spacing
                  Text(
                    value,
                    style: greyTextStyle.copyWith(
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (badgeText != null) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // More padding
                decoration: BoxDecoration(
                  color: (badgeColor ?? greenColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10), // More rounded
                ),
                child: Text(
                  badgeText,
                  style: blackTextStyle.copyWith(
                    fontSize: 12, // Slightly larger font
                    fontWeight: medium,
                    color: badgeColor ?? greenColor,
                  ),
                ),
              ),
              SizedBox(width: 10), // More spacing
            ],
            Icon(
              Icons.arrow_forward_ios,
              size: 16, // Slightly larger
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper method to build settings item
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconColor,
    bool showBadge = false,
    String? badgeText,
    bool showBorder = true,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: showBorder ? null : BorderRadius.vertical(bottom: Radius.circular(16)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18), // More vertical padding
        decoration: BoxDecoration(
          border: showBorder ? Border(
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44, // Slightly larger
              height: 44, // Slightly larger
              decoration: BoxDecoration(
                color: (iconColor ?? greenColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12), // More rounded
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: iconColor ?? greenColor,
                size: 24, // Slightly larger
              ),
            ),
            SizedBox(width: 14), // More spacing
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: blackTextStyle.copyWith(
                      fontSize: 15,
                      fontWeight: semiBold,
                    ),
                  ),
                  SizedBox(height: 3), // Slightly more spacing
                  Text(
                    subtitle,
                    style: greyTextStyle.copyWith(
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (showBadge) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // More padding
                decoration: BoxDecoration(
                  color: (iconColor ?? greenColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  badgeText ?? 'Baru',
                  style: blackTextStyle.copyWith(
                    fontSize: 12, // Slightly larger font
                    fontWeight: medium,
                    color: iconColor ?? greenColor,
                  ),
                ),
              ),
              SizedBox(width: 10), // More spacing
            ],
            Icon(
              Icons.arrow_forward_ios,
              size: 16, // Slightly larger
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

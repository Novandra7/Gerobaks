import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/services/auth_api_service.dart';
import 'package:bank_sha/ui/pages/sign_in/sign_in_page.dart';
import 'package:bank_sha/utils/responsive_helper.dart';
import 'package:bank_sha/ui/widgets/dashboard/dashboard_background.dart';
import 'package:bank_sha/ui/pages/mitra/profile/widgets/profile_header.dart';
import 'package:bank_sha/ui/pages/mitra/profile/widgets/profile_stats_card.dart';
import 'package:bank_sha/ui/pages/mitra/profile/widgets/profile_menu_item.dart';
import 'package:bank_sha/ui/pages/mitra/profile/widgets/profile_action_card.dart';
import 'package:bank_sha/ui/pages/mitra/profile/widgets/profile_info_item.dart';
import 'package:bank_sha/ui/pages/mitra/profile/widgets/profile_section.dart';

class ProfileMitraPageImproved extends StatefulWidget {
  const ProfileMitraPageImproved({super.key});

  @override
  State<ProfileMitraPageImproved> createState() => _ProfileMitraPageImprovedState();
}

class _ProfileMitraPageImprovedState extends State<ProfileMitraPageImproved> {
  late final LocalStorageService _localStorageService;
  
  // Define missing colors
  final Color orangeColor = const Color(0xFFFF8A00);
  final Color orangeui = const Color(0xFFFFF5E5);
  final Color redColor = const Color(0xFFFF0000);
  final Color blueui = const Color(0xFFE5F5FF);
  final Color purpleui = const Color(0xFFF0E5FF);
  
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
    return Scaffold(
      body: DashboardBackground(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            children: [
              // Header with profile info
              ProfileHeader(
                name: _userData['name'],
                email: _userData['email'],
                role: _userData['role'],
                id: _userData['id'],
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
              
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 24)),
              
              // Stats Row
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsiveSpacing(context, 16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ProfileStatsCard(
                        title: 'Poin Reward',
                        value: _userData['points'],
                        icon: Icons.star_rounded,
                        backgroundColor: greenui,
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 12)),
                    Expanded(
                      child: ProfileStatsCard(
                        title: 'Transaksi',
                        value: _userData['transactions'],
                        icon: Icons.receipt_long_rounded,
                        backgroundColor: blueui,
                        iconColor: blueColor,
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 12)),
                    Expanded(
                      child: ProfileStatsCard(
                        title: 'Rating',
                        value: _userData['rating'],
                        icon: Icons.thumb_up_alt_rounded,
                        backgroundColor: orangeui,
                        iconColor: orangeColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 24)),
              
              // Quick Actions Section
              ProfileSection(
                title: 'Aksi Cepat',
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsiveSpacing(context, 16),
                  vertical: ResponsiveHelper.getResponsiveSpacing(context, 20),
                ),
                showDivider: false,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: ProfileActionCard(
                          icon: Icons.history_rounded,
                          label: 'Riwayat',
                          onTap: () {
                            // Navigate to history page
                          },
                          iconBackgroundColor: blueui,
                          iconColor: blueColor,
                        ),
                      ),
                      SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 12)),
                      Expanded(
                        child: ProfileActionCard(
                          icon: Icons.account_balance_wallet_rounded,
                          label: 'Saldo',
                          onTap: () {
                            // Navigate to wallet page
                          },
                        ),
                      ),
                      SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 12)),
                      Expanded(
                        child: ProfileActionCard(
                          icon: Icons.card_giftcard_rounded,
                          label: 'Rewards',
                          onTap: () {
                            // Navigate to rewards page
                          },
                          iconBackgroundColor: purpleui,
                          iconColor: purpleColor,
                        ),
                      ),
                      SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 12)),
                      Expanded(
                        child: ProfileActionCard(
                          icon: Icons.help_outline_rounded,
                          label: 'Bantuan',
                          onTap: () {
                            // Navigate to help page
                          },
                          iconBackgroundColor: orangeui,
                          iconColor: orangeColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 24)),
              
              // Personal Information Section
              ProfileSection(
                title: 'Informasi Pribadi',
                children: [
                  ProfileInfoItem(
                    icon: Icons.phone_android_rounded,
                    title: 'Nomor Telepon',
                    value: _userData['phone'],
                  ),
                  SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 16)),
                  ProfileInfoItem(
                    icon: Icons.location_on_rounded,
                    title: 'Alamat',
                    value: _userData['address'],
                    iconColor: orangeColor,
                  ),
                ],
              ),
              
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 24)),
              
              // Settings Section
              ProfileSection(
                title: 'Pengaturan',
                padding: EdgeInsets.zero,
                children: [
                  ProfileMenuItem(
                    icon: Icons.person_outline_rounded,
                    title: 'Edit Profil',
                    onTap: () {
                      // Navigate to edit profile page
                    },
                  ),
                  ProfileMenuItem(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifikasi',
                    onTap: () {
                      // Navigate to notifications settings
                    },
                    iconColor: orangeColor,
                  ),
                  ProfileMenuItem(
                    icon: Icons.lock_outline_rounded,
                    title: 'Keamanan',
                    onTap: () {
                      // Navigate to security settings
                    },
                    iconColor: redColor,
                  ),
                  ProfileMenuItem(
                    icon: Icons.language_rounded,
                    title: 'Bahasa',
                    onTap: () {
                      // Navigate to language settings
                    },
                    iconColor: blueColor,
                  ),
                ],
              ),
              
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 24)),
              
              // About Section
              ProfileSection(
                title: 'Tentang',
                padding: EdgeInsets.zero,
                children: [
                  ProfileMenuItem(
                    icon: Icons.info_outline_rounded,
                    title: 'Tentang Gerobaks',
                    onTap: () {
                      // Navigate to about page
                    },
                    iconColor: greenColor,
                  ),
                  ProfileMenuItem(
                    icon: Icons.policy_rounded,
                    title: 'Kebijakan Privasi',
                    onTap: () {
                      // Navigate to privacy policy
                    },
                    iconColor: blueColor,
                  ),
                  ProfileMenuItem(
                    icon: Icons.description_outlined,
                    title: 'Syarat & Ketentuan',
                    onTap: () {
                      // Navigate to terms and conditions
                    },
                    iconColor: purpleColor,
                  ),
                ],
              ),
              
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 32)),
              
              // Logout Button
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsiveSpacing(context, 16),
                  vertical: ResponsiveHelper.getResponsiveSpacing(context, 8),
                ),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // Logout from API (primary method)
                    final authService = AuthApiService();
                    await authService.logout();
                    
                    // For backward compatibility
                    await _localStorageService.fullLogout();
                    if (!mounted) return;
                    
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const SignInPage()), 
                      (route) => false,
                    );
                  },
                  icon: Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                    size: ResponsiveHelper.getResponsiveIconSize(context, 20),
                  ),
                  label: Text(
                    'Keluar',
                    style: whiteTextStyle.copyWith(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                      fontWeight: semiBold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: redColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveHelper.getResponsiveSpacing(context, 16),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 12)),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 24)),
            ],
          ),
        ),
      ),
    );
  }
}

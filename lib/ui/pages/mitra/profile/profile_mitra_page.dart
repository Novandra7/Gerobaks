import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/ui/pages/sign_in/sign_in_page.dart';
import 'package:bank_sha/utils/responsive_helper.dart';
import 'package:bank_sha/utils/golden_ratio_helper.dart';
import 'package:bank_sha/ui/widgets/dashboard/dashboard_background.dart';
import 'package:bank_sha/ui/pages/mitra/profile/widgets/golden_profile_section.dart';
import 'package:bank_sha/ui/pages/mitra/profile/widgets/enhanced_profile_header.dart';
import 'package:bank_sha/ui/pages/mitra/profile/widgets/enhanced_info_item.dart';
import 'package:bank_sha/ui/pages/mitra/profile/widgets/enhanced_menu_item.dart';
import 'package:bank_sha/ui/pages/mitra/profile/widgets/minimal_stats_card.dart';
import 'package:bank_sha/ui/pages/mitra/profile/widgets/minimal_action_button.dart';

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
    'name': 'Ahmad Sobari',
    'email': 'ahmad.sobari@gmail.com',
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
              
              // Stats Section with minimal cards in row layout
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsiveSpacing(context, basePadding),
                ),
                child: Column(
                  children: [
                    MinimalStatsCard(
                      title: 'Poin Reward',
                      value: _userData['points'],
                      subtitle: 'Tukarkan sekarang',
                      icon: Icons.star_rounded,
                      backgroundColor: greenui,
                      showTrend: true,
                      trendPercentage: 5.2,
                      isPositive: true,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Anda memiliki ${_userData['points']} poin yang bisa ditukarkan!'),
                            backgroundColor: greenColor,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 10)),
                    MinimalStatsCard(
                      title: 'Transaksi',
                      value: _userData['transactions'],
                      subtitle: 'Bulan ini',
                      icon: Icons.receipt_long_rounded,
                      backgroundColor: blueui,
                      iconColor: blueColor,
                      showTrend: true,
                      trendPercentage: 12.7,
                      isPositive: true,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Anda memiliki ${_userData['transactions']} transaksi bulan ini'),
                            backgroundColor: blueColor,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 10)),
                    MinimalStatsCard(
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
              
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, sectionSpacing)),
              
              // Quick Actions Section with minimal buttons
              GoldenProfileSection(
                title: 'Aksi Cepat',
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsiveSpacing(context, basePadding),
                  vertical: ResponsiveHelper.getResponsiveSpacing(context, basePadding / phi),
                ),
                showDivider: false,
                children: [
                  Wrap(
                    spacing: ResponsiveHelper.getResponsiveSpacing(context, 12),
                    runSpacing: ResponsiveHelper.getResponsiveSpacing(context, 8),
                    alignment: WrapAlignment.start,
                    children: [
                      MinimalActionButton(
                        icon: Icons.history_rounded,
                        label: 'Riwayat',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Riwayat transaksi Anda'),
                              backgroundColor: blueColor,
                            ),
                          );
                        },
                        iconBackgroundColor: blueui,
                        iconColor: blueColor,
                        hasNewContent: true,
                      ),
                      MinimalActionButton(
                        icon: Icons.account_balance_wallet_rounded,
                        label: 'Saldo',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Saldo Anda: Rp 2.450.000'),
                              backgroundColor: greenColor,
                            ),
                          );
                        },
                        iconBackgroundColor: greenui,
                        iconColor: greenColor,
                      ),
                      MinimalActionButton(
                        icon: Icons.card_giftcard_rounded,
                        label: 'Rewards',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Anda memiliki 3 hadiah yang bisa diambil!'),
                              backgroundColor: purpleColor,
                            ),
                          );
                        },
                        iconBackgroundColor: purpleui,
                        iconColor: purpleColor,
                      ),
                      MinimalActionButton(
                        icon: Icons.help_outline_rounded,
                        label: 'Bantuan',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Pusat bantuan Gerobaks'),
                              backgroundColor: orangeColor,
                            ),
                          );
                        },
                        iconBackgroundColor: orangeui,
                        iconColor: orangeColor,
                      ),
                      MinimalActionButton(
                        icon: Icons.location_on_rounded,
                        label: 'Lokasi',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Lokasi pengambilan'),
                              backgroundColor: blueColor,
                            ),
                          );
                        },
                        iconBackgroundColor: blueui,
                        iconColor: blueColor,
                      ),
                      MinimalActionButton(
                        icon: Icons.schedule_rounded,
                        label: 'Jadwal',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Jadwal pengambilan'),
                              backgroundColor: greenColor,
                            ),
                          );
                        },
                        iconBackgroundColor: greenui,
                        iconColor: greenColor,
                      ),
                    ],
                  ),
                ],
              ),
              
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, sectionSpacing)),
              
              // Personal Information Section - More minimal
              GoldenProfileSection(
                title: 'Informasi Pribadi',
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsiveSpacing(context, basePadding),
                ),
                children: [
                  EnhancedInfoItem(
                    icon: Icons.phone_android_rounded,
                    title: 'Nomor Telepon',
                    value: _userData['phone'],
                    badge: 'Terverifikasi',
                    badgeColor: greenColor,
                    showEditIcon: true,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Edit nomor telepon'),
                          backgroundColor: greenColor,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, basePadding / phi)),
                  EnhancedInfoItem(
                    icon: Icons.location_on_rounded,
                    title: 'Alamat',
                    value: _userData['address'],
                    iconColor: orangeColor,
                    showEditIcon: true,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Edit alamat'),
                          backgroundColor: orangeColor,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, basePadding / phi)),
                  EnhancedInfoItem(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    value: _userData['email'],
                    iconColor: blueColor,
                    badge: 'Terverifikasi',
                    badgeColor: blueColor,
                    showEditIcon: true,
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
              
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, sectionSpacing)),
              
              // Settings Section - More compact
              GoldenProfileSection(
                title: 'Pengaturan & Informasi',
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsiveSpacing(context, basePadding),
                ),
                children: [
                  Wrap(
                    spacing: ResponsiveHelper.getResponsiveSpacing(context, 16),
                    runSpacing: ResponsiveHelper.getResponsiveSpacing(context, 16),
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.42,
                        child: EnhancedMenuItem(
                          icon: Icons.person_outline_rounded,
                          title: 'Edit Profil',
                          subtitle: 'Perbarui informasi',
                          onTap: () {
                            // Navigate to edit profile page
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Halaman edit profil akan segera hadir!'),
                                backgroundColor: greenColor,
                              ),
                            );
                          },
                          isNew: true,
                          showTrailing: false,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.42,
                        child: EnhancedMenuItem(
                          icon: Icons.notifications_none_rounded,
                          title: 'Notifikasi',
                          subtitle: 'Preferensi notifikasi',
                          onTap: () {
                            // Navigate to notifications settings
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Pengaturan notifikasi'),
                                backgroundColor: orangeColor,
                              ),
                            );
                          },
                          iconColor: orangeColor,
                          showBadge: true,
                          badgeText: '3',
                          showTrailing: false,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.42,
                        child: EnhancedMenuItem(
                          icon: Icons.lock_outline_rounded,
                          title: 'Keamanan',
                          subtitle: 'Keamanan akun',
                          onTap: () {
                            // Navigate to security settings
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Pengaturan keamanan'),
                                backgroundColor: redColor,
                              ),
                            );
                          },
                          iconColor: redColor,
                          showTrailing: false,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.42,
                        child: EnhancedMenuItem(
                          icon: Icons.language_rounded,
                          title: 'Bahasa',
                          subtitle: 'Bahasa aplikasi',
                          onTap: () {
                            // Navigate to language settings
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Pengaturan bahasa'),
                                backgroundColor: blueColor,
                              ),
                            );
                          },
                          iconColor: blueColor,
                          showTrailing: false,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.42,
                        child: EnhancedMenuItem(
                          icon: Icons.info_outline_rounded,
                          title: 'Tentang',
                          subtitle: 'Informasi aplikasi',
                          onTap: () {
                            // Navigate to about page
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Tentang Gerobaks'),
                                backgroundColor: greenColor,
                              ),
                            );
                          },
                          iconColor: greenColor,
                          showTrailing: false,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.42,
                        child: EnhancedMenuItem(
                          icon: Icons.headset_mic_outlined,
                          title: 'Bantuan',
                          subtitle: 'Hubungi kami',
                          onTap: () {
                            // Navigate to contact page
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Kontak Gerobaks'),
                                backgroundColor: orangeColor,
                              ),
                            );
                          },
                          iconColor: orangeColor,
                          isNew: true,
                          showTrailing: false,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, sectionSpacing * 1.15)),
              
              // Logout Button with golden ratio proportions
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsiveSpacing(context, basePadding),
                  vertical: ResponsiveHelper.getResponsiveSpacing(context, basePadding / phi),
                ),
                child: ElevatedButton.icon(
                  onPressed: () async {
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
                      fontSize: GoldenRatioHelper.goldenFontSize(context, level: 0, base: 16.0),
                      fontWeight: semiBold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: redColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveHelper.getResponsiveSpacing(context, basePadding),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 12)),
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
}

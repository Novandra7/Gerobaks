import 'package:bank_sha/ui/pages/end_user/profile/List/about_us.dart';
import 'package:bank_sha/ui/pages/end_user/profile/List/myprofile.dart';
import 'package:bank_sha/ui/pages/end_user/profile/List/privacy_policy.dart';
import 'package:bank_sha/ui/pages/end_user/profile/List/settings/settings.dart';
import 'package:bank_sha/ui/pages/end_user/profile/points_history_page.dart';
import 'package:bank_sha/ui/widgets/shared/profile_picture_picker.dart';
import 'package:bank_sha/ui/widgets/shared/responsive_menu.dart';
import 'package:bank_sha/ui/widgets/shared/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/skeleton/skeleton_items.dart';
import 'package:bank_sha/models/user_model.dart';
import 'package:bank_sha/services/user_service.dart';
import 'package:bank_sha/mixins/app_dialog_mixin.dart';
import 'package:bank_sha/blocs/blocs.dart';

class ProfileContent extends StatefulWidget {
  final double horizontalPadding;
  
  const ProfileContent({
    super.key,
    this.horizontalPadding = 24.0,
  });

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> with AppDialogMixin, SingleTickerProviderStateMixin {
  bool _isLoading = true;
  UserModel? _user;
  late UserService _userService;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    // Load real user data
    _loadUserData();
    
    // Start animation after a brief delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUserData() async {
    try {
      _userService = await UserService.getInstance();
      await _userService.init();
      
      final user = await _userService.getCurrentUser();
      
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading user data: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Skeleton loading for profile
  Widget _buildSkeletonLoading() {
    return Container(
      color: uicolor,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          
          // Profile Info Skeleton
          Column(
            children: [
              SkeletonItems.circle(size: 120),
              const SizedBox(height: 12),
              SkeletonItems.text(width: 120, height: 16),
              const SizedBox(height: 4),
              SkeletonItems.text(width: 180, height: 14),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Menu Items Skeleton
          for (int i = 0; i < 6; i++) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  SkeletonItems.circle(size: 24),
                  const SizedBox(width: 12),
                  SkeletonItems.text(width: 120, height: 16),
                  const Spacer(),
                  SkeletonItems.circle(size: 18),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildSkeletonLoading();
    }
    
    // Get screen width for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final horizontalPadding = isTablet ? 32.0 : widget.horizontalPadding;
    
    return Container(
      color: uicolor,
      width: double.infinity,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        physics: const BouncingScrollPhysics(),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),

                // Profile Info
                Column(
                  children: [
                  ProfilePicturePicker(
                    currentPicture: _user?.profilePicUrl ?? 'assets/img_profile.png',
                    onPictureSelected: (String newPicture) async {
                      try {
                        await _userService.updateUserProfile(
                          profilePicUrl: newPicture,
                        );
                        _loadUserData(); // Refresh data
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal mengubah foto profil: $e')),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _user?.name ?? 'Pengguna',
                    style: blackTextStyle.copyWith(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: semiBold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _user?.email ?? 'email@gerobaks.com',
                    style: greyTextStyle.copyWith(
                      fontSize: isTablet ? 14 : 12,
                    ),
                  ),
                  if (_user != null) ...[
                    const SizedBox(height: 8),
                    // Badge verifikasi telepon
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _user!.isPhoneVerified ? greenColor : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _user!.isPhoneVerified 
                              ? Icons.check_circle_outline 
                              : Icons.info_outline,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _user!.isPhoneVerified 
                              ? 'Telepon Terverifikasi' 
                              : 'Telepon Belum Terverifikasi',
                            style: whiteTextStyle.copyWith(
                              fontSize: 10,
                              fontWeight: medium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _user?.email ?? 'email@gerobaks.com',
                    style: greyTextStyle.copyWith(
                      fontSize: isTablet ? 15 : 14,
                      fontWeight: regular,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      // Navigasi ke halaman riwayat poin ketika card diklik
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => const PointsHistoryPage(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Ink(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 20 : 16, 
                        vertical: isTablet ? 12 : 10
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: greenColor.withOpacity(0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: greenColor.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.stars_rounded,
                            color: greenColor,
                            size: isTablet ? 24 : 20,
                          ),
                          SizedBox(width: isTablet ? 10 : 8),
                          Text(
                            '${_user?.points ?? 0} Poin',
                            style: greenTextStyle.copyWith(
                              fontWeight: semiBold,
                              fontSize: isTablet ? 16 : 14,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: greenColor,
                            size: isTablet ? 16 : 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36), // Jarak lebih besar untuk memisahkan profil dan menu

                // Menu Items with Responsive Layout
                ResponsiveAppMenu(
                  iconURL: 'assets/ic_profile_profile.png',
                  title: 'My profile',
                  isHighlighted: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Myprofile()),
                    );
                  },
                ),
                ResponsiveAppMenu(
                  iconURL: 'assets/ic_stars.png',
                  title: 'Riwayat Poin',
                  isHighlighted: false,
                  onTap: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => const PointsHistoryPage(),
                      ),
                    );
                  },
                ),
                ResponsiveAppMenu(
                  iconURL: 'assets/ic_my_rewards.png',
                  title: 'Langganan Saya',
                  isHighlighted: false,
                  onTap: () {
                    Navigator.pushNamed(context, '/my-subscription');
                  },
                ),
                ResponsiveAppMenu(
                  iconURL: 'assets/ic_kebijakan.png',
                  title: 'Privacy policy',
                  isHighlighted: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PrivacyPolicy()),
                    );
                  },
                ),
                ResponsiveAppMenu(
                  iconURL: 'assets/ic_aboutus.png',
                  title: 'About us',
                  isHighlighted: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutUs()),
                    );
                  },
                ),
                ResponsiveAppMenu(
                  iconURL: 'assets/ic_setting.png',
                  title: 'Settings',
                  isHighlighted: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Settings()),
                    );
                  },
                ),
                  ResponsiveAppMenu(
                  iconURL: 'assets/ic_logout_profile.png',
                  title: 'Log out',
                  isHighlighted: false,
                  onTap: () async {
                    // Show confirmation dialog using DialogHelper
                    final confirm = await DialogHelper.showConfirmDialog(
                      context: context,
                      title: 'Logout',
                      message: 'Apakah Anda yakin ingin keluar?',
                      confirmText: 'Ya, Keluar',
                      cancelText: 'Batal',
                      icon: Icons.logout,
                    );
                      
                    if (confirm) {
                      // Use AuthBloc to handle logout properly
                      if (mounted) {
                        context.read<AuthBloc>().add(const LogoutRequested());
                        
                        // Wait a moment for logout to complete, then navigate
                        await Future.delayed(const Duration(milliseconds: 500));
                        
                        if (mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/sign-in',
                            (route) => false,
                          );
                        }
                      }
                    }
                  },
                ),                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

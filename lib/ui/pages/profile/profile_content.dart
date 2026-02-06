import 'package:bank_sha/ui/pages/end_user/profile/List/about_us.dart';
import 'package:bank_sha/ui/pages/end_user/profile/List/myprofile.dart';
import 'package:bank_sha/ui/pages/end_user/profile/List/privacy_policy.dart';
import 'package:bank_sha/ui/pages/end_user/profile/List/settings/settings.dart';
import 'package:bank_sha/ui/pages/end_user/profile/points_history_page.dart';
import 'package:bank_sha/ui/widgets/shared/responsive_menu.dart';
import 'package:bank_sha/ui/widgets/shared/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/pages/sign_in/sign_in_page.dart';
import 'package:bank_sha/ui/widgets/skeleton/skeleton_items.dart';
import 'package:bank_sha/models/user_model.dart';
import 'package:bank_sha/services/user_service.dart';
import 'package:bank_sha/mixins/app_dialog_mixin.dart';

class ProfileContent extends StatefulWidget {
  final double horizontalPadding;
  
  const ProfileContent({
    super.key,
    this.horizontalPadding = 24.0,
  });

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> with AppDialogMixin {
  bool _isLoading = true;
  UserModel? _user;
  late UserService _userService;
  
  @override
  void initState() {
    super.initState();
    // Load real user data
    _loadUserData();
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

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    
    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0].substring(0, words[0].length >= 2 ? 2 : 1).toUpperCase();
    } else {
      return (words[0][0] + words[1][0]).toUpperCase();
    }
  }

  Widget _buildProfilePicture() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final size = isTablet ? 70.0 : 60.0;
    
    final profilePicUrl = _user?.profilePicUrl;
    final hasValidUrl = profilePicUrl != null && 
                       profilePicUrl.isNotEmpty && 
                       (profilePicUrl.startsWith('http://') || profilePicUrl.startsWith('https://'));

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Myprofile()),
        );
      },
      child: Container(
        width: size * 2,
        height: size * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: hasValidUrl ? null : greenColor.withAlpha(25),
          border: Border.all(
            color: greenColor.withAlpha(77),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipOval(
          child: hasValidUrl
              ? Image.network(
                  profilePicUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildInitialAvatar();
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        color: greenColor,
                        strokeWidth: 2,
                      ),
                    );
                  },
                )
              : _buildInitialAvatar(),
        ),
      ),
    );
  }

  Widget _buildInitialAvatar() {
    return Center(
      child: Text(
        _getInitials(_user?.name ?? 'Pengguna'),
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          color: greenColor,
        ),
      ),
    );
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),

            // Profile Info
            Column(
              children: [
                _buildProfilePicture(),
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
                    fontSize: isTablet ? 15 : 14,
                    fontWeight: regular,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 20 : 16, 
                    vertical: isTablet ? 10 : 8
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: greenColor.withOpacity(0.5)),
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
                    ],
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
                  // Logout and redirect to sign in page
                  await _userService.logout();
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignInPage(),
                      ),
                      (route) => false,
                    );
                  }
                }
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

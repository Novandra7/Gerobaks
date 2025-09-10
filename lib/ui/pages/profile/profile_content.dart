import 'package:bank_sha/ui/pages/profile/List/about_us.dart';
import 'package:bank_sha/ui/pages/profile/List/myprofile.dart';
import 'package:bank_sha/ui/pages/profile/List/privacy_policy.dart';
import 'package:bank_sha/ui/pages/profile/List/settings/settings.dart';
<<<<<<< HEAD
import 'package:bank_sha/ui/pages/profile/points_history_page.dart';
<<<<<<< HEAD
=======
import 'package:bank_sha/services/local_storage_service.dart';
>>>>>>> 31182ad (feat: Enhance user data management by implementing LocalStorageService for profile and home content)
=======
import 'package:bank_sha/services/local_storage_service.dart';
>>>>>>> acba58a040fb6da781db35c748178afc5837a3f6
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/pages/sign_in/sign_in_page.dart';
import 'package:bank_sha/ui/widgets/skeleton/skeleton_items.dart';
import 'package:bank_sha/models/user_model.dart';
import 'package:bank_sha/services/user_service.dart';

class ProfileContent extends StatefulWidget {
  const ProfileContent({super.key});

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
<<<<<<< HEAD
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
=======
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final storage = await LocalStorageService.getInstance();
    final data = await storage.getUserData();
    if (mounted) {
      setState(() {
        userData = data;
      });
    }
  }
>>>>>>> 31182ad (feat: Enhance user data management by implementing LocalStorageService for profile and home content)

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildSkeletonLoading();
    }
    
    return Container(
      color: uicolor,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),

          // Profile Info
          Column(
            children: [
              CircleAvatar(
                radius: 60,
<<<<<<< HEAD
                backgroundImage: _user?.profilePicUrl != null 
                    ? NetworkImage(_user!.profilePicUrl!) as ImageProvider
                    : const AssetImage('assets/img_profile.png'),
              ),
              const SizedBox(height: 12),
              Text(
                _user?.name ?? 'Pengguna',
=======
                backgroundImage: AssetImage(
                  userData?['profile_picture'] ?? 'assets/img_profile.png',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                userData?['name'] ?? 'Loading...',
>>>>>>> 31182ad (feat: Enhance user data management by implementing LocalStorageService for profile and home content)
                style: blackTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: semiBold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
<<<<<<< HEAD
                _user?.email ?? 'email@gerobaks.com',
=======
                userData?['email'] ?? 'Loading...',
>>>>>>> 31182ad (feat: Enhance user data management by implementing LocalStorageService for profile and home content)
                style: greyTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: regular,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_user?.points ?? 0} Poin',
                      style: greeTextStyle.copyWith(
                        fontWeight: semiBold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Menu Items
          CustomAppMenu(
            iconURL: 'assets/ic_profile_profile.png',
            title: 'My profile',
            page: Myprofile(), // ganti dengan halaman yang sesuai
          ),
          CustomAppMenu(
            iconURL: 'assets/ic_stars.png',
            title: 'Riwayat Poin',
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => const PointsHistoryPage(),
                ),
              );
            },
            page: Container(),
          ),
          CustomAppMenu(
            iconURL: 'assets/ic_my_rewards.png',
            title: 'Langganan Saya',
            page: Container(), // Will be handled with navigation
            onTap: () {
              Navigator.pushNamed(context, '/my-subscription');
            },
          ),
          CustomAppMenu(
            iconURL: 'assets/ic_kebijakan.png',
            title: 'Privacy policy',
            page: PrivacyPolicy(),
          ),
          CustomAppMenu(
            iconURL: 'assets/ic_aboutus.png',
            title: 'About us',
            page: AboutUs(),
          ),
          CustomAppMenu(
            iconURL: 'assets/ic_setting.png',
            title: 'Settings',
            page: const Settings(),
          ),
          CustomAppMenu(
            iconURL: 'assets/ic_logout_profile.png',
            title: 'Log out',
            onTap: () async {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    'Logout',
                    style: blackTextStyle.copyWith(fontWeight: semiBold),
                  ),
                  content: Text(
                    'Apakah Anda yakin ingin keluar?',
                    style: blackTextStyle,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Batal',
                        style: greyTextStyle,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
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
                      },
                      child: Text(
                        'Keluar',
                        style: greeTextStyle,
                      ),
                    ),
                  ],
                ),
              );
            },
            page: const SignInPage(),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

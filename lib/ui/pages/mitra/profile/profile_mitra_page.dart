import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/blocs/auth/auth_bloc.dart';
import 'package:bank_sha/blocs/auth/auth_event.dart';
import 'package:bank_sha/blocs/auth/auth_state.dart';
import 'package:bank_sha/utils/navigation_service.dart';
import 'package:bank_sha/ui/pages/mitra/profile/edit_profile_page.dart';
import 'package:bank_sha/ui/pages/mitra/profile/riwayat_page.dart';
import 'package:bank_sha/ui/pages/mitra/profile/notifikasi_page.dart';
import 'package:bank_sha/ui/pages/mitra/profile/keamanan_page.dart';

class ProfileMitraPage extends StatefulWidget {
  const ProfileMitraPage({super.key});

  @override
  State<ProfileMitraPage> createState() => _ProfileMitraPageState();
}

class _ProfileMitraPageState extends State<ProfileMitraPage> {
  @override
  void initState() {
    super.initState();
  }

  // Dummy data - in real app, this would come from API or provider
  final Map<String, dynamic> _userData = {
    'name': 'Ahmad Kurniawan',
    'email': 'driver.jakarta@gerobaks.com',
    'id': 'DRV-JKT-001',
    'role': 'Mitra Premium',
    'phone': '+62 813 4567 8901',
    'address': 'Jakarta Pusat',
    'points': '2,500',
    'transactions': '56',
    'rating': '4.8',
  };

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.loading) {
          // Show loading indicator
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) =>
                const Center(child: CircularProgressIndicator()),
          );
        } else if (state.status == AuthStatus.unauthenticated) {
          // Close all dialogs
          try {
            Navigator.of(context, rootNavigator: true).popUntil((route) {
              return route.isFirst;
            });
          } catch (e) {
            print('Error closing dialogs: $e');
          }

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Logout berhasil',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              duration: const Duration(seconds: 2),
            ),
          );

          // Navigate using global NavigationService
          print('🔄 Attempting navigation to /sign-in');
          final result = NavigationService.pushNamedAndRemoveUntil('/sign-in');
          if (result == null) {
            print('❌ Navigation failed - trying with context');
            // Fallback to context navigation
            Future.delayed(const Duration(milliseconds: 200), () {
              try {
                Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
                  '/sign-in',
                  (route) => false,
                );
              } catch (e) {
                print('❌ Context navigation also failed: $e');
              }
            });
          } else {
            print('✅ Navigation successful');
          }
        }else {
          // Close loading dialog if it exists
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(
            0xFFF9FFF8,
          ), // Match dashboard and jadwal pages
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            title: Text(
              'Profile',
              style: blackTextStyle.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF9FFF8), // Consistent background color
              ),
              child: Column(
                children: [
                  // Modern Profile Header Card
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          greenColor,
                          greenColor.withOpacity(0.8),
                          const Color(0xFF059669),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: greenColor.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          blurRadius: 1,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Modern Profile Avatar dengan glassmorphism effect
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    _userData['name'][0].toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w800,
                                      color: greenColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),

                            // Profile Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _userData['name'],
                                    style: whiteTextStyle.copyWith(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'ID: ${_userData['id']}',
                                      style: whiteTextStyle.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
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

                  const SizedBox(height: 24),

                  // Modern Stats Cards - Responsive Design
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildResponsiveStatCard(
                            'Poin',
                            _userData['points'],
                            Icons.stars_rounded,
                            const Color(0xFF10B981),
                            const Color(0xFFD1FAE5),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildResponsiveStatCard(
                            'Transaksi',
                            _userData['transactions'],
                            Icons.receipt_long_rounded,
                            const Color(0xFF3B82F6),
                            const Color(0xFFDBEAFE),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildResponsiveStatCard(
                            'Rating',
                            _userData['rating'],
                            Icons.star_rounded,
                            const Color(0xFFF59E0B),
                            const Color(0xFFFEF3C7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Modern Menu Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Menu Utama',
                          style: blackTextStyle.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.3, // Adjusted for better fit
                          children: [
                            _buildModernMenuCard(
                              'Edit Profile',
                              'Kelola info pribadi',
                              Icons.person_rounded,
                              const Color(0xFF3B82F6),
                              const Color(0xFFDBEAFE),
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EditProfilePage(),
                                ),
                              ),
                            ),
                            _buildModernMenuCard(
                              'Riwayat',
                              'Transaksi & aktivitas',
                              Icons.history_rounded,
                              const Color(0xFF10B981),
                              const Color(0xFFD1FAE5),
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RiwayatPage(),
                                ),
                              ),
                            ),
                            _buildModernMenuCard(
                              'Notifikasi',
                              'Pengaturan alert',
                              Icons.notifications_rounded,
                              const Color(0xFFF59E0B),
                              const Color(0xFFFEF3C7),
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NotifikasiPage(),
                                ),
                              ),
                            ),
                            _buildModernMenuCard(
                              'Keamanan',
                              'Password & privasi',
                              Icons.security_rounded,
                              const Color(0xFFEF4444),
                              const Color(0xFFFECACB),
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const KeamananPage(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Modern Information Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: blueColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.info_outline_rounded,
                                  color: blueColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Informasi Akun',
                                style: blackTextStyle.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildModernInfoItem(
                            'Email Address',
                            _userData['email'],
                            Icons.email_rounded,
                            const Color(0xFF3B82F6),
                          ),
                          const SizedBox(height: 16),
                          _buildModernInfoItem(
                            'Nomor Telepon',
                            _userData['phone'],
                            Icons.phone_rounded,
                            const Color(0xFF10B981),
                          ),
                          const SizedBox(height: 16),
                          _buildModernInfoItem(
                            'Area Kerja',
                            _userData['address'],
                            Icons.location_on_rounded,
                            const Color(0xFFF59E0B),
                          ),
                          const SizedBox(height: 16),
                          _buildModernInfoItem(
                            'Employee ID',
                            _userData['id'],
                            Icons.badge_rounded,
                            const Color(0xFF8B5CF6),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Modern Logout Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFEF4444),
                            const Color(0xFFDC2626),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showLogoutDialog(),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.logout_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Keluar dari Akun',
                                  style: whiteTextStyle.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method untuk responsive stat card - No Overflow
  Widget _buildResponsiveStatCard(
    String label,
    String value,
    IconData icon,
    Color iconColor,
    Color backgroundColor,
  ) {
    return Container(
      height: 80, // Fixed height to prevent overflow
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: blackTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: greyTextStyle.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method untuk modern menu card
  Widget _buildModernMenuCard(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    Color backgroundColor,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16), // Reduced padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Prevent overflow
              children: [
                Container(
                  width: 36, // Slightly smaller icon container
                  height: 36,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 18, // Slightly smaller icon
                  ),
                ),
                const Spacer(),
                Flexible(
                  // Added Flexible to prevent overflow
                  child: Text(
                    title,
                    style: blackTextStyle.copyWith(
                      fontSize: 14, // Reduced font size
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1, // Prevent text wrapping
                    overflow: TextOverflow.ellipsis, // Handle overflow
                  ),
                ),
                const SizedBox(height: 3), // Reduced spacing
                Flexible(
                  // Added Flexible to prevent overflow
                  child: Text(
                    subtitle,
                    style: greyTextStyle.copyWith(
                      fontSize: 11, // Reduced font size
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2, // Allow max 2 lines
                    overflow: TextOverflow.ellipsis, // Handle overflow
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method untuk modern info item
  Widget _buildModernInfoItem(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FFF8), // Match overall background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: greyTextStyle.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: blackTextStyle.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Method untuk show logout dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFEF4444),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Konfirmasi Logout',
                style: blackTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apakah Anda yakin ingin keluar dari akun?',
                style: greyTextStyle.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Anda akan diarahkan ke halaman login.',
                style: greyTextStyle.copyWith(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: greyTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Trigger logout event
                context.read<AuthBloc>().add(const LogoutRequested());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Logout',
                style: whiteTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/utils/user_data_mock.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/ui/pages/sign_in/sign_in_page.dart';
import 'package:flutter/material.dart';

class ProfileMitraPage extends StatefulWidget {
  const ProfileMitraPage({super.key});

  @override
  State<ProfileMitraPage> createState() => _ProfileMitraPageState();
}

class _ProfileMitraPageState extends State<ProfileMitraPage> {
  Map<String, dynamic>? currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final localStorage = await LocalStorageService.getInstance();
    final userData = await localStorage.getUserData();
    if (userData != null) {
      final user = UserDataMock.getUserByEmail(userData['email']);
      setState(() {
        currentUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackgroundColor,
      appBar: AppBar(
        backgroundColor: greenColor,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/img_gerobakss.png',
              height: 30,
            ),
            const SizedBox(width: 10),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement edit profile
            },
            icon: Image.asset(
              'assets/ic_edit_profile2.png',
              width: 24,
              height: 24,
              color: whiteColor,
            ),
          ),
        ],
      ),
      body: currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Profile Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [greenColor, greenColor.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: greenColor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Profile Picture
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
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
                              currentUser!['name'].substring(0, 1),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: extraBold,
                                color: greenColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          currentUser!['name'],
                          style: whiteTextStyle.copyWith(
                            fontSize: 24,
                            fontWeight: extraBold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentUser!['employee_id'],
                          style: whiteTextStyle.copyWith(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Mitra Aktif',
                                style: whiteTextStyle.copyWith(
                                  fontSize: 14,
                                  fontWeight: semiBold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Rating',
                          value: currentUser!['rating'].toString(),
                          icon: Icons.star_rounded,
                          color: Color(0xFFEAB308), // Vibrant amber
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Total Pengambilan',
                          value: currentUser!['total_collections'].toString(),
                          icon: Icons.local_shipping_rounded,
                          color: Color(0xFF3B82F6), // Vibrant blue
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Vehicle Info
                  _buildInfoSection(
                    title: 'Informasi Kendaraan',
                    items: [
                      _buildInfoItem(
                        'Jenis Kendaraan',
                        currentUser!['vehicle_type'],
                        Icons.local_shipping_rounded,
                      ),
                      _buildInfoItem(
                        'Nomor Plat',
                        currentUser!['vehicle_plate'],
                        Icons.confirmation_number_rounded,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Work Info
                  _buildInfoSection(
                    title: 'Informasi Kerja',
                    items: [
                      _buildInfoItem(
                        'Area Kerja',
                        currentUser!['work_area'],
                        Icons.location_on_rounded,
                      ),
                      _buildInfoItem(
                        'Status',
                        currentUser!['status'],
                        Icons.work_rounded,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Contact Info
                  _buildInfoSection(
                    title: 'Informasi Kontak',
                    items: [
                      _buildInfoItem(
                        'Email',
                        currentUser!['email'],
                        Icons.email_rounded,
                      ),
                      _buildInfoItem(
                        'Nomor Telepon',
                        currentUser!['phone'],
                        Icons.phone_rounded,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Edit profile
                          },
                          
                          label: Text(
                            'Edit Profil',
                            style: whiteTextStyle.copyWith(
                              fontSize: 16,
                              fontWeight: semiBold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: greenColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Change password
                          },
                          icon: Icon(
                            Icons.lock_rounded,
                            color: whiteColor,
                          ),
                          label: Text(
                            'Ubah Password',
                            style: whiteTextStyle.copyWith(
                              fontSize: 16,
                              fontWeight: semiBold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF3B82F6), // Vibrant blue
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
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
                         
                          label: Text(
                            'Logout',
                            style: whiteTextStyle.copyWith(
                              fontSize: 16,
                              fontWeight: semiBold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFEF4444), // Vibrant red
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: whiteTextStyle.copyWith(
              fontSize: 24,
              fontWeight: extraBold,
            ),
          ),
          Text(
            title,
            style: whiteTextStyle.copyWith(
              fontSize: 14,
              fontWeight: medium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
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
              
              const SizedBox(width: 8),
              Text(
                title,
                style: blackTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: semiBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: greenColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 22,
              color: greenColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: greyTextStyle.copyWith(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: blackTextStyle.copyWith(
                    fontSize: 16,
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

import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:bank_sha/ui/widgets/shared/profile_picture_picker.dart';
import 'package:bank_sha/services/user_service.dart';
import 'package:bank_sha/models/user_model.dart';
import 'package:flutter/material.dart';
import 'edit_profile.dart';

class Myprofile extends StatefulWidget {
  const Myprofile({super.key});

  @override
  State<Myprofile> createState() => _MyprofileState();
}

class _MyprofileState extends State<Myprofile> {
  Map<String, dynamic>? userData;
  bool _isLoading = true;
  UserModel? _user;
  late UserService _userService;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      _userService = await UserService.getInstance();
      await _userService.init();
      
      // Get user directly from UserService
      final user = await _userService.getCurrentUser();
      
      // Convert UserModel to Map for backward compatibility
      final Map<String, dynamic> userMap = {
        'name': user?.name ?? 'Pengguna',
        'email': user?.email ?? 'email@gerobaks.com',
        'phone': user?.phone ?? '-',
        'address': user?.address ?? '-',
        'profile_picture': user?.profilePicUrl ?? 'assets/img_profile.png',
      };
      
      if (mounted) {
        setState(() {
          _user = user;
          userData = userMap;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: uicolor,
      appBar: const CustomAppNotif(title: 'My Profile', showBackButton: true),
      body: _isLoading
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(greenColor),
                ),
                const SizedBox(height: 16),
                Text(
                  'Memuat data profil...',
                  style: greyTextStyle.copyWith(
                    fontWeight: medium,
                  ),
                ),
              ],
            ),
          )
        : SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Foto Profil
              ProfilePicturePicker(
                currentPicture: _user?.profilePicUrl ?? userData?['profile_picture'] ?? 'assets/img_profile.png',
              onPictureSelected: (String newPicture) async {
                // Update using UserService for persistent storage
                final userService = await UserService.getInstance();
                final updatedUser = await userService.updateUserProfile(
                  profilePicUrl: newPicture,
                );
                
                if (mounted) {
                  setState(() {
                    _user = updatedUser;
                    // Update map for backward compatibility
                    if (userData != null) {
                      userData!['profile_picture'] = newPicture;
                    }
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Nama
            Text(
              _user?.name ?? userData?['name'] ?? 'Loading...',
              style: blackTextStyle.copyWith(
                fontSize: 20,
                fontWeight: semiBold,
              ),
            ),
            const SizedBox(height: 4),

            // Email
            Text(
              _user?.email ?? userData?['email'] ?? 'Loading...',
              style: greyTextStyle.copyWith(fontSize: 14, fontWeight: regular),
            ),

            const SizedBox(height: 32),

            // Info Tambahan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'No. Telepon',
                  style: blackTextStyle.copyWith(fontSize: 14),
                ),
                Text(
                  _user?.phone ?? userData?['phone'] ?? 'Loading...',
                  style: greyTextStyle.copyWith(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Alamat', style: blackTextStyle.copyWith(fontSize: 14)),
                    if (_user?.address == null || (_user!.address?.length ?? 0) < 30)
                      Flexible(
                        child: Text(
                          _user?.address ?? userData?['address'] ?? 'Loading...',
                          style: greyTextStyle.copyWith(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
                // Jika alamat panjang, tampilkan di bawah sebagai teks penuh
                if (_user?.address != null && (_user!.address?.length ?? 0) >= 30) 
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: Text(
                      _user!.address!,
                      style: greyTextStyle.copyWith(fontSize: 14),
                    ),
                  ),
                
                // Tampilkan alamat tersimpan jika ada
                if (_user?.savedAddresses != null && (_user!.savedAddresses?.isNotEmpty ?? false)) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Alamat Tersimpan',
                    style: blackTextStyle.copyWith(fontSize: 14, fontWeight: semiBold),
                  ),
                  const SizedBox(height: 8),
                  ..._user!.savedAddresses!.map((savedAddress) => Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: greenColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            savedAddress,
                            style: greyTextStyle.copyWith(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ],
            ),

            const SizedBox(height: 40),

            // Tombol Edit
            CustomFilledButton(
              title: 'Edit Profile',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfile()),
                );
                
                // Reload data when returning from edit profile
                if (result == true) {
                  _loadUserData();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

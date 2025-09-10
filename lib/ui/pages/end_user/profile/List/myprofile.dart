import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:bank_sha/ui/widgets/shared/profile_picture_picker.dart';
import 'package:bank_sha/services/user_service.dart';
import 'package:bank_sha/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For phone number formatting
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
  
  // Controllers untuk dialog verifikasi telepon
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isVerificationInProgress = false;
  bool _isOtpSent = false;
  String? _generatedOtp;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
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

  Future<void> _showPhoneVerificationDialog() async {
    // Pre-fill dengan nomor telepon yang sudah ada (jika ada)
    if (_user?.phone != null && _user!.phone!.isNotEmpty) {
      _phoneController.text = _user!.phone!;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                _isOtpSent ? 'Verifikasi OTP' : 'Verifikasi Nomor Telepon',
                style: blackTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: semiBold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_isOtpSent) ...[
                      // Form nomor telepon
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Masukkan nomor telepon',
                          labelText: 'Nomor Telepon',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.phone),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Kami akan mengirimkan kode verifikasi ke nomor telepon Anda.',
                        style: greyTextStyle.copyWith(fontSize: 12),
                      ),
                    ] else ...[
                      // Form OTP
                      Text(
                        'Kode OTP telah dikirim ke ${_phoneController.text}',
                        style: greyTextStyle.copyWith(fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        decoration: InputDecoration(
                          hintText: 'Masukkan kode OTP',
                          labelText: 'Kode OTP',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.lock_outline),
                          counterText: '',
                        ),
                      ),
                    ],
                    if (_isVerificationInProgress) ...[
                      const SizedBox(height: 16),
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(greenColor),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Reset state
                    _isOtpSent = false;
                    _isVerificationInProgress = false;
                    _otpController.clear();
                  },
                  child: Text(
                    'Batal',
                    style: greyTextStyle,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: greenColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isVerificationInProgress
                      ? null
                      : () async {
                          if (!_isOtpSent) {
                            // Kirim OTP
                            if (_phoneController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Nomor telepon tidak boleh kosong'),
                                ),
                              );
                              return;
                            }

                            setState(() {
                              _isVerificationInProgress = true;
                            });

                            try {
                              // Dalam aplikasi sebenarnya, ini akan mengirim OTP via SMS
                              // Untuk demo, kita hanya generate OTP di UserService
                              _generatedOtp = await _userService.requestPhoneVerification(_phoneController.text);
                              
                              setState(() {
                                _isOtpSent = true;
                                _isVerificationInProgress = false;
                              });
                              
                              // Untuk demo, tampilkan OTP (dalam produksi, ini akan dikirim via SMS)
                              if (_generatedOtp != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('OTP Demo: $_generatedOtp'),
                                    duration: const Duration(seconds: 10),
                                  ),
                                );
                              }
                            } catch (e) {
                              setState(() {
                                _isVerificationInProgress = false;
                              });
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                ),
                              );
                            }
                          } else {
                            // Verifikasi OTP
                            if (_otpController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Kode OTP tidak boleh kosong'),
                                ),
                              );
                              return;
                            }

                            setState(() {
                              _isVerificationInProgress = true;
                            });

                            try {
                              final isVerified = await _userService.verifyPhoneWithOTP(
                                _phoneController.text,
                                _otpController.text,
                              );

                              if (isVerified) {
                                // Refresh data user
                                await _loadUserData();
                                
                                Navigator.of(context).pop();
                                
                                // Reset state
                                _isOtpSent = false;
                                _isVerificationInProgress = false;
                                _otpController.clear();
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Nomor telepon berhasil diverifikasi'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                setState(() {
                                  _isVerificationInProgress = false;
                                });
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Kode OTP tidak valid'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } catch (e) {
                              setState(() {
                                _isVerificationInProgress = false;
                              });
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                ),
                              );
                            }
                          }
                        },
                  child: Text(
                    _isOtpSent ? 'Verifikasi' : 'Kirim OTP',
                    style: whiteTextStyle,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
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
                Row(
                  children: [
                    Text(
                      _user?.phone ?? userData?['phone'] ?? 'Loading...',
                      style: greyTextStyle.copyWith(fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    // Badge untuk status verifikasi telepon
                    GestureDetector(
                      onTap: () {
                        if (_user?.isPhoneVerified != true) {
                          _showPhoneVerificationDialog();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _user?.isPhoneVerified == true ? greenColor : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _user?.isPhoneVerified == true 
                                ? Icons.check_circle_outline 
                                : Icons.info_outline,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _user?.isPhoneVerified == true 
                                ? 'Terverifikasi' 
                                : 'Belum Verifikasi',
                              style: whiteTextStyle.copyWith(
                                fontSize: 10,
                                fontWeight: medium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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

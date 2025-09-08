import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:bank_sha/ui/widgets/shared/dialog_helper.dart';
import 'package:bank_sha/models/user_model.dart';
import 'package:bank_sha/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:bank_sha/ui/widgets/shared/map_picker.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  
  // Controllers untuk dialog verifikasi telepon
  final TextEditingController _otpController = TextEditingController();
  bool _isVerificationInProgress = false;
  bool _isOtpSent = false;
  String? _generatedOtp;
  
  bool _isLoading = true;
  bool _isSaving = false;
  UserModel? _user;
  late UserService _userService;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      _userService = await UserService.getInstance();
      await _userService.init();
      
      final user = await _userService.getCurrentUser();
      
      if (mounted) {
        setState(() {
          _user = user;
          // Isi form dengan data user
          _nameController.text = user?.name ?? '';
          _emailController.text = user?.email ?? '';
          _phoneController.text = user?.phone ?? '';
          _addressController.text = user?.address ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading user data: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Show error dialog
        DialogHelper.showErrorDialog(
          context: context,
          title: 'Error',
          message: 'Gagal memuat data profil: $e',
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _otpController.dispose();
    super.dispose();
  }
  
  Future<void> _showPhoneVerificationDialog() async {
    // Pre-fill dengan nomor telepon yang sudah ada
    _phoneController.text = _phoneController.text.isNotEmpty 
      ? _phoneController.text 
      : (_user?.phone ?? '');

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
      appBar: const CustomAppBar(title: 'Edit Profile'),
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
                'Memuat data...',
                style: greyTextStyle.copyWith(
                  fontWeight: medium,
                ),
              ),
            ],
          ),
        )
      : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture Section
              Container(
                margin: const EdgeInsets.only(bottom: 32),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: _user?.profilePicUrl != null && 
                                          _user!.profilePicUrl!.startsWith('http') 
                              ? NetworkImage(_user!.profilePicUrl!) as ImageProvider
                              : AssetImage(_user?.profilePicUrl ?? 'assets/img_profile.png'),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              _showImagePicker();
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: greenColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: whiteColor, width: 2),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: whiteColor,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tap to change photo',
                      style: greyTextStyle.copyWith(
                        fontSize: 12,
                        fontWeight: medium,
                      ),
                    ),
                  ],
                ),
              ),

              // Form Fields
              _buildFormField(
                title: 'Nama Lengkap',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama lengkap tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildFormField(
                title: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!value.contains('@')) {
                    return 'Email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'No. Telepon',
                        style: blackTextStyle.copyWith(
                          fontSize: 14,
                          fontWeight: medium,
                        ),
                      ),
                      if (_user != null) 
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _user!.isPhoneVerified 
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
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Masukkan nomor telepon',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      suffixIcon: _user != null && !_user!.isPhoneVerified 
                        ? GestureDetector(
                            onTap: () => _showPhoneVerificationDialog(),
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: greenColor,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  'Verifikasi',
                                  style: whiteTextStyle.copyWith(
                                    fontSize: 12,
                                    fontWeight: medium,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : null,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nomor telepon tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alamat',
                    style: blackTextStyle.copyWith(
                      fontSize: 14,
                      fontWeight: medium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      TextFormField(
                        controller: _addressController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Masukkan alamat lengkap Anda',
                          contentPadding: const EdgeInsets.all(12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: greyColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: greyColor.withOpacity(0.5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: greenColor, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: redcolor, width: 2),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.map_outlined,
                              color: greenColor,
                            ),
                            onPressed: () {
                              _openMapPicker();
                            },
                            tooltip: 'Pilih dari peta',
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Alamat tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Save Button
              CustomFilledButton(
                title: _isSaving ? 'Menyimpan...' : 'Simpan Perubahan',
                onPressed: _isSaving 
                  ? null 
                  : () {
                      if (_formKey.currentState!.validate()) {
                        _saveProfile();
                      }
                    },
              ),

              const SizedBox(height: 16),

              // Cancel Button
              CustomTextButton(
                title: 'Batal',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: greyColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Text(
              'Pilih Foto Profile',
              style: blackTextStyle.copyWith(
                fontWeight: semiBold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),

            // Options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement camera functionality
                    _showMessage('Kamera akan dibuka');
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: greenColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: greenColor,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kamera',
                        style: blackTextStyle.copyWith(fontWeight: medium),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement gallery functionality
                    _showMessage('Galeri akan dibuka');
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: greenColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.photo_library,
                          color: greenColor,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Galeri',
                        style: blackTextStyle.copyWith(fontWeight: medium),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      // Update user profile using UserService
      await _userService.updateUserProfile(
        name: _nameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        latitude: _selectedLat,
        longitude: _selectedLng,
      );
      
      // Show success message
      if (mounted) {
        DialogHelper.showSuccessDialog(
          context: context,
          title: 'Berhasil',
          message: 'Profil berhasil diperbarui',
          buttonText: 'OK',
          onPressed: () {
            Navigator.pop(context); // Close dialog
            Navigator.pop(context, true); // Return to previous page with success result
          },
        );
      }
    } catch (e) {
      print("Error updating profile: $e");
      
      if (mounted) {
        DialogHelper.showErrorDialog(
          context: context,
          title: 'Gagal',
          message: 'Gagal memperbarui profil: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // Koordinat lokasi yang dipilih
  double? _selectedLat;
  double? _selectedLng;
  
  void _openMapPicker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerPage(
          onLocationSelected: (address, lat, lng) {
            setState(() {
              _addressController.text = address;
              _selectedLat = lat;
              _selectedLng = lng;
            });
          },
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: whiteTextStyle.copyWith(fontWeight: medium),
        ),
        backgroundColor: greenColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildFormField({
    required String title,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: blackTextStyle.copyWith(fontWeight: medium)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: blackTextStyle,
          decoration: InputDecoration(
            filled: true,
            fillColor: whiteColor,
            hintText: 'Masukkan $title',
            hintStyle: greyTextStyle,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: greyColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: greenColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: redcolor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: redcolor, width: 2),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}

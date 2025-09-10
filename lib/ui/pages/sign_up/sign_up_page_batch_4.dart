import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/form.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:bank_sha/services/user_service.dart';
import 'package:bank_sha/services/sign_up_service.dart';
import 'package:flutter/material.dart';
import 'package:bank_sha/mixins/app_dialog_mixin.dart';
import 'package:bank_sha/ui/widgets/shared/map_picker.dart';

class SignUpBatch4Page extends StatefulWidget {
  const SignUpBatch4Page({super.key});

  @override
  State<SignUpBatch4Page> createState() => _SignUpBatch4PageState();
}

class _SignUpBatch4PageState extends State<SignUpBatch4Page> with AppDialogMixin {
  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedLocation;
  double? _selectedLat;
  double? _selectedLng;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _openMapPicker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerPage(
          onLocationSelected: (address, lat, lng) {
            setState(() {
              _selectedLocation = address;
              _selectedLat = lat;
              _selectedLng = lng;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Logo Section
                    const SizedBox(height: 60),

                    // Logo GEROBAKS
                    Container(
                      width: 200,
                      height: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      child: Image.asset(
                        'assets/img_gerobakss.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.shopping_cart,
                                color: greenColor,
                                size: 32,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'GEROBAKS',
                                style: greeTextStyle.copyWith(
                                  fontSize: 28,
                                  fontWeight: bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Title
                    Text(
                      'Alamat & Lokasi',
                      style: blackTextStyle.copyWith(
                        fontSize: 24,
                        fontWeight: bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Langkah 4 dari 5 - Informasi Alamat',
                      style: greyTextStyle.copyWith(
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Masukkan alamat dan tandai lokasi tempat tinggal Anda',
                      textAlign: TextAlign.center,
                      style: greyTextStyle.copyWith(
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Progress Indicator
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: greenColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: greenColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: greenColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: greenColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: greyColor.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Address Field
                    CustomFormField(
                      title: 'Alamat Lengkap',
                      keyboardType: TextInputType.streetAddress,
                      controller: _addressController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Alamat tidak boleh kosong';
                        }
                        if (value.length < 10) {
                          return 'Alamat terlalu pendek, minimal 10 karakter';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Location Picker
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedLocation != null ? greenColor : greyColor.withOpacity(0.5),
                          width: _selectedLocation != null ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: _openMapPicker,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: _selectedLocation != null ? greenColor : greyColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Pilih Lokasi di Peta',
                                    style: (_selectedLocation != null ? greeTextStyle : greyTextStyle).copyWith(
                                      fontSize: 14,
                                      fontWeight: semiBold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: greyColor,
                                    size: 16,
                                  ),
                                ],
                              ),
                              if (_selectedLocation != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: greenColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Lokasi Terpilih:',
                                        style: greeTextStyle.copyWith(
                                          fontSize: 12,
                                          fontWeight: semiBold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _selectedLocation!,
                                        style: blackTextStyle.copyWith(
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Lat: ${_selectedLat?.toStringAsFixed(6)}, Lng: ${_selectedLng?.toStringAsFixed(6)}',
                                        style: greyTextStyle.copyWith(
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Tap untuk membuka peta dan pilih lokasi tempat tinggal Anda',
                                  style: greyTextStyle.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    if (_selectedLocation == null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '* Lokasi pada peta wajib dipilih',
                        style: TextStyle(
                          color: redcolor,
                          fontSize: 12,
                        ),
                      ),
                    ],

                    const Spacer(),

                    const SizedBox(height: 30),

                    // Next Button
                    CustomFilledButton(
                      title: 'Lanjutkan',
                      onPressed: () async {
                        if (_formKey.currentState!.validate() && _selectedLocation != null) {
                          // Show loading dialog
                          showAppLoadingDialog(
                            message: 'Mendaftarkan akun Anda...',
                          );
                          
                          try {
                            // Create user data object with all information
                            final userData = {
                              ...?arguments,
                              'address': _selectedLocation ?? _addressController.text,
                              'selectedLocation': _selectedLocation,
                              'latitude': _selectedLat,
                              'longitude': _selectedLng,
                            };
                            
                            // Register the user first using UserService
                            final userService = await UserService.getInstance();
                            await userService.init();
                            
                            // Register user with basic info
                            final user = await userService.registerUser(
                              name: userData['fullName'] ?? userData['name'] ?? 'User',
                              email: userData['email'],
                              password: userData['password'],
                              phone: userData['phone'],
                              address: _selectedLocation ?? _addressController.text,
                              latitude: _selectedLat,
                              longitude: _selectedLng,
                            );
                            
                            // Save location coordinates in user data
                            if (_selectedLat != null && _selectedLng != null) {
                              // Save as a saved address if we have a pinpointed location
                              if (_selectedLocation != null) {
                                List<String> savedAddresses = user.savedAddresses ?? [];
                                if (!savedAddresses.contains(_selectedLocation)) {
                                  savedAddresses.add(_selectedLocation!);
                                  await userService.updateSavedAddresses(savedAddresses);
                                }
                              }
                            }
                            
                            // Mark onboarding complete
                            final signUpService = await SignUpService.getInstance();
                            await signUpService.markOnboardingComplete();
                            
                            // Close loading dialog
                            if (mounted) Navigator.of(context).pop();
                            
                            // Navigate to subscription page with user data
                            if (mounted) {
                              Navigator.pushNamed(
                                context,
                                '/sign-up-subscription',
                                arguments: userData,
                              );
                            }
                          } catch (e) {
                            // Close loading dialog
                            if (mounted) Navigator.of(context).pop();
                            
                            // Show error dialog
                            showAppErrorDialog(
                              title: 'Gagal Mendaftar',
                              message: 'Terjadi kesalahan saat mendaftarkan akun: ${e.toString()}',
                              buttonText: 'Coba Lagi',
                            );
                          }
                        } else if (_selectedLocation == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Silakan pilih lokasi pada peta',
                                style: whiteTextStyle.copyWith(fontSize: 14),
                              ),
                              backgroundColor: redcolor,
                            ),
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    // Sign In Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah punya akun? ',
                          style: greyTextStyle.copyWith(fontSize: 14),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/sign-in');
                          },
                          child: Text(
                            'Sign In',
                            style: greeTextStyle.copyWith(
                              fontSize: 14,
                              fontWeight: semiBold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Map Picker Page

import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/form.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:bank_sha/ui/widgets/shared/layout.dart';
import 'package:flutter/material.dart';

class SignUpBatch1Page extends StatefulWidget {
  const SignUpBatch1Page({super.key});

  @override
  State<SignUpBatch1Page> createState() => _SignUpBatch1PageState();
}

class _SignUpBatch1PageState extends State<SignUpBatch1Page> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26.0),
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
                      width: 250,
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
                      'Daftar Akun Baru',
                      style: blackTextStyle.copyWith(
                        fontSize: 24,
                        fontWeight: bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Langkah 1 dari 5 - Data Pribadi',
                      style: greyTextStyle.copyWith(fontSize: 14),
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
                              color: greyColor.withOpacity(0.3),
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

                    // Google Sign Up Button
                    CustomGoogleSignInButton(
                      title: 'Sign Up With Google',
                      onPressed: () {},
                    ),

                    const SizedBox(height: 24),

                    // OR Divider
                    const CustomDividerLayout(title: 'OR'),

                    const SizedBox(height: 24),

                    // Form Fields
                    CustomFormField(
                      title: 'Full Name',
                      keyboardType: TextInputType.name,
                      controller: _fullNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama lengkap tidak boleh kosong';
                        }
                        if (value.length < 2) {
                          return 'Nama lengkap minimal 2 karakter';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    CustomFormField(
                      title: 'Email Address',
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    CustomFormField(
                      title: 'Nomor Handphone',
                      keyboardType: TextInputType.phone,
                      controller: _phoneController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nomor handphone tidak boleh kosong';
                        }
                        if (value.length < 10) {
                          return 'Nomor handphone minimal 10 digit';
                        }
                        return null;
                      },
                    ),

                    const Spacer(),

                    const SizedBox(height: 30),

                    // Next Button
                    CustomFilledButton(
                      title: 'Lanjutkan',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Langsung ke batch 3 (lewati verifikasi OTP)
                          Navigator.pushNamed(
                            context,
                            '/sign-up-batch-3',
                            arguments: {
                              'fullName': _fullNameController.text,
                              'email': _emailController.text,
                              'phone': _phoneController.text,
                              // Tambahkan dummy otpCode untuk kompatibilitas
                              'otpCode': 'skip_verification',
                            },
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

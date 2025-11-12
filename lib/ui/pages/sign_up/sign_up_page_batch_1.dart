import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/form.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:bank_sha/ui/widgets/shared/layout.dart';
import 'package:bank_sha/services/auth_api_service.dart';
import 'package:bank_sha/mixins/app_dialog_mixin.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SignUpBatch1Page extends StatefulWidget {
  const SignUpBatch1Page({super.key});

  @override
  State<SignUpBatch1Page> createState() => _SignUpBatch1PageState();
}

class _SignUpBatch1PageState extends State<SignUpBatch1Page>
    with AppDialogMixin {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isChecking = false;
  bool _isCheckingRealtime = false;
  bool?
  _isEmailAvailable; // null = not checked, true = available, false = taken
  String? _emailCheckMessage;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Listen to email changes for realtime validation
    _emailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _emailController.removeListener(_onEmailChanged);
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Reset state when email changes
    setState(() {
      _isEmailAvailable = null;
      _emailCheckMessage = null;
    });

    // Only check if email format is valid
    final email = _emailController.text;
    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      return;
    }

    // Debounce: wait 800ms after user stops typing
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _checkEmailRealtime();
    });
  }

  Future<void> _checkEmailRealtime() async {
    final email = _emailController.text;
    if (email.isEmpty) return;

    setState(() {
      _isCheckingRealtime = true;
    });

    try {
      final authApiService = AuthApiService();
      final response = await authApiService.checkEmail(email);

      if (!mounted) return;

      setState(() {
        _isEmailAvailable = !(response['exists'] as bool);
        _emailCheckMessage = response['message'] as String?;
        _isCheckingRealtime = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isEmailAvailable = null;
        _emailCheckMessage = 'Gagal memeriksa email';
        _isCheckingRealtime = false;
      });
    }
  }

  Future<void> _checkEmailAndContinue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isChecking = true;
    });

    try {
      final authApiService = AuthApiService();

      // Check if email already exists
      final response = await authApiService.checkEmail(_emailController.text);

      if (!mounted) return;

      // If email exists, show error
      if (response['exists'] == true) {
        showAppErrorDialog(
          title: 'Email Sudah Terdaftar',
          message:
              'Email ${_emailController.text} sudah terdaftar. Silakan gunakan email lain atau login.',
          buttonText: 'OK',
        );
        return;
      }

      // If email doesn't exist, continue to next step
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/sign-up-batch-2',
          arguments: {
            'fullName': _fullNameController.text,
            'email': _emailController.text,
            'phone': _phoneController.text,
          },
        );
      }
    } catch (e) {
      if (!mounted) return;

      // If error checking email (e.g., no internet), still allow to continue
      // The final check will be done at registration
      print('Error checking email: $e');

      Navigator.pushNamed(
        context,
        '/sign-up-batch-2',
        arguments: {
          'fullName': _fullNameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
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
                                style: greenTextStyle.copyWith(
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

                    // Email Field with Realtime Validation
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomFormField(
                          title: 'Email Address',
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          suffixIcon: _isCheckingRealtime
                              ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : _isEmailAvailable == true
                              ? Icon(Icons.check_circle, color: greenColor)
                              : _isEmailAvailable == false
                              ? const Icon(Icons.error, color: Colors.red)
                              : null,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email tidak boleh kosong';
                            }
                            if (!RegExp(
                              r'^[^@]+@[^@]+\.[^@]+',
                            ).hasMatch(value)) {
                              return 'Format email tidak valid';
                            }
                            // Check email availability (prevent submit if not available)
                            if (_isEmailAvailable == false) {
                              return ''; // Return empty string to prevent submit without duplicate message
                            }
                            return null;
                          },
                        ),
                        if (_emailCheckMessage != null &&
                            _emailCheckMessage!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                            child: Row(
                              children: [
                                Icon(
                                  _isEmailAvailable == true
                                      ? Icons.check_circle
                                      : Icons.info,
                                  size: 16,
                                  color: _isEmailAvailable == true
                                      ? greenColor
                                      : _isEmailAvailable == false
                                      ? Colors.red
                                      : Colors.orange,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _emailCheckMessage!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _isEmailAvailable == true
                                          ? greenColor
                                          : _isEmailAvailable == false
                                          ? Colors.red
                                          : Colors.orange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
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
                      showIcon: true,
                      icon: Icons.arrow_forward,
                      isLoading: _isChecking,
                      onPressed: _checkEmailAndContinue,
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
                            style: greenTextStyle.copyWith(
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

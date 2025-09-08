import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/form.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:flutter/material.dart';

class SignUpBatch3Page extends StatefulWidget {
  const SignUpBatch3Page({super.key});

  @override
  State<SignUpBatch3Page> createState() => _SignUpBatch3PageState();
}

class _SignUpBatch3PageState extends State<SignUpBatch3Page> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  final bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Method untuk handle perubahan pada password field
  void _onPasswordChanged(String value) {
    setState(() {}); // Rebuild untuk update requirements
  }

  bool _isPasswordStrong(String password) {
    // Check if password meets criteria
    bool hasMinLength = password.length >= 8;
    bool hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowerCase = password.contains(RegExp(r'[a-z]'));
    bool hasNumber = password.contains(RegExp(r'[0-9]'));

    return hasMinLength && hasUpperCase && hasLowerCase && hasNumber;
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

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
                      'Buat Password',
                      style: blackTextStyle.copyWith(
                        fontSize: 24,
                        fontWeight: bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Langkah 3 dari 5 - Keamanan Akun',
                      style: greyTextStyle.copyWith(fontSize: 14),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Buat password yang kuat untuk mengamankan akun Anda',
                      textAlign: TextAlign.center,
                      style: greyTextStyle.copyWith(fontSize: 14),
                    ),

                    const SizedBox(height: 30),

                    // Progress Indicator - Step 3 of 5
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

                    // Password Requirements
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: greyColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: greyColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password harus mengandung:',
                            style: blackTextStyle.copyWith(
                              fontSize: 14,
                              fontWeight: semiBold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildRequirement(
                            'Minimal 8 karakter',
                            _passwordController.text.length >= 8,
                          ),
                          _buildRequirement(
                            'Huruf besar (A-Z)',
                            _passwordController.text.contains(RegExp(r'[A-Z]')),
                          ),
                          _buildRequirement(
                            'Huruf kecil (a-z)',
                            _passwordController.text.contains(RegExp(r'[a-z]')),
                          ),
                          _buildRequirement(
                            'Angka (0-9)',
                            _passwordController.text.contains(RegExp(r'[0-9]')),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Password Field - Custom implementation to handle onChanged
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Password',
                          style: blackTextStyle.copyWith(
                            fontSize: 14,
                            fontWeight: medium,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          style: blackTextStyle.copyWith(fontSize: 14),
                          onChanged: _onPasswordChanged,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password tidak boleh kosong';
                            }
                            if (!_isPasswordStrong(value)) {
                              return 'Password tidak memenuhi syarat';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Masukkan password',
                            hintStyle: greyTextStyle.copyWith(fontSize: 14),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: greyColor,
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: greyColor,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: lightBackgroundColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: greyColor.withOpacity(0.3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: greyColor.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: greenColor,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: redcolor, width: 1),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: redcolor, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            isDense: true,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Confirm Password Field
                    CustomFormField(
                      title: 'Konfirmasi Password',
                      obscureText: !_isConfirmPasswordVisible,
                      controller: _confirmPasswordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Konfirmasi password tidak boleh kosong';
                        }
                        if (value != _passwordController.text) {
                          return 'Password tidak cocok';
                        }
                        return null;
                      },
                    ),

                    const Spacer(),

                    const SizedBox(height: 30),

                    // Continue Button
                    CustomFilledButton(
                      title: 'Lanjutkan',
                      showIcon: true,
                      icon: Icons.arrow_forward,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Navigate to batch 4 with all previous data plus password
                          Navigator.pushNamed(
                            context,
                            '/sign-up-batch-4',
                            arguments: {
                              ...?arguments,
                              'password': _passwordController.text,
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

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isMet ? greenColor : greyColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? greenColor : greyColor,
              fontWeight: isMet ? semiBold : regular,
            ),
          ),
        ],
      ),
    );
  }
}

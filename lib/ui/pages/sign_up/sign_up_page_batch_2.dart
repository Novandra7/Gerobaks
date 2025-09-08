import 'package:bank_sha/shared/theme.dart';
<<<<<<< HEAD
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:bank_sha/ui/widgets/shared/layout.dart';
<<<<<<< HEAD
import 'package:bank_sha/utils/toast_helper.dart';
=======
>>>>>>> 02b957d (feat: adding & improve sign up)
=======
>>>>>>> fef3eca6e643bc33c01547823ba332b867597d34
import 'package:flutter/material.dart';

class SignUpBatch2Page extends StatefulWidget {
  const SignUpBatch2Page({super.key});

  @override
  State<SignUpBatch2Page> createState() => _SignUpBatch2PageState();
}

class _SignUpBatch2PageState extends State<SignUpBatch2Page> {
  @override
  void initState() {
    super.initState();
    
    // Tunggu sejenak kemudian lanjut ke langkah berikutnya
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        if (arguments != null) {
          // Lanjut ke batch 3 dengan data yang sama dan OTP dummy
          Navigator.pushReplacementNamed(
            context,
            '/sign-up-batch-3',
            arguments: {
              ...arguments,
              'otpCode': 'skip_verification', // Tambahkan dummy OTP untuk kompatibilitas
            },
          );
        } else {
          // Jika tidak ada data, kembali ke langkah 1
          Navigator.pushReplacementNamed(context, '/sign-up-batch-1');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
<<<<<<< HEAD
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
              child: Column(
                children: [

                  // Logo Section with proper spacing
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
                    'Verifikasi OTP',
                    style: blackTextStyle.copyWith(
                      fontSize: 24,
                      fontWeight: bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Langkah 2 dari 5 - Konfirmasi Nomor HP',
                    style: greyTextStyle.copyWith(
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Masukkan kode OTP yang dikirim ke\n$phone',
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

                  const SizedBox(height: 40),

                  // OTP Input Fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 45,
                        height: 50,
                        child: TextField(
                          controller: _otpControllers[index],
                          focusNode: _otpFocusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: greyColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: greenColor, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: greyColor.withOpacity(0.5)),
                            ),
                          ),
                          style: blackTextStyle.copyWith(
                            fontSize: 18,
                            fontWeight: semiBold,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 5) {
                              _otpFocusNodes[index + 1].requestFocus();
                            } else if (value.isEmpty && index > 0) {
                              _otpFocusNodes[index - 1].requestFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 30),

                  // Timer and Resend
                  if (!_canResend)
                    Text(
                      'Kirim ulang OTP dalam $_formattedTime',
                      style: greyTextStyle.copyWith(fontSize: 14),
                    )
                  else
                    TextButton(
                      onPressed: () {
                        _startTimer();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Kode OTP telah dikirim ulang',
                              style: whiteTextStyle.copyWith(fontSize: 14),
                            ),
                            backgroundColor: greenColor,
                          ),
                        );
                      },
                      child: Text(
                        'Kirim Ulang OTP',
                        style: greeTextStyle.copyWith(
                          fontSize: 14,
                          fontWeight: semiBold,
                        ),
                      ),
                    ),

                  const Spacer(),

                  const SizedBox(height: 30),

                  // Verify Button
                  CustomFilledButton(
                    title: 'Verifikasi',
                    onPressed: () {
                      String otpCode = _otpControllers
                          .map((controller) => controller.text)
                          .join();

                      if (otpCode.length != 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Masukkan kode OTP lengkap',
                              style: whiteTextStyle.copyWith(fontSize: 14),
                            ),
                            backgroundColor: redcolor,
                          ),
                        );
                        return;
                      }

                      // Pass all data to next page
                      Navigator.pushNamed(
                        context,
                        '/sign-up-batch-3',
                        arguments: {
                          ...?arguments,
                          'otpCode': otpCode,
                        },
                      );
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
=======
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(greenColor),
>>>>>>> fef3eca6e643bc33c01547823ba332b867597d34
              ),
              const SizedBox(height: 24),
              Text(
                'Melanjutkan ke langkah berikutnya...',
                style: blackTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: medium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
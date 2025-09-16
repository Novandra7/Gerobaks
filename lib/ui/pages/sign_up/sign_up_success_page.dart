import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:bank_sha/services/notification_service.dart';
import 'package:bank_sha/utils/toast_helper.dart';
import 'package:bank_sha/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:bank_sha/mixins/app_dialog_mixin.dart';

class SignUpSuccessPage extends StatefulWidget {
  const SignUpSuccessPage({super.key});

  @override
  State<SignUpSuccessPage> createState() => _SignUpSuccessPageState();
}

class _SignUpSuccessPageState extends State<SignUpSuccessPage> with AppDialogMixin {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: uicolor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Akun Berhasil\nTerdaftar',
              style: blackTextStyle.copyWith(
                fontWeight: semiBold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 26),
            Text(
              'Bersih bareng, Hijau bareng,\nMulai bareng kami.',
              style: greyTextStyle.copyWith(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: greenColor.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded, color: greenColor, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    '+15 Poin',
                    style: greenTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: semiBold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Anda mendapatkan 15 poin awal!',
              style: blackTextStyle.copyWith(fontWeight: medium),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            _isLoading
                ? const CircularProgressIndicator()
                : CustomFilledButton(
                    title: 'Mulai',
                    width: 183,
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });

                      try {
                        // Get user data from arguments
                        final args =
                            ModalRoute.of(context)!.settings.arguments
                                as Map<String, dynamic>?;
                        if (args == null ||
                            !args.containsKey('email') ||
                            !args.containsKey('password')) {
                          throw Exception('Data registrasi tidak lengkap');
                        }

                        // The user is already registered in batch 4 page
                        
                        final userService = await UserService.getInstance();
                        await userService.init();
                        
                        // Get current user
                        final user = await userService.getCurrentUser();
                        
                        print("In sign-up success page for: ${args['email']}");
                        
                        if (user == null) {
                          print("User not found in sign-up success page, attempting login");
                          
                          // Try logging in with provided credentials
                          final loggedInUser = await userService.loginUser(
                            email: args['email'],
                            password: args['password'],
                          );
                          
                          if (loggedInUser == null) {
                            throw Exception('Gagal login, akun tidak ditemukan');
                          }
                          
                          print("Login successful for: ${loggedInUser.name}");
                        } else {
                          print("User found: ${user.name} (${user.email})");
                        }
                        
                        // Update subscription status if needed
                        final bool hasSubscription = args['hasSubscription'] ?? false;
                        if (hasSubscription) {
                          // In a real app, you would update subscription status
                          print('User ${args['email']} has subscription: $hasSubscription');
                        }

                        // Show notification and toast
                        await NotificationService().showNotification(
                          id: DateTime.now().millisecond,
                          title: 'Selamat Bergabung!',
                          body:
                              'Akun Anda telah berhasil terdaftar di Gerobaks dengan 15 poin',
                        );

                        if (mounted) {
                          // Show custom success dialog
                          showAppSuccessDialog(
                            title: 'Registrasi Berhasil',
                            message: 'Akun Anda telah berhasil terdaftar di Gerobaks dengan 15 poin bonus. Silakan login untuk melanjutkan.',
                            buttonText: 'Login Sekarang',
                          );

                          // Navigate to sign in with credentials
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/sign-in',
                            (route) => false,
                            arguments: {
                              'email': args['email'],
                              'password': args['password'],
                            },
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ToastHelper.showToast(
                            context: context,
                            message: 'Error: ${e.toString()}',
                            isSuccess: false,
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

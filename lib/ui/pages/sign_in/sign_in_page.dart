import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/services/auth_api_service.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/form.dart';
import 'package:bank_sha/ui/widgets/shared/layout.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:bank_sha/utils/toast_helper.dart';
import 'package:bank_sha/services/notification_service.dart';
import 'package:bank_sha/services/user_service.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  UserService? _userService;

  @override
  void initState() {
    super.initState();
    _initializeServices();

    // Handle auto-fill credentials from sign up
    Future.delayed(Duration.zero, () {
      if (!mounted) return;

      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null &&
          args.containsKey('email') &&
          args.containsKey('password')) {
        setState(() {
          _emailController.text = args['email'];
          _passwordController.text = args['password'];
        });

        // Show auto-fill notification
        ToastHelper.showToast(
          context: context,
          message: 'Kredensial login telah diisi otomatis',
          isSuccess: true,
        );
      }
    });
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize API auth service
      final authService = AuthApiService();

      // Check for valid token
      final token = await authService.getToken();
      final isLoggedIn = token != null && token.isNotEmpty;

      if (isLoggedIn && mounted) {
        try {
          // Get user data from API
          final userData = await authService.me();

          // For backward compatibility
          final localStorage = await LocalStorageService.getInstance();
          await localStorage.saveUserData(userData);

          // Navigate based on role
          if (userData['role'] == 'mitra') {
            Navigator.pushReplacementNamed(context, '/mitra-dashboard-new');
          } else {
            // Default to end_user dashboard
            Navigator.pushReplacementNamed(context, '/home');
          }
        } catch (e) {
          print("Error getting user data: $e");
          // Token might be invalid, clear it
          await authService.logout();
        }
      } else {
        // For backward compatibility
        _userService = await UserService.getInstance();
        await _userService!.init();
      }
    } catch (e) {
      print("Error initializing services: $e");
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handle sign in
  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create API service instance
      final authService = AuthApiService();

      // Attempt login using the API service
      final userData = await authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      print(
        "Login successful via API for: ${userData['name']} (${userData['email']}) with role: ${userData['role']}",
      );

      // For backward compatibility - update local storage
      final localStorage = await LocalStorageService.getInstance();

      // Pastikan role tersimpan dengan benar
      if (!userData.containsKey('role')) {
        print(
          "WARNING: Role not found in user data from API, adding default role",
        );
        userData['role'] = 'end_user';
      }

      // Simpan data user dengan role yang benar untuk backward compatibility
      await localStorage.saveUserData(userData);
      print("User data saved with role: ${userData['role']}");

      // Set flag login = true for backward compatibility
      await localStorage.saveBool(localStorage.getLoginKey(), true);

      // Simpan kredensial untuk auto-login berikutnya
      await localStorage.saveCredentials(
        _emailController.text,
        _passwordController.text,
      );
      print("Credentials saved for future auto-login");

      // Menampilkan notifikasi login berhasil
      await NotificationService().showNotification(
        id: DateTime.now().millisecond,
        title: 'Login Berhasil',
        body: 'Selamat datang di Gerobaks, ${userData['name']}!',
      );

      // Menampilkan toast login berhasil
      if (mounted) {
        String message = 'Login berhasil! ';
        if (userData['role'] == 'end_user') {
          message += userData['points'] != null
              ? 'Poin Anda: ${userData['points']}'
              : 'Selamat datang!';
        } else {
          message += 'Selamat bekerja, Mitra!';
        }

        ToastHelper.showToast(
          context: context,
          message: message,
          isSuccess: true,
        );

        // Navigate based on role
        if (userData['role'] == 'mitra') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/mitra-dashboard-new',
            (route) => false,
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      }
    } catch (e) {
      print("Login failed for: ${_emailController.text} - Error: $e");

      if (mounted) {
        ToastHelper.showToast(
          context: context,
          message: 'Email atau password salah: ${e.toString()}',
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
  }

  @override
  Widget build(BuildContext context) {
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
              child: Column(
                children: [
                  // Logo Section dengan spacing yang tepat
                  const SizedBox(height: 80),

                  // Logo GEROBAKS dengan fallback
                  Container(
                    width: 250,
                    height: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    child: Image.asset(
                      'assets/img_gerobakss.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback jika asset tidak ditemukan
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

                  const SizedBox(height: 60),

                  // Google Sign In Button - menggunakan CustomGoogleSignInButton
                  CustomGoogleSignInButton(
                    title: 'Log in dengan Google',
                    onPressed: () {
                      // Handle Google Sign In
                    },
                  ),

                  const SizedBox(height: 24),

                  // OR Divider
                  const CustomDividerLayout(title: 'Or'),

                  const SizedBox(height: 24),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email Input menggunakan CustomFormField
                        CustomFormField(
                          title: 'Email Address',
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

                        // Password Input menggunakan CustomFormField
                        CustomFormField(
                          title: 'Password',
                          controller: _passwordController,
                          obscureText:
                              true, // Gunakan default password handling dari CustomFormField
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password tidak boleh kosong';
                            }
                            if (value.length < 6) {
                              return 'Password minimal 6 karakter';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Lupa Password?',
                        style: greentextstyle2.copyWith(
                          fontSize: 14,
                          fontWeight: regular,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sign In Button with loading state
                  _isLoading
                      ? const CircularProgressIndicator()
                      : CustomFilledButton(
                          title: 'Sign In',
                          height: 48,
                          onPressed: _handleSignIn,
                        ),

                  const SizedBox(height: 12),

                  // Sign Up Nav
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun? ',
                        style: greyTextStyle.copyWith(fontSize: 14),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/sign-up-batch-1');
                        },
                        child: Text(
                          'Sign Up',
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
    );
  }
}

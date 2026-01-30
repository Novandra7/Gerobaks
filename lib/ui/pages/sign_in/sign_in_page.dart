import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/services/auth_api_service.dart';
// import 'package:bank_sha/services/global_notification_polling_service.dart'; // ❌ DISABLED - see FIX_DOUBLE_NOTIFICATION_POPUP.md
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/form.dart';
import 'package:bank_sha/ui/widgets/shared/layout.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:bank_sha/utils/toast_helper.dart';
import 'package:bank_sha/utils/app_config.dart';
import 'package:bank_sha/utils/api_routes.dart';
import 'package:bank_sha/services/notification_service.dart';
import 'package:bank_sha/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bank_sha/blocs/blocs.dart';

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

          // Normalize field names dari backend (user_phone → phone)
          if (userData.containsKey('user_phone')) {
            userData['phone'] = userData['user_phone'];
          }
          if (userData.containsKey('user_address')) {
            userData['address'] = userData['user_address'];
          }

          // Get existing user data from localStorage to preserve phone/address
          final existingData = await localStorage.getUserData();

          // Merge: API data (newer) + existing localStorage data (preserve phone/address)
          if (existingData != null) {
            // Preserve phone and address from localStorage if not in API response
            if (!userData.containsKey('phone') || userData['phone'] == null) {
              userData['phone'] = existingData['phone'];
            }
            if (!userData.containsKey('address') ||
                userData['address'] == null) {
              userData['address'] = existingData['address'];
            }
            if (!userData.containsKey('latitude') ||
                userData['latitude'] == null) {
              userData['latitude'] = existingData['latitude'];
            }
            if (!userData.containsKey('longitude') ||
                userData['longitude'] == null) {
              userData['longitude'] = existingData['longitude'];
            }
          }

          // Pastikan role tersimpan dengan benar
          if (!userData.containsKey('role') || userData['role'] == null) {
            userData['role'] = 'end_user';
          }

          // Memastikan role valid
          String role = userData['role'];
          if (role != 'end_user' && role != 'mitra') {
            userData['role'] = 'end_user';
            role = 'end_user';
          }

          // Simpan data user dengan role yang benar
          await localStorage.saveUserData(userData);

          // Double-check user role setelah disimpan
          final savedRole = await localStorage.getUserRole();

          if (savedRole != role) {
            // Force resave with correct role
            userData['role'] = role;
            await localStorage.saveUserData(userData);
          }

          // Navigate based on role
          if (role == 'mitra') {
            Navigator.pushReplacementNamed(context, '/mitra-dashboard-new');
          } else {
            // Default to end_user dashboard

            // ❌ DISABLED: Polling service (menyebabkan duplicate popup)
            // FCM push notification sudah handle popup, tidak perlu polling
            // See: FIX_DOUBLE_NOTIFICATION_POPUP.md
            // try {
            //   final GlobalNotificationPollingService notificationService =
            //       GlobalNotificationPollingService();
            //   await notificationService.startPolling();
            //   print('✅ Global notification polling started (auto-login)');
            // } catch (e) {
            //   print('⚠️ Failed to start notification polling (auto-login): $e');
            // }

            Navigator.pushReplacementNamed(context, '/home');
          }
        } catch (e) {
          // Token might be invalid, clear it
          await authService.logout();
        }
      } else {
        // For backward compatibility
        _userService = await UserService.getInstance();
        await _userService!.init();
      }
    } catch (e) {
      // Handle initialization errors
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showDemoCredentials() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Kredensial Demo',
          style: blackTextStyle.copyWith(fontSize: 18, fontWeight: semiBold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Gunakan kredensial berikut untuk login:'),
            const SizedBox(height: 16),
            _buildCredentialCard('User Biasa', 'user@example.com', 'password'),
            const SizedBox(height: 12),
            _buildCredentialCard('Mitra', 'mitra@example.com', 'password'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Tutup', style: blueTextStyle),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialCard(String title, String email, String password) {
    return Card(
      color: lightBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: blackTextStyle.copyWith(
                fontWeight: semiBold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Email: ',
                  style: blackTextStyle.copyWith(fontWeight: semiBold),
                ),
                Text(email, style: blackTextStyle),
                IconButton(
                  icon: Icon(Icons.copy, size: 18, color: greyColor),
                  onPressed: () {
                    _emailController.text = email;
                    Navigator.pop(context);
                  },
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'Password: ',
                  style: blackTextStyle.copyWith(fontWeight: semiBold),
                ),
                Text(password, style: blackTextStyle),
                IconButton(
                  icon: Icon(Icons.copy, size: 18, color: greyColor),
                  onPressed: () {
                    _passwordController.text = password;
                    Navigator.pop(context);
                  },
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

      // For backward compatibility - update local storage
      final localStorage = await LocalStorageService.getInstance();

      // Normalize field names dari backend (user_phone → phone)
      if (userData.containsKey('user_phone')) {
        userData['phone'] = userData['user_phone'];
      }
      if (userData.containsKey('user_address')) {
        userData['address'] = userData['user_address'];
      }

      // Get existing user data from localStorage to preserve phone/address
      final existingData = await localStorage.getUserData();

      // Merge: API data (newer) + existing localStorage data (preserve phone/address)
      if (existingData != null) {
        // Preserve phone and address from localStorage if not in API response
        if (!userData.containsKey('phone') || userData['phone'] == null) {
          userData['phone'] = existingData['phone'];
        }
        if (!userData.containsKey('address') || userData['address'] == null) {
          userData['address'] = existingData['address'];
        }
        if (!userData.containsKey('latitude') || userData['latitude'] == null) {
          userData['latitude'] = existingData['latitude'];
        }
        if (!userData.containsKey('longitude') ||
            userData['longitude'] == null) {
          userData['longitude'] = existingData['longitude'];
        }
      }

      // Pastikan role tersimpan dengan benar
      if (!userData.containsKey('role')) {
        userData['role'] = 'end_user';
      }

      // Print role untuk debugging

      // Pastikan semua field yang diperlukan ada
      if (!userData.containsKey('name')) {}

      if (!userData.containsKey('email')) {}

      // Simpan data user dengan role yang benar untuk backward compatibility
      await localStorage.saveUserData(userData);

      // Set flag login = true for backward compatibility
      await localStorage.saveBool(localStorage.getLoginKey(), true);

      // Simpan kredensial untuk auto-login berikutnya
      await localStorage.saveCredentials(
        _emailController.text,
        _passwordController.text,
      );

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

        // Navigasi berdasarkan role dengan validasi yang lebih baik
        String userRole = userData['role'] ?? 'end_user';

        // Validasi dan normalisasi role
        if (!['end_user', 'mitra', 'admin'].contains(userRole)) {
          userRole = 'end_user';
          userData['role'] = userRole;
          await localStorage.saveUserData(userData);
        }

        // Navigate berdasarkan role
        switch (userRole) {
          case 'mitra':
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/mitra-dashboard-new',
              (route) => false,
            );
            break;
          case 'admin':
            // Untuk sementara redirect ke mitra dashboard, bisa diganti nanti
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/mitra-dashboard-new',
              (route) => false,
            );
            break;
          case 'end_user':
          default:

            // ❌ DISABLED: Polling service (menyebabkan duplicate popup)
            // FCM push notification sudah handle popup, tidak perlu polling
            // See: FIX_DOUBLE_NOTIFICATION_POPUP.md
            // try {
            //   final GlobalNotificationPollingService notificationService =
            //       GlobalNotificationPollingService();
            //   await notificationService.startPolling();
            //   print('✅ Global notification polling started for end_user');
            // } catch (e) {
            //   print('⚠️ Failed to start notification polling: $e');
            // }

            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
            break;
        }
      }
    } catch (e) {
      if (mounted) {
        // More user-friendly error message
        String errorMessage = 'Email atau password salah';

        if (e.toString().contains('NotInitializedError')) {
          errorMessage = 'Koneksi server gagal. Silakan coba lagi.';
        } else if (e.toString().contains('Connection refused')) {
          errorMessage =
              'Server tidak dapat dijangkau. Pastikan server berjalan.';
        } else if (e.toString().contains('Http status error [404]')) {
          errorMessage =
              'Endpoint API tidak ditemukan. Periksa konfigurasi API.';
        } else if (e.toString().contains('TimeoutException')) {
          errorMessage = 'Koneksi ke server timeout. Periksa jaringan Anda.';
        }

        ToastHelper.showToast(
          context: context,
          message: errorMessage,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Lupa Password?',
                          style: greentextstyle2.copyWith(
                            fontSize: 14,
                            fontWeight: regular,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Demo credentials button
                  Center(
                    child: TextButton(
                      onPressed: () {
                        _showDemoCredentials();
                      },
                      child: Text(
                        'Gunakan Kredensial Demo',
                        style: blueTextStyle.copyWith(
                          fontSize: 14,
                          fontWeight: medium,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

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

                  const SizedBox(height: 24),

                  // Demo Credentials Button
                  TextButton(
                    onPressed: () {
                      _showDemoCredentials();
                    },
                    child: Text(
                      'Gunakan Demo Credentials',
                      style: blueTextStyle.copyWith(fontSize: 12),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

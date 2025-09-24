import 'package:bank_sha/ui/pages/end_user/buat_keluhan/buat_keluhan_page.dart';
import 'package:bank_sha/ui/pages/end_user/buat_keluhan/golden_keluhan_pages.dart';
import 'package:bank_sha/ui/pages/end_user/profile/List/about_us.dart';
import 'package:bank_sha/ui/pages/end_user/reward/reward_page.dart';
import 'package:bank_sha/ui/pages/end_user/tracking/tracking_full_screen.dart';
import 'package:bank_sha/ui/pages/end_user/wilayah/wilayah_full_screen.dart';
import 'package:bank_sha/ui/pages/end_user/wilayah/wilayah_page.dart';
import 'package:bank_sha/ui/pages/end_user/chat/chat_list_page.dart';
import 'package:bank_sha/ui/pages/end_user/subscription/subscription_plans_page.dart';
import 'package:bank_sha/ui/pages/end_user/subscription/my_subscription_page.dart';
import 'package:bank_sha/ui/pages/end_user/payment/qris_payment_page.dart';
import 'package:bank_sha/ui/pages/end_user/payment/payment_success_page.dart';
import 'package:bank_sha/ui/pages/end_user/payment/payment_timeout_page.dart';
import 'package:bank_sha/ui/pages/end_user/payment/checkout_page.dart';
import 'package:bank_sha/ui/pages/end_user/payment/payment_methods_page.dart';
import 'package:bank_sha/ui/pages/mitra/dashboard/mitra_dashboard_page.dart';
import 'package:bank_sha/ui/pages/mitra/dashboard/mitra_dashboard_page_new.dart';
import 'package:bank_sha/ui/pages/mitra/lokasi/mitra_lokasi_page.dart';
import 'package:bank_sha/ui/pages/mitra/pengambilan/navigation_page_improved.dart';
import 'package:bank_sha/ui/pages/mitra/pengambilan/navigation_page_redesigned.dart';
import 'package:bank_sha/ui/pages/mitra/pengambilan/navigation_demo_page.dart';
import 'package:bank_sha/blocs/tracking/tracking_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bank_sha/ui/pages/user/schedule/create_schedule_page.dart';
import 'package:bank_sha/ui/pages/user/schedule/user_schedules_page_updated.dart';
import 'package:bank_sha/services/notification_service.dart';
import 'package:bank_sha/services/otp_service.dart';
import 'package:bank_sha/utils/pantun_helper.dart';
import 'package:bank_sha/utils/navigation_helper.dart';
import 'package:bank_sha/utils/debug_helper.dart';
import 'package:bank_sha/services/tile_provider_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:bank_sha/ui/pages/end_user/home/home_page.dart';
import 'package:bank_sha/ui/pages/end_user/tracking/tracking_page.dart';
import 'package:bank_sha/ui/pages/end_user/noftification_page.dart';
import 'package:bank_sha/ui/pages/splash_onboard/onboarding_page.dart';
import 'package:bank_sha/ui/pages/sign_in/sign_in_page.dart';
import 'package:bank_sha/ui/pages/sign_up/sign_up_success_page.dart';
import 'package:bank_sha/ui/pages/sign_up/sign_up_uplod_profile_page.dart';
import 'package:bank_sha/ui/pages/sign_up/sign_up_page_batch_1.dart';
import 'package:bank_sha/ui/pages/sign_up/sign_up_page_batch_2.dart';
import 'package:bank_sha/ui/pages/sign_up/sign_up_page_batch_3.dart';
import 'package:bank_sha/ui/pages/sign_up/sign_up_page_batch_4.dart';
import 'package:bank_sha/ui/pages/sign_up/sign_up_subscription_page.dart';
import 'package:bank_sha/ui/pages/splash_onboard/splash_page.dart';
import 'package:bank_sha/ui/pages/end_user/tambah_jadwal_page.dart';

import 'package:bank_sha/services/gemini_ai_service.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/services/subscription_service.dart';
import 'package:bank_sha/services/user_service.dart';
import 'package:bank_sha/controllers/profile_controller.dart';

Future<void> main() async {
  try {
    // Ensure Flutter is initialized before doing anything
    WidgetsFlutterBinding.ensureInitialized();

    // Debug console test
    print('===== DEBUG CONSOLE TEST =====');
    print('If you see this message in the debug console, it is working!');
    print('==============================');

    // Use our debug helper
    DebugHelper.testDebugConsole();

    // Menangani error global
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      print('Uncaught Flutter error: ${details.exception}');
      print('Stack trace: ${details.stack}');
    };

    await dotenv.load();
    await initializeDateFormatting('id_ID', null);

    // Inisialisasi LocalStorage Service
    try {
      await LocalStorageService.getInstance();
      print("LocalStorage berhasil diinisialisasi");

      // Inisialisasi SubscriptionService setelah LocalStorage
      await SubscriptionService().initialize();
      print("SubscriptionService berhasil diinisialisasi");

      // Initialize User Service and Profile Controller
      final userService = await UserService.getInstance();
      await userService.init();
      print("UserService berhasil diinisialisasi");

      // Initialize Profile Controller
      final profileController = await ProfileController.getInstance();
      await profileController.init();
      print("ProfileController berhasil diinisialisasi");
    } catch (e) {
      print("Error saat inisialisasi services: $e");
    }

    // Inisialisasi layanan notifikasi secara eksplisit
    try {
      await NotificationService().initialize();
      print("Notifikasi berhasil diinisialisasi");

      // Pastikan notifikasi pantun berjalan
      try {
        await fixPantunNotifications();
        print("Pantun notifications berhasil diperbaiki");
      } catch (e) {
        print("Error saat memperbaiki pantun notifications: $e");
      }
    } catch (e) {
      print("Error saat inisialisasi notifikasi: $e");
    }

    // Inisialisasi layanan OTP
    try {
      await OTPService().initialize();
      print("OTP Service berhasil diinisialisasi");
    } catch (e) {
      print("Error saat inisialisasi OTP Service: $e");
    }

    // Inisialisasi layanan AI Gemini
    try {
      await GeminiAIService().initialize();
      print("Gemini AI berhasil diinisialisasi");
    } catch (e) {
      print("Error saat inisialisasi Gemini AI: $e");
    }

    // Initialize the tile provider service for maps
    try {
      await TileProviderService().initialize();
      print("Tile Provider Service berhasil diinisialisasi");
    } catch (e) {
      print("Error saat inisialisasi Tile Provider Service: $e");
    }

    print('[DEBUG] ORS_API_KEY: ${dotenv.env['ORS_API_KEY']}');
  } catch (e) {
    print("Error fatal saat inisialisasi aplikasi: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App is paused/backgrounded - cleanup resources
      NavigationHelper.cleanupResources();
    } else if (state == AppLifecycleState.resumed) {
      // App is resumed - can reinitialize if needed
      print("App resumed - resources were cleaned up");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => TrackingBloc())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (context) => const SplashPage(),
          '/onboarding': (context) => OnboardingPage(),
          '/sign-in': (context) => SignInPage(),
          // Sign up batch pages - urutan proses pendaftaran baru
          '/sign-up-batch-1': (context) => const SignUpBatch1Page(),
          // Route sign-up-batch-2 sebagai langkah kedua (setelah batch-1)
          '/sign-up-batch-2': (context) => const SignUpBatch2Page(),
          '/sign-up-batch-3': (context) => const SignUpBatch3Page(),
          '/sign-up-batch-4': (context) => const SignUpBatch4Page(),
          '/sign-up-subscription': (context) => const SignUpSubscriptionPage(),
          // Batch 5 removed - redirect to subscription page after batch 4
          // Redirect old sign-up route to the new batch flow
          '/sign-up': (context) =>
              const SignUpBatch1Page(), // Redirect ke halaman batch 1
          '/sign-up-uplod-profile': (context) => const SignUpUplodProfilePage(),
          '/sign-up-success': (context) => SignUpSuccessPage(),
          '/home': (context) => HomePage(),
          '/mitra-dashboard': (context) => const MitraDashboardPage(),
          '/mitra-dashboard-new': (context) => const MitraDashboardPageNew(),
          '/notif': (context) => const NotificationPage(),
          '/chat': (context) => ChatListPage(),
          '/subscription-plans': (context) => SubscriptionPlansPage(),
          '/my-subscription': (context) => MySubscriptionPage(),
          '/tambah-jadwal': (context) => const TambahJadwalPage(),
          '/user-add-schedule': (context) => const CreateSchedulePage(),
          '/jadwal': (context) => const UserSchedulesPageNew(),
          '/tracking': (context) => const TrackingPage(),
          '/wilayah': (context) => const WilayahPage(),
          '/mitra-wilayah': (context) => const MitraLokasiPage(),
          '/reward': (context) => const RewardPage(),
          '/tracking_full': (context) => const TrackingFullScreen(),
          '/buatKeluhan': (context) => const BuatKeluhanPage(),
          '/goldenKeluhan': (context) => const GoldenKeluhanPage(),
          '/about-us': (context) => AboutUs(),
          '/wilayah_full': (context) => const WilayahFullScreen(),
          '/qris-payment': (context) => QRISPaymentPage(
            amount: ModalRoute.of(context)?.settings.arguments != null
                ? (ModalRoute.of(context)?.settings.arguments
                              as Map<String, dynamic>)['amount']
                          as int? ??
                      0
                : 0,
            transactionId: ModalRoute.of(context)?.settings.arguments != null
                ? (ModalRoute.of(context)?.settings.arguments
                              as Map<String, dynamic>)['transactionId']
                          as String? ??
                      ''
                : '',
            description: ModalRoute.of(context)?.settings.arguments != null
                ? (ModalRoute.of(context)?.settings.arguments
                              as Map<String, dynamic>)['description']
                          as String? ??
                      ''
                : '',
            returnData: ModalRoute.of(context)?.settings.arguments != null
                ? (ModalRoute.of(context)?.settings.arguments
                          as Map<String, dynamic>)['returnData']
                      as Map<String, dynamic>?
                : null,
          ),
          '/payment-success': (context) => const PaymentSuccessPage(),
          '/payment-timeout': (context) => const PaymentTimeoutPage(),
          '/checkout': (context) => const CheckoutPage(),
          '/payment-methods': (context) => const PaymentMethodsPage(),
          '/navigation-improved': (context) => InAppNavigationPage(
            scheduleData: ModalRoute.of(context)?.settings.arguments != null
                ? (ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>)
                : {},
          ),
          '/navigation-redesigned': (context) => NavigationPageRedesigned(
            scheduleData: ModalRoute.of(context)?.settings.arguments != null
                ? (ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>)
                : {},
          ),
          '/navigation-demo': (context) => const NavigationDemoPage(),
        },
      ),
    );
  }
}

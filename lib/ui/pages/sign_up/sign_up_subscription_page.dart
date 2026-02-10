import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/models/subscription_model.dart';
import 'package:bank_sha/services/subscription_service.dart';
import 'package:bank_sha/ui/pages/end_user/subscription/payment_gateway_page.dart';
import 'package:bank_sha/services/user_service.dart';
import 'package:bank_sha/mixins/app_dialog_mixin.dart';
import 'package:logger/logger.dart';

class SignUpSubscriptionPage extends StatefulWidget {
  const SignUpSubscriptionPage({super.key});

  @override
  State<SignUpSubscriptionPage> createState() => _SignUpSubscriptionPageState();
}

class _SignUpSubscriptionPageState extends State<SignUpSubscriptionPage>
    with AppDialogMixin {
  final SubscriptionService _subscriptionService = SubscriptionService();
  final Logger _logger = Logger();
  Future<List<SubscriptionPlan>>? _plansFuture;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Don't call _loadPlans here, wait for didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load plans only once after dependencies are ready
    if (!_isInitialized) {
      _isInitialized = true;
      _loadPlans();
    }
  }

  Future<void> _loadPlans() async {
    _logger.i('Loading subscription plans from API...');
    
    // Check if user is authenticated (from auto sign-in)
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final isAuthenticated = arguments?['isAuthenticated'] ?? false;
    
    if (isAuthenticated) {
      _logger.i('✅ User is authenticated, will try to fetch from API');
      // Smaller delay since we already waited after auto sign-in
      await Future.delayed(const Duration(milliseconds: 200));
    } else {
      _logger.w('⚠️ User not authenticated, will use static plans');
    }
    
    setState(() {
      _plansFuture = _subscriptionService.getAvailablePlans();
    });
    
    // Log the result for debugging
    _plansFuture?.then((plans) {
      _logger.i('Successfully loaded ${plans.length} subscription plans');
      // Check if we got API plans or static plans
      if (plans.isNotEmpty) {
        final firstPlan = plans.first;
        _logger.i('First plan: ${firstPlan.name} - ${firstPlan.formattedPrice}');
      }
    }).catchError((error) {
      _logger.e('Failed to load subscription plans: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _plansFuture == null
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(greenColor),
                      ),
                    )
                  : FutureBuilder<List<SubscriptionPlan>>(
                      future: _plansFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(greenColor),
                            ),
                          );
                        }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: redcolor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Gagal memuat paket langganan',
                              style: blackTextStyle.copyWith(
                                fontSize: 16,
                                fontWeight: semiBold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              snapshot.error.toString(),
                              style: greyTextStyle.copyWith(fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _plansFuture = _subscriptionService
                                      .getAvailablePlans();
                                });
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Coba Lagi'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: greenColor,
                                foregroundColor: whiteColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final plans = snapshot.data ?? [];
                  if (plans.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: greyColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada paket tersedia',
                            style: greyTextStyle.copyWith(
                              fontSize: 16,
                              fontWeight: medium,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _plansFuture = _subscriptionService
                                    .getAvailablePlans();
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Muat Ulang'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: greenColor,
                              foregroundColor: whiteColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      _logger.i('Refreshing subscription plans...');
                      final future = _subscriptionService.getAvailablePlans();
                      setState(() {
                        _plansFuture = future;
                      });
                      await future;
                    },
                    color: greenColor,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: plans.length,
                      itemBuilder: (context, index) {
                        return _buildPlanCard(plans[index]);
                      },
                    ),
                  );
                },
              ),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo
          Container(
            width: 120,
            height: 40,
            margin: const EdgeInsets.only(bottom: 20),
            child: Image.asset('assets/img_gerobakss.png', fit: BoxFit.contain),
          ),
          Text(
            'Selamat Datang! 🎉',
            style: blackTextStyle.copyWith(fontSize: 24, fontWeight: semiBold),
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih paket langganan untuk mendapatkan pengalaman terbaik dengan Gerobaks',
            style: greyTextStyle.copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: greenColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: greenColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: greenColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Anda bisa melewati step ini dan berlangganan kapan saja melalui menu Profile',
                    style: blackTextStyle.copyWith(
                      fontSize: 12,
                      fontWeight: medium,
                      color: greenColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: plan.isPopular
              ? greenColor
              : Colors.grey.withValues(alpha: 0.3),
          width: plan.isPopular ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Popular badge
          if (plan.isPopular)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: greenColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Text(
                  'PALING POPULER',
                  style: whiteTextStyle.copyWith(
                    fontSize: 10,
                    fontWeight: bold,
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getPlanColor(plan.type).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getPlanEmoji(plan.type),
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name,
                            style: blackTextStyle.copyWith(
                              fontSize: 20,
                              fontWeight: semiBold,
                            ),
                          ),
                          Text(
                            plan.description,
                            style: greyTextStyle.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Price
                Row(
                  children: [
                    Text(
                      plan.formattedPrice,
                      style: blackTextStyle.copyWith(
                        fontSize: 28,
                        fontWeight: bold,
                        color: _getPlanColor(plan.type),
                      ),
                    ),
                    Text(
                      '/${plan.durationText}',
                      style: greyTextStyle.copyWith(fontSize: 14),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Features
                ...plan.features.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: greenColor, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: blackTextStyle.copyWith(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Subscribe button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _selectPlan(plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getPlanColor(plan.type),
                      foregroundColor: whiteColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Pilih ${plan.name}',
                      style: whiteTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: semiBold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Skip button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _skipSubscription,
              style: OutlinedButton.styleFrom(
                foregroundColor: greyColor,
                side: BorderSide(color: greyColor.withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Nanti Saja',
                style: greyTextStyle.copyWith(fontSize: 16, fontWeight: medium),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Anda bisa berlangganan kapan saja melalui menu Profile',
            style: greyTextStyle.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getPlanEmoji(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.basic:
        return '🏠';
      case SubscriptionType.premium:
        return '⭐';
      case SubscriptionType.pro:
        return '🏢';
    }
  }

  Color _getPlanColor(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.basic:
        return Colors.blue;
      case SubscriptionType.premium:
        return Colors.purple;
      case SubscriptionType.pro:
        return Colors.amber[700]!;
    }
  }

  void _selectPlan(SubscriptionPlan plan) {
    _logger.i(
      'User selected plan: ${plan.name} (${plan.id}) - ${plan.formattedPrice}',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PaymentGatewayPage(plan: plan, isFromSignup: true),
      ),
    ).then((result) {
      if (result == true) {
        _logger.i('Payment successful for plan: ${plan.name}');
        // Payment successful, go to home
        _completeSignup(hasSubscription: true);
      } else {
        _logger.w('Payment cancelled or failed for plan: ${plan.name}');
      }
    });
  }

  void _skipSubscription() {
    _logger.i('User chose to skip subscription during signup');
    _completeSignup(hasSubscription: false);
  }

  Future<void> _completeSignup({required bool hasSubscription}) async {
    // Get all user data passed from previous pages
    final Map<String, dynamic> userData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};

    try {
      // Get user service and current user
      final userService = await UserService.getInstance();
      await userService.init();
      if (!mounted) return;

      // The user should already be registered from batch 4
      final user = await userService.getCurrentUser();
      if (!mounted) return;

      if (user == null) {
        debugPrint(
          'WARNING: User not found in _completeSignup, cannot update subscription status',
        );

        // Navigate directly to sign-in with the credentials
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/sign-in',
          (route) => false,
          arguments: {
            'email': userData['email'],
            'password': userData['password'],
          },
        );
        return;
      }

      // User exists, update subscription status (in a real app)
      debugPrint(
        'User found: ${user.name}, setting subscription status: $hasSubscription',
      );

      // In a real app, you would store this status to the user's account
      // For now we'll just navigate to the success page

      // Navigate to sign-up-success page to show success message
      if (!mounted) return;

      // Pass ALL user data to success page for API registration
      Navigator.pushNamed(
        context,
        '/sign-up-success',
        arguments: {
          'fullName': userData['fullName'] ?? userData['name'] ?? 'New User',
          'email': user.email,
          'password': userData['password'],
          'role': userData['role'] ?? 'end_user',
          'phone': userData['phone'],
          'address': userData['address'],
          'latitude': userData['latitude'],
          'longitude': userData['longitude'],
          'hasSubscription': hasSubscription,
        },
      );
    } catch (e) {
      debugPrint('Error in _completeSignup: $e');

      // Show error dialog
      showAppErrorDialog(
        title: 'Gagal Melanjutkan',
        message:
            'Terjadi kesalahan saat memproses pendaftaran: ${e.toString()}',
        buttonText: 'Coba Lagi',
      );
    }
  }
}

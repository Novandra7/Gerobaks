import 'package:flutter/material.dart';
import 'package:bank_sha/services/subscription_service.dart';
import 'package:bank_sha/models/subscription_model.dart';
import 'package:bank_sha/ui/pages/end_user/subscription/subscription_plans_page.dart';
import 'package:bank_sha/ui/widgets/shared/dialog_helper.dart';
import 'package:bank_sha/shared/theme.dart';

class SubscriptionGuard {
  static final SubscriptionService _subscriptionService = SubscriptionService();

  static Future<bool> checkSubscriptionAndShowDialog(BuildContext context) async {
    await _subscriptionService.initialize();
    final hasSubscription = _subscriptionService.hasActiveSubscription();
    
    if (!hasSubscription) {
      _showSubscriptionDialog(context);
      return false;
    }
    
    return true;
  }

  static void _showSubscriptionDialog(BuildContext context) {
    DialogHelper.showCustomDialog(
      context: context,
      title: 'Berlangganan Diperlukan',
      positiveButtonText: 'Berlangganan',
      negativeButtonText: 'Nanti',
      icon: Icons.card_membership,
      customContent: Text(
        'Untuk menggunakan layanan ini, Anda perlu berlangganan terlebih dahulu. Silakan pilih paket yang sesuai dengan kebutuhan Anda.',
        style: greyTextStyle.copyWith(
          fontSize: 14,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
      onPositivePressed: () {
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SubscriptionPlansPage(),
          ),
        );
      },
      onNegativePressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  static Widget buildSubscriptionBanner(BuildContext context) {
    return FutureBuilder<UserSubscription?>(
      future: _getCurrentSubscription(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Memuat status langganan...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }
        
        final subscription = snapshot.data;
        return _buildSubscriptionCard(context, subscription);
      },
    );
  }

  static Widget _buildSubscriptionCard(BuildContext context, UserSubscription? subscription) {
    // Debug: Print subscription status
    print('DEBUG: Subscription = $subscription');
    print('DEBUG: Subscription isActive = ${subscription?.isActive}');
    
    if (subscription != null && subscription.isActive) {
      // User has active subscription
      final subscriptionType = _getSubscriptionTypeFromPlanId(subscription.planId);
      
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _getSubscriptionGradient(subscriptionType),
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _getSubscriptionBorderColor(subscriptionType)),
          boxShadow: [
            BoxShadow(
              color: _getSubscriptionBorderColor(subscriptionType).withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getSubscriptionIcon(subscriptionType),
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Anda Telah Berlangganan',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          subscription.planName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getSubscriptionBorderColor(subscriptionType),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Berlaku hingga ${_formatDate(subscription.endDate)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      );
    } else {
      // User doesn't have active subscription
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red[100]!, Colors.red[50]!],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.red[300]!.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[200]!.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.warning_outlined,
                color: Colors.red[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Anda Belum Berlangganan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[800],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Berlangganan untuk menikmati layanan penuh Gerobaks',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubscriptionPlansPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Berlangganan',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  static SubscriptionType _getSubscriptionTypeFromPlanId(String planId) {
    if (planId.contains('basic')) {
      return SubscriptionType.basic;
    } else if (planId.contains('premium')) {
      return SubscriptionType.premium;
    } else if (planId.contains('pro')) {
      return SubscriptionType.pro;
    }
    return SubscriptionType.basic; // default
  }

  static List<Color> _getSubscriptionGradient(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.basic:
        return [Colors.blue[400]!, Colors.blue[300]!];
      case SubscriptionType.premium:
        return [Colors.amber[400]!, Colors.amber[300]!];
      case SubscriptionType.pro:
        return [Colors.green[400]!, Colors.green[300]!];
    }
  }

  static Color _getSubscriptionBorderColor(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.basic:
        return Colors.blue[600]!;
      case SubscriptionType.premium:
        return Colors.amber[600]!;
      case SubscriptionType.pro:
        return Colors.green[600]!;
    }
  }

  static IconData _getSubscriptionIcon(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.basic:
        return Icons.home;
      case SubscriptionType.premium:
        return Icons.star;
      case SubscriptionType.pro:
        return Icons.business;
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static Future<UserSubscription?> _getCurrentSubscription() async {
    print('DEBUG: Initializing subscription service...');
    await _subscriptionService.initialize();
    final result = _subscriptionService.getCurrentSubscription();
    print('DEBUG: getCurrentSubscription result = $result');
    return result;
  }
}

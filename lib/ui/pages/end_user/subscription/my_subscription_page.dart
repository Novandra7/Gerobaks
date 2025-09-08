import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';
import 'package:bank_sha/models/subscription_model.dart';
import 'package:bank_sha/services/subscription_service.dart';
import 'package:bank_sha/ui/pages/end_user/subscription/subscription_plans_page.dart';
import 'package:bank_sha/ui/widgets/shared/dialog_helper.dart';
import 'package:intl/intl.dart';

class MySubscriptionPage extends StatefulWidget {
  const MySubscriptionPage({super.key});

  @override
  State<MySubscriptionPage> createState() => _MySubscriptionPageState();
}

class _MySubscriptionPageState extends State<MySubscriptionPage> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  UserSubscription? _currentSubscription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _subscriptionService.initialize();
    setState(() {
      _currentSubscription = _subscriptionService.getCurrentSubscription();
      _isLoading = false;
    });

    // Listen to subscription updates
    _subscriptionService.subscriptionStream.listen((subscription) {
      if (mounted) {
        setState(() {
          _currentSubscription = subscription;
        });
      }
    });
  }

  Future<void> _cancelSubscription() async {
    final confirm = await DialogHelper.showConfirmDialog(
      context: context,
      title: 'Batalkan Langganan?',
      message: 'Apakah Anda yakin ingin membatalkan langganan? Layanan akan tetap aktif hingga periode berakhir.',
      confirmText: 'Ya, Batalkan',
      cancelText: 'Batal',
      icon: Icons.cancel_outlined,
      isDestructiveAction: true,
    );

    if (confirm == true) {
      await _subscriptionService.cancelSubscription();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Langganan berhasil dibatalkan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppNotif(
        title: 'Langganan Saya',
        showBackButton: true,
      ),
      backgroundColor: uicolor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentSubscription == null || !_currentSubscription!.isActive
              ? _buildNoSubscription()
              : _buildActiveSubscription(),
    );
  }

  Widget _buildNoSubscription() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.subscriptions_outlined,
                size: 60,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Langganan Aktif',
              style: blackTextStyle.copyWith(
                fontSize: 20,
                fontWeight: bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Berlangganan sekarang untuk menikmati layanan pengelolaan sampah yang mudah dan terpercaya.',
              style: greyTextStyle.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionPlansPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Berlangganan Sekarang',
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
    );
  }

  Widget _buildActiveSubscription() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubscriptionCard(),
          const SizedBox(height: 24),
          _buildSubscriptionDetails(),
          const SizedBox(height: 24),
          _buildManageSection(),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard() {
    final subscription = _currentSubscription!;
    final daysRemaining = subscription.daysRemaining;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            greenColor,
            greenColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: greenColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: whiteColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Langganan Aktif',
                style: whiteTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: semiBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            subscription.planName,
            style: whiteTextStyle.copyWith(
              fontSize: 24,
              fontWeight: bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Berlaku hingga ${DateFormat('dd MMMM yyyy', 'id_ID').format(subscription.endDate)}',
            style: whiteTextStyle.copyWith(
              fontSize: 14,
              color: whiteColor.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: whiteColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$daysRemaining hari tersisa',
              style: whiteTextStyle.copyWith(
                fontSize: 12,
                fontWeight: medium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionDetails() {
    final subscription = _currentSubscription!;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Langganan',
            style: blackTextStyle.copyWith(
              fontSize: 16,
              fontWeight: semiBold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('ID Langganan', subscription.id),
          const SizedBox(height: 12),
          _buildDetailRow('Status', subscription.statusText),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Mulai Aktif',
            DateFormat('dd MMMM yyyy', 'id_ID').format(subscription.startDate),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Berakhir',
            DateFormat('dd MMMM yyyy', 'id_ID').format(subscription.endDate),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Metode Pembayaran', subscription.paymentMethod ?? '-'),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Total Pembayaran',
            'Rp ${subscription.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: greyTextStyle.copyWith(
            fontSize: 14,
            fontWeight: medium,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: blackTextStyle.copyWith(
              fontSize: 14,
              fontWeight: medium,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildManageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kelola Langganan',
          style: blackTextStyle.copyWith(
            fontSize: 16,
            fontWeight: semiBold,
          ),
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          icon: Icons.credit_card,
          title: 'Perpanjang Langganan',
          subtitle: 'Perpanjang paket langganan Anda',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SubscriptionPlansPage(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          icon: Icons.history,
          title: 'Riwayat Pembayaran',
          subtitle: 'Lihat semua transaksi langganan',
          onTap: () {
            // TODO: Implement payment history
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur dalam pengembangan')),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          icon: Icons.cancel,
          title: 'Batalkan Langganan',
          subtitle: 'Hentikan perpanjangan otomatis',
          onTap: _cancelSubscription,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isDestructive ? Colors.red : greenColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : greenColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: blackTextStyle.copyWith(
                      fontSize: 14,
                      fontWeight: medium,
                      color: isDestructive ? Colors.red : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: greyTextStyle.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}

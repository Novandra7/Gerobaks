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
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh subscription when page comes back to foreground
    // But avoid refreshing during first initialization
    if (_isInitialized && !_isLoading) {
      _refreshSubscription();
    }
  }

  Future<void> _initializeData() async {
    await _subscriptionService.initialize();
    
    // Try to fetch from API first
    await _refreshSubscription();
    
    // Mark as initialized
    _isInitialized = true;

    // Listen to subscription updates
    _subscriptionService.subscriptionStream.listen((subscription) {
      if (mounted) {
        setState(() {
          _currentSubscription = subscription;
        });
      }
    });
  }

  Future<void> _refreshSubscription() async {
    try {
      // Fetch latest subscription from API
      final subscription = await _subscriptionService.getCurrentSubscriptionFromAPI();
      
      if (mounted) {
        setState(() {
          _currentSubscription = subscription;
          _isLoading = false;
        });
      }
    } catch (e) {
      // If API fails, fallback to local cache
      if (mounted) {
        setState(() {
          _currentSubscription = _subscriptionService.getCurrentSubscription();
          _isLoading = false;
        });
      }
    }
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
      try {
        await _subscriptionService.cancelSubscription();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Langganan berhasil dibatalkan'),
              backgroundColor: Colors.green,
            ),
          );
          await _refreshSubscription();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
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
      body: RefreshIndicator(
        onRefresh: _refreshSubscription,
        color: greenColor,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _currentSubscription == null || !_currentSubscription!.isActive
                ? _buildNoSubscription()
                : _buildActiveSubscription(),
      ),
    );
  }

  Widget _buildNoSubscription() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height - 100,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            const SizedBox(height: 8),
            Text(
              'Tarik ke bawah untuk refresh',
              style: greyTextStyle.copyWith(
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionPlansPage(),
                    ),
                  );
                  
                  // Refresh subscription after returning from plans page
                  if (mounted) {
                    await _refreshSubscription();
                  }
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
            greenColor.withAlpha(204),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: greenColor.withAlpha(77),
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
              color: whiteColor.withAlpha(229),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: whiteColor.withAlpha(51),
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
            color: blackColor.withAlpha(26),
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
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SubscriptionPlansPage(),
              ),
            );
            
            // Refresh subscription after returning
            if (mounted) {
              await _refreshSubscription();
            }
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
                color: (isDestructive ? Colors.red : greenColor).withAlpha(25),
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

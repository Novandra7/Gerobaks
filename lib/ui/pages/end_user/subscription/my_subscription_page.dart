import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';
import 'package:bank_sha/models/subscription_model.dart';
import 'package:bank_sha/services/subscription_service.dart';
import 'package:bank_sha/ui/pages/end_user/subscription/subscription_plans_page.dart';
import 'package:bank_sha/ui/pages/end_user/subscription/payment_gateway_page.dart';
import 'package:bank_sha/ui/pages/end_user/location/add_location_page.dart';
import 'package:bank_sha/ui/widgets/shared/dialog_helper.dart';
import 'package:intl/intl.dart';

class MySubscriptionPage extends StatefulWidget {
  const MySubscriptionPage({super.key});

  @override
  State<MySubscriptionPage> createState() => _MySubscriptionPageState();
}

class _MySubscriptionPageState extends State<MySubscriptionPage>
    with SingleTickerProviderStateMixin {
  final SubscriptionService _subscriptionService = SubscriptionService();
  List<UserSubscription> _allSubscriptions = [];
  UserSubscription? _selectedSubscription;
  String? _selectedType;
  bool _isLoading = true;
  bool _isInitialized = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized && !_isLoading) {
      _refreshSubscriptions();
    }
  }

  // --- Filtered lists ---

  List<UserSubscription> get _activeSubscriptions => _allSubscriptions
      .where((s) => s.status == PaymentStatus.success && s.isActive)
      .toList();

  List<UserSubscription> get _pendingSubscriptions => _allSubscriptions
      .where((s) => s.status == PaymentStatus.pending)
      .toList();

  List<UserSubscription> get _expiredSubscriptions => _allSubscriptions
      .where(
        (s) =>
            s.status == PaymentStatus.expired ||
            (s.status == PaymentStatus.success && s.isExpired),
      )
      .toList();

  List<UserSubscription> get _cancelledSubscriptions => _allSubscriptions
      .where((s) => s.status == PaymentStatus.cancelled)
      .toList();

  // --- Data fetching ---

  Future<void> _initializeData() async {
    await _subscriptionService.initialize();
    await _refreshSubscriptions();
    _isInitialized = true;

    _subscriptionService.subscriptionStream.listen((subscription) {
      if (mounted) _refreshSubscriptions();
    });
  }

  Future<void> _refreshSubscriptions() async {
    try {
      final history = await _subscriptionService.getAllSubscriptionsFromAPI();
      if (mounted) {
        setState(() {
          _allSubscriptions = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Fallback: try current subscription from cache
      if (mounted) {
        final current = _subscriptionService.getCurrentSubscription();
        setState(() {
          _allSubscriptions = current != null ? [current] : [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cancelSubscription() async {
    if (_selectedSubscription == null) return;
    final subscriptionId = _selectedSubscription!.id;

    final confirm = await DialogHelper.showConfirmDialog(
      context: context,
      title: 'Batalkan Langganan?',
      message:
          'Apakah Anda yakin ingin membatalkan langganan? Layanan akan tetap aktif hingga periode berakhir.',
      confirmText: 'Ya, Batalkan',
      cancelText: 'Batal',
      icon: Icons.cancel_outlined,
      isDestructiveAction: true,
    );

    if (confirm == true) {
      try {
        await _subscriptionService.cancelSubscription(subscriptionId);
        if (mounted) {
          setState(() {
            _selectedSubscription = null;
            _selectedType = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Langganan berhasil dibatalkan'),
              backgroundColor: Colors.green,
            ),
          );
          await _refreshSubscriptions();
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

  void _onPendingCardTap(UserSubscription subscription) {
    final plan = SubscriptionPlan(
      id: subscription.planId,
      name: subscription.planName,
      description: '',
      price: subscription.amount,
      durationInDays: subscription.endDate
          .difference(subscription.startDate)
          .inDays,
      type: SubscriptionType.basic,
      features: [],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PaymentGatewayPage(plan: plan, subscriptionId: subscription.id),
      ),
    ).then((_) {
      if (mounted) _refreshSubscriptions();
    });
  }

  // --- Build ---

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
          : Column(
              children: [
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTabView(_activeSubscriptions, 'active'),
                      _buildTabView(_pendingSubscriptions, 'pending'),
                      _buildTabView(_expiredSubscriptions, 'expired'),
                      _buildTabView(_cancelledSubscriptions, 'cancelled'),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: whiteColor,
      child: TabBar(
        controller: _tabController,
        labelColor: greenColor,
        unselectedLabelColor: greyColor,
        indicatorColor: greenColor,
        indicatorWeight: 3,
        labelStyle: blackTextStyle.copyWith(fontSize: 13, fontWeight: semiBold),
        unselectedLabelStyle: greyTextStyle.copyWith(fontSize: 13),
        tabs: const [
          Tab(text: 'Active'),
          Tab(text: 'Pending'),
          Tab(text: 'Expired'),
          Tab(text: 'Cancelled'),
        ],
      ),
    );
  }

  Widget _buildTabView(List<UserSubscription> subscriptions, String type) {
    // Only show detail for the tab where the card was tapped
    if (_selectedSubscription != null && _selectedType == type) {
      return _buildSubscriptionDetail(_selectedSubscription!, type);
    }

    // Empty state
    if (subscriptions.isEmpty) {
      return _buildEmptyTab(type);
    }

    return RefreshIndicator(
      onRefresh: _refreshSubscriptions,
      color: greenColor,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: subscriptions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final sub = subscriptions[index];
          return _buildSubscriptionListCard(sub, type);
        },
      ),
    );
  }

  Widget _buildEmptyTab(String type) {
    final Map<String, Map<String, dynamic>> emptyConfig = {
      'active': {
        'icon': Icons.subscriptions_outlined,
        'title': 'Belum Ada Langganan Aktif',
        'subtitle':
            'Tambahkan lokasi terlebih dahulu untuk mulai berlangganan layanan pengelolaan sampah.',
        'showButton': true,
      },
      'pending': {
        'icon': Icons.hourglass_empty,
        'title': 'Tidak Ada Pembayaran Tertunda',
        'subtitle': 'Semua pembayaran sudah diselesaikan.',
        'showButton': false,
      },
      'expired': {
        'icon': Icons.history,
        'title': 'Tidak Ada Langganan Kedaluwarsa',
        'subtitle': 'Belum ada langganan yang berakhir.',
        'showButton': false,
      },
      'cancelled': {
        'icon': Icons.cancel_outlined,
        'title': 'Tidak Ada Langganan Dibatalkan',
        'subtitle': 'Belum ada langganan yang dibatalkan.',
        'showButton': false,
      },
    };

    final config = emptyConfig[type]!;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height - 200,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                config['icon'] as IconData,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              config['title'] as String,
              style: blackTextStyle.copyWith(fontSize: 18, fontWeight: bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              config['subtitle'] as String,
              style: greyTextStyle.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            if (config['showButton'] == true) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddLocationPage(),
                      ),
                    );
                    if (mounted) await _refreshSubscriptions();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: greenColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Tambah Lokasi',
                    style: whiteTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: semiBold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- Subscription list card (summary) ---

  Widget _buildSubscriptionListCard(
    UserSubscription subscription,
    String type,
  ) {
    final statusColor = _statusColor(subscription);

    return InkWell(
      onTap: () {
        if (type == 'pending') {
          _onPendingCardTap(subscription);
        } else {
          setState(() {
            _selectedSubscription = subscription;
            _selectedType = type;
          });
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: blackColor.withAlpha(20),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 50,
              decoration: BoxDecoration(
                color: statusColor.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_statusIcon(type), color: statusColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subscription.planName,
                    style: blackTextStyle.copyWith(
                      fontSize: 14,
                      fontWeight: semiBold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _cardSubtitle(subscription, type),
                    style: greyTextStyle.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            if (type == 'pending')
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Bayar',
                  style: whiteTextStyle.copyWith(
                    fontSize: 12,
                    fontWeight: semiBold,
                  ),
                ),
              )
            else ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  subscription.statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 20, color: Colors.grey[400]),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(UserSubscription subscription) {
    switch (subscription.status) {
      case PaymentStatus.success:
        return subscription.isExpired ? orangeColor : greenColor;
      case PaymentStatus.pending:
        return orangeColor;
      case PaymentStatus.expired:
        return orangeColor;
      case PaymentStatus.cancelled:
        return Colors.red;
      case PaymentStatus.failed:
        return Colors.red;
    }
  }

  IconData _statusIcon(String type) {
    switch (type) {
      case 'active':
        return Icons.star;
      case 'pending':
        return Icons.hourglass_top;
      case 'expired':
        return Icons.event_busy;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.subscriptions;
    }
  }

  String _cardSubtitle(UserSubscription subscription, String type) {
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
    switch (type) {
      case 'active':
        return '${subscription.daysRemaining} hari tersisa • s.d. ${dateFormat.format(subscription.endDate)}';
      case 'pending':
        return 'Rp. ${subscription.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
      case 'expired':
        return 'Berakhir ${dateFormat.format(subscription.endDate)}';
      case 'cancelled':
        return 'Dibatalkan • ${dateFormat.format(subscription.endDate)}';
      default:
        return '';
    }
  }

  // --- Detail view (shown when a card is tapped) ---

  Widget _buildSubscriptionDetail(UserSubscription subscription, String type) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() {
                _selectedSubscription = null;
                _selectedType = null;
              }),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Kembali ke daftar'),
              style: TextButton.styleFrom(foregroundColor: greenColor),
            ),
          ),
          const SizedBox(height: 8),
          _buildSubscriptionHeroCard(subscription, type),
          const SizedBox(height: 24),
          _buildSubscriptionDetails(subscription),
          if (type == 'active') ...[
            const SizedBox(height: 24),
            _buildManageSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildSubscriptionHeroCard(
    UserSubscription subscription,
    String type,
  ) {
    final Color color;
    final String label;
    final String? badgeText;

    switch (type) {
      case 'active':
        color = greenColor;
        label = 'Langganan Aktif';
        badgeText = '${subscription.daysRemaining} hari tersisa';
        break;
      case 'pending':
        color = orangeColor;
        label = 'Menunggu Pembayaran';
        badgeText = null;
        break;
      case 'expired':
        color = Colors.grey;
        label = 'Langganan Berakhir';
        badgeText = null;
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Langganan Dibatalkan';
        badgeText = null;
        break;
      default:
        color = greenColor;
        label = '';
        badgeText = null;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withAlpha(204)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(77),
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
              Icon(_statusIcon(type), color: whiteColor, size: 24),
              const SizedBox(width: 8),
              Text(
                label,
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
            style: whiteTextStyle.copyWith(fontSize: 24, fontWeight: bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Berlaku hingga ${DateFormat('dd MMMM yyyy', 'id_ID').format(subscription.endDate)}',
            style: whiteTextStyle.copyWith(
              fontSize: 14,
              color: whiteColor.withAlpha(229),
            ),
          ),
          if (badgeText != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: whiteColor.withAlpha(51),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badgeText,
                style: whiteTextStyle.copyWith(
                  fontSize: 12,
                  fontWeight: medium,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubscriptionDetails(UserSubscription subscription) {
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
            style: blackTextStyle.copyWith(fontSize: 16, fontWeight: semiBold),
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
          _buildDetailRow(
            'Metode Pembayaran',
            subscription.paymentMethod ?? '-',
          ),
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
          style: greyTextStyle.copyWith(fontSize: 14, fontWeight: medium),
        ),
        Flexible(
          child: Text(
            value,
            style: blackTextStyle.copyWith(fontSize: 14, fontWeight: medium),
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
          style: blackTextStyle.copyWith(fontSize: 16, fontWeight: semiBold),
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
            if (mounted) await _refreshSubscriptions();
          },
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          icon: Icons.history,
          title: 'Riwayat Pembayaran',
          subtitle: 'Lihat semua transaksi langganan',
          onTap: () {
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
                  Text(subtitle, style: greyTextStyle.copyWith(fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

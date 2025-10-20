import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/models/user_model.dart';
import 'package:bank_sha/services/user_service.dart';
import 'package:bank_sha/services/end_user_api_service.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';
import 'package:bank_sha/ui/widgets/skeleton/skeleton_items.dart';
import 'package:flutter/material.dart';

class PointsHistoryPage extends StatefulWidget {
  const PointsHistoryPage({super.key});

  @override
  State<PointsHistoryPage> createState() => _PointsHistoryPageState();
}

class _PointsHistoryPageState extends State<PointsHistoryPage> {
  bool _isLoading = true;
  UserModel? _user;
  List<Map<String, dynamic>> _pointsHistory = [];
  Map<String, dynamic>? _balanceSummary;
  late UserService _userService;
  late EndUserApiService _apiService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _apiService = EndUserApiService();
    await _apiService.initialize();
    await _loadData();
  }

  Future<void> _loadData() async {
    try {
      _userService = await UserService.getInstance();
      await _userService.init();

      final user = await _userService.getCurrentUser();

<<<<<<< HEAD
      // Load data from API instead of mock data
      final balanceSummary = await _apiService.getBalanceSummary();
      final pointsHistory = await _apiService.getBalanceLedger();
=======
      // Simulate loading point history
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock points history data
      // In a real app, this would come from an API or local database
      final List<Map<String, dynamic>> mockHistory = [
        {
          'id': '1',
          'type': 'earned',
          'amount': 15,
          'description': 'Pendaftaran akun baru',
          'date': DateTime.now().subtract(const Duration(days: 7)),
        },
        {
          'id': '2',
          'type': 'earned',
          'amount': 10,
          'description': 'Pengambilan sampah plastik',
          'date': DateTime.now().subtract(const Duration(days: 5)),
        },
        {
          'id': '3',
          'type': 'spent',
          'amount': 5,
          'description': 'Penukaran voucher diskon',
          'date': DateTime.now().subtract(const Duration(days: 2)),
        },
        {
          'id': '4',
          'type': 'earned',
          'amount': 8,
          'description': 'Pengambilan sampah kertas',
          'date': DateTime.now().subtract(const Duration(days: 1)),
        },
      ];
>>>>>>> 2e541a34a65c54536f2513f1cd751746eb9fc575

      if (mounted) {
        setState(() {
          _user = user;
          _balanceSummary = balanceSummary;
          _pointsHistory = pointsHistory;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading points data: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Skeleton loading for points history
  Widget _buildSkeletonLoading() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Points summary skeleton
        SkeletonItems.card(height: 100, borderRadius: 16),
        const SizedBox(height: 32),

        // History title skeleton
        SkeletonItems.text(width: 150, height: 24),
        const SizedBox(height: 16),

        // History items skeleton
        for (int i = 0; i < 5; i++) ...[
          SkeletonItems.listItem(),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: uicolor,
<<<<<<< HEAD
      appBar: const CustomAppHeader(title: 'Riwayat Poin'),
=======
      appBar: const CustomAppBar(title: 'Riwayat Poin', showBackButton: true),
>>>>>>> 2e541a34a65c54536f2513f1cd751746eb9fc575
      body: _isLoading
          ? _buildSkeletonLoading()
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Points summary card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Total Poin Anda',
                          style: blackTextStyle.copyWith(fontWeight: medium),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.stars_rounded,
                              color: greenColor,
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_user?.points ?? 0}',
                              style: greenTextStyle.copyWith(
                                fontSize: 28,
                                fontWeight: bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // History title
                  Text(
                    'Riwayat Transaksi',
                    style: blackTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: semiBold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // History items
                  _pointsHistory.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Belum ada riwayat poin',
                                  style: greyTextStyle.copyWith(
                                    fontWeight: medium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          children: _pointsHistory.map((item) {
                            final bool isEarned = item['type'] == 'earned';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: whiteColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  // Icon
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: isEarned
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isEarned
                                          ? Icons.add_circle
                                          : Icons.remove_circle,
                                      color: isEarned ? greenColor : Colors.red,
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  // Transaction details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['description'],
                                          style: blackTextStyle.copyWith(
                                            fontWeight: medium,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatDate(item['date']),
                                          style: greyTextStyle.copyWith(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Amount
                                  Text(
                                    '${isEarned ? '+' : '-'}${item['amount']}',
                                    style: isEarned
                                        ? greenTextStyle.copyWith(
                                            fontWeight: semiBold,
                                          )
                                        : TextStyle(
                                            color: Colors.red,
                                            fontWeight: semiBold,
                                          ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

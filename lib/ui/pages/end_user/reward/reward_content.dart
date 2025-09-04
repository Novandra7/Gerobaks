import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/services/user_service.dart';
import 'package:bank_sha/models/user_model.dart';

class RewardContent extends StatefulWidget {
  const RewardContent({super.key});

  @override
  State<RewardContent> createState() => _RewardContentState();
}

class _RewardContentState extends State<RewardContent> {
  late UserService _userService;
  UserModel? _user;
  bool _isLoading = true;
  
  // Getter for points that returns 0 if user is null
  int get totalPoints => _user?.points ?? 0;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Set up periodic refresh of points
    _setupRefreshTimer();
  }
  
  void _setupRefreshTimer() {
    // Refresh user data every minute to keep points up to date
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted) {
        _refreshUserData();
        _setupRefreshTimer(); // Set up the timer again
      }
    });
  }
  
  Future<void> _refreshUserData() async {
    try {
      final user = await _userService.getCurrentUser();
      _handleUserChange(user);
    } catch (e) {
      print("Error refreshing user data: $e");
    }
  }

  void _handleUserChange(UserModel? user) {
    if (mounted) {
      setState(() {
        _user = user;
      });
    }
  }
  
  Future<void> _loadUserData() async {
    try {
      _userService = await UserService.getInstance();
      await _userService.init();
      
      // Get initial user data
      final user = await _userService.getCurrentUser();
      
      // Add a small delay to show the loading state
      await Future.delayed(const Duration(milliseconds: 800));
      
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
      
      // Set up listener for user changes
      _userService.addUserChangeListener(_handleUserChange);
    } catch (e) {
      print("Error loading user data: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  void dispose() {
    // Remove user change listener
    _userService.removeUserChangeListener(_handleUserChange);
    super.dispose();
  }

  final List<Map<String, dynamic>> rewardHistory = const [
    {
      'date': '26 Juni 2025',
      'sampah': {'Organik': 2.0, 'Anorganik': 1.0, 'B3': 1.5},
      'poin': 12,
      'status': 'Completed',
      'waktu': '14:30',
    },
    {
      'date': '23 Juni 2025',
      'sampah': {'Organik': 1.0, 'B3': 1.0},
      'poin': 7,
      'status': 'Completed',
      'waktu': '09:15',
    },
    {
      'date': '20 Juni 2025',
      'sampah': {'Anorganik': 3.0, 'Organik': 0.5},
      'poin': 8,
      'status': 'Processing',
      'waktu': '16:45',
    },
  ];

  // Data untuk reward items yang bisa ditukar
  final List<Map<String, dynamic>> rewardItems = const [
    {
      'name': 'Voucher Belanja',
      'poin': 50,
      'image': 'assets/ic_reward.png',
      'description': 'Voucher belanja Rp 25.000',
      'category': 'Shopping',
    },
    {
      'name': 'Pulsa 20K',
      'poin': 30,
      'image': 'assets/ic_reward.png',
      'description': 'Pulsa untuk semua operator',
      'category': 'Digital',
    },
    {
      'name': 'Go-Food Voucher',
      'poin': 40,
      'image': 'assets/ic_reward.png',
      'description': 'Voucher Go-Food Rp 20.000',
      'category': 'Food',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await _refreshUserData();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
          // Header Section dengan animasi
          _buildHeaderSection(),
          const SizedBox(height: 24),

          // Total Points Card dengan desain baru
          _buildTotalPointCard(),
          const SizedBox(height: 32),

          // Quick Stats
          _buildQuickStats(),
          const SizedBox(height: 32),

          // Reward Items untuk ditukar
          _buildRewardItemsSection(),
          const SizedBox(height: 32),

          // History Section
          _buildHistorySection(),
          const SizedBox(height: 24),
        ],
      ),
    ));
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [greenColor.withOpacity(0.1), greenColor.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: greenColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: greenColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.card_giftcard_rounded,
                  color: greenColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎁 Reward Center',
                      style: blackTextStyle.copyWith(
                        fontSize: 22,
                        fontWeight: bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tukar poin dengan hadiah menarik!',
                      style: greyTextStyle.copyWith(fontSize: 14, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalPointCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            greenColor,
            greenColor.withOpacity(0.8),
            Colors.teal.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: greenColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: whiteColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: whiteColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(Icons.stars_rounded, size: 40, color: whiteColor),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💎 Total Poin Anda',
                      style: whiteTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: medium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isLoading
                      ? Container(
                          width: 120,
                          height: 40,
                          decoration: BoxDecoration(
                            color: whiteColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        )
                      : Text(
                          '$totalPoints Poin',
                          style: whiteTextStyle.copyWith(
                            fontSize: 32,
                            fontWeight: bold,
                            letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: whiteColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _isLoading
              ? Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: whiteColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 160,
                      height: 13,
                      decoration: BoxDecoration(
                        color: whiteColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Icon(Icons.trending_up_rounded, color: whiteColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Naik 12 poin dari bulan lalu! 🚀',
                      style: whiteTextStyle.copyWith(
                        fontSize: 13,
                        fontWeight: medium,
                      ),
                    ),
                  ],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _isLoading 
            ? _buildLoadingStatCard()
            : _buildStatCard(
                'Total Sampah',
                '${(_user?.points ?? 0) / 10} kg', // Assuming 10 points per kg for estimation
                Icons.delete_outline_rounded,
                Colors.blue.shade600,
              ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _isLoading
            ? _buildLoadingStatCard()
            : _buildStatCard(
                'Penjemputan',
                '${rewardHistory.length}x',
                Icons.local_shipping_rounded,
                Colors.orange.shade600,
              ),
        ),
      ],
    );
  }
  
  Widget _buildLoadingStatCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightBackgroundColor,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: greyColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 80,
            height: 16,
            decoration: BoxDecoration(
              color: greyColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 60,
            height: 20,
            decoration: BoxDecoration(
              color: greyColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: blackTextStyle.copyWith(
              fontSize: 20,
              fontWeight: bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: greyTextStyle.copyWith(fontSize: 12, fontWeight: medium),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '🛍️ Tukar Poin',
                  style: blackTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  // Navigate to all rewards page
                },
                child: Text(
                  'Lihat Semua',
                  style: TextStyle(
                    color: greenColor,
                    fontSize: 14,
                    fontWeight: medium,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250, // Increased height to prevent overflow
          child: rewardItems.isNotEmpty
              ? ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  itemCount: rewardItems.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = rewardItems[index];
                    return _buildRewardItemCard(item);
                  },
                )
              : Center(
                  child: Text(
                    'Tidak ada reward tersedia',
                    style: greyTextStyle.copyWith(fontSize: 14),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildRewardItemCard(Map<String, dynamic> item) {
    final bool canRedeem = totalPoints >= item['poin'];

    return Container(
      width: 160,
      padding: const EdgeInsets.all(12), // Reduced padding from 16 to 12
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: canRedeem ? greenColor.withOpacity(0.3) : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Add this to prevent overflow
        children: [
          Container(
            width: double.infinity,
            height: 70, // Reduced height from 80 to 70
            decoration: BoxDecoration(
              color: _getCategoryColor(item['category']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(item['category']),
              size: 35, // Reduced size from 40 to 35
              color: _getCategoryColor(item['category']),
            ),
          ),
          const SizedBox(height: 10), // Reduced from 12 to 10
          Flexible(
            // Changed from Text to Flexible
            child: Text(
              item['name'],
              style: blackTextStyle.copyWith(
                fontSize: 13,
                fontWeight: semiBold,
              ), // Reduced font size
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 3), // Reduced from 4 to 3
          Flexible(
            // Changed from Text to Flexible
            child: Text(
              item['description'],
              style: greyTextStyle.copyWith(fontSize: 10), // Reduced font size
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8), // Add fixed spacing instead of Spacer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ), // Reduced padding
                  decoration: BoxDecoration(
                    color: canRedeem
                        ? greenColor.withOpacity(0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${item['poin']} pts',
                    style: TextStyle(
                      color: canRedeem ? greenColor : Colors.grey.shade600,
                      fontSize: 11, // Reduced font size
                      fontWeight: semiBold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                canRedeem ? Icons.check_circle : Icons.lock,
                size: 14, // Reduced size from 16 to 14
                color: canRedeem ? greenColor : Colors.grey.shade400,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '📋 Riwayat Penjemputan',
              style: blackTextStyle.copyWith(fontSize: 18, fontWeight: bold),
            ),
            Text(
              '${rewardHistory.length} transaksi',
              style: greyTextStyle.copyWith(fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...rewardHistory.map((data) => _buildHistoryCard(data)),
      ],
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> data) {
    final Map<String, double> sampah = Map<String, double>.from(data['sampah']);
    final String status = data['status'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan tanggal dan status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: greenColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.calendar_today_rounded,
                      color: greenColor,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['date'],
                        style: blackTextStyle.copyWith(
                          fontWeight: bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Jam ${data['waktu']}',
                        style: greyTextStyle.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getStatusColor(status).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _getStatusText(status),
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontSize: 11,
                    fontWeight: semiBold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Detail sampah
          Text(
            'Detail Sampah:',
            style: blackTextStyle.copyWith(fontWeight: semiBold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sampah.entries.map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getSampahColor(entry.key).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getSampahColor(entry.key).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getSampahIcon(entry.key),
                      size: 16,
                      color: _getSampahColor(entry.key),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${entry.key}: ${entry.value} kg',
                      style: TextStyle(
                        color: _getSampahColor(entry.key),
                        fontSize: 13,
                        fontWeight: semiBold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Poin yang diperoleh
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade50, Colors.orange.shade100],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.stars_rounded,
                    color: Colors.orange.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '🎁 Poin Diperoleh: ${data['poin']} poin',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods untuk warna dan icon
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Shopping':
        return Colors.purple.shade600;
      case 'Digital':
        return Colors.blue.shade600;
      case 'Food':
        return Colors.orange.shade600;
      default:
        return greenColor;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Digital':
        return Icons.phone_android_rounded;
      case 'Food':
        return Icons.restaurant_rounded;
      default:
        return Icons.card_giftcard_rounded;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green.shade600;
      case 'Processing':
        return Colors.orange.shade600;
      default:
        return greyColor;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'Completed':
        return '✅ Selesai';
      case 'Processing':
        return '⏳ Diproses';
      default:
        return status;
    }
  }

  Color _getSampahColor(String jenis) {
    switch (jenis) {
      case 'Organik':
        return Colors.green.shade600;
      case 'Anorganik':
        return Colors.blue.shade600;
      case 'B3':
        return Colors.red.shade600;
      default:
        return greyColor;
    }
  }

  IconData _getSampahIcon(String jenis) {
    switch (jenis) {
      case 'Organik':
        return Icons.eco_rounded;
      case 'Anorganik':
        return Icons.recycling_rounded;
      case 'B3':
        return Icons.warning_rounded;
      default:
        return Icons.delete_outline_rounded;
    }
  }
}

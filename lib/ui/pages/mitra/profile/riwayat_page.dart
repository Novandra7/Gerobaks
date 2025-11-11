import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bank_sha/shared/theme.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Dummy data untuk riwayat
  final List<Map<String, dynamic>> _transactionHistory = [
    {
      'id': 'TXN-001',
      'type': 'pickup',
      'title': 'Pengambilan Sampah',
      'location': 'Jl. Sudirman No. 123',
      'date': '10 Nov 2025',
      'time': '08:30',
      'status': 'completed',
      'amount': 'Rp 25.000',
      'points': '+50',
    },
    {
      'id': 'TXN-002',
      'type': 'pickup',
      'title': 'Pengambilan Sampah',
      'location': 'Jl. Thamrin No. 456',
      'date': '09 Nov 2025',
      'time': '14:15',
      'status': 'completed',
      'amount': 'Rp 35.000',
      'points': '+70',
    },
    {
      'id': 'TXN-003',
      'type': 'pickup',
      'title': 'Pengambilan Sampah',
      'location': 'Jl. Gatot Subroto No. 789',
      'date': '08 Nov 2025',
      'time': '10:45',
      'status': 'cancelled',
      'amount': 'Rp 0',
      'points': '0',
    },
  ];

  final List<Map<String, dynamic>> _activityHistory = [
    {
      'id': 'ACT-001',
      'type': 'login',
      'title': 'Login ke Aplikasi',
      'description': 'Login berhasil dari perangkat mobile',
      'date': '10 Nov 2025',
      'time': '07:30',
    },
    {
      'id': 'ACT-002',
      'type': 'profile',
      'title': 'Update Profile',
      'description': 'Mengubah nomor telepon',
      'date': '09 Nov 2025',
      'time': '16:20',
    },
    {
      'id': 'ACT-003',
      'type': 'schedule',
      'title': 'Jadwal Baru',
      'description': 'Menerima jadwal pengambilan sampah',
      'date': '08 Nov 2025',
      'time': '09:15',
    },
  ];

  final List<Map<String, dynamic>> _earnings = [
    {
      'id': 'EARN-001',
      'title': 'Komisi Pengambilan',
      'amount': 'Rp 25.000',
      'date': '10 Nov 2025',
      'type': 'commission',
    },
    {
      'id': 'EARN-002',
      'title': 'Bonus Bulanan',
      'amount': 'Rp 150.000',
      'date': '01 Nov 2025',
      'type': 'bonus',
    },
    {
      'id': 'EARN-003',
      'title': 'Komisi Pengambilan',
      'amount': 'Rp 35.000',
      'date': '09 Nov 2025',
      'type': 'commission',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: blackColor,
              size: 20,
            ),
          ),
        ),
        title: Text(
          'Riwayat',
          style: blackTextStyle.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: greenColor,
              ),
              labelColor: Colors.white,
              unselectedLabelColor: greyColor,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Transaksi'),
                Tab(text: 'Aktivitas'),
                Tab(text: 'Penghasilan'),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionHistory(),
                _buildActivityHistory(),
                _buildEarningsHistory(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _transactionHistory.length,
      itemBuilder: (context, index) {
        final transaction = _transactionHistory[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        transaction['status'],
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.local_shipping_rounded,
                      color: _getStatusColor(transaction['status']),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction['title'],
                          style: blackTextStyle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          transaction['location'],
                          style: greyTextStyle.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        transaction['status'],
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(transaction['status']),
                      style: TextStyle(
                        color: _getStatusColor(transaction['status']),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time_rounded, color: greyColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${transaction['date']} • ${transaction['time']}',
                    style: greyTextStyle.copyWith(fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    transaction['amount'],
                    style: blackTextStyle.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    transaction['points'],
                    style: TextStyle(
                      color: greenColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityHistory() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _activityHistory.length,
      itemBuilder: (context, index) {
        final activity = _activityHistory[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getActivityColor(activity['type']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getActivityIcon(activity['type']),
                  color: _getActivityColor(activity['type']),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['title'],
                      style: blackTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      activity['description'],
                      style: greyTextStyle.copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${activity['date']} • ${activity['time']}',
                      style: greyTextStyle.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEarningsHistory() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _earnings.length,
      itemBuilder: (context, index) {
        final earning = _earnings[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: greenColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  earning['type'] == 'bonus'
                      ? Icons.card_giftcard_rounded
                      : Icons.account_balance_wallet_rounded,
                  color: greenColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      earning['title'],
                      style: blackTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      earning['date'],
                      style: greyTextStyle.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                earning['amount'],
                style: TextStyle(
                  color: greenColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return greenColor;
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Proses';
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'login':
        return const Color(0xFF3B82F6);
      case 'profile':
        return const Color(0xFF8B5CF6);
      case 'schedule':
        return greenColor;
      default:
        return greyColor;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'login':
        return Icons.login_rounded;
      case 'profile':
        return Icons.person_rounded;
      case 'schedule':
        return Icons.schedule_rounded;
      default:
        return Icons.info_rounded;
    }
  }
}

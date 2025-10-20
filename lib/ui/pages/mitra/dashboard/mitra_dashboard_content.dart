import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/services/mitra_service.dart';
import 'package:bank_sha/services/api_service_manager.dart';
import 'package:bank_sha/services/api_service_manager_extension.dart';
import 'package:flutter/material.dart';

class MitraDashboardContent extends StatefulWidget {
  const MitraDashboardContent({super.key});

  @override
  State<MitraDashboardContent> createState() => _MitraDashboardContentState();
}

class _MitraDashboardContentState extends State<MitraDashboardContent> {
  final MitraService _mitraService = MitraService();
  final ApiServiceManager _apiManager = ApiServiceManager();

  bool _isLoading = true;
  bool _isOnline = false;
  String _errorMessage = '';

  // Dashboard data
  int _activeOrders = 0;
  int _todayCompleted = 0;
  int _totalPoints = 0;
  int _unreadNotifications = 0;
  String _driverName = '';
  String _driverArea = '';

  @override
  void initState() {
    super.initState();
    _loadDashboard();
    _loadDriverStatus();
  }

  Future<void> _loadDriverStatus() async {
    try {
      final isOnline = await _apiManager.getMitraStatus();
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
        });
      }
    } catch (e) {
      print('Error loading driver status: $e');
    }
  }

  Future<void> _loadDashboard() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Dapatkan data dashboard dari API
      final dashboardData = await _mitraService.getDashboardSummary();

      // Dapatkan user data
      final userData = await _apiManager.getCurrentUserData();

      if (!mounted) return;

      setState(() {
        _activeOrders = dashboardData['active_orders'] ?? 0;
        _todayCompleted = dashboardData['today_completed'] ?? 0;
        _totalPoints = dashboardData['total_points'] ?? 0;
        _unreadNotifications = dashboardData['unread_notifications'] ?? 0;
        _driverName = userData['name'] ?? 'Driver';
        _driverArea = userData['work_area'] ?? 'Jakarta';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Gagal memuat data: ${e.toString()}';
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data dashboard: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleOnlineStatus() async {
    try {
      final newStatus = !_isOnline;
      await _apiManager.setMitraStatus(newStatus);

      if (mounted) {
        setState(() {
          _isOnline = newStatus;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isOnline
                  ? 'Anda sekarang ONLINE dan dapat menerima tugas'
                  : 'Anda sekarang OFFLINE',
            ),
            backgroundColor: _isOnline ? greenColor : Colors.grey,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah status: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: _isLoading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: CircularProgressIndicator(),
                ),
              )
            : _errorMessage.isNotEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 100),
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 50,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadDashboard,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang',
                            style: greyTextStyle.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _driverName,
                            style: blackTextStyle.copyWith(
                              fontSize: 20,
                              fontWeight: semiBold,
                            ),
                          ),
                          Text(
                            'Area: $_driverArea',
                            style: greyTextStyle.copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isOnline,
                        onChanged: (value) => _toggleOnlineStatus(),
                        activeThumbColor: greenColor,
                        activeTrackColor: greenColor.withOpacity(0.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Stats cards
                  Text(
                    'Ringkasan Hari Ini',
                    style: blackTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: semiBold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _buildStatCard(
                        title: 'Tugas Aktif',
                        value: _activeOrders.toString(),
                        icon: Icons.pending_actions,
                        color: blueColor,
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard(
                        title: 'Selesai Hari Ini',
                        value: _todayCompleted.toString(),
                        icon: Icons.check_circle_outline,
                        color: greenColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatCard(
                        title: 'Total Poin',
                        value: _totalPoints.toString(),
                        icon: Icons.star_border,
                        color: yellowColor,
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard(
                        title: 'Notifikasi',
                        value: _unreadNotifications.toString(),
                        icon: Icons.notifications_none,
                        color: purpleColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Status section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: _isOnline ? greenColor : Colors.grey,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status Anda:',
                          style: whiteTextStyle.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isOnline ? 'AKTIF' : 'TIDAK AKTIF',
                          style: whiteTextStyle.copyWith(
                            fontSize: 20,
                            fontWeight: semiBold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isOnline
                              ? 'Anda saat ini dapat menerima tugas pengambilan sampah.'
                              : 'Aktifkan status untuk mulai menerima tugas.',
                          style: whiteTextStyle.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 150,
                          child: TextButton(
                            onPressed: _toggleOnlineStatus,
                            style: TextButton.styleFrom(
                              backgroundColor: whiteColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(56),
                              ),
                            ),
                            child: Text(
                              _isOnline ? 'NONAKTIFKAN' : 'AKTIFKAN',
                              style: blackTextStyle.copyWith(
                                fontSize: 14,
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
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: whiteColor,
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
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Icon(icon, color: color, size: 24)),
                ),
                const SizedBox(width: 14),
                Text(
                  value,
                  style: blackTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: semiBold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: greyTextStyle.copyWith(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

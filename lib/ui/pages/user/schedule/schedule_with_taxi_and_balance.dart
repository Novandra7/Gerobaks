import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScheduleWithTaxiAndBalance extends StatefulWidget {
  const ScheduleWithTaxiAndBalance({Key? key}) : super(key: key);

  @override
  State<ScheduleWithTaxiAndBalance> createState() => _ScheduleWithTaxiAndBalanceState();
}

class _ScheduleWithTaxiAndBalanceState extends State<ScheduleWithTaxiAndBalance> {
  bool _isLoading = false;
  bool _showEmptyState = false;
  List<Map<String, dynamic>> _schedules = [];
  double _balance = 250000; // Nilai awal untuk contoh
  bool _isBalanceLoading = true;
  String? _balanceError;
  final String _taxiPhoneNumber = '+62 812-3456-7890';
  bool _isCalling = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isBalanceLoading = true;
      _balanceError = null;
    });

    // Simulasi pemanggilan API untuk mendapatkan data
    await Future.delayed(const Duration(milliseconds: 1200));

    // Simulasi data jadwal
    final schedules = [
      {
        'id': '1',
        'title': 'Pengambilan Sampah Rumah Tangga',
        'date': DateTime.now().add(const Duration(days: 1)),
        'time': '09:00',
        'address': 'Jl. Merdeka No. 123, Surabaya',
        'status': 'pending',
        'wasteType': 'Organik',
        'weight': 5.0,
      },
      {
        'id': '2',
        'title': 'Pengambilan Sampah Elektronik',
        'date': DateTime.now().add(const Duration(days: 3)),
        'time': '14:30',
        'address': 'Jl. Pahlawan No. 45, Surabaya',
        'status': 'confirmed',
        'wasteType': 'Elektronik',
        'weight': 2.5,
      },
    ];

    // Simulasi panggilan API untuk mendapatkan saldo
    try {
      // Dalam implementasi nyata, ini adalah panggilan API sebenarnya
      // final response = await http.get(Uri.parse('https://example.com/saldo/user/123'));
      
      // Simulasi respons
      // if (response.statusCode == 200) {
      //   final data = json.decode(response.body);
      //   _balance = data['balance'];
      // }
      
      // Untuk demo, gunakan nilai tetap
      _balance = 250000;
      _balanceError = null;
    } catch (e) {
      _balanceError = 'Gagal memuat saldo';
    }

    if (mounted) {
      setState(() {
        _schedules = schedules;
        _showEmptyState = _schedules.isEmpty;
        _isLoading = false;
        _isBalanceLoading = false;
      });
    }
  }

  void _onTaxiCall() async {
    setState(() {
      _isCalling = true;
    });

    // Simulasi panggilan taksi (dalam aplikasi nyata, gunakan url_launcher)
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Panggil Taksi',
            style: blackTextStyle.copyWith(
              fontWeight: semiBold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Anda akan menghubungi:',
                style: blackTextStyle,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: greenColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_taxi,
                      color: greenColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Taksi Gerobaks',
                            style: blackTextStyle.copyWith(
                              fontWeight: semiBold,
                            ),
                          ),
                          Text(
                            _taxiPhoneNumber,
                            style: greyTextStyle.copyWith(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isCalling = false;
                });
              },
              child: Text(
                'Batal',
                style: greyTextStyle,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Simulasi panggilan
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          Icons.call,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text('Menghubungi $_taxiPhoneNumber...'),
                      ],
                    ),
                    duration: const Duration(seconds: 2),
                    backgroundColor: greenColor,
                  ),
                );
                
                // Reset status panggilan setelah beberapa saat
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) {
                    setState(() {
                      _isCalling = false;
                    });
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: greenColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Hubungi',
                style: whiteTextStyle.copyWith(
                  fontWeight: semiBold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Jadwal Pengambilan',
          style: blackTextStyle.copyWith(
            fontSize: 20,
            fontWeight: semiBold,
          ),
        ),
        centerTitle: true,
        backgroundColor: whiteColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: blackColor,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          children: [
            // Balance Card
            _buildBalanceCard(),
            
            const SizedBox(height: 24),
            
            // Schedules
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Jadwal Mendatang',
                  style: blackTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: semiBold,
                  ),
                ),
                if (_isLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        greenColor,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Schedules List or Empty State
            _isLoading 
                ? _buildLoadingSkeleton() 
                : _showEmptyState 
                    ? _buildEmptyState() 
                    : _buildSchedulesList(),
            
            // Taxi Call Section
            const SizedBox(height: 32),
            _buildTaxiCallCard(),
            
            const SizedBox(height: 80), // Bottom padding for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to add schedule
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Navigasi ke halaman tambah jadwal'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        backgroundColor: greenColor,
        icon: const Icon(Icons.add),
        label: Text(
          'Jadwal Baru',
          style: whiteTextStyle.copyWith(
            fontWeight: semiBold,
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    final formatCurrency = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      width: double.infinity,
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            greenColor.withOpacity(0.9),
            greenColor,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saldo Anda',
                style: whiteTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: medium,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: whiteColor,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'e-Wallet',
                    style: whiteTextStyle.copyWith(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _isBalanceLoading
              ? Container(
                  height: 28,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                )
              : _balanceError != null
                  ? Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.orange,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _balanceError!,
                          style: whiteTextStyle.copyWith(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatCurrency.format(_balance),
                          style: whiteTextStyle.copyWith(
                            fontSize: 24,
                            fontWeight: bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Icon(
                            Icons.visibility,
                            color: whiteColor.withOpacity(0.7),
                            size: 16,
                          ),
                        ),
                      ],
                    ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildBalanceActionButton(
                icon: Icons.add,
                label: 'Top Up',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Navigasi ke halaman top up'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              _buildBalanceActionButton(
                icon: Icons.swap_horiz,
                label: 'Transfer',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Navigasi ke halaman transfer'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              _buildBalanceActionButton(
                icon: Icons.history,
                label: 'Riwayat',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Navigasi ke halaman riwayat'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: whiteColor,
                size: 18,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: whiteTextStyle.copyWith(
                  fontSize: 12,
                  fontWeight: medium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      children: List.generate(2, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Skeleton status bar
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 100,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Container(
                          width: 80,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 200,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 150,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 60,
        horizontal: 24,
      ),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 70,
            color: greyColor,
          ),
          const SizedBox(height: 20),
          Text(
            'Belum Ada Jadwal',
            style: blackTextStyle.copyWith(
              fontSize: 20,
              fontWeight: semiBold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Buat jadwal pengambilan sampah\npertama Anda sekarang!',
            style: greyTextStyle.copyWith(
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Navigasi ke halaman tambah jadwal'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: greenColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(56),
              ),
            ),
            child: Text(
              'Buat Jadwal',
              style: whiteTextStyle.copyWith(
                fontSize: 16,
                fontWeight: semiBold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedulesList() {
    return Column(
      children: _schedules.map((schedule) {
        final statusInfo = _getStatusInfo(schedule['status']);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status bar at top
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: statusInfo['color'],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time and status row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Time slot
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              color: greenColor,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              schedule['time'],
                              style: blackTextStyle.copyWith(
                                fontSize: 14,
                                fontWeight: medium,
                              ),
                            ),
                          ],
                        ),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusInfo['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                statusInfo['icon'],
                                color: statusInfo['color'],
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                statusInfo['text'],
                                style: TextStyle(
                                  color: statusInfo['color'],
                                  fontSize: 12,
                                  fontWeight: medium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Title
                    Text(
                      schedule['title'],
                      style: blackTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: semiBold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Address
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: greyColor,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            schedule['address'],
                            style: greyTextStyle.copyWith(
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          color: greyColor,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('dd MMMM yyyy').format(schedule['date']),
                          style: greyTextStyle.copyWith(
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Waste type and weight
                    Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: greyColor,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          schedule['wasteType'],
                          style: greyTextStyle.copyWith(
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.scale,
                          color: greyColor,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${schedule['weight']} kg',
                          style: greyTextStyle.copyWith(
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Menampilkan detail jadwal'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: greenColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Detail',
                              style: TextStyle(
                                color: greenColor,
                                fontWeight: medium,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _onTaxiCall();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: greenColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.local_taxi,
                                  color: whiteColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Panggil Taksi',
                                  style: whiteTextStyle.copyWith(
                                    fontWeight: medium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTaxiCallCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFD700).withOpacity(0.9),
            Color(0xFFFFD700),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_taxi,
                color: Colors.black87,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Butuh Transportasi?',
                style: blackTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: semiBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Anda dapat menghubungi taksi untuk transportasi menuju lokasi pengambilan sampah atau untuk keperluan lainnya.',
            style: blackTextStyle.copyWith(
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: _isCalling ? null : _onTaxiCall,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: _isCalling
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.call),
              label: Text(
                _isCalling ? 'Menghubungi...' : 'Panggil Taksi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'pending':
        return {
          'color': Colors.orange,
          'text': 'Menunggu',
          'icon': Icons.access_time_rounded,
        };
      case 'confirmed':
        return {
          'color': Colors.blue,
          'text': 'Terkonfirmasi',
          'icon': Icons.check_circle_outline,
        };
      case 'in_progress':
        return {
          'color': Colors.blue,
          'text': 'Sedang Berjalan',
          'icon': Icons.directions_car_rounded,
        };
      case 'completed':
        return {
          'color': Colors.green,
          'text': 'Selesai',
          'icon': Icons.check_circle_outline_rounded,
        };
      case 'cancelled':
        return {
          'color': Colors.red,
          'text': 'Dibatalkan',
          'icon': Icons.cancel_outlined,
        };
      default:
        return {
          'color': Colors.grey,
          'text': 'Tidak Diketahui',
          'icon': Icons.help_outline,
        };
    }
  }
}

import 'package:bank_sha/models/schedule_model.dart';
import 'package:bank_sha/services/balance_service.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/taxi_call_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserSchedulesPageWithTaxi extends StatefulWidget {
  const UserSchedulesPageWithTaxi({super.key});

  @override
  State<UserSchedulesPageWithTaxi> createState() =>
      _UserSchedulesPageWithTaxiState();
}

class _UserSchedulesPageWithTaxiState extends State<UserSchedulesPageWithTaxi> {
  bool _isLoading = false;
  bool _showEmptyState = false;
  List<ScheduleModel> _schedules = [];
  final String _userId =
      '123'; // Ganti dengan ID pengguna dari sistem autentikasi

  // Nomor telepon taksi - ganti dengan nomor yang sebenarnya
  final String _taxiPhoneNumber = '+62 812-3456-7890';

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoading = true;
    });

    // Di sini Anda akan mengambil jadwal dari API atau penyimpanan lokal
    // Contoh implementasi:
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      // Contoh data jadwal
      // Dalam implementasi nyata, Anda akan mengambilnya dari API
      _schedules = [];
      _showEmptyState = _schedules.isEmpty;
      _isLoading = false;
    });
  }

  void _onTaxiCall() async {
    // Di sini Anda akan mengimplementasikan fungsi panggilan sebenarnya
    // Misalnya, menggunakan url_launcher untuk membuat panggilan telepon

    // Untuk demonstrasi, kami hanya menampilkan dialog konfirmasi
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Panggil Taksi',
            style: blackTextStyle.copyWith(fontWeight: semiBold),
          ),
          content: Text(
            'Anda akan dihubungkan dengan layanan taksi di $_taxiPhoneNumber',
            style: blackTextStyle,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal', style: greyTextStyle),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Menghubungi taksi...'),
                    duration: Duration(seconds: 2),
                    backgroundColor: greenColor,
                  ),
                );
              },
              child: Text(
                'Hubungi',
                style: TextStyle(color: greenColor, fontWeight: semiBold),
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
          style: blackTextStyle.copyWith(fontSize: 20, fontWeight: semiBold),
        ),
        centerTitle: true,
        backgroundColor: whiteColor,
        elevation: 0,
        iconTheme: IconThemeData(color: blackColor),
      ),
      body: RefreshIndicator(
        onRefresh: _loadSchedules,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            // Balance Card
            BalanceCard(
              userId: _userId,
              onTap: () {
                // Anda dapat menambahkan navigasi ke layar detail saldo atau topup di sini
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Memperbarui saldo...'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Schedule List
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          valueColor: AlwaysStoppedAnimation<Color>(greenColor),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_showEmptyState)
                  _buildEmptyState()
                else
                  _buildScheduleList(),
              ],
            ),

            // Taxi Call Section
            const SizedBox(height: 32),
            Container(
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
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_taxi, color: greenColor, size: 24),
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
                    style: blackTextStyle.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TaxiCallButton(
                      onCall: _onTaxiCall,
                      phoneNumber: _taxiPhoneNumber,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80), // Bottom padding for FAB
          ],
        ),
      ),
      floatingActionButton: TaxiCallFAB(
        onCall: _onTaxiCall,
        phoneNumber: _taxiPhoneNumber,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 70, color: greyColor),
          const SizedBox(height: 20),
          Text(
            'Belum Ada Jadwal',
            style: blackTextStyle.copyWith(fontSize: 20, fontWeight: semiBold),
          ),
          const SizedBox(height: 10),
          Text(
            'Buat jadwal pengambilan sampah\npertama Anda sekarang!',
            style: greyTextStyle.copyWith(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/user-add-schedule');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: greenColor,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
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

  Widget _buildScheduleList() {
    return Column(
      children: List.generate(2, (index) {
        // Contoh data jadwal
        final date = DateFormat(
          'dd MMMM yyyy',
        ).format(DateTime.now().add(Duration(days: index)));
        final time = '${9 + index}:00 WIB';
        final title = 'Jadwal Pengambilan Sampah ${index + 1}';
        final status = index == 0 ? 'pending' : 'in_progress';

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
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
                    color: status == 'pending' ? Colors.orange : greenColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
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
                                time,
                                style: blackTextStyle.copyWith(
                                  fontSize: 14,
                                  fontWeight: medium,
                                ),
                              ),
                            ],
                          ),
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (status == 'pending'
                                          ? Colors.orange
                                          : greenColor)
                                      .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  status == 'pending'
                                      ? Icons.access_time_rounded
                                      : Icons.directions_car_rounded,
                                  color: status == 'pending'
                                      ? Colors.orange
                                      : greenColor,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  status == 'pending'
                                      ? 'Menunggu'
                                      : 'Sedang Berjalan',
                                  style: TextStyle(
                                    color: status == 'pending'
                                        ? Colors.orange
                                        : greenColor,
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
                        title,
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
                              'Jl. Contoh No. ${index + 1}, Kota Surabaya',
                              style: greyTextStyle.copyWith(fontSize: 13),
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
                            date,
                            style: greyTextStyle.copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

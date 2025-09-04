import 'package:bank_sha/models/schedule_model.dart';
import 'package:bank_sha/services/balance_service.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/schedule_item.dart';
import 'package:bank_sha/ui/widgets/shared/taxi_call_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bank_sha/blocs/schedule/schedule_bloc.dart';
import 'package:intl/intl.dart';

class UserSchedulesPageNew extends StatefulWidget {
  const UserSchedulesPageNew({Key? key}) : super(key: key);

  @override
  State<UserSchedulesPageNew> createState() => _UserSchedulesPageNewState();
}

class _UserSchedulesPageNewState extends State<UserSchedulesPageNew> {
  bool _isLoading = false;
  bool _showEmptyState = false;
  List<ScheduleModel> _schedules = [];
  final String _userId = '123'; // Replace with actual user ID from your auth system
  
  // Taxi phone number - replace with your actual number
  final String _taxiPhoneNumber = '+62 812-3456-7890';

  @override
  void initState() {
    super.initState();
    context.read<ScheduleBloc>().add(ScheduleFetch());
  }

  void _onTaxiCall() async {
    // Here you would implement the actual call functionality
    // For example, using url_launcher to make a phone call
    
    // For demonstration, we're just showing a confirmation dialog
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
          content: Text(
            'Anda akan dihubungkan dengan layanan taksi di $_taxiPhoneNumber',
            style: blackTextStyle,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Batal',
                style: greyTextStyle,
              ),
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
                style: TextStyle(
                  color: greenColor,
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
        onRefresh: () async {
          context.read<ScheduleBloc>().add(ScheduleFetch());
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          children: [
            // Balance Card
            BalanceCard(
              userId: _userId,
              onTap: () {
                // You can add navigation to balance details or topup screen here
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
            BlocConsumer<ScheduleBloc, ScheduleState>(
              listener: (context, state) {
                if (state is ScheduleSuccess) {
                  setState(() {
                    _schedules = state.schedules;
                    _showEmptyState = _schedules.isEmpty;
                    _isLoading = false;
                  });
                }
                
                if (state is ScheduleLoading) {
                  setState(() {
                    _isLoading = true;
                    _showEmptyState = false;
                  });
                }
                
                if (state is ScheduleFailed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.e),
                      backgroundColor: redcolor,
                    ),
                  );
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              builder: (context, state) {
                return Column(
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                greenColor,
                              ),
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
                );
              },
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
                      Icon(
                        Icons.local_taxi,
                        color: greenColor,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/user-add-schedule');
        },
        backgroundColor: greenColor,
        child: Icon(
          Icons.add,
          color: whiteColor,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 60,
      ),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(20),
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
              Navigator.pushNamed(context, '/user-add-schedule');
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

  Widget _buildScheduleList() {
    return Column(
      children: _schedules.map((schedule) {
        // Format date
        final date = schedule.date != null
            ? DateFormat('dd MMMM yyyy').format(schedule.date!)
            : 'Tanggal tidak tersedia';
            
        // Format time
        final time = schedule.time != null
            ? schedule.time!
            : 'Waktu tidak tersedia';
            
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ScheduleItem(
            title: schedule.title ?? 'Jadwal Pengambilan Sampah',
            date: date,
            time: time,
            status: schedule.status ?? 'pending',
            onTap: () {
              // Navigate to detail page
              Navigator.pushNamed(
                context,
                '/user-schedule-detail',
                arguments: schedule,
              );
            },
          ),
        );
      }).toList(),
    );
  }
}

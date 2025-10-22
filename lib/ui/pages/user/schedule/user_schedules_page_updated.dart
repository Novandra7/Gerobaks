import 'package:bank_sha/models/schedule_model.dart';
import 'package:bank_sha/services/balance_service.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/schedule_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bank_sha/blocs/schedule/schedule_bloc.dart';
import 'package:bank_sha/blocs/schedule/schedule_event.dart';
import 'package:bank_sha/blocs/schedule/schedule_state.dart';
import 'package:intl/intl.dart';

class UserSchedulesPageNew extends StatefulWidget {
  const UserSchedulesPageNew({super.key});

  @override
  State<UserSchedulesPageNew> createState() => _UserSchedulesPageNewState();
}

class _UserSchedulesPageNewState extends State<UserSchedulesPageNew> {
  bool _isLoading = true;
  bool _showEmptyState = false;
  List<ScheduleModel> _schedules = [];
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
    });

    final localStorage = await LocalStorageService.getInstance();
    final userData = await localStorage.getUserData();
    final fetchedUserId = userData?['id']?.toString();

    if (!mounted) return;

    setState(() {
      _userId = (fetchedUserId == null || fetchedUserId.isEmpty)
          ? null
          : fetchedUserId;
    });

    context.read<ScheduleBloc>().add(ScheduleFetch(fallbackUserId: _userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackgroundColor,
      resizeToAvoidBottomInset: false, // Mencegah resize ketika keyboard muncul
      extendBody: true, // Membuat body diperpanjang hingga di belakang FAB
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
        onRefresh: () async {
          setState(() {
            _isLoading = true;
          });
          context.read<ScheduleBloc>().add(
            ScheduleFetch(fallbackUserId: _userId),
          );
          await Future.delayed(const Duration(milliseconds: 350));
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            // Balance Card
            if (_userId != null)
              BalanceCard(
                userId: _userId!,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Memperbarui saldo...'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              )
            else
              _buildBalanceLoading(),

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
                      content: Text(state.error),
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

            const SizedBox(height: 80), // Bottom padding for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/user-add-schedule');
        },
        backgroundColor: greenColor,
        elevation:
            4, // Tambahkan elevation untuk efek bayangan yang lebih jelas
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Ubah border radius
        ),
        child: Icon(Icons.add, color: whiteColor),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // Tetapkan posisi FAB
    );
  }

  Widget _buildBalanceLoading() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(greenColor),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Memuat saldo...',
            style: blackTextStyle.copyWith(fontSize: 16, fontWeight: semiBold),
          ),
        ],
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
      children: _schedules.map((schedule) {
        // Format date
        final date = DateFormat('dd MMMM yyyy').format(schedule.scheduledDate);

        // Format time
        final time =
            '${schedule.timeSlot.hour}:${schedule.timeSlot.minute.toString().padLeft(2, '0')}';

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ScheduleItem(
            title: 'Jadwal Pengambilan Sampah',
            date: date,
            time: time,
            status: schedule.status.toString().split('.').last,
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

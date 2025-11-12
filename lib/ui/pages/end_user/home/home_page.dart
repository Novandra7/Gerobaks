import 'package:bank_sha/ui/pages/end_user/popupiklan.dart';
import 'package:bank_sha/ui/pages/end_user/wilayah/wilayah_page.dart';
import 'package:bank_sha/ui/pages/user/schedule/add_schedule_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bank_sha/blocs/schedule/schedule_bloc.dart';
import 'package:bank_sha/services/popup_notification_service.dart';
import 'package:bank_sha/services/waste_schedule_service.dart';
import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/pages/end_user/activity/activity_page_improved.dart';
import 'package:bank_sha/ui/pages/end_user/profile/profile_page.dart';
import 'package:bank_sha/ui/pages/end_user/home/home_content.dart';
import 'package:bank_sha/ui/widgets/shared/navbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  int _activityPageKey = 0; // Key to force activity page refresh

  List<Widget> _buildPages() => [
    const HomeContent(),
    ActivityPageImproved(key: ValueKey(_activityPageKey)),
    const WilayahPage(),
    const ProfilePage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    // Tampilkan popup iklan, lalu notifikasi jadwal setelah iklan ditutup
    _showInitialPopups();
  }

  void _showInitialPopups() async {
    try {
      // Tunggu sebentar setelah build selesai
      await Future.delayed(const Duration(milliseconds: 500));

      // Tampilkan popup iklan dan tunggu sampai ditutup
      await showIklanPopup(context);

      // Setelah popup iklan ditutup, tampilkan notifikasi jadwal (jika ada)
      if (mounted && WasteScheduleService.hasTodayPickup()) {
        // Beri jeda sebentar untuk transisi yang smooth
        await Future.delayed(const Duration(milliseconds: 300));
        PopupNotificationService.showWasteScheduleNotification(context);
      }
    } catch (e) {
      // Jika ada error dengan popup iklan, tetap tampilkan notifikasi jadwal
      if (mounted && WasteScheduleService.hasTodayPickup()) {
        await Future.delayed(const Duration(milliseconds: 800));
        PopupNotificationService.showWasteScheduleNotification(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: uicolor,
      floatingActionButton: Container(
        height: 60,
        width: 60,
        margin: const EdgeInsets.only(top: 30),
        child: FloatingActionButton(
          onPressed: () async {
            // Allow adding schedule without subscription requirement
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  value: context.read<ScheduleBloc>(),
                  child: const AddSchedulePage(),
                ),
              ),
            );

            // If schedule was created successfully, refresh activity page
            if (result == true) {
              // Increment key to force activity page rebuild
              setState(() {
                _activityPageKey++; // Increment key to force rebuild
                print(
                  '🔄 Schedule created successfully, refreshing activity page...',
                );
              });

              // If user not on activity tab, switch to it to show the new schedule
              if (_currentIndex != 1) {
                setState(() {
                  _currentIndex = 1; // Switch to activity tab
                });
              }
            }
          },
          elevation: 4,
          highlightElevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: Colors.white, width: 3),
          ),
          backgroundColor: greenColor,
          child: Icon(Icons.add_rounded, color: whiteColor, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTabTapped: _onTabTapped,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _buildPages()[_currentIndex],
      ),
    );
  }
}

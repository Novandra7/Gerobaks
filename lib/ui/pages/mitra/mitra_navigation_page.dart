import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/pages/mitra/aktivitas/aktivitas_mitra_page.dart';
import 'package:bank_sha/ui/pages/mitra/dashboard/mitra_dashboard_page_new.dart';
import 'package:bank_sha/ui/pages/mitra/mitra_home_page.dart'; // Updated to use MitraHomePage (Jadwal Tersedia with tabs)
import 'package:bank_sha/ui/pages/mitra/profile/profile_mitra_page.dart';
import 'package:flutter/material.dart';

class MitraNavigationPage extends StatefulWidget {
  const MitraNavigationPage({super.key});

  @override
  State<MitraNavigationPage> createState() => _MitraNavigationPageState();
}

class _MitraNavigationPageState extends State<MitraNavigationPage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const MitraDashboardPageNew(),
    const MitraHomePage(), // Updated: Now shows Jadwal Tersedia with sliding tabs
    const AktivitasMitraPage(),
    const ProfileMitraPage(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: whiteColor,
        currentIndex: _currentIndex,
        selectedItemColor: greenColor,
        unselectedItemColor: greyColor,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: greenTextStyle.copyWith(
          fontSize: 10,
          fontWeight: medium,
        ),
        unselectedLabelStyle: greyTextStyle.copyWith(
          fontSize: 10,
          fontWeight: medium,
        ),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.jumpToPage(index);
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/ic_overview.png',
              width: 20,
              color: _currentIndex == 0 ? greenColor : greyColor,
            ),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/ic_calender.png',
              width: 20,
              color: _currentIndex == 1 ? greenColor : greyColor,
            ),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/ic_history.png',
              width: 20,
              color: _currentIndex == 2 ? greenColor : greyColor,
            ),
            label: 'Aktivitas',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/ic_profile.png',
              width: 20,
              color: _currentIndex == 3 ? greenColor : greyColor,
            ),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

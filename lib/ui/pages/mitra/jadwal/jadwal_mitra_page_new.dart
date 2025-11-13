import 'package:bank_sha/ui/pages/mitra/available_schedules_tab_content.dart';
import 'package:bank_sha/ui/pages/mitra/active_schedules_page.dart';
import 'package:bank_sha/ui/pages/mitra/history_page.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';

/// Jadwal Tersedia Page - Main page untuk mitra dengan 3 sliding tabs
/// Contains: Tersedia, Aktif, and Riwayat tabs (can be swiped)
class JadwalMitraPageNew extends StatefulWidget {
  const JadwalMitraPageNew({super.key});

  @override
  State<JadwalMitraPageNew> createState() => _JadwalMitraPageNewState();
}

class _JadwalMitraPageNewState extends State<JadwalMitraPageNew>
    with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: uicolor, // Background color dari theme
      ),
      child: Column(
        children: [
          // Custom AppBar with TabBar
          Container(
            color: whiteColor,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Jadwal Tersedia',
                          style: blackTextStyle.copyWith(
                            fontSize: 20,
                            fontWeight: bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.notifications_outlined, color: blackColor),
                          onPressed: () {
                            // Handle notification
                          },
                        ),
                      ],
                    ),
                  ),

                  // TabBar
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: greyColor.withOpacity(0.3), width: 1),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: greenColor,
                      unselectedLabelColor: greyColor,
                      indicatorColor: greenColor,
                      indicatorWeight: 3,
                      labelStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: semiBold,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: regular,
                      ),
                      tabs: const [
                        Tab(text: 'Tersedia'),
                        Tab(text: 'Aktif'),
                        Tab(text: 'Riwayat'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // TabBarView (swipeable content)
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                AvailableSchedulesTabContent(),
                ActiveSchedulesPage(),
                HistoryPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

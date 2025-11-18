import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';
import 'available_schedules_tab_content.dart';
import 'active_schedules_page.dart';
import 'history_page.dart';

/// Main navigation container for Mitra role - Jadwal Tersedia dengan sliding tabs
/// Contains 3 tabs: Tersedia, Aktif, and Riwayat (can be swiped)
class MitraHomePage extends StatefulWidget {
  const MitraHomePage({super.key});

  @override
  State<MitraHomePage> createState() => _MitraHomePageState();
}

class _MitraHomePageState extends State<MitraHomePage>
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
                          icon: Icon(
                            Icons.notifications_outlined,
                            color: blackColor,
                          ),
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
                        bottom: BorderSide(
                          color: greyColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: greenColor,
                      unselectedLabelColor: greyColor,
                      indicatorColor: greenColor,
                      indicatorWeight: 3,
                      labelStyle: TextStyle(fontSize: 15, fontWeight: semiBold),
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

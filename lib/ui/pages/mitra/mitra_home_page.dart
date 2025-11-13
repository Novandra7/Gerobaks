import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      decoration: const BoxDecoration(
        color: Color(0xFFF9FFF8), // Background color
      ),
      child: Column(
        children: [
          // Custom AppBar with TabBar
          Container(
            color: Colors.white,
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
                        const Text(
                          'Jadwal Tersedia',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
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
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.green,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.green,
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
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

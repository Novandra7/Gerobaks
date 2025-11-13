import 'package:flutter/material.dart';
import 'available_schedules_page.dart';
import 'active_schedules_page.dart';
import 'history_page.dart';

/// Main navigation container for Mitra role
/// Contains 3 tabs: Available Schedules, Active Schedules, and History
class MitraHomePage extends StatefulWidget {
  const MitraHomePage({super.key});

  @override
  State<MitraHomePage> createState() => _MitraHomePageState();
}

class _MitraHomePageState extends State<MitraHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const AvailableSchedulesPage(),
    const ActiveSchedulesPage(),
    const HistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Tersedia',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            activeIcon: Icon(Icons.work),
            label: 'Aktif',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
        ],
      ),
    );
  }
}

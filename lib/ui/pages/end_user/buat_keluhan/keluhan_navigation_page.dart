import 'package:bank_sha/ui/pages/end_user/buat_keluhan/buat_keluhan_page.dart';
import 'package:bank_sha/ui/pages/end_user/buat_keluhan/keluhan_page_new.dart';
import 'package:bank_sha/ui/pages/end_user/buat_keluhan/improved_keluhan_form.dart';
import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';

class KeluhanNavigationPage extends StatefulWidget {
  const KeluhanNavigationPage({super.key});

  @override
  State<KeluhanNavigationPage> createState() => _KeluhanNavigationPageState();
}

class _KeluhanNavigationPageState extends State<KeluhanNavigationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  
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
  
  final List<Widget> _pages = [
    const KeluhanPage(), // New implementation
    const BuatKeluhanPage(), // Original implementation
    const BuatKeluhanFormEnhanced(), // Enhanced form
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: uicolor,
      appBar: const CustomAppBar(
        title: 'Keluhan Gerobaks',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            margin: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              controller: _tabController,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: greenColor,
              ),
              labelColor: whiteColor,
              unselectedLabelColor: greyColor,
              labelStyle: blackTextStyle.copyWith(
                fontWeight: semiBold,
              ),
              unselectedLabelStyle: blackTextStyle,
              tabs: const [
                Tab(text: 'Modern UI'),
                Tab(text: 'Original'),
                Tab(text: 'Enhanced Form'),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: _pages[_currentIndex],
          ),
        ],
      ),
    );
  }
}

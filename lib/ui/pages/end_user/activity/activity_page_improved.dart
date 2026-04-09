import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar_improved.dart';
import 'package:bank_sha/ui/pages/end_user/activity/tabs/scheduled_tab.dart';
import 'package:bank_sha/ui/pages/end_user/activity/tabs/ongoing_tab.dart';
import 'package:bank_sha/ui/pages/end_user/activity/tabs/completed_tab.dart';
import 'package:bank_sha/ui/pages/end_user/activity/tabs/cancelled_tab.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class ActivityPageImproved extends StatefulWidget {
  const ActivityPageImproved({super.key});

  @override
  State<ActivityPageImproved> createState() => _ActivityPageImprovedState();
}

class _ActivityPageImprovedState extends State<ActivityPageImproved>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;
  DateTime? selectedDate;
  String currentFilter = 'Semua';

  // Pilihan filter kategori
  final List<String> filterOptions = [
    'Semua',
    'Dijadwalkan',
    'Menuju Lokasi',
    'Dibatalkan',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _tabController = TabController(length: 4, vsync: this);

    // Listen to tab changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // Reset filters when tab changes
        setState(() {
          selectedDate = null;
          currentFilter = 'Semua';
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.light(
              primary: greenColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _resetFilter() {
    setState(() {
      selectedDate = null;
      currentFilter = 'Semua';
    });
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Filter Kategori',
                      style: blackTextStyle.copyWith(
                        fontSize: 18,
                        fontWeight: semiBold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _resetFilter();
                      },
                      child: Text(
                        'Reset',
                        style: greentextstyle2.copyWith(fontWeight: medium),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),

              // Filter options
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filterOptions.length,
                itemBuilder: (context, index) {
                  final option = filterOptions[index];
                  return ListTile(
                    title: Text(
                      option,
                      style: blackTextStyle.copyWith(
                        fontWeight: option == currentFilter
                            ? semiBold
                            : regular,
                      ),
                    ),
                    trailing: option == currentFilter
                        ? Icon(Icons.check, color: greenColor)
                        : null,
                    onTap: () {
                      setState(() {
                        currentFilter = option;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: uicolor,
      appBar: CustomAppHeaderImproved(
        title: 'Aktivitas',
        showIconWithTitle: false, // Tidak perlu menampilkan ikon di judul lagi
        imageAssetPath: 'assets/ic_calender_search.png',
        onActionPressed: _pickDate,
        actions: [
          // Hanya tampilkan tombol filter
          IconButton(
            onPressed: _showFilterOptions,
            icon: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.filter_list, color: blackColor),
                if (currentFilter != 'Semua')
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: greenColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: greenColor,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          indicatorColor: greenColor,
          tabs: const [
            Tab(text: 'Dijadwalkan'),
            Tab(text: 'Berlangsung'),
            Tab(text: 'Selesai'),
            Tab(text: 'Dibatalkan'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter indicator
          if (selectedDate != null || currentFilter != 'Semua')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              color: Colors.grey[50],
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      children: [
                        if (selectedDate != null)
                          Chip(
                            label: Text(
                              DateFormat(
                                'd MMMM yyyy',
                                'id_ID',
                              ).format(selectedDate!),
                              style: blackTextStyle.copyWith(fontSize: 12),
                            ),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () {
                              setState(() {
                                selectedDate = null;
                              });
                            },
                            backgroundColor: Colors.grey[200],
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),

                        if (currentFilter != 'Semua')
                          Chip(
                            label: Text(
                              currentFilter,
                              style: blackTextStyle.copyWith(fontSize: 12),
                            ),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () {
                              setState(() {
                                currentFilter = 'Semua';
                              });
                            },
                            backgroundColor: Colors.grey[200],
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _resetFilter,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Reset',
                      style: greentextstyle2.copyWith(
                        fontSize: 13,
                        fontWeight: medium,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: [
                // Dijadwalkan Tab (Pending)
                ScheduledTab(
                  key: const ValueKey('scheduled-tab'),
                  selectedDate: selectedDate,
                ),

                // Berlangsung Tab (Assigned/On The Way/Arrived)
                OngoingTab(key: const ValueKey('ongoing-tab')),

                // Selesai Tab (Completed)
                CompletedTab(
                  key: const ValueKey('completed-tab'),
                  selectedDate: selectedDate,
                ),

                // Dibatalkan Tab (Cancelled)
                CancelledTab(
                  key: const ValueKey('cancelled-tab'),
                  selectedDate: selectedDate,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

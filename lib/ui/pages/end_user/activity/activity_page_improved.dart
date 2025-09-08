import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar_improved.dart';
import 'package:bank_sha/ui/pages/end_user/activity/activity_content_improved.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class ActivityPageImproved extends StatefulWidget {
  const ActivityPageImproved({super.key});

  @override
  State<ActivityPageImproved> createState() => _ActivityPageImprovedState();
}

class _ActivityPageImprovedState extends State<ActivityPageImproved>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? selectedDate;
  String currentFilter = 'Semua';
  
  // Pilihan filter kategori
  final List<String> filterOptions = [
    'Semua',
    'Dijadwalkan',
    'Menuju Lokasi',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _tabController = TabController(length: 2, vsync: this);
    
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
    // Tampilkan bottom sheet dengan opsi untuk reset dan pilih tanggal
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
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
                      'Filter Tanggal',
                      style: blackTextStyle.copyWith(
                        fontSize: 18,
                        fontWeight: semiBold,
                      ),
                    ),
                    const Spacer(),
                    if (selectedDate != null)
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            selectedDate = null;
                          });
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
              
              // Opsi-opsi filter tanggal
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  'Pilih Tanggal',
                  style: blackTextStyle.copyWith(fontWeight: medium),
                ),
                subtitle: selectedDate != null 
                    ? Text(
                        DateFormat('d MMMM yyyy', 'id_ID').format(selectedDate!),
                        style: greyTextStyle,
                      )
                    : null,
                onTap: () async {
                  // Tutup bottom sheet
                  Navigator.pop(context);
                  
                  // Tampilkan date picker
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: greenColor,
                            onPrimary: Colors.white,
                            surface: Colors.white,
                            onSurface: Colors.black,
                          ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
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
                },
              ),
              
              // Opsi tanggal cepat
              ListTile(
                leading: Icon(Icons.today, color: greenColor),
                title: Text(
                  'Hari Ini',
                  style: blackTextStyle.copyWith(fontWeight: medium),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    selectedDate = DateTime.now();
                  });
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.date_range),
                title: Text(
                  'Minggu Ini',
                  style: blackTextStyle.copyWith(fontWeight: medium),
                ),
                onTap: () {
                  Navigator.pop(context);
                  final now = DateTime.now();
                  // Mencari hari Senin di minggu ini (atau hari ini jika sekarang Senin)
                  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                  setState(() {
                    // Hapus jam, menit, detik untuk mempermudah filter
                    selectedDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
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
                        fontWeight: option == currentFilter ? semiBold : regular,
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
    return Scaffold(
      backgroundColor: uicolor,
      appBar: CustomAppHeaderImproved(
        title: 'Aktivitas',
        // Tampilkan ikon kalender di samping judul Aktivitas
        showIconWithTitle: false, // Tidak perlu menampilkan ikon di judul lagi
        // Gunakan imageAssetPath untuk menampilkan ikon kalender sebagai tombol aksi
        imageAssetPath: 'assets/ic_calender_search.png',
        // Fungsi untuk menangani klik pada tombol kalender
        onActionPressed: _pickDate,
        actions: [
          // Hanya tampilkan tombol filter
          IconButton(
            onPressed: _showFilterOptions,
            icon: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.filter_list,
                  color: blackColor,
                ),
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
            Tab(text: 'Aktif'),
            Tab(text: 'Riwayat'),
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
                              DateFormat('d MMMM yyyy', 'id_ID').format(selectedDate!),
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
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                // Active Tab
                ActivityContentImproved(
                  key: ValueKey('active-tab-${selectedDate?.toString() ?? ''}-$currentFilter'),
                  showActive: true,
                  selectedDate: selectedDate,
                  filterCategory: currentFilter,
                  searchQuery: null, // Tidak ada pencarian
                  onRefresh: () async {
                    // Simulate refresh
                    await Future.delayed(const Duration(seconds: 1));
                    setState(() {});
                    return;
                  },
                ),
                
                // History Tab
                ActivityContentImproved(
                  key: ValueKey('history-tab-${selectedDate?.toString() ?? ''}-$currentFilter'),
                  showActive: false,
                  selectedDate: selectedDate,
                  filterCategory: currentFilter,
                  searchQuery: null, // Tidak ada pencarian
                  onRefresh: () async {
                    // Simulate refresh
                    await Future.delayed(const Duration(seconds: 1));
                    setState(() {});
                    return;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

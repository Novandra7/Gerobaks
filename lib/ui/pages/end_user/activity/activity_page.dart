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
    // Get screen width for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('id', 'ID'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: greenColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textTheme: TextTheme(
              bodyMedium: TextStyle(fontSize: isTablet ? 16 : 14),
              labelLarge: TextStyle(fontSize: isTablet ? 16 : 14),
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
  }

  void _resetFilter() {
    setState(() {
      selectedDate = null;
      currentFilter = 'Semua';
    });
  }

  void _showFilterOptions() {
    // Get screen size for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Untuk memastikan modal bisa scrollable jika konten banyak
      backgroundColor: Colors.transparent, // Untuk memastikan background transparan
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Container(
          width: isTablet ? screenWidth * 0.7 : screenWidth,
          margin: isTablet 
              ? EdgeInsets.symmetric(horizontal: screenWidth * 0.15, vertical: 20) 
              : null,
          padding: EdgeInsets.only(
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
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
              
              // Title dengan padding yang lebih baik
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 30 : 24),
                child: Row(
                  children: [
                    Text(
                      'Filter Kategori',
                      style: blackTextStyle.copyWith(
                        fontSize: isTablet ? 20 : 18,
                        fontWeight: semiBold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _resetFilter();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                      ),
                      child: Text(
                        'Reset',
                        style: greentextstyle2.copyWith(
                          fontWeight: medium, 
                          fontSize: isTablet ? 16 : 14
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Separator dengan margin yang lebih baik
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey[200],
                ),
              ),
              
              // Filter options dengan padding yang lebih konsisten
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filterOptions.length,
                itemBuilder: (context, index) {
                  final option = filterOptions[index];
                  final screenWidth = MediaQuery.of(context).size.width;
                  final isTablet = screenWidth > 600;
                  
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 10 : 0),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
                      title: Text(
                        option,
                        style: blackTextStyle.copyWith(
                          fontWeight: option == currentFilter ? semiBold : regular,
                          fontSize: isTablet ? 16 : 14,
                        ),
                      ),
                      trailing: option == currentFilter
                          ? Icon(Icons.check, color: greenColor, size: isTablet ? 26 : 22)
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      tileColor: option == currentFilter ? greenColor.withOpacity(0.05) : Colors.transparent,
                      onTap: () {
                        setState(() {
                          currentFilter = option;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
              
              // Tambahkan padding di bagian bawah untuk spacing yang lebih baik
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Scaffold(
      backgroundColor: uicolor,
      appBar: CustomAppHeaderImproved(
        title: 'Aktivitas',
        imageAssetPath: 'assets/ic_calender.png',
        onActionPressed: _pickDate,
        actions: [
          Container(
            margin: EdgeInsets.only(right: isTablet ? 8 : 4),
            child: IconButton(
              onPressed: _showFilterOptions,
              icon: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.filter_list,
                    color: blackColor,
                    size: isTablet ? 26 : 24,
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
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: greenColor,
          unselectedLabelColor: Colors.grey[600],
          labelStyle: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: isTablet ? 16 : 14,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: isTablet ? 16 : 14,
          ),
          indicatorColor: greenColor,
          indicatorWeight: 3,
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
          tabs: const [
            Tab(text: 'Aktif'),
            Tab(text: 'Riwayat'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter indicator dengan tampilan yang lebih responsif
          if (selectedDate != null || currentFilter != 'Semua')
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 28 : 24, 
                vertical: isTablet ? 14 : 12
              ),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: isTablet ? 12 : 8,
                      runSpacing: isTablet ? 10 : 6,
                      children: [
                        if (selectedDate != null)
                          Chip(
                            label: Text(
                              DateFormat('d MMMM yyyy', 'id_ID').format(selectedDate!),
                              style: blackTextStyle.copyWith(
                                fontSize: isTablet ? 14 : 12,
                              ),
                            ),
                            deleteIcon: Icon(
                              Icons.close, 
                              size: isTablet ? 18 : 16,
                              color: Colors.grey[600],
                            ),
                            onDeleted: () {
                              setState(() {
                                selectedDate = null;
                              });
                            },
                            backgroundColor: greenColor.withOpacity(0.1),
                            side: BorderSide(color: greenColor.withOpacity(0.2)),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            elevation: 0,
                          ),
                          
                        if (currentFilter != 'Semua')
                          Chip(
                            label: Text(
                              currentFilter,
                              style: blackTextStyle.copyWith(
                                fontSize: isTablet ? 14 : 12,
                                color: greenColor,
                              ),
                            ),
                            deleteIcon: Icon(
                              Icons.close, 
                              size: isTablet ? 18 : 16,
                              color: Colors.grey[600],
                            ),
                            onDeleted: () {
                              setState(() {
                                currentFilter = 'Semua';
                              });
                            },
                            backgroundColor: greenColor.withOpacity(0.1),
                            side: BorderSide(color: greenColor.withOpacity(0.2)),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            elevation: 0,
                          ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _resetFilter,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: isTablet ? 8 : 6,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: Colors.grey.withOpacity(0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Reset',
                      style: greentextstyle2.copyWith(
                        fontSize: isTablet ? 14 : 13,
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
              children: [
                // Active Tab
                ActivityContentImproved(
                  showActive: true,
                  selectedDate: selectedDate,
                  filterCategory: currentFilter,
                ),
                
                // History Tab
                ActivityContentImproved(
                  showActive: false,
                  selectedDate: selectedDate,
                  filterCategory: currentFilter,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

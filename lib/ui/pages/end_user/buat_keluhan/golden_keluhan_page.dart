import 'package:bank_sha/ui/pages/end_user/buat_keluhan/golden_keluhan_form.dart';
import 'package:bank_sha/ui/pages/end_user/buat_keluhan/tanggapan_keluhan_page.dart';
import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';
import 'package:intl/intl.dart';

class GoldenKeluhanPage extends StatefulWidget {
  const GoldenKeluhanPage({super.key});

  @override
  State<GoldenKeluhanPage> createState() => _GoldenKeluhanPageState();
}

class _GoldenKeluhanPageState extends State<GoldenKeluhanPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Data dummy untuk hasil keluhan yang sudah ada
  final List<Map<String, dynamic>> daftarKeluhan = [
    {
      'id': '1723456789012',
      'nama': 'Ghani',
      'judul': 'Sampah belum diambil',
      'kategori': 'Pengambilan Sampah',
      'prioritas': 'Tinggi',
      'tanggal': '2025-08-01',
      'status': 'Sedang Diproses',
      'lokasi': 'Jl. Merdekan No. 123, Samarinda',
      'deskripsi': 'Petugas belum mengambil sampah padahal sudah dijadwalkan untuk hari Senin.'
    },
    {
      'id': '1723456789013',
      'nama': 'Ghani',
      'judul': 'Petugas datang terlambat',
      'kategori': 'Jadwal Terlambat',
      'prioritas': 'Normal',
      'tanggal': '2025-07-30',
      'status': 'Selesai',
      'lokasi': 'Jl. Merdekan No. 123, Samarinda',
      'deskripsi': 'Petugas datang 2 jam lebih lambat dari jadwal yang ditentukan.',
      'balasan': 'Terima kasih atas laporannya. Kami akan melakukan perbaikan sistem untuk memastikan jadwal tepat waktu.'
    },
    {
      'id': '1723456789014',
      'nama': 'Ghani',
      'judul': 'Aplikasi crash saat tracking',
      'kategori': 'Aplikasi Bermasalah',
      'prioritas': 'Urgent',
      'tanggal': '2025-08-20',
      'status': 'Menunggu',
      'lokasi': 'Jl. Merdekan No. 123, Samarinda',
      'deskripsi': 'Aplikasi selalu crash ketika mencoba melihat tracking truk sampah.',
    },
    {
      'id': '1723456789015',
      'nama': 'Ghani',
      'judul': 'Keterlambatan pengambilan rutin',
      'kategori': 'Jadwal Terlambat',
      'prioritas': 'Normal',
      'tanggal': '2025-08-15',
      'status': 'Selesai',
      'lokasi': 'Jl. Merdekan No. 123, Samarinda',
      'deskripsi': 'Pengambilan sampah rutin selalu terlambat 1-2 jam dari jadwal yang ditentukan.',
      'balasan': 'Terima kasih atas laporannya. Kami telah mengingatkan petugas untuk tepat waktu.'
    },
    {
      'id': '1723456789016',
      'nama': 'Ghani',
      'judul': 'Sampah tidak dipisahkan dengan benar',
      'kategori': 'Kualitas Layanan',
      'prioritas': 'Rendah',
      'tanggal': '2025-08-10',
      'status': 'Sedang Diproses',
      'lokasi': 'Jl. Merdekan No. 123, Samarinda',
      'deskripsi': 'Petugas tidak memisahkan sampah organik dan anorganik sesuai prosedur.',
    },
  ];
  
  // Filter state
  List<Map<String, dynamic>> filteredKeluhan = [];
  String selectedStatus = 'Semua';
  String searchQuery = '';
  String selectedCategory = 'Semua';
  String selectedPriority = 'Semua';

  // Sections for tab view - simplified to avoid overflow
  final List<String> tabSections = ['Semua', 'Riwayat', 'Terbaru'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    // Initialize filtered list with all keluhan
    filteredKeluhan = List.from(daftarKeluhan);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        switch (_tabController.index) {
          case 0: // All complaints
            selectedStatus = 'Semua';
            break;
          case 1: // History (completed)
            selectedStatus = 'Selesai';
            break;
          case 2: // Recent (pending/processing)
            selectedStatus = 'Semua';
            _sortByRecent();
            break;
        }
        _filterKeluhan();
      });
    }
  }
  
  // Sort by most recent
  void _sortByRecent() {
    filteredKeluhan.sort((a, b) {
      DateTime dateA = DateFormat('yyyy-MM-dd').parse(a['tanggal']);
      DateTime dateB = DateFormat('yyyy-MM-dd').parse(b['tanggal']);
      return dateB.compareTo(dateA);
    });
  }

  // Method untuk membuat animated tab dengan ikon dan efek hover
  Widget _buildAnimatedTab(int index, IconData icon) {
    final isSelected = _tabController.index == index;
    final String tabText = tabSections[index];
    
    // Golden ratio derived sizes
    final phi = 1.618;
    final baseSize = 14.0;
    final largeSize = baseSize * phi; // ~22.7
    final smallSize = baseSize / phi; // ~8.7
    
    return Tab(
      height: 46, // Slightly taller for better touch targets
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with animated container and pulse effect for selected tab
            Stack(
              alignment: Alignment.center,
              children: [
                // Background pulse animation
                if (isSelected)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.easeInOutCubic,
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                
                // Icon container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.all(isSelected ? smallSize : smallSize * 0.8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Colors.white.withOpacity(0.25)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      color: isSelected ? whiteColor : greyColor,
                      fontSize: isSelected ? 18 : 16,
                    ),
                    child: Icon(
                      icon,
                      size: isSelected ? baseSize : baseSize * 0.9,
                      color: isSelected ? whiteColor : greyColor,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(width: 8),
            
            // Animated text for better transition - now shows full text since we've simplified the labels
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isSelected ? 15 : 14,
                fontWeight: isSelected ? semiBold : medium,
                color: isSelected ? whiteColor : greyColor,
              ),
              child: Text(
                tabText, // Show full simplified label
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Filter keluhan berdasarkan status, kategori, prioritas, dan pencarian
  void _filterKeluhan() {
    setState(() {
      filteredKeluhan = daftarKeluhan.where((keluhan) {
        // Filter berdasarkan status
        bool statusMatch = selectedStatus == 'Semua' || 
            keluhan['status'] == selectedStatus;
            
        // Filter berdasarkan kategori
        bool categoryMatch = selectedCategory == 'Semua' ||
            keluhan['kategori'] == selectedCategory;
            
        // Filter berdasarkan prioritas
        bool priorityMatch = selectedPriority == 'Semua' ||
            keluhan['prioritas'] == selectedPriority;
            
        // Filter berdasarkan pencarian
        bool searchMatch = searchQuery.isEmpty || 
            keluhan['judul'].toLowerCase().contains(searchQuery.toLowerCase()) ||
            (keluhan['deskripsi'] != null && 
             keluhan['deskripsi'].toLowerCase().contains(searchQuery.toLowerCase())) ||
            keluhan['kategori'].toLowerCase().contains(searchQuery.toLowerCase()) ||
            keluhan['id'].toLowerCase().contains(searchQuery.toLowerCase());
            
        return statusMatch && categoryMatch && priorityMatch && searchMatch;
      }).toList();
      
      // Sort by date if "Recent Complaints" tab
      if (_tabController.index == 2) {
        _sortByRecent();
      }
    });
  }

  void _navigateToKeluhanForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GoldenKeluhanForm()),
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          daftarKeluhan.add(result);
          _filterKeluhan();
        });
      }
    });
  }
  
  void _navigateToTanggapanPage(Map<String, dynamic> keluhan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TanggapanKeluhanPage(keluhanData: keluhan),
      ),
    ).then((result) {
      if (result != null) {
        setState(() {
          // Find the index of the keluhan in the list
          final index = daftarKeluhan.indexWhere((k) => k['id'] == keluhan['id']);
          if (index != -1) {
            // Update the keluhan with the result
            daftarKeluhan[index] = result;
            // Re-filter
            _filterKeluhan();
          }
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Keluhan berhasil diperbarui!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate golden ratio width divisions - approximately 1:1.618
    final screenWidth = MediaQuery.of(context).size.width;
    final goldenWidth = screenWidth - 48; // Total width minus padding
    final primaryWidth = (goldenWidth / 2.618).ceil(); // Main content (larger)
    final secondaryWidth = goldenWidth - primaryWidth; // Sidebar content (smaller)

    // Golden ratio for vertical spacing
    final baseSpacing = 16.0;
    final phi = 1.618; // Golden ratio
    final smallSpacing = baseSpacing / phi; // ~9.9
    final largeSpacing = baseSpacing * phi; // ~25.9

    return Scaffold(
      backgroundColor: uicolor,
      appBar: const CustomAppBar(
        title: 'Keluhan',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Enhanced Tab Bar with golden ratio styling and better balance - fixed overflow issues
          Container(
            margin: const EdgeInsets.fromLTRB(24, 16, 24, 16), // More balanced margins
            height: 52, // Fixed height for better control
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(largeSpacing),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(largeSpacing),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: greenColor,
                  boxShadow: [
                    BoxShadow(
                      color: greenColor.withOpacity(0.4),
                      blurRadius: 4,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: whiteColor,
                unselectedLabelColor: blackColor.withOpacity(0.6),
                labelStyle: blackTextStyle.copyWith(
                  fontWeight: semiBold,
                  fontSize: 13.5,
                ),
                unselectedLabelStyle: blackTextStyle.copyWith(
                  fontWeight: medium,
                  fontSize: 13,
                ),
                // Adjusted tab padding to prevent overflow
                labelPadding: EdgeInsets.symmetric(
                  horizontal: smallSpacing / 1.2, // Reduced horizontal padding
                  vertical: smallSpacing / phi, // ~6.1
                ),
                tabs: [
                  _buildAnimatedTab(0, Icons.list_alt_rounded),
                  _buildAnimatedTab(1, Icons.history_rounded),
                  _buildAnimatedTab(2, Icons.new_releases_rounded),
                ],
              ),
            ),
          ),
          
          // Enhanced Search and Filter Row with Golden Ratio (38.2% : 61.8%)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                // Search box (larger portion ~61.8%)
                Expanded(
                  flex: 16, // Golden ratio approximation
                  child: Container(
                    height: 50, // Fixed height for better proportions
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(25), // More rounded for modern look
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                          _filterKeluhan();
                        });
                      },
                      style: blackTextStyle.copyWith(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Cari keluhan...',
                        hintStyle: greyTextStyle.copyWith(fontSize: 15),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 16, right: 8),
                          child: Icon(Icons.search, color: greyColor, size: 22),
                        ),
                        suffixIcon: searchQuery.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: IconButton(
                                  icon: Icon(Icons.close, color: greyColor, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      searchQuery = '';
                                      _filterKeluhan();
                                    });
                                  },
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Filter button (smaller portion ~38.2%) with improved visuals
                Container(
                  height: 50, // Match search box height
                  width: 50, // Perfect square for balance
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      _showFilterBottomSheet(context);
                    },
                    icon: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.filter_list_rounded,
                          color: greenColor,
                          size: 24,
                        ),
                        if (selectedCategory != 'Semua' || selectedPriority != 'Semua')
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    tooltip: 'Filter',
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Enhanced Status Filter Chips with better scrolling and visuals
          SizedBox(
            height: 44, // Fixed height for consistency
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterChip('Semua'),
                  _buildFilterChip('Menunggu'),
                  _buildFilterChip('Sedang Diproses'),
                  _buildFilterChip('Selesai'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Keluhan List Content with Golden Ratio Padding
          Expanded(
            child: filteredKeluhan.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    itemCount: filteredKeluhan.length,
                    itemBuilder: (context, index) {
                      final keluhan = filteredKeluhan[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildKeluhanCard(keluhan),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToKeluhanForm,
        backgroundColor: greenColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  
  Widget _buildFilterChip(String status) {
    final isSelected = selectedStatus == status;
    
    // Golden ratio calculations
    final phi = 1.618;
    final basePadding = 10.0;
    final horizontalPadding = basePadding * phi;  // ~16.2
    final verticalPadding = basePadding; // 10
    
    // Get appropriate color based on status
    Color statusColor = greenColor;
    IconData statusIcon;
    
    switch(status.toLowerCase()) {
      case 'menunggu':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time_rounded;
        break;
      case 'sedang diproses':
        statusColor = Colors.blue;
        statusIcon = Icons.pending_rounded;
        break;
      case 'selesai':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_rounded;
        break;
      default:
        statusColor = greenColor;
        statusIcon = Icons.list_alt_rounded;
    }
    
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedStatus = status;
            _filterKeluhan();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: isSelected ? statusColor : whiteColor,
            borderRadius: BorderRadius.circular(20), // More rounded
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey.shade300,
              width: 1,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: statusColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              if (!isSelected)
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Only show icon when selected
              if (isSelected) ...[
                Icon(
                  statusIcon,
                  color: whiteColor,
                  size: 14,
                ),
                SizedBox(width: 6),
              ],
              Text(
                status,
                style: isSelected
                    ? whiteTextStyle.copyWith(
                        fontWeight: semiBold,
                        fontSize: 13,
                      )
                    : blackTextStyle.copyWith(
                        color: Colors.black87,
                        fontSize: 13,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeluhanCard(Map<String, dynamic> keluhan) {
    // Calculate golden ratio padding (to create visual harmony)
    final phi = 1.618;
    final basePadding = 16.0;
    final smallPadding = basePadding / phi; // ~9.9
    final largePadding = basePadding * phi; // ~25.9
    
    // Calculate animations based on golden ratio
    final animationDuration = const Duration(milliseconds: 300);
    
    return GestureDetector(
      onTap: () => _showDetailKeluhan(keluhan),
      child: AnimatedContainer(
        duration: animationDuration,
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: _getStatusColor(keluhan['status']).withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status bar at top for visual hierarchy
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: _getStatusColor(keluhan['status']),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            
            // Header with ID and Status - follows golden ratio for spacing
            Padding(
              padding: EdgeInsets.fromLTRB(
                basePadding, smallPadding, basePadding, smallPadding / phi
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ID with icon
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getStatusColor(keluhan['status']).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getStatusIcon(keluhan['status']),
                            color: _getStatusColor(keluhan['status']),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'ID: ${keluhan['id']}',
                            style: greyTextStyle.copyWith(
                              fontSize: 12,
                              fontWeight: medium,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(keluhan['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(keluhan['status']).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      keluhan['status'],
                      style: TextStyle(
                        color: _getStatusColor(keluhan['status']),
                        fontSize: 11,
                        fontWeight: semiBold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Title - main focal point
            Padding(
              padding: EdgeInsets.symmetric(horizontal: basePadding),
              child: Text(
                keluhan['judul'],
                style: blackTextStyle.copyWith(
                  fontSize: 16, 
                  fontWeight: bold,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 10),

            // Category and Priority - golden ratio spacing
            Padding(
              padding: EdgeInsets.symmetric(horizontal: basePadding),
              child: Row(
                children: [
                  _buildInfoChip(
                    keluhan['kategori'],
                    Icons.category_rounded,
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    keluhan['prioritas'],
                    Icons.priority_high_rounded,
                    _getPrioritasColor(keluhan['prioritas']),
                  ),
                ],
              ),
            ),

            // Divider - golden ratio position (~61.8% from top)
            Padding(
              padding: EdgeInsets.only(top: smallPadding, bottom: 0),
              child: Divider(
                color: Colors.grey.shade200,
                thickness: 1,
                height: 1,
              ),
            ),

            // Footer with user info and date
            Padding(
              padding: EdgeInsets.all(smallPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // User and location - takes 61.8% of space (golden ratio)
                  Expanded(
                    flex: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User info
                        Row(
                          children: [
                            Icon(Icons.person_rounded, color: greyColor, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              keluhan['nama'],
                              style: greyTextStyle.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Location with truncation
                        Row(
                          children: [
                            Icon(Icons.location_on_rounded, color: greyColor, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                keluhan['lokasi'],
                                style: greyTextStyle.copyWith(fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Date - takes 38.2% of space (golden ratio)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: greyColor,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          keluhan['tanggal'],
                          style: greyTextStyle.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: semiBold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    bool isFiltering = searchQuery.isNotEmpty || selectedStatus != 'Semua' || 
                      selectedCategory != 'Semua' || selectedPriority != 'Semua';
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFiltering ? Icons.filter_alt_rounded : Icons.inbox_rounded,
                size: 60,
                color: greyColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isFiltering ? 'Tidak Ada Hasil' : 'Belum Ada Keluhan',
              style: blackTextStyle.copyWith(fontSize: 18, fontWeight: semiBold),
            ),
            const SizedBox(height: 12),
            Text(
              isFiltering
                  ? 'Tidak ada keluhan yang sesuai dengan\nfilter atau pencarian Anda.'
                  : 'Anda belum memiliki keluhan apapun.\nBuat keluhan pertama Anda sekarang.',
              style: greyTextStyle.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200, // Golden ratio of typical screen width
              child: isFiltering
                  ? ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          searchQuery = '';
                          selectedStatus = 'Semua';
                          selectedCategory = 'Semua';
                          selectedPriority = 'Semua';
                          _filterKeluhan();
                        });
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reset Filter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: whiteColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: _navigateToKeluhanForm,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Buat Keluhan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: greenColor,
                        foregroundColor: whiteColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    // Temporary variables for filter values
    String tempCategory = selectedCategory;
    String tempPriority = selectedPriority;
    
    final List<String> categoryList = [
      'Semua',
      'Pengambilan Sampah',
      'Jadwal Terlambat',
      'Kualitas Layanan',
      'Aplikasi Bermasalah',
      'Petugas',
      'Lainnya',
    ];
    
    final List<String> priorityList = [
      'Semua',
      'Rendah',
      'Normal',
      'Tinggi',
      'Urgent',
    ];
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Filter Title
              Text(
                'Filter Keluhan',
                style: blackTextStyle.copyWith(
                  fontSize: 20,
                  fontWeight: bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // Category Filter
              Text(
                'Kategori',
                style: blackTextStyle.copyWith(fontWeight: semiBold),
              ),
              const SizedBox(height: 12),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categoryList.map((category) {
                  final isSelected = tempCategory == category;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        tempCategory = category;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? greenColor : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isSelected 
                              ? greenColor 
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        category,
                        style: isSelected
                            ? whiteTextStyle.copyWith(fontWeight: medium)
                            : greyTextStyle.copyWith(fontWeight: medium),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // Priority Filter
              Text(
                'Prioritas',
                style: blackTextStyle.copyWith(fontWeight: semiBold),
              ),
              const SizedBox(height: 12),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: priorityList.map((priority) {
                  final isSelected = tempPriority == priority;
                  final Color priorityColor = priority == 'Semua' 
                      ? Colors.grey
                      : _getPrioritasColor(priority);
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        tempPriority = priority;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? priority == 'Semua' ? greenColor : priorityColor
                            : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isSelected
                              ? priority == 'Semua' ? greenColor : priorityColor
                              : priority == 'Semua' 
                                  ? Colors.grey.shade300
                                  : priorityColor.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (priority != 'Semua')
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: isSelected ? whiteColor : priorityColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          if (priority != 'Semua')
                            const SizedBox(width: 6),
                          Text(
                            priority,
                            style: isSelected
                                ? priority == 'Semua' 
                                    ? whiteTextStyle.copyWith(fontWeight: medium)
                                    : whiteTextStyle.copyWith(fontWeight: medium)
                                : priority == 'Semua'
                                    ? greyTextStyle.copyWith(fontWeight: medium)
                                    : TextStyle(
                                        color: priorityColor,
                                        fontWeight: medium,
                                      ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const Spacer(),
              
              // Apply and Reset buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          tempCategory = 'Semua';
                          tempPriority = 'Semua';
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: greenColor),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Reset Filter',
                        style: TextStyle(color: greenColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Apply the filters
                        setState(() {
                          selectedCategory = tempCategory;
                          selectedPriority = tempPriority;
                          _filterKeluhan();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: greenColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Terapkan Filter',
                        style: whiteTextStyle.copyWith(fontWeight: medium),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailKeluhan(Map<String, dynamic> keluhan) {
    // Using golden ratio for section heights
    final height = MediaQuery.of(context).size.height;
    final goldenHeight = height * 0.618; // ~62% of screen height
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: goldenHeight,
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Status bar at top
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _getStatusColor(keluhan['status']),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              ),
            ),
            
            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    
                    // Status dan ID in golden ratio row
                    Row(
                      children: [
                        // ID (smaller part)
                        Expanded(
                          flex: 10, // Golden ratio approximation (38.2%)
                          child: Text(
                            'ID: ${keluhan['id']}',
                            style: greyTextStyle.copyWith(fontSize: 13),
                          ),
                        ),
                        // Status (larger part)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(keluhan['status']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getStatusColor(keluhan['status']).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getStatusIcon(keluhan['status']),
                                color: _getStatusColor(keluhan['status']),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                keluhan['status'],
                                style: TextStyle(
                                  color: _getStatusColor(keluhan['status']),
                                  fontSize: 13,
                                  fontWeight: semiBold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Judul
                    Text(
                      keluhan['judul'],
                      style: blackTextStyle.copyWith(
                        fontSize: 22,
                        fontWeight: bold,
                        height: 1.3,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Info submission with golden ratio layout
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            // User info (larger part - ~61.8%)
                            Expanded(
                              flex: 16,
                              child: Row(
                                children: [
                                  // Avatar
                                  CircleAvatar(
                                    backgroundColor: greenColor.withOpacity(0.1),
                                    child: Text(
                                      keluhan['nama'][0],
                                      style: TextStyle(
                                        color: greenColor,
                                        fontWeight: bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Name and date
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          keluhan['nama'],
                                          style: blackTextStyle.copyWith(
                                            fontWeight: semiBold,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today_rounded,
                                              size: 12,
                                              color: greyColor,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              keluhan['tanggal'],
                                              style: greyTextStyle.copyWith(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Vertical divider
                            VerticalDivider(
                              color: Colors.grey.shade300,
                              thickness: 1,
                              width: 32,
                            ),
                            
                            // Priority (smaller part - ~38.2%)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Prioritas',
                                  style: greyTextStyle.copyWith(fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getPrioritasColor(keluhan['prioritas']).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: _getPrioritasColor(keluhan['prioritas']),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        keluhan['prioritas'],
                                        style: TextStyle(
                                          color: _getPrioritasColor(keluhan['prioritas']),
                                          fontSize: 12,
                                          fontWeight: medium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Section header with icons
                    _buildSectionHeader('Deskripsi Keluhan', Icons.description_outlined),
                    
                    // Description
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 32, // Golden ratio alignment
                        top: 12,
                        bottom: 24,
                      ),
                      child: Text(
                        keluhan['deskripsi'],
                        style: blackTextStyle.copyWith(
                          fontSize: 14,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    
                    // Kategori & Lokasi
                    _buildSectionHeader('Kategori', Icons.category_outlined),
                    _buildDetailText(keluhan['kategori']),
                    
                    const SizedBox(height: 16),
                    
                    _buildSectionHeader('Lokasi', Icons.location_on_outlined),
                    _buildDetailText(keluhan['lokasi']),
                    
                    const SizedBox(height: 24),
                    
                    // Balasan jika ada
                    if (keluhan.containsKey('balasan') && keluhan['balasan'] != null) ...[
                      _buildSectionHeader('Balasan Admin', Icons.comment_outlined, color: Colors.green),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.green.shade100,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.green.shade200,
                                  radius: 16,
                                  child: Icon(
                                    Icons.support_agent,
                                    color: Colors.green.shade700,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Admin Gerobaks',
                                  style: blackTextStyle.copyWith(
                                    fontWeight: semiBold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.only(left: 42), // Alignment with avatar
                              child: Text(
                                keluhan['balasan'],
                                style: blackTextStyle.copyWith(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ] else if (keluhan['status'] != 'Selesai') ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Belum ada balasan untuk keluhan ini',
                                style: greyTextStyle.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
            
            // Bottom action bar with golden ratio division
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              decoration: BoxDecoration(
                color: whiteColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // If not resolved, show respond button (larger portion)
                  if (keluhan['status'] != 'Selesai') ...[
                    Expanded(
                      flex: 16, // Golden ratio (larger)
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _navigateToTanggapanPage(keluhan);
                        },
                        icon: const Icon(Icons.comment_rounded),
                        label: const Text('Tanggapi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: greenColor,
                          foregroundColor: whiteColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  // Close button (smaller portion if respond exists)
                  Expanded(
                    flex: keluhan['status'] != 'Selesai' ? 10 : 26, // Golden ratio adjustment
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text('Tutup'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: greyColor,
                        side: BorderSide(color: greyColor),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {Color color = Colors.green}) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: blackTextStyle.copyWith(
            fontSize: 16,
            fontWeight: semiBold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildDetailText(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, top: 8), // Alignment with header
      child: Text(
        text,
        style: blackTextStyle.copyWith(fontSize: 14),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Colors.green.shade600;
      case 'sedang diproses':
        return Colors.orange.shade600;
      case 'menunggu':
        return Colors.blue.shade600;
      default:
        return greyColor;
    }
  }
  
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Icons.check_circle_rounded;
      case 'sedang diproses':
        return Icons.pending_rounded;
      case 'menunggu':
        return Icons.access_time_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Color _getPrioritasColor(String prioritas) {
    switch (prioritas.toLowerCase()) {
      case 'rendah':
        return Colors.green.shade600;
      case 'normal':
        return Colors.blue.shade600;
      case 'tinggi':
        return Colors.orange.shade600;
      case 'urgent':
        return Colors.red.shade600;
      default:
        return greyColor;
    }
  }
}

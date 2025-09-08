import 'package:bank_sha/ui/pages/end_user/buat_keluhan/buat_keluhan_form.dart';
import 'package:bank_sha/ui/pages/end_user/buat_keluhan/tanggapan_keluhan_page.dart';
import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';

class KeluhanPage extends StatefulWidget {
  const KeluhanPage({super.key});

  @override
  State<KeluhanPage> createState() => _KeluhanPageState();
}

class _KeluhanPageState extends State<KeluhanPage> {
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
      'judul': 'Sampah tidak dipisahkan',
      'kategori': 'Kualitas Layanan',
      'prioritas': 'Normal',
      'tanggal': '2025-08-15',
      'status': 'Selesai',
      'lokasi': 'Jl. Merdekan No. 123, Samarinda',
      'deskripsi': 'Petugas tidak memisahkan sampah organik dan non-organik seperti yang diminta.',
      'balasan': 'Mohon maaf atas ketidaknyamanannya. Kami sudah memberikan pelatihan kepada petugas kami.'
    },
  ];
  
  // Filter state
  List<Map<String, dynamic>> filteredKeluhan = [];
  String selectedStatus = 'Semua';
  String searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    // Initialize filtered list with all keluhan
    filteredKeluhan = List.from(daftarKeluhan);
  }
  
  // Filter keluhan berdasarkan status dan pencarian
  void _filterKeluhan() {
    setState(() {
      filteredKeluhan = daftarKeluhan.where((keluhan) {
        // Filter berdasarkan status
        bool statusMatch = selectedStatus == 'Semua' || 
            keluhan['status'] == selectedStatus;
            
        // Filter berdasarkan pencarian
        bool searchMatch = searchQuery.isEmpty || 
            keluhan['judul'].toLowerCase().contains(searchQuery.toLowerCase()) ||
            (keluhan['deskripsi'] != null && 
             keluhan['deskripsi'].toLowerCase().contains(searchQuery.toLowerCase())) ||
            keluhan['kategori'].toLowerCase().contains(searchQuery.toLowerCase()) ||
            keluhan['id'].toLowerCase().contains(searchQuery.toLowerCase());
            
        return statusMatch && searchMatch;
      }).toList();
    });
  }

  void _navigateToKeluhanForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BuatKeluhanForm()),
    ).then((result) {
      if (result != null) {
        // Add new complaint to the list
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
    return Scaffold(
      backgroundColor: uicolor,
      appBar: CustomAppBar(
        title: 'Daftar Keluhan',
        rightImageAsset: 'assets/ic_plus.png',
        onRightImagePressed: _navigateToKeluhanForm,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Simulate fetching data from a server
          await Future.delayed(const Duration(seconds: 1));
          setState(() {
            _filterKeluhan();
          });
          return;
        },
        color: greenColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      greenColor.withOpacity(0.1),
                      greenColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: greenColor.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.list_alt_rounded, color: greenColor, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          '📋 Riwayat Keluhan Anda',
                          style: blackTextStyle.copyWith(
                            fontSize: 20,
                            fontWeight: bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Berikut adalah daftar keluhan yang telah Anda sampaikan. Pantau status penanganan keluhan Anda di sini.',
                      style: greyTextStyle.copyWith(fontSize: 14, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildStatCard(
                          'Total Keluhan',
                          daftarKeluhan.length.toString(),
                          Icons.description_rounded,
                          Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          'Selesai',
                          daftarKeluhan
                              .where((k) => k['status'] == 'Selesai')
                              .length
                              .toString(),
                          Icons.check_circle_rounded,
                          Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quick Action Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [greenColor, greenColor.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: greenColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: whiteColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.add_circle_rounded,
                        color: whiteColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '✨ Punya Keluhan Baru?',
                            style: whiteTextStyle.copyWith(
                              fontSize: 16,
                              fontWeight: bold,
                            ),
                          ),
                          Text(
                            'Sampaikan keluhan Anda dengan mudah',
                            style: whiteTextStyle.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _navigateToKeluhanForm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Buat Sekarang',
                          style: TextStyle(
                            color: greenColor,
                            fontWeight: semiBold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Search Box
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
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
                  decoration: InputDecoration(
                    hintText: 'Cari keluhan...',
                    hintStyle: greyTextStyle,
                    prefixIcon: Icon(Icons.search, color: greyColor),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.close, color: greyColor),
                            onPressed: () {
                              setState(() {
                                searchQuery = '';
                                _filterKeluhan();
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Semua'),
                    _buildFilterChip('Menunggu'),
                    _buildFilterChip('Sedang Diproses'),
                    _buildFilterChip('Selesai'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Section Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Keluhan Terkini',
                    style: blackTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: bold,
                    ),
                  ),
                  Text(
                    '${filteredKeluhan.length} Keluhan',
                    style: greyTextStyle.copyWith(fontSize: 12),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Daftar Keluhan
              filteredKeluhan.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredKeluhan.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final keluhan = filteredKeluhan[index];
                        return _buildKeluhanCard(keluhan);
                      },
                    ),

              const SizedBox(height: 80), // Extra space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToKeluhanForm,
        backgroundColor: greenColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Buat Keluhan',
          style: whiteTextStyle.copyWith(fontWeight: semiBold),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: blackTextStyle.copyWith(
                fontSize: 20,
                fontWeight: bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: greyTextStyle.copyWith(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeluhanCard(Map<String, dynamic> keluhan) {
    return GestureDetector(
      onTap: () => _showDetailKeluhan(keluhan),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: _getStatusColor(keluhan['status']).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan ID dan Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'ID: ${keluhan['id']}',
                          style: greyTextStyle.copyWith(
                            fontSize: 12,
                            fontWeight: medium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
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

            const SizedBox(height: 12),

            // Judul Keluhan
            Text(
              keluhan['judul'],
              style: blackTextStyle.copyWith(fontSize: 16, fontWeight: bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // Info Pelapor dan Tanggal
            Row(
              children: [
                Icon(Icons.person_rounded, color: greyColor, size: 16),
                const SizedBox(width: 6),
                Text(
                  keluhan['nama'],
                  style: greyTextStyle.copyWith(fontSize: 13),
                ),
                const SizedBox(width: 12),
                Icon(Icons.calendar_today_rounded, color: greyColor, size: 14),
                const SizedBox(width: 6),
                Text(
                  keluhan['tanggal'],
                  style: greyTextStyle.copyWith(fontSize: 13),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Detail Info
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    keluhan['kategori'],
                    Icons.category_rounded,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoChip(
                    keluhan['prioritas'],
                    Icons.priority_high_rounded,
                    _getPrioritasColor(keluhan['prioritas']),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Lokasi
            Row(
              children: [
                Icon(Icons.location_on_rounded, color: greyColor, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    keluhan['lokasi'],
                    style: greyTextStyle.copyWith(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action Button
            Row(
              children: [
                if (keluhan['status'] == 'Selesai' && keluhan.containsKey('balasan'))
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showDetailKeluhan(keluhan);
                      },
                      icon: const Icon(Icons.comment_outlined, size: 16, color: Colors.green),
                      label: const Text('Lihat Balasan', 
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.green),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Action untuk lihat detail
                        _showDetailKeluhan(keluhan);
                      },
                      icon: Icon(
                        Icons.visibility_rounded,
                        size: 16,
                        color: greenColor,
                      ),
                      label: Text(
                        'Lihat Detail',
                        style: TextStyle(color: greenColor, fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: greenColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
              ],
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
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: semiBold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    bool isFiltering = searchQuery.isNotEmpty || selectedStatus != 'Semua';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            isFiltering ? Icons.filter_alt_rounded : Icons.inbox_rounded,
            size: 64,
            color: greyColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            isFiltering ? 'Tidak Ada Hasil' : 'Belum Ada Keluhan',
            style: blackTextStyle.copyWith(fontSize: 18, fontWeight: semiBold),
          ),
          const SizedBox(height: 8),
          Text(
            isFiltering
                ? 'Tidak ada keluhan yang sesuai dengan\nfilter atau pencarian Anda.'
                : 'Anda belum memiliki keluhan apapun.\nBuat keluhan pertama Anda sekarang.',
            style: greyTextStyle.copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          isFiltering
              ? ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      searchQuery = '';
                      selectedStatus = 'Semua';
                      _filterKeluhan();
                    });
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reset Filter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: whiteColor,
                  ),
                )
              : ElevatedButton.icon(
                  onPressed: _navigateToKeluhanForm,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Buat Keluhan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: greenColor,
                    foregroundColor: whiteColor,
                  ),
                ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(String status) {
    final isSelected = selectedStatus == status;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedStatus = status;
            _filterKeluhan();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? greenColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? greenColor : greyColor.withOpacity(0.3),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: greenColor.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            status,
            style: isSelected
                ? whiteTextStyle.copyWith(fontWeight: medium)
                : greyTextStyle.copyWith(fontWeight: medium),
          ),
        ),
      ),
    );
  }

  void _showDetailKeluhan(Map<String, dynamic> keluhan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
            
            // Status dan ID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: ${keluhan['id']}',
                  style: greyTextStyle.copyWith(fontSize: 14),
                ),
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
                          fontSize: 12,
                          fontWeight: semiBold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Judul
            Text(
              keluhan['judul'],
              style: blackTextStyle.copyWith(
                fontSize: 20,
                fontWeight: bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Info submission
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getPrioritasColor(keluhan['prioritas']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      keluhan['prioritas'],
                      style: TextStyle(
                        color: _getPrioritasColor(keluhan['prioritas']),
                        fontSize: 12,
                        fontWeight: medium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Deskripsi header
            Row(
              children: [
                Icon(Icons.description_outlined, color: greenColor),
                const SizedBox(width: 8),
                Text(
                  'Deskripsi Keluhan',
                  style: blackTextStyle.copyWith(
                    fontSize: 16,
                    fontWeight: semiBold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Deskripsi
            Text(
              keluhan['deskripsi'],
              style: greyTextStyle.copyWith(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Lokasi header
            Row(
              children: [
                Icon(Icons.location_on_outlined, color: greenColor),
                const SizedBox(width: 8),
                Text(
                  'Lokasi',
                  style: blackTextStyle.copyWith(
                    fontSize: 16,
                    fontWeight: semiBold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Lokasi
            Text(
              keluhan['lokasi'],
              style: greyTextStyle.copyWith(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            
            const Spacer(),
            
            // Balasan jika ada
            if (keluhan.containsKey('balasan') && keluhan['balasan'] != null) ...[
              Container(
                width: double.infinity,
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
                    Text(
                      'Balasan dari Admin:',
                      style: blackTextStyle.copyWith(
                        fontWeight: semiBold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      keluhan['balasan'],
                      style: greyTextStyle.copyWith(
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'Belum ada balasan untuk keluhan ini',
                    style: greyTextStyle,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Bottom buttons
            Row(
              children: [
                if (keluhan['status'] != 'Selesai') ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _navigateToTanggapanPage(keluhan);
                      },
                      icon: const Icon(Icons.comment_rounded),
                      label: const Text('Tanggapi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: whiteColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Tutup'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: greyColor,
                      foregroundColor: whiteColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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

import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// Data model untuk statistik sampah
class WasteData {
  final String type;
  final double value;
  final Color color;
  
  WasteData(this.type, this.value, this.color);
}

class LaporanMitraPage extends StatefulWidget {
  const LaporanMitraPage({super.key});

  @override
  State<LaporanMitraPage> createState() => _LaporanMitraPageState();
}

class _LaporanMitraPageState extends State<LaporanMitraPage> {
  String selectedPeriod = 'today';

  // Data untuk donut chart statistik sampah
  final List<WasteData> wasteData = [
    WasteData('Organik', 45, greenColor),
    WasteData('Plastik', 25, blueColor),
    WasteData('Kertas', 15, orangeColor),
    WasteData('Logam', 10, purpleColor),
    WasteData('Kaca', 5, redcolor),
  ];

  @override
  Widget build(BuildContext context) {
    bool isSmallScreen = MediaQuery.of(context).size.width < 360;
    
    return Scaffold(
      backgroundColor: lightBackgroundColor,
      body: Column(
        children: [
          // Custom Header seperti di jadwal mitra page
          _buildCustomHeader(context, isSmallScreen),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period Selector
                  _buildPeriodSelector(),

                  const SizedBox(height: 24),

                  // Donut Chart Section untuk Statistik Sampah
                  _buildWasteStatisticsSection(),

                  const SizedBox(height: 24),

                  // Performance Stats
                  _buildPerformanceStatsSection(),

                  const SizedBox(height: 24),

                  // Recent Activities
                  _buildRecentActivitiesSection(),

                  const SizedBox(height: 24),

                  // Export Button
                  _buildExportButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [greenColor, greenLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 1.0],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: greenColor.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Top bar with logo and notifications
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              Row(
                children: [
                  Image.asset(
                    'assets/ic_truck.png',
                    width: isSmallScreen ? 24 : 32,
                    height: isSmallScreen ? 24 : 32,
                    color: Colors.white,
                  ),
                  SizedBox(width: isSmallScreen ? 4 : 8),
                  Text(
                    'GEROBAKS',
                    style: whiteTextStyle.copyWith(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              
              // Notification and export icons
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Export functionality
                    },
                    child: Container(
                      padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.download_rounded,
                        color: Colors.white,
                        size: isSmallScreen ? 16 : 20,
                      ),
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  GestureDetector(
                    onTap: () {
                      // Navigate to notifications
                    },
                    child: Container(
                      padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                        size: isSmallScreen ? 16 : 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          SizedBox(height: isSmallScreen ? 12 : 16),
          
          // Laporan Kinerja Text
          Text(
            'Laporan Kinerja Mitra',
            style: whiteTextStyle.copyWith(
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 8 : 12),
          
          Text(
            'Statistik dan analisis performa harian',
            style: whiteTextStyle.copyWith(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w400,
              color: whiteColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: greenColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: greenColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.insert_chart_rounded,
                  color: greenColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Periode Laporan',
                style: blackTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: semiBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPeriodChip('Hari Ini', 'today'),
                const SizedBox(width: 12),
                _buildPeriodChip('Minggu Ini', 'week'),
                const SizedBox(width: 12),
                _buildPeriodChip('Bulan Ini', 'month'),
                const SizedBox(width: 12),
                _buildPeriodChip('3 Bulan', 'quarter'),
                const SizedBox(width: 12),
                _buildPeriodChip('1 Tahun', 'year'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWasteStatisticsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 32,
                width: 4,
                decoration: BoxDecoration(
                  color: greenColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Statistik Jenis Sampah',
                style: blackTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: semiBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Donut Chart
          Row(
            children: [
              // Chart
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 60,
                      sections: _getWasteChartSections(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              
              // Legend
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: wasteData.map((data) => 
                    _buildLegendItem(data)
                  ).toList(),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Total info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: greenColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.recycling_rounded,
                  color: greenColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Total: ${wasteData.fold(0.0, (sum, item) => sum + item.value).toInt()} Kg',
                  style: greentextstyle2.copyWith(
                    fontSize: 16,
                    fontWeight: semiBold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                height: 32,
                width: 4,
                decoration: BoxDecoration(
                  color: greenColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Statistik Kinerja',
                style: blackTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: semiBold,
                ),
              ),
            ],
          ),
        ),
        
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildStatCard(
              title: 'Total Pengambilan',
              value: '45',
              icon: Icons.local_shipping_rounded,
              color: blueColor,
              subtitle: 'Hari ini',
            ),
            _buildStatCard(
              title: 'Selesai Tepat Waktu',
              value: '42',
              icon: Icons.schedule_rounded,
              color: greenColor,
              subtitle: '93.3%',
            ),
            _buildStatCard(
              title: 'Rating Pelanggan',
              value: '4.8',
              icon: Icons.star_rounded,
              color: orangeColor,
              subtitle: 'Rata-rata',
            ),
            _buildStatCard(
              title: 'Jarak Tempuh',
              value: '125',
              icon: Icons.route_rounded,
              color: purpleColor,
              subtitle: 'KM',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aktivitas Terbaru',
          style: blackTextStyle.copyWith(
            fontSize: 18,
            fontWeight: semiBold,
          ),
        ),
        const SizedBox(height: 12),
        
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            return _buildActivityItem(index);
          },
        ),
      ],
    );
  }

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: Export report functionality
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Laporan berhasil diunduh'),
              backgroundColor: greenColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        icon: const Icon(Icons.download_rounded, color: Colors.white),
        label: Text(
          'Unduh Laporan',
          style: whiteTextStyle.copyWith(
            fontWeight: semiBold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: greenColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  List<PieChartSectionData> _getWasteChartSections() {
    return wasteData.asMap().entries.map((entry) {
      final data = entry.value;
      final total = wasteData.fold(0.0, (sum, item) => sum + item.value);
      final percentage = (data.value / total * 100);
      
      return PieChartSectionData(
        color: data.color,
        value: data.value,
        title: '${percentage.toInt()}%',
        radius: 50,
        titleStyle: whiteTextStyle.copyWith(
          fontSize: 12,
          fontWeight: bold,
        ),
      );
    }).toList();
  }

  Widget _buildLegendItem(WasteData data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: data.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.type,
                  style: blackTextStyle.copyWith(
                    fontSize: 12,
                    fontWeight: medium,
                  ),
                ),
                Text(
                  '${data.value.toInt()} Kg',
                  style: greyTextStyle.copyWith(
                    fontSize: 10,
                    fontWeight: regular,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPeriodChip(String title, String value) {
    final isSelected = selectedPeriod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPeriod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? greenColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected ? [
            BoxShadow(
              color: greenColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
              spreadRadius: 0,
            ),
          ] : [],
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? whiteColor : Colors.grey.shade700,
            fontWeight: isSelected ? semiBold : medium,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: extraBold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: blackTextStyle.copyWith(
              fontSize: 15,
              fontWeight: semiBold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: greyTextStyle.copyWith(
              fontSize: 12,
              fontWeight: medium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(int index) {
    final activities = [
      {
        'time': '15:30',
        'action': 'Selesai pengambilan',
        'location': 'Jl. Merdeka No. 5',
        'status': 'completed',
      },
      {
        'time': '14:45',
        'action': 'Mulai pengambilan',
        'location': 'Komplek Bumi Asri',
        'status': 'in_progress',
      },
      {
        'time': '13:20',
        'action': 'Selesai pengambilan',
        'location': 'Perumahan Indah',
        'status': 'completed',
      },
      {
        'time': '12:10',
        'action': 'Istirahat',
        'location': 'Rest Area KM 15',
        'status': 'break',
      },
      {
        'time': '11:30',
        'action': 'Selesai pengambilan',
        'location': 'Villa Mutiara',
        'status': 'completed',
      },
    ];

    final activity = activities[index];
    Color statusColor;
    IconData statusIcon;

    switch (activity['status']) {
      case 'completed':
        statusColor = greenColor;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'in_progress':
        statusColor = blueColor;
        statusIcon = Icons.access_time_rounded;
        break;
      case 'break':
        statusColor = orangeColor;
        statusIcon = Icons.coffee_rounded;
        break;
      default:
        statusColor = greyColor;
        statusIcon = Icons.help_outline_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['action'] as String,
                  style: blackTextStyle.copyWith(
                    fontSize: 14,
                    fontWeight: semiBold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['location'] as String,
                  style: greyTextStyle.copyWith(
                    fontSize: 12,
                    fontWeight: medium,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              activity['time'] as String,
              style: TextStyle(
                fontSize: 12,
                color: statusColor,
                fontWeight: medium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

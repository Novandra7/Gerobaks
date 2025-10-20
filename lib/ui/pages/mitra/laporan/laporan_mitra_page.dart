import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:bank_sha/utils/responsive_helper.dart';

// Format currency
final currencyFormatter = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

// Data model untuk statistik sampah
class WasteData {
  final String type;
  final double value;
  final Color color;
  final double previousValue;
  final double economicValue; // nilai ekonomis per kg
  final double carbonReduction; // pengurangan karbon per kg (dalam gram CO2)

  WasteData(
    this.type,
    this.value,
    this.color, {
    this.previousValue = 0.0,
    this.economicValue = 0.0,
    this.carbonReduction = 0.0,
  });

  // Menghitung persentase perubahan
  double get changePercentage =>
      previousValue > 0 ? ((value - previousValue) / previousValue * 100) : 0.0;

  // Menentukan apakah ada peningkatan
  bool get isIncreasing => value > previousValue;

  // Total nilai ekonomis
  double get totalEconomicValue => value * economicValue;

  // Total pengurangan karbon
  double get totalCarbonReduction => value * carbonReduction;
}

// Data model untuk metrik kinerja
class PerformanceMetric {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double? targetValue;
  final double? actualValue;
  final String? trend; // 'up', 'down', or 'stable'
  final double? changePercentage;

  PerformanceMetric({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.targetValue,
    this.actualValue,
    this.trend,
    this.changePercentage,
  });

  // Helper untuk menentukan warna trend berdasarkan konteks
  Color getTrendColor(bool isPositiveTrend) {
    if (trend == null) return Colors.grey;

    if (trend == 'up') {
      return isPositiveTrend ? greenColor : redcolor;
    } else if (trend == 'down') {
      return isPositiveTrend ? redcolor : greenColor;
    } else {
      return Colors.amber;
    }
  }

  // Helper untuk menentukan ikon trend
  IconData getTrendIcon() {
    if (trend == 'up') {
      return Icons.trending_up;
    } else if (trend == 'down') {
      return Icons.trending_down;
    } else {
      return Icons.trending_flat;
    }
  }

  // Menghitung persentase pencapaian target
  double getAchievementPercentage() {
    if (targetValue == null || actualValue == null) return 0.0;
    return (actualValue! / targetValue! * 100).clamp(0.0, 100.0);
  }
}

// Data model untuk insight/rekomendasi
class ActionableInsight {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String actionText;
  final VoidCallback? onAction;
  final InsightType type;

  ActionableInsight({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.actionText,
    this.onAction,
    required this.type,
  });
}

// Tipe insight
enum InsightType { recommendation, alert, tip, achievement }

class LaporanMitraPage extends StatefulWidget {
  const LaporanMitraPage({super.key});

  @override
  State<LaporanMitraPage> createState() => _LaporanMitraPageState();
}

class _LaporanMitraPageState extends State<LaporanMitraPage>
    with SingleTickerProviderStateMixin {
  String selectedPeriod = 'today';
  bool isLoading = false;
  late TabController _tabController;

  // Data dummy untuk demo
  double totalEarnings = 450000;
  double targetEarnings = 500000;
  double totalDistance = 125;
  int totalPickups = 45;
  double incentiveEarned = 75000;
  double averageRating = 4.8;
  double averageTimePerPickup = 15.5; // dalam menit

  // Carbon footprint reduction total (dalam kg CO2)
  double totalCarbonReduction = 125.5;

  // Data untuk waste statistik yang lebih komprehensif
  final List<WasteData> wasteData = [
    WasteData(
      'Organik',
      45,
      greenColor,
      previousValue: 42,
      economicValue: 2000, // Rp2000/kg
      carbonReduction: 0.5, // 0.5kg CO2/kg sampah
    ),
    WasteData(
      'Plastik',
      25,
      blueColor,
      previousValue: 20,
      economicValue: 5000, // Rp5000/kg
      carbonReduction: 2.5, // 2.5kg CO2/kg sampah
    ),
    WasteData(
      'Kertas',
      15,
      orangeColor,
      previousValue: 18,
      economicValue: 3000, // Rp3000/kg
      carbonReduction: 1.8, // 1.8kg CO2/kg sampah
    ),
    WasteData(
      'Logam',
      10,
      purpleColor,
      previousValue: 8,
      economicValue: 8000, // Rp8000/kg
      carbonReduction: 4.0, // 4kg CO2/kg sampah
    ),
    WasteData(
      'Kaca',
      5,
      redcolor,
      previousValue: 5,
      economicValue: 1500, // Rp1500/kg
      carbonReduction: 0.8, // 0.8kg CO2/kg sampah
    ),
  ];

  // Top lokasi pengambilan
  final List<Map<String, dynamic>> topLocations = [
    {'name': 'Perumahan Bumi Asri', 'totalWaste': 28.5, 'frequency': 12},
    {'name': 'Apartemen Green Tower', 'totalWaste': 22.3, 'frequency': 8},
    {'name': 'Komplek Permata Hijau', 'totalWaste': 18.7, 'frequency': 10},
    {'name': 'Perumahan Villa Melati', 'totalWaste': 15.2, 'frequency': 7},
    {'name': 'Kawasan Industri Jaya', 'totalWaste': 14.8, 'frequency': 5},
  ];

  // Performance metrics
  late List<PerformanceMetric> performanceMetrics;

  // Actionable insights
  late List<ActionableInsight> actionableInsights;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeData() {
    // Initialize performance metrics
    performanceMetrics = [
      PerformanceMetric(
        title: 'Total Pendapatan',
        value: currencyFormatter.format(totalEarnings),
        subtitle:
            '${(totalEarnings / targetEarnings * 100).toStringAsFixed(0)}% dari target',
        icon: Icons.monetization_on_rounded,
        color: greenColor,
        targetValue: targetEarnings,
        actualValue: totalEarnings,
        trend: 'up',
        changePercentage: 8.5,
      ),
      PerformanceMetric(
        title: 'Efisiensi Rute',
        value: '${(totalDistance / totalPickups).toStringAsFixed(1)} km',
        subtitle: 'per pengambilan',
        icon: Icons.route_rounded,
        color: blueColor,
        trend: 'down',
        changePercentage: 5.2,
      ),
      PerformanceMetric(
        title: 'Rating Pelanggan',
        value: averageRating.toString(),
        subtitle: 'dari 5.0',
        icon: Icons.star_rounded,
        color: orangeColor,
        trend: 'up',
        changePercentage: 2.1,
      ),
      PerformanceMetric(
        title: 'Waktu Pengambilan',
        value: '${averageTimePerPickup.toStringAsFixed(1)} min',
        subtitle: 'rata-rata',
        icon: Icons.timer_rounded,
        color: purpleColor,
        trend: 'down',
        changePercentage: 10.5,
      ),
      PerformanceMetric(
        title: 'Total Pengambilan',
        value: totalPickups.toString(),
        subtitle: 'Hari ini',
        icon: Icons.local_shipping_rounded,
        color: blueColor,
        targetValue: 50,
        actualValue: 45,
      ),
      PerformanceMetric(
        title: 'Bonus Diterima',
        value: currencyFormatter.format(incentiveEarned),
        subtitle: 'Hari ini',
        icon: Icons.card_giftcard_rounded,
        color: orangeColor,
        trend: 'up',
        changePercentage: 15.0,
      ),
    ];

    // Initialize actionable insights
    actionableInsights = [
      ActionableInsight(
        title: 'Tingkatkan Pendapatan',
        description:
            'Ambil 5 pengambilan lagi untuk mencapai target harian dan dapatkan bonus Rp50.000',
        icon: Icons.monetization_on_rounded,
        color: greenColor,
        actionText: 'Lihat Jadwal',
        onAction: () {
          // Navigate to schedule
        },
        type: InsightType.recommendation,
      ),
      ActionableInsight(
        title: 'Optimasi Rute',
        description:
            'Pengambilan di Perumahan Bumi Asri dapat dioptimasi untuk mengurangi 3.5km jarak tempuh',
        icon: Icons.route_rounded,
        color: blueColor,
        actionText: 'Lihat Rute Optimal',
        onAction: () {
          // Show optimal route
        },
        type: InsightType.tip,
      ),
      ActionableInsight(
        title: 'Alert! Target Belum Tercapai',
        description:
            'Anda baru mencapai 90% target pendapatan harian. Masih ada waktu 3 jam untuk mencapainya.',
        icon: Icons.warning_amber_rounded,
        color: redcolor,
        actionText: 'Lihat Peluang',
        onAction: () {
          // Show opportunities
        },
        type: InsightType.alert,
      ),
      ActionableInsight(
        title: 'Prestasi Tercapai!',
        description:
            'Anda berhasil mengurangi 125kg emisi karbon hari ini. Teruskan kontribusi positif Anda!',
        icon: Icons.nature_rounded,
        color: greenColor,
        actionText: 'Bagikan',
        onAction: () {
          // Share achievement
        },
        type: InsightType.achievement,
      ),
    ];
  }

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
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: greenColor))
                : RefreshIndicator(
                    onRefresh: () async {
                      // Simulate refresh
                      setState(() {
                        isLoading = true;
                      });
                      await Future.delayed(const Duration(seconds: 1));
                      setState(() {
                        isLoading = false;
                      });
                    },
                    color: greenColor,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Period Selector
                          _buildPeriodSelector(),

                          const SizedBox(height: 20),

                          // Earning & Performance Summary Card
                          _buildEarningsSummary(),

                          const SizedBox(height: 20),

                          // Tabs untuk Statistik dan Insight
                          _buildTabBar(),

                          // Tab Content
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.65,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                // Statistics Tab
                                _buildStatisticsTab(),

                                // Insights Tab
                                _buildInsightsTab(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: TabBar(
        controller: _tabController,
        labelColor: greenColor,
        unselectedLabelColor: greyColor,
        labelStyle: TextStyle(fontWeight: semiBold),
        unselectedLabelStyle: TextStyle(fontWeight: medium),
        indicator: BoxDecoration(
          color: greenColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        tabs: [
          Tab(text: 'Statistik', icon: Icon(Icons.insert_chart_outlined)),
          Tab(text: 'Insights', icon: Icon(Icons.lightbulb_outline)),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Performance Metrics Grid
        _buildPerformanceMetricsSection(),

        const SizedBox(height: 20),

        // Waste Statistics Section
        _buildWasteStatisticsSection(),

        const SizedBox(height: 20),

        // Waste Value Economics
        _buildWasteEconomicsSection(),

        const SizedBox(height: 20),

        // Top Locations
        _buildTopLocationsSection(),

        const SizedBox(height: 20),

        // Carbon Footprint Impact
        _buildCarbonFootprintSection(),

        const SizedBox(height: 20),

        // Recent Activities
        _buildRecentActivitiesSection(),

        const SizedBox(height: 20),

        // Export Button
        _buildExportButton(),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildInsightsTab() {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Actionable Insights
        ...actionableInsights.map((insight) => _buildInsightCard(insight)),

        const SizedBox(height: 20),

        // Performance Improvement Tips
        _buildPerformanceImprovementSection(),

        const SizedBox(height: 20),
      ],
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
                    'assets/img_gerobakss.png',
                    height: ResponsiveHelper.getResponsiveHeight(context, 28),
                    color: Colors.white,
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
                      child: Stack(
                        children: [
                          Icon(
                            Icons.notifications_none,
                            color: Colors.white,
                            size: isSmallScreen ? 16 : 20,
                          ),
                          // Badge untuk notifikasi baru
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: redcolor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildEarningsSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [greenColor, greenColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: greenColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pendapatan Hari Ini',
                style: whiteTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: medium,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '8.5%',
                      style: whiteTextStyle.copyWith(
                        fontSize: 12,
                        fontWeight: semiBold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            currencyFormatter.format(totalEarnings),
            style: whiteTextStyle.copyWith(fontSize: 28, fontWeight: extraBold),
          ),
          const SizedBox(height: 4),
          Text(
            'Dari target ${currencyFormatter.format(targetEarnings)}',
            style: whiteTextStyle.copyWith(
              fontSize: 14,
              fontWeight: regular,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: totalEarnings / targetEarnings,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildEarningInfoItem(
                Icons.calendar_today,
                'Hari Ini',
                currencyFormatter.format(totalEarnings),
              ),
              _buildEarningInfoItem(
                Icons.card_giftcard,
                'Bonus',
                currencyFormatter.format(incentiveEarned),
              ),
              _buildEarningInfoItem(
                Icons.route,
                'Jarak',
                '${totalDistance.toInt()} km',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: whiteTextStyle.copyWith(
            fontSize: 12,
            fontWeight: medium,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: whiteTextStyle.copyWith(fontSize: 14, fontWeight: bold),
        ),
      ],
    );
  }

  Widget _buildPerformanceMetricsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              height: 24,
              width: 4,
              decoration: BoxDecoration(
                color: greenColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Metrik Kinerja',
              style: blackTextStyle.copyWith(
                fontSize: 18,
                fontWeight: semiBold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemCount: performanceMetrics.length,
          itemBuilder: (context, index) {
            return _buildMetricCard(performanceMetrics[index]);
          },
        ),
      ],
    );
  }

  Widget _buildMetricCard(PerformanceMetric metric) {
    final hasTrend = metric.trend != null && metric.changePercentage != null;
    final hasTarget = metric.targetValue != null && metric.actualValue != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: metric.color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: metric.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(metric.icon, color: metric.color, size: 20),
              ),
              if (hasTrend)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: metric
                        .getTrendColor(
                          // Metrics dimana tren naik positif: pendapatan, rating, bonus
                          // Metrics dimana tren turun positif: waktu per pickup, jarak per pickup
                          metric.title.contains('Pendapatan') ||
                              metric.title.contains('Rating') ||
                              metric.title.contains('Bonus') ||
                              metric.title.contains('Pengambilan'),
                        )
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        metric.getTrendIcon(),
                        color: metric.getTrendColor(
                          metric.title.contains('Pendapatan') ||
                              metric.title.contains('Rating') ||
                              metric.title.contains('Bonus') ||
                              metric.title.contains('Pengambilan'),
                        ),
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${metric.changePercentage!.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: medium,
                          color: metric.getTrendColor(
                            metric.title.contains('Pendapatan') ||
                                metric.title.contains('Rating') ||
                                metric.title.contains('Bonus') ||
                                metric.title.contains('Pengambilan'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          Expanded(
            child: Center(
              child: Text(
                metric.value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: extraBold,
                  color: metric.color,
                ),
              ),
            ),
          ),
          Text(
            metric.title,
            style: blackTextStyle.copyWith(fontSize: 14, fontWeight: semiBold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          if (hasTarget) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: metric.getAchievementPercentage() / 100,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(metric.color),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            metric.subtitle,
            style: greyTextStyle.copyWith(fontSize: 12, fontWeight: medium),
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
        border: Border.all(color: greenColor.withOpacity(0.2), width: 1),
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
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: greenColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                    spreadRadius: 0,
                  ),
                ]
              : [],
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
                height: 24,
                width: 4,
                decoration: BoxDecoration(
                  color: greenColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Statistik Jenis Sampah',
                  style: blackTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: semiBold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: greenColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Total: ${wasteData.fold(0.0, (sum, item) => sum + item.value).toInt()} Kg',
                  style: greentextstyle2.copyWith(
                    fontSize: 12,
                    fontWeight: semiBold,
                  ),
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
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 60,
                          sections: _getWasteChartSections(),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${wasteData.fold(0.0, (sum, item) => sum + item.value).toInt()}',
                            style: blackTextStyle.copyWith(
                              fontSize: 24,
                              fontWeight: extraBold,
                            ),
                          ),
                          Text(
                            'Kilogram',
                            style: greyTextStyle.copyWith(
                              fontSize: 12,
                              fontWeight: medium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Legend
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: wasteData
                      .map((data) => _buildEnhancedLegendItem(data))
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedLegendItem(WasteData data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      style: blackTextStyle.copyWith(
                        fontSize: 12,
                        fontWeight: semiBold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      data.isIncreasing
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: data.isIncreasing ? greenColor : redcolor,
                      size: 12,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${data.changePercentage.abs().toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: medium,
                        color: data.isIncreasing ? greenColor : redcolor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWasteEconomicsSection() {
    final totalEconomicValue = wasteData.fold(
      0.0,
      (sum, data) => sum + data.totalEconomicValue,
    );

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
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: blueColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.monetization_on_rounded,
                  color: blueColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nilai Ekonomi Sampah',
                      style: blackTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: semiBold,
                      ),
                    ),
                    Text(
                      'Berdasarkan jenis sampah yang dikumpulkan',
                      style: greyTextStyle.copyWith(
                        fontSize: 12,
                        fontWeight: regular,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                currencyFormatter.format(totalEconomicValue),
                style: blueTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: extraBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Waste Economic Value Breakdown
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: wasteData.length,
            itemBuilder: (context, index) {
              final data = wasteData[index];
              final percentage =
                  (data.totalEconomicValue / totalEconomicValue * 100);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data.type,
                          style: blackTextStyle.copyWith(
                            fontSize: 14,
                            fontWeight: medium,
                          ),
                        ),
                        Text(
                          currencyFormatter.format(data.totalEconomicValue),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: semiBold,
                            color: data.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(data.color),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${data.value.toInt()} Kg',
                          style: greyTextStyle.copyWith(
                            fontSize: 12,
                            fontWeight: medium,
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: medium,
                            color: data.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopLocationsSection() {
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
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: purpleColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: purpleColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Lokasi Pengambilan Terbanyak',
                style: blackTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: semiBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topLocations.length,
            itemBuilder: (context, index) {
              final location = topLocations[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: index == 0
                      ? purpleColor.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: index == 0
                      ? Border.all(
                          color: purpleColor.withOpacity(0.5),
                          width: 1,
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: index == 0
                            ? purpleColor
                            : Colors.grey.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: whiteTextStyle.copyWith(
                            fontSize: 14,
                            fontWeight: bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            location['name'] as String,
                            style: blackTextStyle.copyWith(
                              fontSize: 14,
                              fontWeight: medium,
                              color: index == 0 ? purpleColor : blackColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${location['frequency']} pengambilan (${location['totalWaste']} kg)',
                            style: greyTextStyle.copyWith(
                              fontSize: 12,
                              fontWeight: regular,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.pin_drop_rounded,
                      color: index == 0 ? purpleColor : greyColor,
                      size: 20,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCarbonFootprintSection() {
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
          ),
        ],
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
                child: Icon(Icons.nature_rounded, color: greenColor, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                'Dampak Lingkungan',
                style: blackTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: semiBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: greenColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      totalCarbonReduction.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: extraBold,
                        color: greenColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'kg',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: bold,
                        color: greenColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'CO₂ berhasil dikurangi dari aktivitas pengambilan sampah',
                  style: greentextstyle2.copyWith(
                    fontSize: 14,
                    fontWeight: medium,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildEnvironmentalImpactItem(
                      Icons.park_rounded,
                      '${(totalCarbonReduction / 21.77).toStringAsFixed(1)} pohon',
                      'setara penanaman',
                    ),
                    _buildEnvironmentalImpactItem(
                      Icons.electric_car_rounded,
                      '${(totalCarbonReduction * 4.15).toStringAsFixed(1)} km',
                      'perjalanan mobil',
                    ),
                    _buildEnvironmentalImpactItem(
                      Icons.bolt_rounded,
                      '${(totalCarbonReduction * 33.3).toStringAsFixed(1)} kWh',
                      'energi terhemat',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Reduksi CO₂ per Jenis Sampah',
            style: blackTextStyle.copyWith(fontSize: 14, fontWeight: semiBold),
          ),

          const SizedBox(height: 12),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: wasteData.length,
            itemBuilder: (context, index) {
              final data = wasteData[index];
              final percentage =
                  (data.totalCarbonReduction / totalCarbonReduction * 100);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data.type,
                          style: blackTextStyle.copyWith(
                            fontSize: 14,
                            fontWeight: medium,
                          ),
                        ),
                        Text(
                          '${data.totalCarbonReduction.toStringAsFixed(1)} kg CO₂',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: semiBold,
                            color: data.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(data.color),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: medium,
                        color: data.color,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentalImpactItem(
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(icon, color: greenColor, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: greentextstyle2.copyWith(fontSize: 14, fontWeight: semiBold),
        ),
        Text(
          label,
          style: greentextstyle2.copyWith(
            fontSize: 12,
            fontWeight: regular,
            color: greenColor.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(ActionableInsight insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
        border: Border.all(color: insight.color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: insight.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(insight.icon, color: insight.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  insight.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: semiBold,
                    color: insight.color,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: insight.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getInsightTypeText(insight.type),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: medium,
                    color: insight.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insight.description,
            style: blackTextStyle.copyWith(fontSize: 14, fontWeight: regular),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: insight.onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: insight.color,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                insight.actionText,
                style: whiteTextStyle.copyWith(
                  fontWeight: semiBold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInsightTypeText(InsightType type) {
    switch (type) {
      case InsightType.recommendation:
        return 'Rekomendasi';
      case InsightType.alert:
        return 'Alert';
      case InsightType.tip:
        return 'Tips';
      case InsightType.achievement:
        return 'Prestasi';
    }
  }

  Widget _buildPerformanceImprovementSection() {
    final List<Map<String, dynamic>> tips = [
      {
        'title': 'Efisiensi Rute',
        'description':
            'Gunakan fitur navigasi untuk mengoptimalkan rute pengambilan sampah. Rute optimal dapat menghemat hingga 15% bahan bakar.',
        'icon': Icons.map_rounded,
        'color': blueColor,
      },
      {
        'title': 'Komunikasi Aktif',
        'description':
            'Selalu konfirmasi jadwal dengan pelanggan 30 menit sebelum pengambilan untuk menghindari keterlambatan.',
        'icon': Icons.message_rounded,
        'color': orangeColor,
      },
      {
        'title': 'Pemilahan Sampah',
        'description':
            'Lakukan pemilahan sampah dengan tepat untuk meningkatkan nilai ekonomis dan mengurangi waktu di tempat pembuangan akhir.',
        'icon': Icons.category_rounded,
        'color': greenColor,
      },
    ];

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
          ),
        ],
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
                  Icons.tips_and_updates_rounded,
                  color: greenColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Tips Peningkatan Kinerja',
                style: blackTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: semiBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          ...tips.map(
            (tip) => _buildTipItem(
              tip['title'],
              tip['description'],
              tip['icon'],
              tip['color'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: semiBold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: blackTextStyle.copyWith(
                    fontSize: 14,
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
}

// This method is not referenced in the code, could be removed in future cleanup
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
        style: blackTextStyle.copyWith(fontSize: 18, fontWeight: semiBold),
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
  return Builder(
    builder: (BuildContext context) {
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
            style: whiteTextStyle.copyWith(fontWeight: semiBold),
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
    },
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
      border: Border.all(color: color.withOpacity(0.2), width: 1),
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
              child: Icon(icon, color: color, size: 22),
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
          style: blackTextStyle.copyWith(fontSize: 15, fontWeight: semiBold),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: greyTextStyle.copyWith(fontSize: 12, fontWeight: medium),
        ),
      ],
    ),
  );
}

List<PieChartSectionData> _getWasteChartSections() {
  // Creating a fixed set of data for the chart to remove dependency on wasteData
  return [
    PieChartSectionData(
      color: greenColor,
      value: 45,
      title: '',
      radius: 50,
      titlePositionPercentageOffset: 0.55,
      borderSide: BorderSide.none,
    ),
    PieChartSectionData(
      color: blueColor,
      value: 25,
      title: '',
      radius: 50,
      titlePositionPercentageOffset: 0.55,
      borderSide: BorderSide.none,
    ),
    PieChartSectionData(
      color: orangeColor,
      value: 15,
      title: '',
      radius: 50,
      titlePositionPercentageOffset: 0.55,
      borderSide: BorderSide.none,
    ),
    PieChartSectionData(
      color: purpleColor,
      value: 10,
      title: '',
      radius: 50,
      titlePositionPercentageOffset: 0.55,
      borderSide: BorderSide.none,
    ),
    PieChartSectionData(
      color: redcolor,
      value: 5,
      title: '',
      radius: 50,
      titlePositionPercentageOffset: 0.55,
      borderSide: BorderSide.none,
    ),
  ];
}

// Removed duplicate method _buildPeriodChip

// Removed unused method _buildLegendItem

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
          child: Icon(statusIcon, color: statusColor, size: 18),
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
                style: greyTextStyle.copyWith(fontSize: 12, fontWeight: medium),
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

import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';

class LaporanMitraPage extends StatefulWidget {
  const LaporanMitraPage({super.key});

  @override
  State<LaporanMitraPage> createState() => _LaporanMitraPageState();
}

class _LaporanMitraPageState extends State<LaporanMitraPage> {
  String selectedPeriod = 'today';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackgroundColor,
      appBar: AppBar(
        backgroundColor: greenColor,
        elevation: 0,
        title: Text(
          'Laporan Kinerja',
          style: whiteTextStyle.copyWith(
            fontSize: 20,
            fontWeight: semiBold,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            Container(
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
            ),

            const SizedBox(height: 24),

            // Performance Stats
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
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: greenColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.download_rounded,
                          color: greenColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Ekspor',
                          style: greentextstyle2.copyWith(
                            fontSize: 12,
                            fontWeight: medium,
                          ),
                        ),
                      ],
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
                  color: Colors.blue,
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
                  color: Colors.amber,
                  subtitle: 'Rata-rata',
                ),
                _buildStatCard(
                  title: 'Jarak Tempuh',
                  value: '125',
                  icon: Icons.route_rounded,
                  color: Colors.purple,
                  subtitle: 'KM',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recent Activities
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

            const SizedBox(height: 24),

            // Export Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Export report
                },
                icon: const Icon(Icons.download_rounded),
                label: const Text('Unduh Laporan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenColor,
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
    String statusText;

    switch (activity['status']) {
      case 'completed':
        statusColor = greenColor;
        statusIcon = Icons.check_circle_rounded;
        statusText = 'Selesai';
        break;
      case 'in_progress':
        statusColor = Colors.blue;
        statusIcon = Icons.access_time_rounded;
        statusText = 'Proses';
        break;
      case 'break':
        statusColor = Colors.orange;
        statusIcon = Icons.coffee_rounded;
        statusText = 'Istirahat';
        break;
      default:
        statusColor = greyColor;
        statusIcon = Icons.help_outline_rounded;
        statusText = 'Lainnya';
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

import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';

class StatisticsSection extends StatelessWidget {
  const StatisticsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistik',
            style: blackTextStyle.copyWith(
              fontSize: 18,
              fontWeight: semiBold,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: StatisticCard(
                  title: 'Pengambilan Selesai',
                  value: '12',
                  icon: Icons.check_circle_outline,
                  iconColor: greenColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatisticCard(
                  title: 'Rating',
                  value: '4.8',
                  icon: Icons.star_border_rounded,
                  iconColor: Colors.amber,
                  suffix: '/5',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatisticCard(
                  title: 'Waktu Aktif',
                  value: '3.5',
                  icon: Icons.access_time,
                  iconColor: Colors.blue,
                  suffix: ' jam',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatisticCard(
                  title: 'Pengambilan Menunggu',
                  value: '3',
                  icon: Icons.hourglass_empty,
                  iconColor: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatisticCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String? suffix;

  const StatisticCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.suffix,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: greyTextStyle.copyWith(
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: blackTextStyle.copyWith(
                  fontSize: 20,
                  fontWeight: semiBold,
                ),
              ),
              if (suffix != null)
                Text(
                  suffix!,
                  style: greyTextStyle.copyWith(
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

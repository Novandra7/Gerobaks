import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';

class ScheduleSection extends StatelessWidget {
  const ScheduleSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jadwal Hari Ini',
                style: blackTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: semiBold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Lihat Semua',
                  style: greeTextStyle.copyWith(
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          
          // Contoh jadwal
          const ScheduleCard(
            timeSlot: '14:00 - 16:00',
            status: 'Menunggu',
            customerName: 'Ahmad Fauzi',
            address: 'Jl. Sudirman No. 123, Jakarta Pusat',
            wasteType: ['Organik', 'Anorganik'],
            estimatedWeight: '5 kg',
          ),
          
          const SizedBox(height: 12),
          
          const ScheduleCard(
            timeSlot: '16:30 - 17:30',
            status: 'Menunggu',
            customerName: 'Budi Santoso',
            address: 'Jl. Thamrin No. 45, Jakarta Pusat',
            wasteType: ['Anorganik'],
            estimatedWeight: '3 kg',
          ),
        ],
      ),
    );
  }
}

class ScheduleCard extends StatelessWidget {
  final String timeSlot;
  final String status;
  final String customerName;
  final String address;
  final List<String> wasteType;
  final String estimatedWeight;

  const ScheduleCard({
    Key? key,
    required this.timeSlot,
    required this.status,
    required this.customerName,
    required this.address,
    required this.wasteType,
    required this.estimatedWeight,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: greenui,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  timeSlot,
                  style: greentextstyle2.copyWith(
                    fontWeight: medium,
                    fontSize: 12,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.orange,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: medium,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Customer Info
          Text(
            customerName,
            style: blackTextStyle.copyWith(
              fontSize: 16,
              fontWeight: semiBold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            address,
            style: greyTextStyle.copyWith(
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          
          // Waste Info
          Row(
            children: [
              ...wasteType.map((type) => Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: lightBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  type,
                  style: greyTextStyle.copyWith(
                    fontSize: 12,
                    fontWeight: medium,
                  ),
                ),
              )),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: lightBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  estimatedWeight,
                  style: greyTextStyle.copyWith(
                    fontSize: 12,
                    fontWeight: medium,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

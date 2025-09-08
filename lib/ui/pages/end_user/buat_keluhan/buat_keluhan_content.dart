import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class BuatKeluhanContent extends StatelessWidget {
  const BuatKeluhanContent({super.key});

  Widget buildStatus(String status) {
    Color color;
    switch (status) {
      case 'Pending':
        color = Colors.orange;
        break;
      case 'Completed':
        color = greenColor;
        break;
      case 'Cancelled':
        color = redcolor;
        break;
      default:
        color = greyColor;
    }

    return Text(
      status,
      style: GoogleFonts.poppins(fontWeight: medium, color: color),
    );
  }

  Widget buildComplaintCard({
    required String name,
    required String date,
    required String time,
    required String status,
    required String address,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Compliant name', style: greyTextStyle.copyWith(fontSize: 12)),
          const SizedBox(height: 4),
          Text(name, style: blackTextStyle.copyWith(fontWeight: semiBold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Compliant date',
                style: greyTextStyle.copyWith(fontSize: 12),
              ),
              Text(
                'Compliant time',
                style: greyTextStyle.copyWith(fontSize: 12),
              ),
              Text('Status', style: greyTextStyle.copyWith(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: blackTextStyle.copyWith(fontWeight: medium)),
              Text(time, style: blackTextStyle.copyWith(fontWeight: medium)),
              buildStatus(status),
            ],
          ),
          const SizedBox(height: 12),
          Text('Address', style: greyTextStyle.copyWith(fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  address,
                  style: blackTextStyle.copyWith(fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: uicolor,
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 16),
            buildComplaintCard(
              name: 'Overflow',
              date: '07/08/24',
              time: '10:00AM',
              status: 'Pending',
              address: 'HSR, layout, sector 3, bengaluru',
            ),
            buildComplaintCard(
              name: 'Kaveri river cleaning',
              date: '05/08/24',
              time: '10:00AM',
              status: 'Completed',
              address: 'HSR, layout, sector 3, bengaluru',
            ),
            buildComplaintCard(
              name: 'Forest garbage cleaning',
              date: '03/08/24',
              time: '10:00AM',
              status: 'Cancelled',
              address: 'HSR, layout, sector 3, bengaluru',
            ),
          ],
        ),
      ),
    );
  }
}

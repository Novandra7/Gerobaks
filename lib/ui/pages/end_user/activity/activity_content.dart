import 'package:flutter/material.dart';
import 'package:bank_sha/ui/pages/end_user/activity/activity_item.dart';
import 'package:intl/intl.dart';

class ActivityContent extends StatelessWidget {
  final DateTime? selectedDate;

  const ActivityContent({super.key, this.selectedDate});

  final List<Map<String, String>> activityList = const [
    {
      'title': 'Menuju Lokasi Pengambilan',
      'address': 'Jl Kenangan No. 12',
      'date': '27 Juni 2025\n08:00 WIB',
      'status': 'Menuju Lokasi',
    },
    // {
    //   'title': 'Dijadwalkan',
    //   'address': 'Jl Kenangan No. 12',
    //   'date': '26 Juni 2025\n14:30 WIB',
    // },
    {
      'title': 'Pengambilan Dibatalkan',
      'address': 'Jl Kenangan No. 12',
      'date': '26 Juni 2025\n10:00 WIB',
      'status': 'Dibatalkan',
    },
    {
      'title': 'Pengambilan Selesai',
      'address': 'Jl Kenangan No. 12',
      'date': '25 Juni 2025\n09:00 WIB',
      'status': 'Selesai',
    },
    {
      'title': 'Pengambilan Selesai',
      'address': 'Jl Kenangan No. 12',
      'date': '24 Juni 2025\n11:00 WIB',
      'status': 'Selesai',
    },
    {
      'title': 'Pengambilan Selesai',
      'address': 'Jl Kenangan No. 12',
      'date': '23 Juni 2025\n10:00 WIB',
      'status': 'Selesai',
    },
  ];

  DateTime? _parseDate(String rawDate) {
    try {
      final datePart = rawDate.split('\n').first;
      return DateFormat("d MMMM yyyy", 'id_ID').parse(datePart);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredList = activityList;

    if (selectedDate != null) {
      filteredList = activityList.where((activity) {
        final parsedDate = _parseDate(activity['date']!);
        return parsedDate != null &&
            parsedDate.isBefore(selectedDate!.add(const Duration(days: 1)));
      }).toList();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final activity = filteredList[index];
        return ActivityItem(
          title: activity['title']!,
          address: activity['address']!,
          dateTime: activity['date']!,
          status: activity['status']!,
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/custom_dialog.dart';
import 'package:intl/intl.dart';

class RescheduleDialog extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime, TimeOfDay) onReschedule;

  const RescheduleDialog({
    super.key,
    required this.initialDate,
    required this.onReschedule,
  });

  @override
  State<RescheduleDialog> createState() => _RescheduleDialogState();

  static Future<void> show({
    required BuildContext context,
    required DateTime initialDate,
    required Function(DateTime, TimeOfDay) onReschedule,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => RescheduleDialog(
        initialDate: initialDate,
        onReschedule: onReschedule,
      ),
    );
  }
}

class _RescheduleDialogState extends State<RescheduleDialog> {
  late DateTime selectedDate;
  late TimeOfDay selectedTime;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    selectedTime = TimeOfDay(
      hour: widget.initialDate.hour,
      minute: widget.initialDate.minute,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: greenColor,
              onPrimary: whiteColor,
              onSurface: blackColor,
            ), dialogTheme: DialogThemeData(backgroundColor: whiteColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          selectedTime.hour,
          selectedTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: greenColor,
              onPrimary: whiteColor,
              onSurface: blackColor,
            ), dialogTheme: DialogThemeData(backgroundColor: whiteColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        selectedDate = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: 'Atur Ulang Jadwal',
      content: '',
      customContent: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Date selector
          ListTile(
            leading: Icon(Icons.calendar_today, color: greenColor),
            title: Text(
              'Tanggal',
              style: blackTextStyle.copyWith(fontSize: 14),
            ),
            subtitle: Text(
              DateFormat('EEEE, dd MMM yyyy').format(selectedDate),
              style: blackTextStyle.copyWith(
                fontSize: 16,
                fontWeight: semiBold,
              ),
            ),
            onTap: () => _selectDate(context),
            trailing: Icon(
              Icons.chevron_right,
              color: greenColor,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          // Time selector
          ListTile(
            leading: Icon(Icons.access_time, color: greenColor),
            title: Text(
              'Waktu',
              style: blackTextStyle.copyWith(fontSize: 14),
            ),
            subtitle: Text(
              selectedTime.format(context),
              style: blackTextStyle.copyWith(
                fontSize: 16,
                fontWeight: semiBold,
              ),
            ),
            onTap: () => _selectTime(context),
            trailing: Icon(
              Icons.chevron_right,
              color: greenColor,
            ),
          ),
        ],
      ),
      positiveButtonText: 'Simpan Perubahan',
      negativeButtonText: 'Batal',
      onPositivePressed: () {
        Navigator.pop(context);
        widget.onReschedule(selectedDate, selectedTime);
      },
      onNegativePressed: () => Navigator.pop(context),
      icon: Icons.edit_calendar,
    );
  }
}

import 'package:bank_sha/blocs/schedule/schedule_bloc.dart';
import 'package:bank_sha/blocs/schedule/schedule_event.dart';
import 'package:bank_sha/blocs/schedule/schedule_state.dart';
import 'package:bank_sha/models/waste_item.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/schedule/waste_item_card.dart';
import 'package:bank_sha/ui/widgets/schedule/waste_type_selector.dart';
import 'package:bank_sha/ui/widgets/schedule/weight_input_dialog.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Halaman tambah jadwal dengan sistem multiple waste items
/// NO GOOGLE MAPS - hanya input manual
class AddSchedulePageNew extends StatefulWidget {
  const AddSchedulePageNew({super.key});

  @override
  State<AddSchedulePageNew> createState() => _AddSchedulePageNewState();
}

class _AddSchedulePageNewState extends State<AddSchedulePageNew> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  // List untuk track jenis sampah yang sudah dipilih (untuk disable di selector)
  final List<String> _selectedWasteTypes = [];

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: greenColor,
              onPrimary: whiteColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: greenColor,
              onPrimary: whiteColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _addWasteType(String wasteType) async {
    if (_selectedWasteTypes.contains(wasteType)) {
      // Jika sudah dipilih, tampilkan pesan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Jenis sampah ${WasteType.getDisplayName(wasteType)} sudah dipilih',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show dialog untuk input berat
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const WeightInputDialog(),
    );

    if (result != null && mounted) {
      final wasteItem = WasteItem(
        wasteType: wasteType,
        estimatedWeight: result['weight'] as double,
        unit: result['unit'] as String,
        notes: result['notes'] as String?,
      );

      // Add ke BLoC
      context.read<ScheduleBloc>().add(ScheduleAddWasteItem(wasteItem));

      // Update selected types
      setState(() {
        _selectedWasteTypes.add(wasteType);
      });
    }
  }

  void _editWasteItem(int index, WasteItem currentItem) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => WeightInputDialog(initialItem: currentItem),
    );

    if (result != null && mounted) {
      final updatedItem = WasteItem(
        wasteType: currentItem.wasteType,
        estimatedWeight: result['weight'] as double,
        unit: result['unit'] as String,
        notes: result['notes'] as String?,
      );

      context.read<ScheduleBloc>().add(
        ScheduleUpdateWasteItem(index, updatedItem),
      );
    }
  }

  void _removeWasteItem(int index, WasteItem item) {
    context.read<ScheduleBloc>().add(ScheduleRemoveWasteItem(index));

    setState(() {
      _selectedWasteTypes.remove(item.wasteType);
    });
  }

  void _submitSchedule() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final formState = context.read<ScheduleBloc>().currentFormState;

    if (formState.wasteItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal 1 jenis sampah'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Format date and time
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final timeStr =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    // Create schedule
    context.read<ScheduleBloc>().add(
      ScheduleCreate(
        date: dateStr,
        time: timeStr,
        address: _addressController.text,
        latitude: -6.2088, // TODO: Get from user location or input
        longitude: 106.8456,
        wasteItems: formState.wasteItems,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Buat Jadwal Baru',
          style: whiteTextStyle.copyWith(fontSize: 18, fontWeight: semiBold),
        ),
        backgroundColor: greenColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: whiteColor),
      ),
      body: BlocConsumer<ScheduleBloc, ScheduleState>(
        listener: (context, state) {
          if (state is ScheduleCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Jadwal berhasil dibuat!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is ScheduleCreateFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal membuat jadwal: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ScheduleCreating;
          final formState = state is ScheduleFormState
              ? state
              : context.read<ScheduleBloc>().currentFormState;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Date & Time Section
                _buildDateTimeSection(),
                const SizedBox(height: 24),

                // Address Section
                _buildAddressSection(),
                const SizedBox(height: 24),

                // Waste Type Selection
                WasteTypeSelector(
                  selectedTypes: _selectedWasteTypes,
                  onTypeSelected: _addWasteType,
                ),
                const SizedBox(height: 24),

                // Selected Waste Items
                if (formState.wasteItems.isNotEmpty) ...[
                  _buildSelectedWasteSection(formState),
                  const SizedBox(height: 24),
                ],

                // Notes Section
                _buildNotesSection(),
                const SizedBox(height: 32),

                // Submit Button
                CustomFilledButton(
                  title: isLoading ? 'Menyimpan...' : 'Buat Jadwal',
                  onPressed: isLoading ? null : _submitSchedule,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tanggal & Waktu',
          style: blackTextStyle.copyWith(fontSize: 16, fontWeight: semiBold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: greyColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: greenColor, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('dd MMM yyyy').format(_selectedDate),
                        style: blackTextStyle.copyWith(
                          fontSize: 14,
                          fontWeight: medium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: _selectTime,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: greyColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: greenColor, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _selectedTime.format(context),
                        style: blackTextStyle.copyWith(
                          fontSize: 14,
                          fontWeight: medium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alamat Pengambilan',
          style: blackTextStyle.copyWith(fontSize: 16, fontWeight: semiBold),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _addressController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Masukkan alamat lengkap...',
            hintStyle: greyTextStyle,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: greyColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: greyColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: greenColor, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Alamat harus diisi';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSelectedWasteSection(ScheduleFormState formState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sampah Terpilih',
              style: blackTextStyle.copyWith(
                fontSize: 16,
                fontWeight: semiBold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: greenColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Total: ${formState.totalEstimatedWeight.toStringAsFixed(1)} kg',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: semiBold,
                  color: greenColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...formState.wasteItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return WasteItemCard(
            wasteItem: item,
            onEdit: () => _editWasteItem(index, item),
            onDelete: () => _removeWasteItem(index, item),
          );
        }),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catatan Tambahan (Opsional)',
          style: blackTextStyle.copyWith(fontSize: 16, fontWeight: semiBold),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Tambahkan catatan untuk petugas...',
            hintStyle: greyTextStyle,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: greyColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: greyColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: greenColor, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}

import 'package:bank_sha/models/schedule_model.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/services/schedule_service.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:bank_sha/ui/widgets/shared/map_picker.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';

class CreateSchedulePage extends StatefulWidget {
  const CreateSchedulePage({super.key});

  @override
  State<CreateSchedulePage> createState() => _CreateSchedulePageState();
}

class _CreateSchedulePageState extends State<CreateSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _weightController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  LatLng? _selectedLocation;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  ScheduleFrequency _selectedFrequency = ScheduleFrequency.once;
  String _selectedWasteType = 'Organik';

  bool _isLoading = false;
  bool _isLocationSelected = false;
  List<TimeOfDay> _availableTimeSlots = [];
  String? _userId;

  final ScheduleService _scheduleService = ScheduleService();

  @override
  void initState() {
    super.initState();
    _getUserId();
    _loadAvailableTimeSlots();
    _initializeScheduleService();
  }

  Future<void> _initializeScheduleService() async {
    await _scheduleService.initialize();
  }

  Future<void> _getUserId() async {
    final localStorage = await LocalStorageService.getInstance();
    final userData = await localStorage.getUserData();
    if (userData != null && userData.containsKey('id')) {
      setState(() {
        _userId = userData['id'];
      });
    }
  }

  void _loadAvailableTimeSlots() {
    // Contoh slot waktu yang tersedia, dari jam 8 pagi hingga 4 sore dengan interval 1 jam
    setState(() {
      _availableTimeSlots = [
        const TimeOfDay(hour: 8, minute: 0),
        const TimeOfDay(hour: 9, minute: 0),
        const TimeOfDay(hour: 10, minute: 0),
        const TimeOfDay(hour: 11, minute: 0),
        const TimeOfDay(hour: 13, minute: 0),
        const TimeOfDay(hour: 14, minute: 0),
        const TimeOfDay(hour: 15, minute: 0),
        const TimeOfDay(hour: 16, minute: 0),
      ];
    });
  }

  void _openMapPicker() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerPage(
          onLocationSelected: (address, lat, lng) {
            // Handle lokasi yang dipilih
            setState(() {
              _addressController.text = address;
              _selectedLocation = LatLng(lat, lng);
              _isLocationSelected = true;
            });
          },
          initialLocation: _selectedLocation,
        ),
      ),
    );

    // Jika result null, user mungkin menekan tombol back, jadi kita tidak melakukan apa-apa
    // Jika tidak null, Map Picker sudah mengatur _addressController dan _selectedLocation
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 90),
      ), // Allow booking up to 90 days in advance
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: greenColor,
              onPrimary: whiteColor,
              onSurface: blackColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: greenColor),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showTimeSlotSelection() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih Waktu Pengambilan',
                style: blackTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: semiBold,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _availableTimeSlots.map((timeSlot) {
                  final isSelected =
                      timeSlot.hour == _selectedTime.hour &&
                      timeSlot.minute == _selectedTime.minute;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedTime = timeSlot;
                      });
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? greenColor : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? greenColor : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        '${timeSlot.hour.toString().padLeft(2, '0')}:${timeSlot.minute.toString().padLeft(2, '0')}',
                        style: isSelected
                            ? whiteTextStyle.copyWith(fontWeight: medium)
                            : blackTextStyle,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitSchedule() async {
    if (_formKey.currentState!.validate() && _isLocationSelected) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Buat jadwal baru menggunakan metode addSchedule dari service
        final schedule = await _scheduleService.addSchedule(
          userId: _userId ?? '',
          scheduledDate: _selectedDate,
          timeSlot: _selectedTime,
          location: _selectedLocation!,
          address: _addressController.text,
          notes: _notesController.text,
          frequency: _selectedFrequency,
          wasteType: _selectedWasteType,
          estimatedWeight: double.tryParse(_weightController.text) ?? 0.0,
          isPaid: false,
          contactName: _contactNameController.text,
          contactPhone: _contactPhoneController.text,
        );

        setState(() {
          _isLoading = false;
        });

        if (schedule.id != null && mounted) {
          _showSuccessDialog();
        } else {
          _showErrorDialog();
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog();
      }
    } else if (!_isLocationSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Silakan pilih lokasi di peta terlebih dahulu',
            style: whiteTextStyle,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Jadwal Berhasil Dibuat',
            style: blackTextStyle.copyWith(fontSize: 18, fontWeight: semiBold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: greenColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, color: greenColor, size: 60),
              ),
              const SizedBox(height: 16),
              Text(
                'Jadwal pengambilan sampah Anda telah berhasil dibuat. Silakan cek detail jadwal di halaman jadwal.',
                style: greyTextStyle.copyWith(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
              },
              child: Text(
                'Kembali ke Jadwal',
                style: TextStyle(color: greenColor, fontWeight: semiBold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Gagal Membuat Jadwal',
            style: blackTextStyle.copyWith(fontSize: 18, fontWeight: semiBold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error, color: Colors.red, size: 60),
              ),
              const SizedBox(height: 16),
              Text(
                'Terjadi kesalahan saat membuat jadwal. Silakan coba lagi nanti.',
                style: greyTextStyle.copyWith(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Tutup',
                style: TextStyle(color: greenColor, fontWeight: semiBold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    _weightController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco, color: greenColor, size: 24),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Hari ini pengambilan sampah organik!',
                style: blackTextStyle.copyWith(
                  fontSize: 20,
                  fontWeight: semiBold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: whiteColor,
        elevation: 0,
        iconTheme: IconThemeData(color: blackColor),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Location Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lokasi Pengambilan',
                    style: blackTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: semiBold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    readOnly: true,
                    onTap: _openMapPicker,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Silakan pilih lokasi di peta';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Pilih Lokasi di Peta',
                      prefixIcon: Icon(Icons.location_on, color: greyColor),
                      suffixIcon: Icon(Icons.map, color: greenColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: greyColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: greyColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: greenColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _isLocationSelected
                      ? Container(
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: greyColor),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: _selectedLocation!,
                                initialZoom: 15.0,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.none,
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.app',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: _selectedLocation!,
                                      child: Icon(
                                        Icons.location_pin,
                                        color: greenColor,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: greyColor),
                            color: Colors.grey[200],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.map, size: 40, color: greyColor),
                                const SizedBox(height: 8),
                                Text(
                                  'Pilih lokasi di peta',
                                  style: greyTextStyle,
                                ),
                              ],
                            ),
                          ),
                        ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Date & Time Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Waktu Pengambilan',
                    style: blackTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: semiBold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date Selection
                  InkWell(
                    onTap: () => _selectDate(context),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: greyColor),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: greyColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tanggal',
                                  style: greyTextStyle.copyWith(fontSize: 12),
                                ),
                                Text(
                                  DateFormat(
                                    'EEEE, d MMMM yyyy',
                                    'id_ID',
                                  ).format(_selectedDate),
                                  style: blackTextStyle,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: greyColor,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Time Selection
                  InkWell(
                    onTap: () => _showTimeSlotSelection(),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: greyColor),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time, color: greyColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Jam',
                                  style: greyTextStyle.copyWith(fontSize: 12),
                                ),
                                Text(
                                  '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                                  style: blackTextStyle,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: greyColor,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Frequency Selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Frekuensi',
                        style: greyTextStyle.copyWith(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildFrequencyChip(ScheduleFrequency.once, 'Sekali'),
                          _buildFrequencyChip(
                            ScheduleFrequency.daily,
                            'Harian',
                          ),
                          _buildFrequencyChip(
                            ScheduleFrequency.weekly,
                            'Mingguan',
                          ),
                          _buildFrequencyChip(
                            ScheduleFrequency.biWeekly,
                            '2 Minggu',
                          ),
                          _buildFrequencyChip(
                            ScheduleFrequency.monthly,
                            'Bulanan',
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Details Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail Sampah',
                    style: blackTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: semiBold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Waste Type Selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jenis Sampah',
                        style: greyTextStyle.copyWith(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildWasteTypeChip('Organik'),
                          _buildWasteTypeChip('Anorganik'),
                          _buildWasteTypeChip('B3'),
                          _buildWasteTypeChip('Campuran'),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Estimated Weight
                  TextFormField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Perkiraan Berat (kg)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: greyColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: greenColor),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Notes
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Catatan (opsional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: greyColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: greenColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Contact Information
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi Kontak',
                    style: blackTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: semiBold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Contact Name
                  TextFormField(
                    controller: _contactNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Silakan masukkan nama kontak';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Nama',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: greyColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: greenColor),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Contact Phone
                  TextFormField(
                    controller: _contactPhoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Silakan masukkan nomor telepon';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Nomor Telepon',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: greyColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: greenColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Submit Button
            _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(greenColor),
                    ),
                  )
                : CustomFilledButton(
                    title: 'Buat Jadwal',
                    onPressed: _submitSchedule,
                  ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyChip(ScheduleFrequency frequency, String label) {
    final bool isSelected = _selectedFrequency == frequency;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFrequency = frequency;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? greenColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? greenColor : greyColor),
        ),
        child: Text(
          label,
          style: isSelected
              ? whiteTextStyle.copyWith(fontWeight: medium)
              : greyTextStyle,
        ),
      ),
    );
  }

  Widget _buildWasteTypeChip(String wasteType) {
    final bool isSelected = _selectedWasteType == wasteType;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedWasteType = wasteType;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? greenColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? greenColor : greyColor),
        ),
        child: Text(
          wasteType,
          style: isSelected
              ? whiteTextStyle.copyWith(fontWeight: medium)
              : greyTextStyle,
        ),
      ),
    );
  }
}

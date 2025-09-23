import 'package:bank_sha/models/schedule_model.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/services/schedule_service.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:bank_sha/ui/widgets/shared/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class AddSchedulePage extends StatefulWidget {
  const AddSchedulePage({super.key});

  @override
  State<AddSchedulePage> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _weightController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  final _scheduleService = ScheduleService();
  bool _isLoading = false;
  String? _userId;

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  LatLng _selectedLocation = const LatLng(
    -6.2088,
    106.8456,
  ); // Default to Jakarta
  String _selectedWasteType = 'Campuran';
  ScheduleFrequency _selectedFrequency = ScheduleFrequency.once;

  final List<String> _wasteTypes = [
    'Campuran',
    'Organik',
    'Anorganik',
    'B3',
    'Elektronik',
  ];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    _weightController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user ID
      final localStorage = await LocalStorageService.getInstance();
      final userData = await localStorage.getUserData();
      if (userData != null) {
        _userId = userData['id'] as String;
      }

      // Get current location
      _getCurrentLocation();

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        // Set mock user data
        _nameController.text = 'Andi Wijaya';
        _phoneController.text = '+62 812-3456-7890';
        _addressController.text =
            'Jl. Sudirman No. 123, Kec. Menteng, Jakarta Pusat, DKI Jakarta 10310';
      });
    } catch (e) {
      print('Error initializing: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check for location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permission denied
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permission permanently denied
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition();

      if (!mounted) return;
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        // Keep mock address data, don't override
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: greenColor,
              onPrimary: whiteColor,
              surface: whiteColor,
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

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: greenColor,
              onPrimary: whiteColor,
              surface: whiteColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitSchedule() async {
    if (_formKey.currentState!.validate() && _userId != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final newSchedule = ScheduleModel(
          userId: _userId!,
          scheduledDate: _selectedDate,
          timeSlot: _selectedTime,
          location: _selectedLocation,
          address:
              'Jl. Sudirman No. 123, Kec. Menteng, Jakarta Pusat, DKI Jakarta 10310',
          notes: _notesController.text.isNotEmpty
              ? _notesController.text
              : null,
          status: ScheduleStatus.pending,
          frequency: _selectedFrequency,
          createdAt: DateTime.now(),
          wasteType: _selectedWasteType,
          estimatedWeight: _weightController.text.isNotEmpty
              ? double.parse(_weightController.text)
              : null,
          isPaid: false,
          contactName: 'Andi Wijaya',
          contactPhone: '+62 812-3456-7890',
        );

        final createdSchedule = await _scheduleService.createSchedule(
          newSchedule,
        );

        if (createdSchedule != null) {
          if (mounted) {
            DialogHelper.showSuccessDialog(
              context: context,
              title: 'Jadwal Berhasil Dibuat',
              message: 'Jadwal pengambilan sampah Anda telah berhasil dibuat.',
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(
                  context,
                  createdSchedule,
                ); // Return to previous screen with created schedule
              },
            );
          }
        } else {
          if (mounted) {
            DialogHelper.showErrorDialog(
              context: context,
              title: 'Gagal Membuat Jadwal',
              message:
                  'Terjadi kesalahan saat membuat jadwal. Silakan coba lagi nanti.',
            );
          }
        }
      } catch (e) {
        print('Error creating schedule: $e');
        if (mounted) {
          DialogHelper.showErrorDialog(
            context: context,
            title: 'Gagal Membuat Jadwal',
            message: 'Terjadi kesalahan: $e',
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackgroundColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        title: Text(
          'Buat Jadwal Baru',
          style: blackTextStyle.copyWith(
            fontSize: 20,
            fontWeight: semiBold,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: blackColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: greenColor))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header section with illustration
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.eco, color: greenColor, size: 60),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hari ini pengambilan sampah organik!',
                                style: blackTextStyle.copyWith(
                                  fontSize: 16,
                                  fontWeight: semiBold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Lengkapi detail jadwal untuk pengambilan sampah',
                                style: greyTextStyle.copyWith(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Form section
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section title - Date and Time
                          _buildSectionTitle(
                            title: 'Waktu Penjemputan',
                            icon: Icons.access_time,
                          ),
                          const SizedBox(height: 16),

                          // Date picker
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: whiteColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: greyColor.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    color: greenColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Tanggal Penjemputan',
                                          style: greyTextStyle.copyWith(
                                            fontSize: 14,
                                            fontWeight: medium,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat(
                                            'EEEE, d MMMM yyyy',
                                            'id_ID',
                                          ).format(_selectedDate),
                                          style: blackTextStyle.copyWith(
                                            fontSize: 16,
                                            fontWeight: medium,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: greenColor,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Time picker
                          GestureDetector(
                            onTap: () => _selectTime(context),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: whiteColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: greyColor.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    color: greenColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Waktu Penjemputan',
                                          style: greyTextStyle.copyWith(
                                            fontSize: 14,
                                            fontWeight: medium,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                                          style: blackTextStyle.copyWith(
                                            fontSize: 16,
                                            fontWeight: medium,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: greenColor,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Frequency
                          DropdownButtonFormField<ScheduleFrequency>(
                            value: _selectedFrequency,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Frekuensi Pengambilan',
                              labelStyle: greyTextStyle.copyWith(
                                fontSize: 14,
                                fontWeight: medium,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: greyColor.withOpacity(0.3),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: greyColor.withOpacity(0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: greenColor),
                              ),
                              prefixIcon: Icon(
                                Icons.repeat_rounded,
                                color: greenColor,
                              ),
                            ),
                            style: blackTextStyle.copyWith(
                              fontSize: 16,
                              fontWeight: medium,
                            ),
                            items: ScheduleFrequency.values.map((frequency) {
                              String label;
                              switch (frequency) {
                                case ScheduleFrequency.once:
                                  label = 'Sekali Saja';
                                  break;
                                case ScheduleFrequency.daily:
                                  label = 'Setiap Hari';
                                  break;
                                case ScheduleFrequency.weekly:
                                  label = 'Setiap Minggu';
                                  break;
                                case ScheduleFrequency.biWeekly:
                                  label = 'Setiap 2 Minggu';
                                  break;
                                case ScheduleFrequency.monthly:
                                  label = 'Setiap Bulan';
                                  break;
                              }
                              return DropdownMenuItem<ScheduleFrequency>(
                                value: frequency,
                                child: Text(label),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedFrequency = value;
                                });
                              }
                            },
                          ),

                          const SizedBox(height: 24),

                          // Section title - Location
                          _buildSectionTitle(
                            title: 'Lokasi Penjemputan',
                            icon: Icons.location_on,
                          ),
                          const SizedBox(height: 16),

                          // Location pickup card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: greenColor.withOpacity(0.2),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: greenColor.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header with icon and title
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: greenColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.home_outlined,
                                        color: greenColor,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Alamat Penjemputan',
                                            style: blackTextStyle.copyWith(
                                              fontSize: 16,
                                              fontWeight: semiBold,
                                            ),
                                          ),
                                          Text(
                                            'Data tetap dari profil Anda',
                                            style: greyTextStyle.copyWith(
                                              fontSize: 12,
                                              fontWeight: regular,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Address display
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: lightBackgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: greyColor.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Contact name
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.person_outline,
                                            color: greenColor,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Andi Wijaya',
                                            style: blackTextStyle.copyWith(
                                              fontSize: 14,
                                              fontWeight: medium,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      // Phone number
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.phone_outlined,
                                            color: greenColor,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '+62 812-3456-7890',
                                            style: blackTextStyle.copyWith(
                                              fontSize: 14,
                                              fontWeight: medium,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      // Address
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.location_on_outlined,
                                            color: greenColor,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Jl. Sudirman No. 123, Kec. Menteng, Jakarta Pusat, DKI Jakarta 10310',
                                              style: blackTextStyle.copyWith(
                                                fontSize: 14,
                                                fontWeight: medium,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Section title - Additional Waste
                          _buildSectionTitle(
                            title: 'Sampah Tambahan',
                            icon: Icons.add_circle_outline,
                          ),
                          const SizedBox(height: 16),

                          // Waste type
                          DropdownButtonFormField<String>(
                            value: _selectedWasteType,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Jenis Sampah',
                              labelStyle: greyTextStyle.copyWith(
                                fontSize: 14,
                                fontWeight: medium,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: greyColor.withOpacity(0.3),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: greyColor.withOpacity(0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: greenColor),
                              ),
                              prefixIcon: Icon(
                                Icons.add_circle_outline,
                                color: greenColor,
                              ),
                            ),
                            style: blackTextStyle.copyWith(
                              fontSize: 16,
                              fontWeight: medium,
                            ),
                            items: _wasteTypes.map((type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedWasteType = value;
                                });
                              }
                            },
                          ),

                          const SizedBox(height: 16),

                          // Estimated weight
                          TextFormField(
                            controller: _weightController,
                            decoration: InputDecoration(
                              labelText: 'Perkiraan Berat (kg)',
                              labelStyle: greyTextStyle.copyWith(
                                fontSize: 14,
                                fontWeight: medium,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: greyColor.withOpacity(0.3),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: greyColor.withOpacity(0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: greenColor),
                              ),
                              prefixIcon: Icon(
                                Icons.scale_outlined,
                                color: greenColor,
                              ),
                              suffixText: 'kg',
                            ),
                            style: blackTextStyle.copyWith(
                              fontSize: 16,
                              fontWeight: medium,
                            ),
                            keyboardType: TextInputType.number,
                          ),

                          const SizedBox(height: 16),

                          // Notes
                          TextFormField(
                            controller: _notesController,
                            decoration: InputDecoration(
                              labelText: 'Catatan (opsional)',
                              labelStyle: greyTextStyle.copyWith(
                                fontSize: 14,
                                fontWeight: medium,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: greyColor.withOpacity(0.3),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: greyColor.withOpacity(0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: greenColor),
                              ),
                              prefixIcon: Icon(
                                Icons.note_outlined,
                                color: greenColor,
                              ),
                            ),
                            style: blackTextStyle.copyWith(
                              fontSize: 16,
                              fontWeight: medium,
                            ),
                            maxLines: 3,
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: whiteColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: CustomFilledButton(
            title: 'Buat Jadwal',
            onPressed: _submitSchedule,
            isLoading: _isLoading,
          ),
        ),
      ),
    );
  }

  // Helper method to build section titles
  Widget _buildSectionTitle({required String title, required IconData icon}) {
    return Row(
      children: [
        Icon(icon, color: greenColor, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: blackTextStyle.copyWith(fontSize: 18, fontWeight: semiBold),
        ),
      ],
    );
  }
}

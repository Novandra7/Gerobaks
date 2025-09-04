import 'package:bank_sha/models/schedule_model.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/services/schedule_service.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';
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
  LatLng _selectedLocation = const LatLng(-6.2088, 106.8456); // Default to Jakarta
  String _selectedWasteType = 'Campuran';
  ScheduleFrequency _selectedFrequency = ScheduleFrequency.once;

  final List<String> _wasteTypes = [
    'Campuran',
    'Organik',
    'Anorganik',
    'B3 (Bahan Berbahaya dan Beracun)',
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

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error initializing: $e');
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
      
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _addressController.text = "Lokasi saya saat ini"; // Default address
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
          address: _addressController.text,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
          status: ScheduleStatus.pending,
          frequency: _selectedFrequency,
          createdAt: DateTime.now(),
          wasteType: _selectedWasteType,
          estimatedWeight: _weightController.text.isNotEmpty ? double.parse(_weightController.text) : null,
          isPaid: false,
          contactName: _nameController.text,
          contactPhone: _phoneController.text,
        );

        final createdSchedule = await _scheduleService.createSchedule(newSchedule);

        if (createdSchedule != null) {
          if (mounted) {
            DialogHelper.showSuccessDialog(
              context: context,
              title: 'Jadwal Berhasil Dibuat',
              message: 'Jadwal pengambilan sampah Anda telah berhasil dibuat.',
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, createdSchedule); // Return to previous screen with created schedule
              },
            );
          }
        } else {
          if (mounted) {
            DialogHelper.showErrorDialog(
              context: context,
              title: 'Gagal Membuat Jadwal',
              message: 'Terjadi kesalahan saat membuat jadwal. Silakan coba lagi nanti.',
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
        backgroundColor: greenColor,
        elevation: 0,
        title: Text(
          'Buat Jadwal Baru',
          style: whiteTextStyle.copyWith(
            fontSize: 20,
            fontWeight: semiBold,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: greenColor),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date and Time
                    Text(
                      'Waktu Penjemputan',
                      style: blackTextStyle.copyWith(
                        fontSize: 18,
                        fontWeight: semiBold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Date picker
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: greyColor.withOpacity(0.3)),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                    DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: greyColor.withOpacity(0.3)),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                      decoration: InputDecoration(
                        labelText: 'Frekuensi Pengambilan',
                        labelStyle: greyTextStyle.copyWith(
                          fontSize: 14,
                          fontWeight: medium,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
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
                    
                    // Location
                    Text(
                      'Lokasi Penjemputan',
                      style: blackTextStyle.copyWith(
                        fontSize: 18,
                        fontWeight: semiBold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // User Information
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap',
                        labelStyle: greyTextStyle.copyWith(
                          fontSize: 14,
                          fontWeight: medium,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: greenColor),
                        ),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: greenColor,
                        ),
                      ),
                      style: blackTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: medium,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Phone input
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Nomor Telepon',
                        labelStyle: greyTextStyle.copyWith(
                          fontSize: 14,
                          fontWeight: medium,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: greenColor),
                        ),
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                          color: greenColor,
                        ),
                      ),
                      style: blackTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: medium,
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nomor telepon tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Address input
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Alamat Lengkap',
                        labelStyle: greyTextStyle.copyWith(
                          fontSize: 14,
                          fontWeight: medium,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: greenColor),
                        ),
                        prefixIcon: Icon(
                          Icons.location_on_outlined,
                          color: greenColor,
                        ),
                      ),
                      style: blackTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: medium,
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Alamat tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Location map preview placeholder
                    Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.map_outlined,
                              color: greenColor,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Peta Lokasi',
                              style: blackTextStyle.copyWith(
                                fontSize: 14,
                                fontWeight: medium,
                              ),
                            ),
                            Text(
                              'Tekan untuk memilih lokasi di peta',
                              style: greyTextStyle.copyWith(
                                fontSize: 12,
                                fontWeight: regular,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Waste Details
                    Text(
                      'Detail Sampah',
                      style: blackTextStyle.copyWith(
                        fontSize: 18,
                        fontWeight: semiBold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Waste type
                    DropdownButtonFormField<String>(
                      value: _selectedWasteType,
                      decoration: InputDecoration(
                        labelText: 'Jenis Sampah',
                        labelStyle: greyTextStyle.copyWith(
                          fontSize: 14,
                          fontWeight: medium,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: greenColor),
                        ),
                        prefixIcon: Icon(
                          Icons.delete_outline,
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
                          borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
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
                          borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
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
                    
                    // Submit button
                    CustomFilledButton(
                      title: 'Buat Jadwal',
                      onPressed: _submitSchedule,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

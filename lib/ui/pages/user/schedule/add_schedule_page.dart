import 'package:bank_sha/models/schedule_model.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/services/schedule_service.dart';
import 'package:bank_sha/services/waste_schedule_service.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:bank_sha/ui/widgets/shared/dialog_helper.dart';
import 'package:bank_sha/utils/user_data_mock.dart';
import 'package:flutter/material.dart';
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

  // Dynamic waste schedule info
  String _todayWasteType = 'Campuran';
  String _todayWasteDescription = 'Hari ini pengambilan sampah campuran!';

  // Additional waste toggle
  bool _hasAdditionalWaste = false;

  // Scheduled waste toggle - default ON
  bool _hasScheduledWaste = true;

  LatLng _selectedLocation = const LatLng(
    -6.2088,
    106.8456,
  ); // Default to Jakarta
  final List<String> _selectedWasteTypes =
      []; // Changed to list for multi-select
  final ScheduleFrequency _selectedFrequency = ScheduleFrequency.once;

  // Dynamic weight controllers for each waste type
  final Map<String, TextEditingController> _weightControllers = {};

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
    // Dispose dynamic weight controllers
    for (var controller in _weightControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _initialize() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Load today's waste schedule info
      _loadTodayWasteSchedule();

      // Get current user ID
      final localStorage = await LocalStorageService.getInstance();
      final userData = await localStorage.getUserData();
      if (userData != null) {
        _userId = userData['id'] as String;

        // Get user data from mock based on user ID
        final userMockData = UserDataMock.getUserById(_userId!);
        if (userMockData != null) {
          _nameController.text = userMockData['name'] ?? '';
          _phoneController.text = userMockData['phone'] ?? '';
          _addressController.text = userMockData['address'] ?? '';
        }
      }

      // Get current location
      _getCurrentLocation();

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error initializing: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadTodayWasteSchedule() {
    final todaySchedule = WasteScheduleService.getTodaySchedule();
    if (todaySchedule != null) {
      setState(() {
        _todayWasteType = todaySchedule['type'] ?? 'Campuran';
        _todayWasteDescription =
            'Hari ini pengambilan sampah ${_todayWasteType.toLowerCase()}!';
      });
    } else {
      setState(() {
        _todayWasteType = 'Campuran';
        _todayWasteDescription = 'Tidak ada jadwal pengambilan hari ini';
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

  Future<void> _submitSchedule() async {
    if (_formKey.currentState!.validate() && _userId != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final newSchedule = ScheduleModel(
          userId: _userId!,
          scheduledDate: DateTime.now().add(
            const Duration(days: 1),
          ), // Always tomorrow
          timeSlot: const TimeOfDay(hour: 6, minute: 0), // Fixed time 06:00
          location: _selectedLocation,
          address:
              'Jl. Sudirman No. 123, Kec. Menteng, Jakarta Pusat, DKI Jakarta 10310',
          notes: _notesController.text.isNotEmpty
              ? _notesController.text
              : null,
          status: ScheduleStatus.pending,
          frequency: _selectedFrequency,
          createdAt: DateTime.now(),
          wasteType: _hasAdditionalWaste && _selectedWasteTypes.isNotEmpty
              ? _selectedWasteTypes.join(', ')
              : null,
          estimatedWeight: _hasAdditionalWaste && _selectedWasteTypes.isNotEmpty
              ? _calculateTotalWeight()
              : null,
          isPaid: false,
          contactName: 'Andi Wijaya',
          contactPhone: '+62 812-3456-7890',
          // Add scheduled waste info in notes or a custom field
          // For now, we'll add it to notes
        );

        // Add scheduled waste info to notes if enabled
        String finalNotes = _notesController.text;
        if (_hasScheduledWaste) {
          String scheduledWasteNote =
              'Sampah sesuai jadwal: $_todayWasteType (GRATIS)';
          if (finalNotes.isNotEmpty) {
            finalNotes = '$finalNotes\n\n$scheduledWasteNote';
          } else {
            finalNotes = scheduledWasteNote;
          }
        }

        // Update schedule with final notes
        final updatedSchedule = ScheduleModel(
          userId: newSchedule.userId,
          scheduledDate: newSchedule.scheduledDate,
          timeSlot: newSchedule.timeSlot,
          location: newSchedule.location,
          address: newSchedule.address,
          notes: finalNotes.isNotEmpty ? finalNotes : null,
          status: newSchedule.status,
          frequency: newSchedule.frequency,
          createdAt: newSchedule.createdAt,
          wasteType: newSchedule.wasteType,
          estimatedWeight: newSchedule.estimatedWeight,
          isPaid: newSchedule.isPaid,
          contactName: newSchedule.contactName,
          contactPhone: newSchedule.contactPhone,
        );

        final createdSchedule = await _scheduleService.createSchedule(
          updatedSchedule,
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

  // Calculate total weight from all selected waste types
  double? _calculateTotalWeight() {
    double total = 0.0;
    bool hasValidWeight = false;

    for (String type in _selectedWasteTypes) {
      final controller = _weightControllers[type];
      if (controller != null && controller.text.isNotEmpty) {
        try {
          total += double.parse(controller.text);
          hasValidWeight = true;
        } catch (e) {
          // Skip invalid numbers
        }
      }
    }

    return hasValidWeight ? total : null;
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
                        Icon(
                          _getWasteTypeIcon(_todayWasteType),
                          color: greenColor,
                          size: 60,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _todayWasteDescription,
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
                          // Section title - Schedule Info
                          _buildSectionTitle(
                            title: 'Jadwal Penjemputan',
                            icon: Icons.schedule,
                          ),
                          const SizedBox(height: 16),

                          // Automatic schedule info card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: greenColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: greenColor.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.schedule_outlined,
                                  color: greenColor,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Waktu Penjemputan Otomatis',
                                  style: blackTextStyle.copyWith(
                                    fontSize: 18,
                                    fontWeight: semiBold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: greenColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '06:00 - 08:00',
                                    style: TextStyle(
                                      color: greenColor,
                                      fontSize: 16,
                                      fontWeight: bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: greenColor.withOpacity(0.8),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Penjemputan akan dilakukan pada pagi hari sesuai jadwal Gerobaks',
                                        style: greyTextStyle.copyWith(
                                          fontSize: 14,
                                          fontWeight: medium,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
                                            _nameController.text.isNotEmpty
                                                ? _nameController.text
                                                : 'Nama Pengguna',
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
                                            _phoneController.text.isNotEmpty
                                                ? _phoneController.text
                                                : 'Nomor Telepon',
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
                                              _addressController.text.isNotEmpty
                                                  ? _addressController.text
                                                  : 'Alamat Lengkap',
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

                          // Section title - Scheduled Waste with Toggle
                          Row(
                            children: [
                              Icon(
                                _getWasteTypeIcon(_todayWasteType),
                                color: greenColor,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Sampah $_todayWasteType',
                                  style: blackTextStyle.copyWith(
                                    fontSize: 18,
                                    fontWeight: semiBold,
                                  ),
                                ),
                              ),
                              // Toggle Switch
                              Transform.scale(
                                scale: 0.8,
                                child: Switch(
                                  value: _hasScheduledWaste,
                                  onChanged: (value) {
                                    setState(() {
                                      _hasScheduledWaste = value;
                                    });
                                  },
                                  activeColor: greenColor,
                                  activeTrackColor: greenColor.withOpacity(0.3),
                                  inactiveThumbColor: greyColor,
                                  inactiveTrackColor: greyColor.withOpacity(
                                    0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Conditional Scheduled Waste Form
                          if (_hasScheduledWaste) ...[
                            // Info Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Sampah ${_todayWasteType.toLowerCase()} sesuai jadwal hari ini - Gratis',
                                      style: TextStyle(
                                        color: Colors.blue.withOpacity(0.8),
                                        fontSize: 14,
                                        fontWeight: medium,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Scheduled waste info display
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: whiteColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: greenColor.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: greenColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      _getWasteTypeIcon(_todayWasteType),
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
                                          'Jenis Sampah: $_todayWasteType',
                                          style: blackTextStyle.copyWith(
                                            fontSize: 16,
                                            fontWeight: semiBold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Pengambilan sesuai jadwal harian',
                                          style: greyTextStyle.copyWith(
                                            fontSize: 14,
                                            fontWeight: medium,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: greenColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'GRATIS',
                                      style: TextStyle(
                                        color: greenColor,
                                        fontSize: 12,
                                        fontWeight: bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            // Inactive state info for scheduled waste
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: greyColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: greyColor.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    _getWasteTypeIcon(_todayWasteType),
                                    color: greyColor.withOpacity(0.6),
                                    size: 48,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Tidak ada sampah ${_todayWasteType.toLowerCase()}',
                                    style: greyTextStyle.copyWith(
                                      fontSize: 16,
                                      fontWeight: medium,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Aktifkan toggle untuk mengambil sampah ${_todayWasteType.toLowerCase()} sesuai jadwal',
                                    style: greyTextStyle.copyWith(fontSize: 14),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Section title - Additional Waste with Toggle
                          Row(
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: greenColor,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Sampah Tambahan',
                                  style: blackTextStyle.copyWith(
                                    fontSize: 18,
                                    fontWeight: semiBold,
                                  ),
                                ),
                              ),
                              // Toggle Switch
                              Transform.scale(
                                scale: 0.8,
                                child: Switch(
                                  value: _hasAdditionalWaste,
                                  onChanged: (value) {
                                    setState(() {
                                      _hasAdditionalWaste = value;
                                      if (!value) {
                                        // Reset values when turned off
                                        _selectedWasteTypes.clear();
                                        _weightController.clear();
                                        // Clear dynamic weight controllers
                                        for (var controller
                                            in _weightControllers.values) {
                                          controller.dispose();
                                        }
                                        _weightControllers.clear();
                                      }
                                    });
                                  },
                                  activeColor: greenColor,
                                  activeTrackColor: greenColor.withOpacity(0.3),
                                  inactiveThumbColor: greyColor,
                                  inactiveTrackColor: greyColor.withOpacity(
                                    0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Conditional Additional Waste Form
                          if (_hasAdditionalWaste) ...[
                            // Info Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: greenColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: greenColor.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: greenColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                'Tambahkan sampah selain yang dijadwalkan hari ini ',
                                            style: TextStyle(
                                              color: greenColor.withOpacity(
                                                0.8,
                                              ),
                                              fontSize: 14,
                                              fontWeight: medium,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '(Berbayar)',
                                            style: TextStyle(
                                              color: redcolor,
                                              fontSize: 14,
                                              fontWeight: semiBold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Multi-select dropdown
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Multi-select dropdown field
                                DropdownButtonFormField<String>(
                                  value: null, // Always null for multi-select
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: 'Jenis Sampah',
                                    hintText: _selectedWasteTypes.isEmpty
                                        ? 'Pilih jenis sampah (dapat memilih lebih dari 1)'
                                        : '${_selectedWasteTypes.length} jenis sampah dipilih',
                                    labelStyle: greyTextStyle.copyWith(
                                      fontSize: 14,
                                      fontWeight: medium,
                                    ),
                                    hintStyle: _selectedWasteTypes.isEmpty
                                        ? greyTextStyle.copyWith(fontSize: 14)
                                        : blackTextStyle.copyWith(
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
                                      Icons.category_outlined,
                                      color: greenColor,
                                    ),
                                  ),
                                  style: blackTextStyle.copyWith(
                                    fontSize: 16,
                                    fontWeight: medium,
                                  ),
                                  items: _wasteTypes.map((type) {
                                    final isSelected = _selectedWasteTypes
                                        .contains(type);
                                    return DropdownMenuItem<String>(
                                      value: type,
                                      child: StatefulBuilder(
                                        builder: (context, setMenuState) {
                                          return InkWell(
                                            onTap: () {
                                              setState(() {
                                                if (isSelected) {
                                                  _selectedWasteTypes.remove(
                                                    type,
                                                  );
                                                  // Remove and dispose controller for this type
                                                  _weightControllers[type]
                                                      ?.dispose();
                                                  _weightControllers.remove(
                                                    type,
                                                  );
                                                } else {
                                                  _selectedWasteTypes.add(type);
                                                  // Create new controller for this type
                                                  _weightControllers[type] =
                                                      TextEditingController();
                                                }
                                              });
                                              setMenuState(
                                                () {},
                                              ); // Update checkbox state
                                            },
                                            child: Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Checkbox(
                                                    value: _selectedWasteTypes
                                                        .contains(type),
                                                    onChanged: (bool? value) {
                                                      setState(() {
                                                        if (value == true) {
                                                          _selectedWasteTypes
                                                              .add(type);
                                                          // Create new controller for this type
                                                          _weightControllers[type] =
                                                              TextEditingController();
                                                        } else {
                                                          _selectedWasteTypes
                                                              .remove(type);
                                                          // Remove and dispose controller for this type
                                                          _weightControllers[type]
                                                              ?.dispose();
                                                          _weightControllers
                                                              .remove(type);
                                                        }
                                                      });
                                                      setMenuState(
                                                        () {},
                                                      ); // Update checkbox state
                                                    },
                                                    activeColor: greenColor,
                                                    materialTapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Icon(
                                                    _getWasteTypeIcon(type),
                                                    color:
                                                        _selectedWasteTypes
                                                            .contains(type)
                                                        ? greenColor
                                                        : greyColor,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      type,
                                                      style: TextStyle(
                                                        color:
                                                            _selectedWasteTypes
                                                                .contains(type)
                                                            ? greenColor
                                                            : blackColor,
                                                        fontWeight:
                                                            _selectedWasteTypes
                                                                .contains(type)
                                                            ? semiBold
                                                            : medium,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    // This prevents the dropdown from closing when an item is selected
                                    // The actual selection is handled in the onTap of each item
                                  },
                                  validator: (value) {
                                    if (_selectedWasteTypes.isEmpty) {
                                      return 'Pilih minimal satu jenis sampah';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 12),

                                // Selected waste types chips
                                if (_selectedWasteTypes.isNotEmpty) ...[
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _selectedWasteTypes.map((type) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: greenColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: greenColor.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _getWasteTypeIcon(type),
                                              color: greenColor,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              type,
                                              style: TextStyle(
                                                color: greenColor,
                                                fontSize: 14,
                                                fontWeight: medium,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _selectedWasteTypes.remove(
                                                    type,
                                                  );
                                                  // Remove and dispose controller for this type
                                                  _weightControllers[type]
                                                      ?.dispose();
                                                  _weightControllers.remove(
                                                    type,
                                                  );
                                                });
                                              },
                                              child: Icon(
                                                Icons.close,
                                                color: greenColor,
                                                size: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Dynamic weight inputs for each selected waste type
                            if (_selectedWasteTypes.isNotEmpty) ...[
                              Text(
                                'Perkiraan Berat per Jenis Sampah',
                                style: blackTextStyle.copyWith(
                                  fontSize: 16,
                                  fontWeight: semiBold,
                                ),
                              ),
                              const SizedBox(height: 12),

                              ...(_selectedWasteTypes.map((type) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Header for each waste type
                                      Row(
                                        children: [
                                          Icon(
                                            _getWasteTypeIcon(type),
                                            color: greenColor,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Sampah $type',
                                            style: blackTextStyle.copyWith(
                                              fontSize: 14,
                                              fontWeight: medium,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Weight input for this waste type
                                      TextFormField(
                                        controller: _weightControllers[type],
                                        decoration: InputDecoration(
                                          labelText: 'Perkiraan Berat (kg)',
                                          labelStyle: greyTextStyle.copyWith(
                                            fontSize: 14,
                                            fontWeight: medium,
                                          ),
                                          hintText:
                                              'Masukkan berat untuk sampah $type',
                                          hintStyle: greyTextStyle.copyWith(
                                            fontSize: 14,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide(
                                              color: greyColor.withOpacity(0.3),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide(
                                              color: greyColor.withOpacity(0.3),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide(
                                              color: greenColor,
                                            ),
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
                                        validator: (value) {
                                          if (_hasAdditionalWaste &&
                                              (value == null ||
                                                  value.isEmpty)) {
                                            return 'Masukkan berat untuk sampah $type';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }).toList()),
                            ],
                          ] else ...[
                            // Inactive state info
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: greyColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: greyColor.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.remove_circle_outline,
                                    color: greyColor.withOpacity(0.6),
                                    size: 48,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Tidak ada sampah tambahan',
                                    style: greyTextStyle.copyWith(
                                      fontSize: 16,
                                      fontWeight: medium,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Aktifkan toggle di atas untuk menambah jenis sampah lain',
                                    style: greyTextStyle.copyWith(fontSize: 14),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status summary
              if (_hasScheduledWaste || _hasAdditionalWaste) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: greenColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: greenColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ringkasan Jadwal:',
                        style: blackTextStyle.copyWith(
                          fontSize: 14,
                          fontWeight: semiBold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_hasScheduledWaste) ...[
                        Row(
                          children: [
                            Icon(
                              _getWasteTypeIcon(_todayWasteType),
                              color: greenColor,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Sampah $_todayWasteType',
                              style: blackTextStyle.copyWith(fontSize: 14),
                            ),
                            const Spacer(),
                            Text(
                              'GRATIS',
                              style: TextStyle(
                                color: greenColor,
                                fontSize: 12,
                                fontWeight: bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (_hasAdditionalWaste) ...[
                        if (_hasScheduledWaste) const SizedBox(height: 4),
                        Column(
                          children: _selectedWasteTypes.map((type) {
                            final controller = _weightControllers[type];
                            final weight =
                                controller != null && controller.text.isNotEmpty
                                ? controller.text
                                : '0';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    _getWasteTypeIcon(type),
                                    color: Colors.orange,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Sampah $type: ${weight}kg',
                                      style: blackTextStyle.copyWith(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Berbayar',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 12,
                                      fontWeight: bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              CustomFilledButton(
                title: _getButtonTitle(),
                onPressed: _submitSchedule,
                isLoading: _isLoading,
              ),
            ],
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

  // Helper method to get icon based on waste type
  IconData _getWasteTypeIcon(String wasteType) {
    switch (wasteType.toLowerCase()) {
      case 'organik':
        return Icons.eco;
      case 'anorganik':
        return Icons.recycling;
      case 'b3':
        return Icons.warning;
      case 'elektronik':
        return Icons.electrical_services;
      case 'campuran':
      default:
        return Icons.delete_outline;
    }
  }

  // Helper method to get button title based on selected options
  String _getButtonTitle() {
    if (!_hasScheduledWaste && !_hasAdditionalWaste) {
      return 'Pilih Jenis Sampah';
    }

    if (_hasScheduledWaste && !_hasAdditionalWaste) {
      return 'Buat Jadwal - Gratis';
    }

    if (!_hasScheduledWaste && _hasAdditionalWaste) {
      return 'Buat Jadwal - Berbayar';
    }

    if (_hasScheduledWaste && _hasAdditionalWaste) {
      return 'Buat Jadwal - Gratis + Berbayar';
    }

    return 'Buat Jadwal';
  }
}

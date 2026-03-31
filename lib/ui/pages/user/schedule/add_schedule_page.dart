import 'dart:io';

import 'package:bank_sha/services/end_user_api_service.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/services/schedule_api_service.dart';
import 'package:bank_sha/services/subscription_service.dart';
import 'package:bank_sha/services/waste_schedule_service.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/pages/end_user/location/my_location_page.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:bank_sha/ui/widgets/shared/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

// Subscription check implemented for additional waste feature

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
  final _scheduledWeightController =
      TextEditingController(); // Controller untuk perkiraan berat sampah terjadwal

  // Image picker for waste photos
  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _wasteImages = [];

  // Address label from active subscription
  String _addressLabel = '';

  // Pickup time selection
  TimeOfDay _selectedPickupTime = const TimeOfDay(
    hour: 6,
    minute: 0,
  ); // Default 06:00
  final _pickupTimeController = TextEditingController(text: '06:00');

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _userId;

  // Dynamic waste schedule info
  String _todayWasteType = 'Campuran';
  String _todayWasteDescription = 'Hari ini pengambilan sampah campuran!';
  bool _hasTodayWasteSchedule = false;

  // Additional waste toggle - requires subscription
  bool _hasAdditionalWaste = false;

  // Scheduled waste toggle - default ON
  final bool _hasScheduledWaste = true;

  final List<String> _selectedWasteTypes =
      []; // Changed to list for multi-select

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
    _scheduledWeightController.dispose();
    _pickupTimeController.dispose();
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

      // Get current user ID and data
      final localStorage = await LocalStorageService.getInstance();
      final userData = await localStorage.getUserData();

      if (userData != null) {
        _userId = userData['id']?.toString() ?? '';

        // Use real user data from localStorage (from backend)
        final name = userData['name'] ?? userData['fullName'] ?? '';
        final phone = userData['phone'] ?? '';
        final address = userData['address'] ?? '';

        _nameController.text = name;
        _phoneController.text = phone;
        // Load address from active subscription, fallback to profile address
        await _loadActiveSubscriptionAddress(fallback: address);
      } else {
        print('⚠️ User data is NULL - user may not be logged in');
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
        _hasTodayWasteSchedule = true;
        _todayWasteType = todaySchedule['type'] ?? 'Campuran';
        _todayWasteDescription =
            'Hari ini pengambilan sampah ${_todayWasteType.toLowerCase()}!';

        _selectedWasteTypes.removeWhere(
          (type) => type.toLowerCase() == _todayWasteType.toLowerCase(),
        );
        _weightControllers.remove(_todayWasteType)?.dispose();
      });
    } else {
      setState(() {
        _hasTodayWasteSchedule = false;
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
      // Location obtained but not used in new API (uses user address from backend)
      print('Location: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _loadActiveSubscriptionAddress({String fallback = ''}) async {
    try {
      final addr = await EndUserApiService().getActiveSubscriptionAddress();
      if (addr != null) {
        final addressText =
            addr['address_text'] as String? ?? addr['address'] as String? ?? '';
        final label = addr['label'] as String? ?? '';
        if (mounted) {
          _addressController.text = addressText.isNotEmpty
              ? addressText
              : fallback;
          _addressLabel = label;
        }
        return;
      }
    } catch (e) {
      print('Error loading subscription address: $e');
    }
    if (mounted) {
      _addressController.text = fallback;
    }
  }

  Future<void> _pickWasteImageFromCamera() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (image != null && mounted) {
      setState(() => _wasteImages.add(image));
    }
  }

  Future<void> _pickWasteImageFromGallery() async {
    final images = await _imagePicker.pickMultiImage(imageQuality: 80);
    if (images.isNotEmpty && mounted) {
      setState(() => _wasteImages.addAll(images));
    }
  }

  void _showWasteTypeSelector() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: greyColor.withAlpha(77),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 4, 8),
              child: Row(
                children: [
                  Text(
                    'Jenis Sampah',
                    style: blackTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: semiBold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {});
                    },
                    child: Text(
                      'Selesai',
                      style: TextStyle(color: greenColor, fontWeight: semiBold),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ..._wasteTypes
                .where(
                  (type) =>
                      !_hasTodayWasteSchedule ||
                      type.toLowerCase() != _todayWasteType.toLowerCase(),
                )
                .map((type) {
              final isSelected = _selectedWasteTypes.contains(type);
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 2,
                ),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? greenColor.withAlpha(26)
                        : greyColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getWasteTypeIcon(type),
                    color: isSelected ? greenColor : greyColor,
                    size: 18,
                  ),
                ),
                title: Text(
                  type,
                  style: blackTextStyle.copyWith(
                    fontSize: 14,
                    fontWeight: isSelected ? semiBold : medium,
                  ),
                ),
                trailing: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isSelected
                      ? Icon(
                          Icons.check_circle_rounded,
                          key: const ValueKey('checked'),
                          color: greenColor,
                          size: 22,
                        )
                      : Icon(
                          Icons.circle_outlined,
                          key: const ValueKey('unchecked'),
                          color: greyColor.withAlpha(128),
                          size: 22,
                        ),
                ),
                onTap: () {
                  setSheetState(() {
                    if (isSelected) {
                      _selectedWasteTypes.remove(type);
                      _weightControllers[type]?.dispose();
                      _weightControllers.remove(type);
                    } else {
                      _selectedWasteTypes.add(type);
                      _weightControllers[type] = TextEditingController();
                    }
                  });
                  setState(() {});
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _selectPickupTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedPickupTime,
    );

    if (picked != null && picked != _selectedPickupTime) {
      final totalMinutes = picked.hour * 60 + picked.minute;
      final isValid = totalMinutes >= 6 * 60 && totalMinutes <= 8 * 60;

      if (!isValid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Waktu penjemputan hanya tersedia antara 06:00 – 08:00',
              ),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
        return;
      }
      setState(() {
        _selectedPickupTime = picked;
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        _pickupTimeController.text = '$hour:$minute';
      });
    }
  }

  Future<void> _submitSchedule() async {
    if (_formKey.currentState!.validate() && _userId != null) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final scheduleApiService = ScheduleApiService();

        // Prepare additional wastes array
        List<Map<String, dynamic>>? additionalWastes;
        if (_hasAdditionalWaste && _selectedWasteTypes.isNotEmpty) {
          additionalWastes = [];
          for (String type in _selectedWasteTypes) {
            final controller = _weightControllers[type];
            if (controller != null && controller.text.isNotEmpty) {
              try {
                final weight = double.parse(controller.text);
                additionalWastes.add({
                  'type': type,
                  'estimated_weight': weight,
                });
              } catch (e) {
                // Skip invalid weight
              }
            }
          }
        }

        // Parse scheduled weight
        double? scheduledWeight;
        if (_hasScheduledWaste && _scheduledWeightController.text.isNotEmpty) {
          try {
            scheduledWeight = double.parse(_scheduledWeightController.text);
          } catch (e) {
            // Keep null if parsing fails
          }
        }

        // Call API endpoint
        final response = await scheduleApiService.createPickupSchedule(
          isScheduledActive: _hasScheduledWaste,
          hasAdditionalWaste: _hasAdditionalWaste,
          additionalWastes: additionalWastes,
          notes: _notesController.text.isNotEmpty
              ? _notesController.text
              : null,
          scheduledWeight: scheduledWeight,
          pickupTimeStart: _pickupTimeController.text.isNotEmpty
              ? _pickupTimeController.text
              : null,
          wasteImages: _wasteImages.isNotEmpty ? _wasteImages : null,
        );

        // Check if successful
        if (response['success'] == true && mounted) {
          final data = response['data'] as Map<String, dynamic>;
          final scheduleId = data['id'] as int;
          final wasteSummary = data['waste_summary'] as String?;
          final totalWeight = data['total_estimated_weight'];

          DialogHelper.showSuccessDialog(
            context: context,
            title: 'Jadwal Berhasil Dibuat',
            message:
                'Jadwal penjemputan sampah berhasil dibuat!\n\nID Jadwal: $scheduleId\n${wasteSummary != null ? 'Jenis sampah: $wasteSummary\n' : ''}${totalWeight != null ? 'Estimasi berat: $totalWeight kg\n' : ''}Status: Menunggu penjemputan',
            onPressed: () {
              Navigator.of(context).pop(); // Close success dialog
              Navigator.of(
                context,
              ).pop(true); // Close AddSchedulePage with success flag
            },
          );
        } else {
          if (mounted) {
            final errorMessage =
                response['message'] as String? ??
                'Terjadi kesalahan saat membuat jadwal';
            DialogHelper.showErrorDialog(
              context: context,
              title: 'Gagal Membuat Jadwal',
              message: errorMessage,
            );
          }
        }
      } catch (e) {
        if (mounted) {
          DialogHelper.showErrorDialog(
            context: context,
            title: 'Gagal Membuat Jadwal',
            message: 'Terjadi kesalahan: ${e.toString()}',
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
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
                          color: Colors.black.withAlpha(26),
                          blurRadius: 8,
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
                              color: greenColor.withAlpha(26),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: greenColor.withAlpha(77),
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
                                    color: greenColor.withAlpha(51),
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
                                      color: greenColor.withAlpha(204),
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
                                color: greenColor.withAlpha(51),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: greenColor.withAlpha(26),
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
                                        color: greenColor.withAlpha(26),
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
                                            'Lokasi dari langganan aktif Anda',
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

                                // Address label chip
                                if (_addressLabel.isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: greenColor.withAlpha(26),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: greenColor.withAlpha(77),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.label_outline,
                                          color: greenColor,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _addressLabel,
                                          style: greenTextStyle.copyWith(
                                            fontSize: 12,
                                            fontWeight: medium,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // Address display
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: lightBackgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: greyColor.withAlpha(51),
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
                                            color: _nameController.text.isEmpty
                                                ? Colors.orange
                                                : greenColor,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _nameController.text.isNotEmpty
                                                  ? _nameController.text
                                                  : 'Nama Pengguna (Belum diisi)',
                                              style: blackTextStyle.copyWith(
                                                fontSize: 14,
                                                fontWeight: medium,
                                                color:
                                                    _nameController.text.isEmpty
                                                    ? Colors.orange
                                                    : null,
                                              ),
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
                                            color: _phoneController.text.isEmpty
                                                ? Colors.orange
                                                : greenColor,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _phoneController.text.isNotEmpty
                                                  ? _phoneController.text
                                                  : 'Nomor Telepon (Belum diisi)',
                                              style: blackTextStyle.copyWith(
                                                fontSize: 14,
                                                fontWeight: medium,
                                                color:
                                                    _phoneController
                                                        .text
                                                        .isEmpty
                                                    ? Colors.orange
                                                    : null,
                                              ),
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
                                            color:
                                                _addressController.text.isEmpty
                                                ? Colors.orange
                                                : greenColor,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _addressController.text.isNotEmpty
                                                  ? _addressController.text
                                                  : 'Alamat Lengkap (Belum diisi)',
                                              style: blackTextStyle.copyWith(
                                                fontSize: 14,
                                                fontWeight: medium,
                                                color:
                                                    _addressController
                                                        .text
                                                        .isEmpty
                                                    ? Colors.orange
                                                    : null,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Warning if data is incomplete
                                      if (_nameController.text.isEmpty ||
                                          _phoneController.text.isEmpty ||
                                          _addressController.text.isEmpty) ...[
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withAlpha(26),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.orange.withAlpha(
                                                77,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.warning_amber_rounded,
                                                color: Colors.orange,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Data profil belum lengkap. Silakan lengkapi di halaman Profil.',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.orange[800],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          width: double.infinity,
                                          child: OutlinedButton.icon(
                                            onPressed: () {
                                              // Navigate to profile page
                                              Navigator.pushNamed(
                                                context,
                                                '/profile',
                                              );
                                            },
                                            icon: Icon(Icons.edit, size: 16),
                                            label: Text('Lengkapi Profil'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.orange,
                                              side: BorderSide(
                                                color: Colors.orange,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const MyLocationPage(),
                                          ),
                                        );
                                        await _loadActiveSubscriptionAddress(
                                          fallback: _addressController.text,
                                        );
                                        if (mounted) setState(() {});
                                      },
                                      icon: Icon(
                                        Icons.edit_location_alt_outlined,
                                        color: greenColor,
                                        size: 18,
                                      ),
                                      label: Text(
                                        'Ubah Alamat',
                                        style: greenTextStyle.copyWith(
                                          fontSize: 14,
                                          fontWeight: medium,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

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
                              // Star icon indicating subscription required
                              Icon(Icons.star, color: Colors.amber, size: 20),
                              const SizedBox(width: 8),
                              // Toggle Switch - WITH SUBSCRIPTION CHECK
                              Transform.scale(
                                scale: 0.8,
                                child: Switch(
                                  value: _hasAdditionalWaste,
                                  onChanged: (value) async {
                                    if (value) {
                                      // Fetch fresh subscription from API to avoid stale local data
                                      final subscriptionService =
                                          SubscriptionService();
                                      final latestSubscription =
                                          await subscriptionService
                                              .getCurrentSubscriptionFromAPI();
                                      final hasActiveSub =
                                          latestSubscription?.isActive ?? false;

                                      if (!mounted) return;
                                      if (!hasActiveSub) {
                                        // Show subscription dialog
                                        _showSubscriptionDialog();
                                        return;
                                      }
                                    }

                                    // Allow toggle if turning off or has subscription
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
                                  activeTrackColor: greenColor.withAlpha(77),
                                  inactiveThumbColor: greyColor,
                                  inactiveTrackColor: greyColor.withAlpha(77),
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
                                color: greenColor.withAlpha(13),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: greenColor.withAlpha(51),
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
                                                'Tambahkan sampah selain yang dijadwalkan hari ini',
                                            style: TextStyle(
                                              color: greenColor.withAlpha(204),
                                              fontSize: 14,
                                              fontWeight: medium,
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
                                FormField<List<String>>(
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (_) => _selectedWasteTypes.isEmpty
                                      ? 'Pilih minimal satu jenis sampah'
                                      : null,
                                  builder: (field) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: _showWasteTypeSelector,
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: field.hasError
                                                  ? Colors.red.shade400
                                                  : _selectedWasteTypes
                                                        .isNotEmpty
                                                  ? greenColor
                                                  : greyColor.withAlpha(77),
                                              width:
                                                  field.hasError ||
                                                      _selectedWasteTypes
                                                          .isNotEmpty
                                                  ? 1.5
                                                  : 1.0,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.category_outlined,
                                                color:
                                                    _selectedWasteTypes
                                                        .isNotEmpty
                                                    ? greenColor
                                                    : greyColor,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  _selectedWasteTypes.isEmpty
                                                      ? 'Pilih jenis sampah'
                                                      : '${_selectedWasteTypes.length} jenis dipilih',
                                                  style:
                                                      _selectedWasteTypes
                                                          .isEmpty
                                                      ? greyTextStyle.copyWith(
                                                          fontSize: 14,
                                                        )
                                                      : blackTextStyle.copyWith(
                                                          fontSize: 14,
                                                          fontWeight: medium,
                                                        ),
                                                ),
                                              ),
                                              Icon(
                                                Icons
                                                    .keyboard_arrow_down_rounded,
                                                color:
                                                    _selectedWasteTypes
                                                        .isNotEmpty
                                                    ? greenColor
                                                    : greyColor,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (field.hasError)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 6,
                                            left: 12,
                                          ),
                                          child: Text(
                                            field.errorText!,
                                            style: TextStyle(
                                              color: Colors.red.shade700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
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
                                color: greyColor.withAlpha(13),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: greyColor.withAlpha(51),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.remove_circle_outline,
                                    color: greyColor.withAlpha(153),
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

                          const SizedBox(height: 24),

                          // Section title - Foto Sampah
                          Row(
                            children: [
                              Icon(
                                Icons.photo_camera_outlined,
                                color: greenColor,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Foto Sampah',
                                  style: blackTextStyle.copyWith(
                                    fontSize: 18,
                                    fontWeight: semiBold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Photo picker container
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: greenColor.withAlpha(51),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: greenColor.withAlpha(26),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tambahkan foto sampah (opsional)',
                                  style: greyTextStyle.copyWith(
                                    fontSize: 13,
                                    fontWeight: regular,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: _pickWasteImageFromCamera,
                                        icon: Icon(
                                          Icons.camera_alt_outlined,
                                          color: greenColor,
                                          size: 18,
                                        ),
                                        label: Text(
                                          'Kamera',
                                          style: greenTextStyle.copyWith(
                                            fontSize: 14,
                                            fontWeight: medium,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: greenColor),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: _pickWasteImageFromGallery,
                                        icon: Icon(
                                          Icons.photo_library_outlined,
                                          color: greenColor,
                                          size: 18,
                                        ),
                                        label: Text(
                                          'Galeri',
                                          style: greenTextStyle.copyWith(
                                            fontSize: 14,
                                            fontWeight: medium,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: greenColor),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_wasteImages.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 88,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _wasteImages.length,
                                      itemBuilder: (context, index) {
                                        return Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(
                                                right: 8,
                                                top: 4,
                                              ),
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                image: DecorationImage(
                                                  image: FileImage(
                                                    File(
                                                      _wasteImages[index].path,
                                                    ),
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 0,
                                              right: 4,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _wasteImages.removeAt(
                                                      index,
                                                    );
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    2,
                                                  ),
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Colors.red,
                                                        shape: BoxShape.circle,
                                                      ),
                                                  child: Icon(
                                                    Icons.close,
                                                    color: whiteColor,
                                                    size: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ],
                            ),
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

                          const SizedBox(height: 24),
                          // Form input perkiraan berat sampah terjadwal
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Perkiraan Berat (kg)',
                                style: blackTextStyle.copyWith(
                                  fontSize: 14,
                                  fontWeight: semiBold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _scheduledWeightController,
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Masukkan perkiraan berat sampah',
                                  hintStyle: greyTextStyle.copyWith(
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.scale_outlined,
                                    color: greenColor,
                                    size: 20,
                                  ),
                                  suffixText: 'kg',
                                  suffixStyle: blackTextStyle.copyWith(
                                    fontSize: 14,
                                    fontWeight: medium,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: greyColor.withAlpha(77),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: greyColor.withAlpha(77),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: greenColor,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Masukkan perkiraan berat sampah';
                                  }
                                  final weight = double.tryParse(value);
                                  if (weight == null || weight <= 0) {
                                    return 'Masukkan berat yang valid';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Waktu Penjemputan section
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: greenColor,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Waktu Penjemputan',
                                style: blackTextStyle.copyWith(
                                  fontSize: 16,
                                  fontWeight: semiBold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Info text
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: lightBackgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: greyColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 20,
                                  color: blueColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Pilih waktu yang Anda inginkan untuk penjemputan sampah',
                                    style: blackTextStyle.copyWith(
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Time picker field
                          TextFormField(
                            controller: _pickupTimeController,
                            readOnly: true,
                            onTap: _selectPickupTime,
                            decoration: InputDecoration(
                              labelText: 'Waktu Penjemputan',
                              labelStyle: greyTextStyle.copyWith(
                                fontSize: 14,
                                fontWeight: medium,
                              ),
                              hintText: 'Pilih waktu',
                              prefixIcon: Icon(
                                Icons.schedule,
                                color: greenColor,
                              ),
                              suffixIcon: Icon(
                                Icons.arrow_drop_down,
                                color: greyColor,
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
                            ),
                            style: blackTextStyle.copyWith(
                              fontSize: 16,
                              fontWeight: medium,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Waktu penjemputan wajib dipilih';
                              }
                              return null;
                            },
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
                title: 'Jadwalkan Penjemputan',
                onPressed: _submitSchedule,
                isLoading: _isSubmitting,
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

  // Show subscription dialog when additional waste is requested without subscription
  void _showSubscriptionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Berlangganan Diperlukan',
                  style: blackTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: semiBold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: Colors.amber,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Fitur "Sampah Tambahan" membutuhkan paket berlangganan',
                        style: blackTextStyle.copyWith(
                          fontSize: 14,
                          fontWeight: medium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Dengan berlangganan, Anda dapat:',
                style: blackTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: semiBold,
                ),
              ),
              const SizedBox(height: 8),
              _buildBenefitItem(
                '✓ Menambah berbagai jenis sampah dalam satu jadwal',
              ),
              _buildBenefitItem('✓ Fleksibilitas pengambilan sampah'),
              _buildBenefitItem('✓ Prioritas layanan customer'),
              _buildBenefitItem('✓ Bonus poin reward lebih banyak'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Tidak Sekarang',
                style: greyTextStyle.copyWith(fontSize: 14, fontWeight: medium),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to subscription plans page for payment
                Navigator.pushNamed(context, '/subscription-plans');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: greenColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Berlangganan Sekarang',
                style: whiteTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: semiBold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper method to build benefit item
  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: greyTextStyle.copyWith(fontSize: 13, fontWeight: regular),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/mitra_pickup_schedule.dart';
import '../../../services/mitra_api_service.dart';

class CompletePickupPage extends StatefulWidget {
  final MitraPickupSchedule schedule;

  const CompletePickupPage({super.key, required this.schedule});

  @override
  State<CompletePickupPage> createState() => _CompletePickupPageState();
}

class _CompletePickupPageState extends State<CompletePickupPage> {
  final MitraApiService _apiService = MitraApiService();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Form data
  final Map<String, TextEditingController> _weightControllers = {};
  final TextEditingController _notesController = TextEditingController();
  final List<XFile> _photos = [];
  bool _isSubmitting = false;

  // Dynamic waste types based on schedule
  late final List<String>
  _scheduledTypes; // Dari jadwal (daily + additional from user input)

  // Getter untuk semua waste types yang akan ditampilkan
  List<String> get _displayedWasteTypes => _scheduledTypes;

  /// Parse jenis sampah dari wasteTypeScheduled
  /// Mendukung format:
  /// - Single: "Campuran" atau "Organik"
  /// - Multiple (comma-separated): "Organik,Plastik,Kertas"
  ///
  /// PRIORITY:
  /// 1. userWasteTypes (semua jenis yang user input)
  /// 2. wasteTypeScheduled (fallback jika userWasteTypes null)
  List<String> _getScheduledWasteTypes() {
    // Priority 1: Use userWasteTypes if available (NEW)
    if (widget.schedule.userWasteTypes != null &&
        widget.schedule.userWasteTypes!.isNotEmpty) {
      final userTypes = widget.schedule.userWasteTypes!.trim();
      print('📦 User waste types (from user input): $userTypes');

      // Parse comma-separated or array
      if (userTypes.contains(',')) {
        final types = userTypes
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        print('✅ Parsed ${types.length} user types: $types');
        return types;
      }

      // Single type
      print('✅ Single user type: $userTypes');
      return [userTypes];
    }

    // Priority 2: Fallback to waste_type_scheduled
    final scheduled = widget.schedule.wasteTypeScheduled.trim();
    print('⚠️  Using fallback waste_type_scheduled: $scheduled');

    // Jika kosong, gunakan fallback
    if (scheduled.isEmpty) {
      print('⚠️  Empty waste_type_scheduled, using full fallback');
      return ['Organik', 'Anorganik', 'Kertas', 'Plastik', 'Logam', 'Kaca'];
    }

    // Jika berisi koma, split
    if (scheduled.contains(',')) {
      final types = scheduled
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      print('✅ Parsed ${types.length} scheduled types: $types');
      return types;
    }

    // Single type
    print('✅ Single scheduled type: $scheduled');
    return [scheduled];
  }

  @override
  void initState() {
    super.initState();
    _apiService.initialize();

    // Initialize scheduled waste types from schedule
    _scheduledTypes = _getScheduledWasteTypes();

    // Initialize weight controllers for scheduled types
    for (var type in _scheduledTypes) {
      _weightControllers[type] = TextEditingController();
    }

    print('🎯 Initialized ${_scheduledTypes.length} scheduled types');
  }

  @override
  void dispose() {
    _weightControllers.forEach((_, controller) => controller.dispose());
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _photos.add(image);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Gagal mengambil foto: $e')));
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: greyColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Pilih Sumber Foto',
                  style: blackTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: blueColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.camera_alt, color: blueColor),
                  ),
                  title: Text(
                    'Ambil Foto dari Kamera',
                    style: blackTextStyle.copyWith(fontWeight: medium),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: greenColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.photo_library, color: greenColor),
                  ),
                  title: Text(
                    'Pilih dari Galeri',
                    style: blackTextStyle.copyWith(fontWeight: medium),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  Future<void> _submitCompletion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Minimal 1 foto harus diupload'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Collect weights
    final actualWeights = <String, double>{};
    bool hasWeight = false;

    _weightControllers.forEach((type, controller) {
      if (controller.text.isNotEmpty) {
        final weight = double.tryParse(controller.text);
        if (weight != null && weight > 0) {
          actualWeights[type] = weight;
          hasWeight = true;
        }
      }
    });

    if (!hasWeight) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Minimal 1 jenis sampah harus diisi beratnya'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Confirm submission
    final totalWeight = actualWeights.values.reduce((a, b) => a + b);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Konfirmasi Penyelesaian',
          style: blackTextStyle.copyWith(fontWeight: bold, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detail pengambilan:',
              style: greyTextStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: greenColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: greenColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Berat:',
                        style: blackTextStyle.copyWith(fontWeight: medium),
                      ),
                      Text(
                        '${totalWeight.toStringAsFixed(2)} kg',
                        style: greenTextStyle.copyWith(
                          fontWeight: bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Jumlah Foto:',
                        style: blackTextStyle.copyWith(fontWeight: medium),
                      ),
                      Text(
                        '${_photos.length}',
                        style: blueTextStyle.copyWith(
                          fontWeight: bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Yakin ingin menyelesaikan pengambilan?',
              style: blackTextStyle.copyWith(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Periksa Kembali',
              style: greyTextStyle.copyWith(fontWeight: semiBold),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: greenColor,
              foregroundColor: whiteColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Ya, Selesaikan',
              style: whiteTextStyle.copyWith(fontWeight: semiBold),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSubmitting = true);

    try {
      // Convert XFile to file paths
      final photoPaths = _photos.map((photo) => photo.path).toList();

      await _apiService.completePickup(
        scheduleId: widget.schedule.id,
        actualWeights: actualWeights,
        photosPaths: photoPaths,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Pengambilan berhasil diselesaikan!',
              style: whiteTextStyle.copyWith(fontWeight: medium),
            ),
            backgroundColor: greenColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context, true); // Return true to refresh previous screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ Gagal menyelesaikan: $e',
              style: whiteTextStyle.copyWith(fontWeight: medium),
            ),
            backgroundColor: redcolor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: uicolor,
      appBar: AppBar(
        title: Text(
          'Selesaikan Pengambilan',
          style: blackTextStyle.copyWith(fontWeight: semiBold, fontSize: 18),
        ),
        backgroundColor: whiteColor,
        elevation: 0,
        iconTheme: IconThemeData(color: blackColor),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Schedule Info Card
            Card(
              elevation: 2,
              shadowColor: greenColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: greenColor.withOpacity(0.1)),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [whiteColor, greenui],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi Jadwal',
                        style: blackTextStyle.copyWith(
                          fontSize: 18,
                          fontWeight: bold,
                        ),
                      ),
                      Divider(height: 24, color: greenColor.withOpacity(0.2)),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: greenColor.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundColor: greenColor.withOpacity(0.1),
                              child: Icon(Icons.person, color: greenColor),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.schedule.userName,
                                  style: blackTextStyle.copyWith(
                                    fontWeight: bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  widget.schedule.pickupAddress,
                                  style: greyTextStyle.copyWith(fontSize: 14),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Photos Section
            Text(
              'Foto Pengambilan *',
              style: blackTextStyle.copyWith(fontSize: 16, fontWeight: bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload minimal 1 foto sampah yang diambil',
              style: greyTextStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 12),

            // Photo Grid
            if (_photos.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _photos.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: greenColor.withOpacity(0.2),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: greenColor.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          image: DecorationImage(
                            image: FileImage(File(_photos[index].path)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removePhoto(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: redcolor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: _showImageSourceDialog,
              style: OutlinedButton.styleFrom(
                foregroundColor: blueColor,
                side: BorderSide(color: blueColor.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: Icon(Icons.add_photo_alternate, color: blueColor),
              label: Text(
                _photos.isEmpty ? 'Tambah Foto' : 'Tambah Foto Lagi',
                style: blueTextStyle.copyWith(fontWeight: semiBold),
              ),
            ),
            const SizedBox(height: 24),

            // Weight Inputs Section
            Text(
              'Berat Sampah (kg) *',
              style: blackTextStyle.copyWith(fontSize: 16, fontWeight: bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Isi berat untuk ${_displayedWasteTypes.length} jenis sampah',
              style: greyTextStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 8),

            // Chips menampilkan jenis sampah yang dijadwalkan
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _displayedWasteTypes.map((type) {
                return Chip(
                  label: Text(type),
                  backgroundColor: greenColor.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: greenColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  side: BorderSide(color: greenColor.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            ..._displayedWasteTypes.map((type) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  controller: _weightControllers[type],
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Berat $type (kg)',
                    labelStyle: greyTextStyle,
                    hintText: 'Contoh: 2.5',
                    hintStyle: greyTextStyle.copyWith(fontSize: 14),
                    prefixIcon: Icon(Icons.monitor_weight, color: greenColor),
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
                      borderSide: BorderSide(color: greenColor, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: redcolor, width: 2),
                    ),
                    filled: true,
                    fillColor: whiteColor,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Berat wajib diisi';
                    }
                    final weight = double.tryParse(value);
                    if (weight == null || weight <= 0) {
                      return 'Masukkan berat yang valid (> 0)';
                    }
                    return null;
                  },
                ),
              );
            }),
            const SizedBox(height: 24),

            // Notes Section
            Text(
              'Catatan (Opsional)',
              style: blackTextStyle.copyWith(fontSize: 16, fontWeight: bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              style: blackTextStyle,
              decoration: InputDecoration(
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
                  borderSide: BorderSide(color: greenColor, width: 2),
                ),
                hintText: 'Tambahkan catatan jika diperlukan...',
                hintStyle: greyTextStyle.copyWith(fontSize: 14),
                filled: true,
                fillColor: whiteColor,
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitCompletion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenColor,
                  foregroundColor: whiteColor,
                  disabledBackgroundColor: greyColor.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  shadowColor: greenColor.withOpacity(0.3),
                ),
                icon: _isSubmitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: whiteColor,
                        ),
                      )
                    : Icon(Icons.check_circle, color: whiteColor),
                label: Text(
                  _isSubmitting ? 'Memproses...' : 'Selesaikan Pengambilan',
                  style: whiteTextStyle.copyWith(
                    fontWeight: semiBold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

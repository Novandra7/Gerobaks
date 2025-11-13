import 'dart:io';
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Ambil Foto dari Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
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
        title: const Text('Konfirmasi Penyelesaian'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Detail pengambilan:'),
            const SizedBox(height: 12),
            Text('Total Berat: ${totalWeight.toStringAsFixed(2)} kg'),
            Text('Jumlah Foto: ${_photos.length}'),
            const SizedBox(height: 12),
            const Text('Yakin ingin menyelesaikan pengambilan?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Periksa Kembali'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Selesaikan'),
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
          const SnackBar(
            content: Text('✅ Pengambilan berhasil diselesaikan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to refresh previous screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal menyelesaikan: $e'),
            backgroundColor: Colors.red,
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
      appBar: AppBar(title: const Text('Selesaikan Pengambilan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Schedule Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Jadwal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.green[100],
                          child: const Icon(Icons.person, color: Colors.green),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.schedule.userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                widget.schedule.pickupAddress,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
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
            const SizedBox(height: 20),

            // Photos Section
            const Text(
              'Foto Pengambilan *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload minimal 1 foto sampah yang diambil',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),

            // Photo Grid
            if (_photos.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _photos.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
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
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
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
              icon: const Icon(Icons.add_photo_alternate),
              label: Text(_photos.isEmpty ? 'Tambah Foto' : 'Tambah Foto Lagi'),
            ),
            const SizedBox(height: 24),

            // Weight Inputs Section
            const Text(
              'Berat Sampah (kg) *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Isi berat untuk ${_displayedWasteTypes.length} jenis sampah',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 8),

            // Chips menampilkan jenis sampah yang dijadwalkan
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _displayedWasteTypes.map((type) {
                return Chip(
                  label: Text(type),
                  backgroundColor: Colors.green[50],
                  labelStyle: TextStyle(
                    color: Colors.green[800],
                    fontWeight: FontWeight.w500,
                  ),
                  side: BorderSide(color: Colors.green[200]!),
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
                    labelText: type,
                    suffixText: 'kg',
                    border: const OutlineInputBorder(),
                    hintText: '0.00',
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),

            // Notes Section
            const Text(
              'Catatan (Opsional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Tambahkan catatan jika diperlukan...',
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitCompletion,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle),
                label: Text(
                  _isSubmitting ? 'Memproses...' : 'Selesaikan Pengambilan',
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

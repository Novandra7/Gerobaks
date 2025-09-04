import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';
import 'package:image_picker/image_picker.dart';

class BuatKeluhanFormEnhanced extends StatefulWidget {
  const BuatKeluhanFormEnhanced({super.key});

  @override
  State<BuatKeluhanFormEnhanced> createState() => _BuatKeluhanFormEnhancedState();
}

class _BuatKeluhanFormEnhancedState extends State<BuatKeluhanFormEnhanced> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _namaController = TextEditingController();
  final _phoneController = TextEditingController();

  String selectedKategori = 'Pengambilan Sampah';
  String selectedPrioritas = 'Normal';
  bool isLoading = false;

  List<XFile>? _imageFiles;
  final ImagePicker _picker = ImagePicker();

  final List<String> kategoriList = [
    'Pengambilan Sampah',
    'Jadwal Terlambat',
    'Kualitas Layanan',
    'Petugas',
    'Lainnya',
  ];

  final List<String> prioritasList = ['Rendah', 'Normal', 'Tinggi', 'Urgent'];

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    _namaController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImages() async {
    try {
      final List<XFile> selectedImages = await _picker.pickMultiImage();
      if (selectedImages.isNotEmpty) {
        setState(() {
          _imageFiles = selectedImages;
        });
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error picking images'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      // Generate random ID
      final String randomId = '${DateTime.now().millisecondsSinceEpoch}';
      final String currentDate = DateTime.now().toString().substring(0, 10);

      // Prepare keluhan data
      final Map<String, dynamic> keluhanData = {
        'id': randomId,
        'judul': _judulController.text,
        'deskripsi': _deskripsiController.text,
        'kategori': selectedKategori,
        'prioritas': selectedPrioritas,
        'lokasi': _lokasiController.text,
        'nama': _namaController.text,
        'phone': _phoneController.text,
        'tanggal': currentDate,
        'status': 'Menunggu',
        'images': _imageFiles?.map((file) => file.path).toList(),
      };

      // Simulate API call with delay
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Navigate to hasil page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HasilKeluhanPageEnhanced(keluhanData: keluhanData),
        ),
      ).then((_) {
        // Return data to previous page
        Navigator.pop(context, keluhanData);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: uicolor,
      appBar: const CustomAppBar(
        title: 'Buat Keluhan Baru',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Welcome
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        greenColor.withOpacity(0.1),
                        greenColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: greenColor.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.feedback_rounded,
                            color: greenColor,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '📝 Form Keluhan',
                            style: blackTextStyle.copyWith(
                              fontSize: 20,
                              fontWeight: bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sampaikan keluhan Anda untuk membantu kami meningkatkan kualitas layanan yang lebih baik. Kami akan merespons dengan cepat! 🚀',
                        style: greyTextStyle.copyWith(
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Judul Keluhan
                Text(
                  'Judul Keluhan',
                  style: blackTextStyle.copyWith(
                    fontWeight: semiBold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _judulController,
                  decoration: InputDecoration(
                    hintText: 'Masukkan judul keluhan',
                    hintStyle: greyTextStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: greyColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: greenColor),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Judul tidak boleh kosong';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Kategori Keluhan
                Text(
                  'Kategori',
                  style: blackTextStyle.copyWith(
                    fontWeight: semiBold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: greyColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedKategori,
                      hint: Text('Pilih kategori', style: greyTextStyle),
                      items: kategoriList.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedKategori = newValue!;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Prioritas Keluhan
                Text(
                  'Prioritas',
                  style: blackTextStyle.copyWith(
                    fontWeight: semiBold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: greyColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedPrioritas,
                      hint: Text('Pilih prioritas', style: greyTextStyle),
                      items: prioritasList.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _getPrioritasColor(value),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(value),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedPrioritas = newValue!;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Deskripsi Keluhan
                Text(
                  'Deskripsi Keluhan',
                  style: blackTextStyle.copyWith(
                    fontWeight: semiBold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _deskripsiController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Jelaskan detail keluhan Anda',
                    hintStyle: greyTextStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: greyColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: greenColor),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Deskripsi tidak boleh kosong';
                    }
                    if (value.length < 10) {
                      return 'Deskripsi minimal 10 karakter';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Lokasi
                Text(
                  'Lokasi',
                  style: blackTextStyle.copyWith(
                    fontWeight: semiBold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _lokasiController,
                  decoration: InputDecoration(
                    hintText: 'Masukkan alamat lokasi',
                    hintStyle: greyTextStyle,
                    prefixIcon: Icon(Icons.location_on_outlined, color: greyColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: greyColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: greenColor),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lokasi tidak boleh kosong';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Nama Pelapor
                Text(
                  'Nama Pelapor',
                  style: blackTextStyle.copyWith(
                    fontWeight: semiBold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _namaController,
                  decoration: InputDecoration(
                    hintText: 'Masukkan nama Anda',
                    hintStyle: greyTextStyle,
                    prefixIcon: Icon(Icons.person_outline, color: greyColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: greyColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: greenColor),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Nomor Telepon
                Text(
                  'Nomor Telepon',
                  style: blackTextStyle.copyWith(
                    fontWeight: semiBold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Masukkan nomor telepon',
                    hintStyle: greyTextStyle,
                    prefixIcon: Icon(Icons.phone_outlined, color: greyColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: greyColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: greenColor),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor telepon tidak boleh kosong';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Upload Photo Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lampiran Foto (Opsional)',
                        style: blackTextStyle.copyWith(
                          fontSize: 16,
                          fontWeight: semiBold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tambahkan foto untuk memperjelas keluhan Anda',
                        style: greyTextStyle.copyWith(fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      
                      // Preview images if selected
                      if (_imageFiles != null && _imageFiles!.isNotEmpty)
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _imageFiles!.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(_imageFiles![index].path),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _imageFiles!.removeAt(index);
                                            if (_imageFiles!.isEmpty) {
                                              _imageFiles = null;
                                            }
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      
                      const SizedBox(height: 16),
                      
                      // Upload button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _pickImages,
                          icon: const Icon(Icons.photo_camera),
                          label: Text(
                            _imageFiles == null ? 'Pilih Foto' : 'Ganti Foto',
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: greenColor),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: isLoading 
                      ? const CustomFilledButton(
                          title: 'Mengirim...',
                          onPressed: null,
                          isLoading: true,
                        ) 
                      : CustomFilledButton(
                          title: 'Kirim Keluhan',
                          onPressed: _submitForm,
                        ),
                ),

                const SizedBox(height: 16),

                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  child: CustomTextButton(
                    title: 'Batal',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Color _getPrioritasColor(String prioritas) {
    switch (prioritas.toLowerCase()) {
      case 'rendah':
        return Colors.green.shade600;
      case 'normal':
        return Colors.blue.shade600;
      case 'tinggi':
        return Colors.orange.shade600;
      case 'urgent':
        return Colors.red.shade600;
      default:
        return Colors.grey;
    }
  }
}

class HasilKeluhanPageEnhanced extends StatelessWidget {
  final Map<String, dynamic> keluhanData;

  const HasilKeluhanPageEnhanced({super.key, required this.keluhanData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: uicolor,
      appBar: const CustomAppBar(
        title: 'Hasil Keluhan Anda',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header Success dengan animasi
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [greenColor, greenColor.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: greenColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: whiteColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: whiteColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: whiteColor,
                      size: 55,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '🎉 Keluhan Berhasil Dikirim!',
                    style: whiteTextStyle.copyWith(
                      fontSize: 22,
                      fontWeight: bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: whiteColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: whiteColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      'ID: ${keluhanData['id']}',
                      style: whiteTextStyle.copyWith(
                        fontSize: 14,
                        fontWeight: semiBold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tim kami akan segera menindaklanjuti keluhan Anda.\nTerima kasih atas kepercayaan Anda! 🙏',
                    style: whiteTextStyle.copyWith(fontSize: 13, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Detail Keluhan
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail Keluhan',
                    style: blackTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Judul
                  _buildDetailItem('Judul', keluhanData['judul']),
                  const Divider(height: 24),

                  // Kategori
                  _buildDetailItem('Kategori', keluhanData['kategori']),
                  const SizedBox(height: 12),

                  // Prioritas
                  _buildDetailItem('Prioritas', keluhanData['prioritas']),
                  const Divider(height: 24),

                  // Deskripsi
                  Text(
                    'Deskripsi',
                    style: greyTextStyle.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    keluhanData['deskripsi'],
                    style: blackTextStyle.copyWith(height: 1.5),
                  ),
                  const Divider(height: 24),

                  // Lokasi
                  _buildDetailItem('Lokasi', keluhanData['lokasi']),
                  const Divider(height: 24),

                  // Pelapor & Kontak
                  _buildDetailItem('Nama Pelapor', keluhanData['nama']),
                  const SizedBox(height: 12),
                  _buildDetailItem('Kontak', keluhanData['phone']),
                  const Divider(height: 24),

                  // Tanggal
                  _buildDetailItem('Tanggal Laporan', keluhanData['tanggal']),
                  const SizedBox(height: 12),
                  _buildDetailItem('Status', keluhanData['status']),
                  
                  // Images if any
                  if (keluhanData['images'] != null && 
                      (keluhanData['images'] as List).isNotEmpty) ...[
                    const Divider(height: 24),
                    Text(
                      'Foto Lampiran',
                      style: greyTextStyle.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: (keluhanData['images'] as List).length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                // Preview image in full screen
                                showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                    child: Image.file(
                                      File(keluhanData['images'][index]),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(keluhanData['images'][index]),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Info Proses
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Informasi Proses',
                          style: blackTextStyle.copyWith(
                            fontSize: 16,
                            fontWeight: semiBold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildProcessStep(
                    1,
                    'Keluhan Diterima',
                    'Keluhan Anda telah berhasil dikirim dan terdaftar dalam sistem kami.',
                    Colors.green,
                    true,
                  ),
                  _buildProcessStep(
                    2,
                    'Dalam Proses Review',
                    'Tim kami akan mereview keluhan Anda dalam 1-3 hari kerja.',
                    Colors.orange,
                    false,
                  ),
                  _buildProcessStep(
                    3,
                    'Penanganan',
                    'Keluhan akan ditangani oleh tim terkait sesuai dengan kategori.',
                    Colors.grey,
                    false,
                  ),
                  _buildProcessStep(
                    4,
                    'Selesai',
                    'Keluhan telah ditangani dan ditutup.',
                    Colors.grey,
                    false,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: CustomFilledButton(
                title: 'Kembali ke Daftar Keluhan',
                onPressed: () => Navigator.pop(context),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: greyTextStyle.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: blackTextStyle.copyWith(
            fontWeight: medium,
          ),
        ),
      ],
    );
  }

  Widget _buildProcessStep(
    int step,
    String title,
    String description,
    Color color,
    bool isActive, {
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isActive ? color : Colors.grey.shade300,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? color.withOpacity(0.3) : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '$step',
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: isActive ? color.withOpacity(0.3) : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: blackTextStyle.copyWith(
                  fontWeight: semiBold,
                  color: isActive ? color : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: greyTextStyle.copyWith(
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

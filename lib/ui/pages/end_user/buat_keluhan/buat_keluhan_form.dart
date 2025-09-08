import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:bank_sha/ui/pages/end_user/buat_keluhan/hasil_keluhan_page.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';

class BuatKeluhanForm extends StatefulWidget {
  const BuatKeluhanForm({super.key});

  @override
  State<BuatKeluhanForm> createState() => _BuatKeluhanFormState();
}

class _BuatKeluhanFormState extends State<BuatKeluhanForm> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _namaController = TextEditingController();
  final _phoneController = TextEditingController();

  String selectedKategori = 'Pengambilan Sampah';
  String selectedPrioritas = 'Normal';

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

                const SizedBox(height: 32),

                // Informasi Pelapor Section
                Text(
                  '👤 Informasi Pelapor',
                  style: blackTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: bold,
                  ),
                ),
                const SizedBox(height: 16),

                _buildFormField(
                  title: '📝 Nama Lengkap',
                  controller: _namaController,
                  hint: 'Masukkan nama lengkap Anda',
                  icon: Icons.person_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama pelapor tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildFormField(
                  title: '📞 Nomor Telepon',
                  controller: _phoneController,
                  hint: 'Masukkan nomor telepon aktif',
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor telepon tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Detail Keluhan Section
                Text(
                  '📋 Detail Keluhan',
                  style: blackTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: bold,
                  ),
                ),
                const SizedBox(height: 16),

                _buildDropdownField(
                  title: '🏷️ Kategori Keluhan',
                  value: selectedKategori,
                  items: kategoriList,
                  icon: Icons.category_rounded,
                  onChanged: (value) {
                    setState(() {
                      selectedKategori = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                _buildDropdownField(
                  title: '⚡ Tingkat Prioritas',
                  value: selectedPrioritas,
                  items: prioritasList,
                  icon: Icons.priority_high_rounded,
                  onChanged: (value) {
                    setState(() {
                      selectedPrioritas = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                _buildFormField(
                  title: '📌 Judul Keluhan',
                  controller: _judulController,
                  hint: 'Ringkasan singkat keluhan Anda',
                  icon: Icons.title_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Judul keluhan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildFormField(
                  title: '📍 Lokasi Kejadian',
                  controller: _lokasiController,
                  hint: 'Alamat atau lokasi spesifik',
                  icon: Icons.location_on_rounded,
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lokasi kejadian tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildFormField(
                  title: '📝 Deskripsi Keluhan',
                  controller: _deskripsiController,
                  hint: 'Jelaskan keluhan Anda secara detail dan lengkap...',
                  icon: Icons.description_rounded,
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Deskripsi keluhan tidak boleh kosong';
                    }
                    if (value.length < 10) {
                      return 'Deskripsi minimal 10 karakter';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Upload Foto Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: greenColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          size: 30,
                          color: greenColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '📷 Upload Foto Pendukung',
                        style: blackTextStyle.copyWith(
                          fontWeight: semiBold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Opsional - Tambahkan foto untuk memperjelas keluhan',
                        style: greyTextStyle.copyWith(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: greenColor),
                        ),
                        child: CustomTextButton(
                          title: '📁 Pilih Foto',
                          onPressed: () {
                            _showImagePicker();
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Submit Button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: [greenColor, greenColor.withOpacity(0.8)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: greenColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CustomFilledButton(
                    title: '🚀 Kirim Keluhan',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _submitKeluhan();
                      }
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Cancel Button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: CustomTextButton(
                    title: '❌ Batal',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String title,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: blackTextStyle.copyWith(fontWeight: semiBold, fontSize: 15),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: blackTextStyle.copyWith(fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: whiteColor,
              hintText: hint,
              hintStyle: greyTextStyle.copyWith(fontSize: 13),
              prefixIcon: Icon(icon, color: greenColor, size: 20),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: greenColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: redcolor),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: redcolor, width: 2),
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String title,
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: blackTextStyle.copyWith(fontWeight: semiBold, fontSize: 15),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            initialValue: value,
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(icon, color: greenColor, size: 20),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item, style: blackTextStyle.copyWith(fontSize: 14)),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: greyColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Text(
              '📷 Pilih Foto',
              style: blackTextStyle.copyWith(fontWeight: bold, fontSize: 18),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _showMessage('📸 Kamera akan dibuka');
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [greenColor, greenColor.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: greenColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          color: whiteColor,
                          size: 35,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '📸 Kamera',
                        style: blackTextStyle.copyWith(fontWeight: semiBold),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _showMessage('🖼️ Galeri akan dibuka');
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade600,
                              Colors.blue.shade400,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.photo_library_rounded,
                          color: whiteColor,
                          size: 35,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '🖼️ Galeri',
                        style: blackTextStyle.copyWith(fontWeight: semiBold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _submitKeluhan() {
    // Kumpulkan data keluhan
    final keluhanData = {
      'nama': _namaController.text,
      'phone': _phoneController.text,
      'kategori': selectedKategori,
      'prioritas': selectedPrioritas,
      'judul': _judulController.text,
      'lokasi': _lokasiController.text,
      'deskripsi': _deskripsiController.text,
      'tanggal': DateTime.now().toString().split(' ')[0], // Format: YYYY-MM-DD
      'waktu': TimeOfDay.now().format(context),
      'status': 'Menunggu',
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    // Navigasi ke halaman hasil output keluhan
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HasilKeluhanPage(keluhanData: keluhanData),
      ),
    );

    // Reset form setelah submit
    _resetForm();
  }

  void _resetForm() {
    // Reset form
    _formKey.currentState!.reset();
    _judulController.clear();
    _deskripsiController.clear();
    _lokasiController.clear();
    _namaController.clear();
    _phoneController.clear();

    setState(() {
      selectedKategori = 'Pengambilan Sampah';
      selectedPrioritas = 'Normal';
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_rounded, color: whiteColor),
            const SizedBox(width: 8),
            Text(message, style: whiteTextStyle.copyWith(fontWeight: medium)),
          ],
        ),
        backgroundColor: greenColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

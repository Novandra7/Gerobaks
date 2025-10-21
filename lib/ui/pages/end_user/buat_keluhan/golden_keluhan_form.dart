import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';
import 'package:bank_sha/services/end_user_api_service.dart';
import 'package:bank_sha/services/local_storage_service.dart';

class GoldenKeluhanForm extends StatefulWidget {
  const GoldenKeluhanForm({super.key});

  @override
  State<GoldenKeluhanForm> createState() => _GoldenKeluhanFormState();
}

class _GoldenKeluhanFormState extends State<GoldenKeluhanForm> {
  final _formKey = GlobalKey<FormState>();

  // Form data
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  String _selectedKategori = 'Pengambilan Sampah';
  String _selectedPrioritas = 'Normal';

  // API and user data
  late EndUserApiService _apiService;
  late LocalStorageService _localStorage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _apiService = EndUserApiService();
    await _apiService.initialize();
    _localStorage = await LocalStorageService.getInstance();
    await _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      await _localStorage.getUserData();
      if (mounted) {
        setState(() {
          // User data loaded successfully
        });
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  // List of kategori
  final List<String> _kategoriList = [
    'Pengambilan Sampah',
    'Jadwal Terlambat',
    'Kualitas Layanan',
    'Aplikasi Bermasalah',
    'Petugas',
    'Lainnya',
  ];

  // List of prioritas
  final List<String> _prioritasList = ['Rendah', 'Normal', 'Tinggi', 'Urgent'];

  // Loading state
  // Removed _isLoading since we now use _isSubmitting

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  // Submit the form
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // Create keluhan data
        final keluhanData = {
          'title': _judulController.text,
          'description': _deskripsiController.text,
          'category': _selectedKategori,
          'priority': _selectedPrioritas,
          'location': _lokasiController.text,
        };

        // Submit to API
        final result = await _apiService.createFeedback(keluhanData);

        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });

          if (result != null) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Keluhan berhasil dikirim!',
                  style: whiteTextStyle.copyWith(fontWeight: medium),
                ),
                backgroundColor: greenColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );

            // Return to previous page with success result
            Navigator.of(context).pop(true);
          } else {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Gagal mengirim keluhan. Silakan coba lagi.',
                  style: whiteTextStyle.copyWith(fontWeight: medium),
                ),
                backgroundColor: redcolor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Terjadi kesalahan: $e',
                style: whiteTextStyle.copyWith(fontWeight: medium),
              ),
              backgroundColor: redcolor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
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
      body: _isSubmitting ? _buildLoadingState() : _buildFormContent(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: greenColor, strokeWidth: 4),
          const SizedBox(height: 20),
          Text(
            'Mengirim Keluhan...',
            style: blackTextStyle.copyWith(fontSize: 16, fontWeight: medium),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    // Calculate golden ratio dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = 24.0;
    final contentWidth = screenWidth - (horizontalPadding * 2);

    // Using golden ratio for consistent spacing
    final largeSpace = 24.0; // Base spacing
    final mediumSpace = largeSpace * 0.618; // Golden ratio applied
    final smallSpace = mediumSpace * 0.618; // Golden ratio applied again

    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(horizontalPadding),
        children: [
          // Form description
          Container(
            padding: EdgeInsets.all(mediumSpace),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                SizedBox(width: smallSpace),
                Expanded(
                  child: Text(
                    'Silakan isi formulir keluhan dengan detail yang lengkap agar kami dapat memproses dengan cepat.',
                    style: blackTextStyle.copyWith(
                      color: Colors.blue.shade900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: largeSpace),

          // Judul field - larger font as the main field
          _buildInputLabel('Judul Keluhan', isRequired: true),
          SizedBox(height: smallSpace),
          _buildTextFormField(
            controller: _judulController,
            hintText: 'Masukkan judul singkat keluhan',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Judul keluhan tidak boleh kosong';
              } else if (value.length < 5) {
                return 'Judul keluhan terlalu pendek';
              }
              return null;
            },
            fontSize: 16.0, // Larger font size for emphasis
          ),

          SizedBox(height: mediumSpace),

          // Kategori field
          _buildInputLabel('Kategori', isRequired: true),
          SizedBox(height: smallSpace),
          _buildDropdownField<String>(
            value: _selectedKategori,
            items: _kategoriList,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedKategori = value;
                });
              }
            },
            getLabel: (value) => value,
          ),

          SizedBox(height: mediumSpace),

          // Prioritas field
          _buildInputLabel('Prioritas', isRequired: true),
          SizedBox(height: smallSpace),
          _buildPrioritasSelector(),

          SizedBox(height: mediumSpace),

          // Lokasi field
          _buildInputLabel('Lokasi', isRequired: true),
          SizedBox(height: smallSpace),
          _buildTextFormField(
            controller: _lokasiController,
            hintText: 'Masukkan lokasi detail',
            prefixIcon: Icons.location_on_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Lokasi tidak boleh kosong';
              }
              return null;
            },
          ),

          SizedBox(height: mediumSpace),

          // Deskripsi field - larger box for detailed input
          _buildInputLabel('Deskripsi Keluhan', isRequired: true),
          SizedBox(height: smallSpace),
          _buildTextFormField(
            controller: _deskripsiController,
            hintText: 'Jelaskan keluhan Anda secara detail',
            maxLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Deskripsi keluhan tidak boleh kosong';
              } else if (value.length < 10) {
                return 'Deskripsi keluhan terlalu pendek';
              }
              return null;
            },
          ),

          SizedBox(height: largeSpace * 1.5),

          // Submit button - follows golden ratio width
          SizedBox(
            width: contentWidth,
            height: 50,
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: greenColor,
                foregroundColor: whiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Text(
                'Kirim Keluhan',
                style: whiteTextStyle.copyWith(
                  fontWeight: semiBold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          SizedBox(height: mediumSpace),

          // Cancel button
          SizedBox(
            width: contentWidth,
            height: 50,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: greyColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Batal',
                style: greyTextStyle.copyWith(fontWeight: semiBold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          label,
          style: blackTextStyle.copyWith(fontWeight: semiBold, fontSize: 14),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          Text(
            '*',
            style: TextStyle(color: Colors.red, fontWeight: semiBold),
          ),
        ],
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
    IconData? prefixIcon,
    int maxLines = 1,
    double fontSize = 14.0,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: blackTextStyle.copyWith(fontSize: fontSize),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: greyTextStyle.copyWith(fontSize: fontSize - 1),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: greyColor)
            : null,
        fillColor: whiteColor,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required T value,
    required List<T> items,
    required void Function(T?) onChanged,
    required String Function(T) getLabel,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: greyColor.withOpacity(0.3)),
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: InputBorder.none,
        ),
        style: blackTextStyle,
        dropdownColor: whiteColor,
        borderRadius: BorderRadius.circular(12),
        icon: Icon(Icons.arrow_drop_down, color: greyColor),
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(getLabel(item), style: blackTextStyle),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildPrioritasSelector() {
    // Using golden ratio to determine width proportions
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth - 48.0; // Total width minus padding
    final itemWidth = (contentWidth / 4)
        .floor(); // Roughly 1/4 of screen for each item

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: greyColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _prioritasList.map((prioritas) {
          final isSelected = _selectedPrioritas == prioritas;
          final color = _getPrioritasColor(prioritas);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedPrioritas = prioritas;
              });
            },
            child: Container(
              width: itemWidth - 8, // Subtracting for margins
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? color : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  // Priority indicator
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.3),
                                blurRadius: 6,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Priority label
                  Text(
                    prioritas,
                    style: TextStyle(
                      color: isSelected ? color : greyColor,
                      fontWeight: isSelected ? semiBold : regular,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
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
        return greyColor;
    }
  }
}

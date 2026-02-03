import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/services/api_service_manager.dart';
import 'package:bank_sha/services/api_service_manager_extension.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfilePage({super.key, required this.userData});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _vehiclePlateController = TextEditingController();
  final _workAreaController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    // Load from passed userData parameter
    _nameController.text = widget.userData['name'] ?? '';
    _emailController.text = widget.userData['email'] ?? '';
    _phoneController.text = widget.userData['phone'] ?? '';
    _addressController.text = widget.userData['address'] ?? '';
    _employeeIdController.text = widget.userData['employee_id'] ?? '';
    _vehicleTypeController.text = widget.userData['vehicle_type'] ?? '';
    _vehiclePlateController.text = widget.userData['vehicle_plate'] ?? '';
    _workAreaController.text = widget.userData['work_area'] ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _employeeIdController.dispose();
    _vehicleTypeController.dispose();
    _vehiclePlateController.dispose();
    _workAreaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: blackColor,
              size: 20,
            ),
          ),
        ),
        title: Text(
          'Edit Profile',
          style: blackTextStyle.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile Picture Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: greenColor.withAlpha(25),
                              border: Border.all(
                                color: greenColor.withAlpha(77),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'AK',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: greenColor,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: greenColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(51),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ubah Foto Profile',
                        style: greyTextStyle.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Personal Information Section
                _buildSectionCard('Informasi Pribadi', Icons.person_rounded, [
                  _buildTextFormField(
                    controller: _nameController,
                    label: 'Nama Lengkap',
                    hint: 'Masukkan nama lengkap',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'Masukkan email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    enabled: false, // Email usually can't be changed
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _phoneController,
                    label: 'Nomor Telepon',
                    hint: 'Masukkan nomor telepon',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _addressController,
                    label: 'Alamat',
                    hint: 'Masukkan alamat lengkap',
                    icon: Icons.location_on_outlined,
                    maxLines: 3,
                  ),
                ]),

                const SizedBox(height: 20),

                // Work Information Section
                _buildSectionCard(
                  'Informasi Pekerjaan',
                  Icons.work_outline_rounded,
                  [
                    _buildTextFormField(
                      controller: _employeeIdController,
                      label: 'Employee ID',
                      hint: 'Employee ID',
                      icon: Icons.badge_outlined,
                      enabled: false, // Employee ID usually can't be changed
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _vehicleTypeController,
                      label: 'Jenis Kendaraan',
                      hint: 'Masukkan jenis kendaraan',
                      icon: Icons.local_shipping_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _vehiclePlateController,
                      label: 'Nomor Plat',
                      hint: 'Masukkan nomor plat kendaraan',
                      icon: Icons.confirmation_number_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _workAreaController,
                      label: 'Area Kerja',
                      hint: 'Masukkan area kerja',
                      icon: Icons.location_city_outlined,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [greenColor, greenColor.withAlpha(204)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: greenColor.withAlpha(77),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isLoading ? null : _saveProfile,
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: _isLoading
                              ? const Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.save_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Simpan Perubahan',
                                      style: whiteTextStyle.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: greenColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: greenColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: blackTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool enabled = true,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: blackTextStyle.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
          maxLines: maxLines,
          style: blackTextStyle.copyWith(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: greyTextStyle.copyWith(fontSize: 14),
            prefixIcon: Icon(
              icon,
              color: enabled ? greenColor : greyColor,
              size: 20,
            ),
            filled: true,
            fillColor: enabled
                ? const Color(0xFFF8FAFC)
                : const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: greenColor, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: (value) {
            if (enabled && (value == null || value.isEmpty)) {
              return '$label tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiServiceManager();

      // Prepare update data based on role
      final updateData = <String, dynamic>{
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
      };

      // Add mitra-specific fields if role is mitra
      if (widget.userData['role'] == 'mitra') {
        updateData['vehicle_type'] = _vehicleTypeController.text.trim();
        updateData['vehicle_plate'] = _vehiclePlateController.text.trim();
        updateData['work_area'] = _workAreaController.text.trim();
      }

      // Call update profile API
      await apiService.updateProfile(
        name: updateData['name'],
        phone: updateData['phone'],
        address: updateData['address'],
        vehicleType: widget.userData['role'] == 'mitra'
            ? updateData['vehicle_type']
            : null,
        vehiclePlate: widget.userData['role'] == 'mitra'
            ? updateData['vehicle_plate']
            : null,
        workArea: widget.userData['role'] == 'mitra'
            ? updateData['work_area']
            : null,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Profile berhasil diperbarui',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: greenColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      // Go back to profile page with refresh signal
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}

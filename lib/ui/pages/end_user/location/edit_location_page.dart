import 'package:bank_sha/blocs/blocs.dart';
import 'package:bank_sha/models/address_model.dart';
import 'package:bank_sha/models/subscription_model.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/pages/end_user/subscription/subscription_plans_page.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';
import 'package:bank_sha/ui/widgets/shared/map_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

class EditLocationPage extends StatefulWidget {
  final AddressModel address;
  final SubscriptionPlan? initialPlan;
  final String? initialSubscriptionId;

  const EditLocationPage({
    super.key,
    required this.address,
    this.initialPlan,
    this.initialSubscriptionId,
  });

  @override
  State<EditLocationPage> createState() => _EditLocationPageState();
}

class _EditLocationPageState extends State<EditLocationPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _addressController;
  late bool _isDefault;
  double? _latitude;
  double? _longitude;
  String? _mapAddress;
  bool _isSubmitting = false;
  SubscriptionPlan? _selectedPlan;
  String? _originalPlanId; // tracks the plan at page open to detect changes
  String? _existingSubscriptionId; // ID of the current subscription for PATCH

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.address.label);
    _addressController = TextEditingController(
      text: widget.address.addressText ?? widget.address.address,
    );
    _isDefault = widget.address.isDefault;

    // Pre-populate immediately from passed plan (no loading flash)
    _selectedPlan = widget.initialPlan;
    _originalPlanId = widget.initialPlan?.id;
    _existingSubscriptionId = widget.initialSubscriptionId;

    final lat = double.tryParse(widget.address.latitude ?? '');
    final lng = double.tryParse(widget.address.longitude ?? '');
    if (lat != null && lng != null) {
      _latitude = lat;
      _longitude = lng;
      _mapAddress = widget.address.address;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _openSubscriptionPicker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubscriptionPlansPage(
          onPlanSelected: (plan) {
            setState(() => _selectedPlan = plan);
          },
        ),
      ),
    );
  }

  void _openMapPicker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerPage(
          initialLocation: _latitude != null && _longitude != null
              ? LatLng(_latitude!, _longitude!)
              : null,
          onLocationSelected: (address, lat, lng) {
            setState(() {
              _mapAddress = address;
              _latitude = lat;
              _longitude = lng;
            });
          },
        ),
      ),
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pilih lokasi pada peta terlebih dahulu'),
          backgroundColor: orangeColor,
        ),
      );
      return;
    }

    context.read<AddressBloc>().add(
      UpdateAddress(
        addressId: widget.address.id,
        label: _labelController.text.trim(),
        address: _mapAddress ?? widget.address.address,
        addressText: _addressController.text.trim(),
        latitude: _latitude.toString(),
        longitude: _longitude.toString(),
        isDefault: _isDefault,
        // Only send subscriptionPlanId if the user actually changed it
        subscriptionPlanId:
            _selectedPlan?.id != _originalPlanId ? _selectedPlan?.id : null,
        // Pass existing subscription ID so bloc can PATCH instead of POST
        existingSubscriptionId:
            _selectedPlan?.id != _originalPlanId ? _existingSubscriptionId : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddressBloc, AddressState>(
      listener: (context, state) {
        if (state.status == AddressStatus.operating) {
          setState(() => _isSubmitting = true);
        } else {
          setState(() => _isSubmitting = false);
        }

        if (state.status == AddressStatus.operationSuccess) {
          Navigator.pop(context);
        }

        if (state.status == AddressStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: redcolor,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: uicolor,
        appBar: const CustomAppNotif(
          title: 'Edit Alamat',
          showBackButton: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header illustration
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: greenColor.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit_location_alt_rounded,
                        size: 40,
                        color: greenColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Ubah detail alamat',
                      style: greyTextStyle.copyWith(
                        fontSize: 14,
                        fontWeight: regular,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Label Alamat
                  _buildInputField(
                    label: 'Label Alamat',
                    hint: 'Contoh: Rumah, Kantor, Toko...',
                    controller: _labelController,
                    icon: Icons.label_outline_rounded,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Label alamat tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Nama Alamat
                  _buildInputField(
                    label: 'Nama Alamat',
                    hint: 'Masukkan alamat lengkap...',
                    controller: _addressController,
                    icon: Icons.location_on_outlined,
                    maxLines: 1,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama alamat tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Map Picker Section
                  Text(
                    'Lokasi di Peta',
                    style: blackTextStyle.copyWith(
                      fontSize: 14,
                      fontWeight: semiBold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _openMapPicker,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _latitude != null
                              ? greenColor.withAlpha(127)
                              : greyColor.withAlpha(77),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: blackColor.withAlpha(10),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _latitude != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: greenColor.withAlpha(25),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.where_to_vote_rounded,
                                        color: greenColor,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Lokasi dipilih',
                                            style: greenTextStyle.copyWith(
                                              fontSize: 13,
                                              fontWeight: semiBold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _mapAddress ?? '',
                                            style: greyTextStyle.copyWith(
                                              fontSize: 12,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.edit_location_alt_outlined,
                                      color: greyColor,
                                      size: 20,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: lightBackgroundColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.gps_fixed_rounded,
                                        size: 14,
                                        color: greyColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                                        style: greyTextStyle.copyWith(
                                          fontSize: 11,
                                          fontWeight: medium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: lightBackgroundColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.map_outlined,
                                    color: greyColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pilih Lokasi di Peta',
                                        style: blackTextStyle.copyWith(
                                          fontSize: 14,
                                          fontWeight: medium,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Tap untuk membuka peta',
                                        style: greyTextStyle.copyWith(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: greyColor,
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Subscription Picker Section
                  Text(
                    'Paket Langganan',
                    style: blackTextStyle.copyWith(
                      fontSize: 14,
                      fontWeight: semiBold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _openSubscriptionPicker,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _selectedPlan != null
                              ? greenColor.withAlpha(127)
                              : greyColor.withAlpha(77),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: blackColor.withAlpha(10),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _selectedPlan == null
                          ? Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: lightBackgroundColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.card_membership_rounded,
                                    color: greyColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.address.subscriptionPlan != null
                                            ? widget.address.subscriptionPlan!
                                            : 'Pilih Paket Langganan',
                                        style: blackTextStyle.copyWith(
                                          fontSize: 14,
                                          fontWeight: medium,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        widget.address.subscriptionPlan != null
                                            ? 'Tap untuk mengganti paket'
                                            : 'Tap untuk memilih paket',
                                        style: greyTextStyle.copyWith(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: greyColor,
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: greenColor.withAlpha(25),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.card_membership_rounded,
                                    color: greenColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedPlan!.name,
                                        style: blackTextStyle.copyWith(
                                          fontSize: 14,
                                          fontWeight: semiBold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${_selectedPlan!.formattedPrice} / ${_selectedPlan!.durationText}',
                                        style: greenTextStyle.copyWith(
                                          fontSize: 12,
                                          fontWeight: medium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedPlan = null),
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: greyColor,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(
                    color: greyColor.withAlpha(77),
                    thickness: 1,
                    height: 1,
                  ),
                  const SizedBox(height: 20),

                  // Toggle Default Address
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: greyColor.withAlpha(51)),
                      boxShadow: [
                        BoxShadow(
                          color: blackColor.withAlpha(10),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _isDefault
                                ? greenColor.withAlpha(25)
                                : lightBackgroundColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _isDefault
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: _isDefault ? greenColor : greyColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Jadikan Alamat Utama',
                                style: blackTextStyle.copyWith(
                                  fontSize: 14,
                                  fontWeight: medium,
                                ),
                              ),
                              Text(
                                'Alamat ini akan digunakan sebagai default',
                                style: greyTextStyle.copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: _isDefault,
                          onChanged: (val) => setState(() => _isDefault = val),
                          activeThumbColor: greenColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: greenColor,
                        foregroundColor: whiteColor,
                        disabledBackgroundColor: greenColor.withAlpha(127),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: whiteColor,
                              ),
                            )
                          : Text(
                              'Simpan Perubahan',
                              style: whiteTextStyle.copyWith(
                                fontSize: 16,
                                fontWeight: semiBold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: blackTextStyle.copyWith(fontSize: 14, fontWeight: semiBold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: blackTextStyle.copyWith(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: greyTextStyle.copyWith(fontSize: 13),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(icon, color: greyColor, size: 20),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            filled: true,
            fillColor: whiteColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: greyColor.withAlpha(51)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: greenColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: redcolor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: redcolor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

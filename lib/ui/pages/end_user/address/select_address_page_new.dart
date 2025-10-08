import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:bank_sha/services/end_user_api_service.dart';
import 'package:bank_sha/ui/widgets/skeleton/skeleton_items.dart';
import 'add_address_page.dart';

class SelectAddressPage extends StatefulWidget {
  const SelectAddressPage({super.key});

  @override
  State<SelectAddressPage> createState() => _SelectAddressPageState();
}

class _SelectAddressPageState extends State<SelectAddressPage> {
  int selectedIndex = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _addresses = [];
  late EndUserApiService _apiService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _apiService = EndUserApiService();
    await _apiService.initialize();
    await _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    try {
      final addresses = await _apiService.getUserAddresses();

      if (mounted) {
        setState(() {
          _addresses = addresses;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading addresses: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _setDefaultAddress(int addressId) async {
    final success = await _apiService.setDefaultAddress(addressId);
    if (success) {
      await _loadAddresses(); // Refresh the list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Alamat berhasil dijadikan utama',
              style: whiteTextStyle.copyWith(fontWeight: medium),
            ),
            backgroundColor: greenColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteAddress(int addressId) async {
    final success = await _apiService.deleteAddress(addressId);
    if (success) {
      await _loadAddresses(); // Refresh the list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Alamat berhasil dihapus',
              style: whiteTextStyle.copyWith(fontWeight: medium),
            ),
            backgroundColor: greenColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: uicolor,
      appBar: CustomAppBar(
        title: 'Pilih Alamat',
        rightImageAsset: 'assets/ic_plus.png',
        onRightImagePressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddAddressPage()),
          );
          if (result == true) {
            await _loadAddresses(); // Refresh addresses if new address was added
          }
        },
      ),
      body: _isLoading
          ? _buildSkeletonLoading()
          : _addresses.isEmpty
          ? _buildEmptyState()
          : _buildAddressList(),
      bottomNavigationBar: _isLoading || _addresses.isEmpty
          ? null
          : _buildBottomNavBar(),
    );
  }

  Widget _buildSkeletonLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: List.generate(
          3,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonItems.circle(size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonItems.text(height: 16, width: 100),
                        const SizedBox(height: 8),
                        SkeletonItems.text(height: 12, width: 200),
                        const SizedBox(height: 8),
                        SkeletonItems.text(height: 14, width: double.infinity),
                        const SizedBox(height: 4),
                        SkeletonItems.text(height: 14, width: 250),
                      ],
                    ),
                  ),
                  SkeletonItems.circle(size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Belum ada alamat tersimpan',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambah alamat baru untuk melanjutkan',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _addresses.length,
            itemBuilder: (context, index) {
              final address = _addresses[index];
              final isSelected = selectedIndex == index;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? greenColor : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Radio Button
                        Container(
                          margin: const EdgeInsets.only(top: 2, right: 12),
                          child: Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: isSelected ? greenColor : greyColor,
                            size: 20,
                          ),
                        ),

                        // Address Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Address Title and Default Badge
                              Row(
                                children: [
                                  Text(
                                    address['label'] ?? 'Alamat',
                                    style: blackTextStyle.copyWith(
                                      fontWeight: semiBold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (address['is_default'] == 1 ||
                                      address['is_default'] == true) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: greenColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Utama',
                                        style: whiteTextStyle.copyWith(
                                          fontSize: 10,
                                          fontWeight: medium,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                              const SizedBox(height: 4),

                              // Name and Phone
                              Text(
                                '${address['recipient_name'] ?? ''} | ${address['phone'] ?? ''}',
                                style: greyTextStyle.copyWith(
                                  fontSize: 12,
                                  fontWeight: medium,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Address
                              Text(
                                _formatFullAddress(address),
                                style: blackTextStyle.copyWith(
                                  fontSize: 14,
                                  fontWeight: regular,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // More Options
                        InkWell(
                          onTap: () {
                            _showAddressOptions(context, address);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.more_vert,
                              color: greyColor,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatFullAddress(Map<String, dynamic> address) {
    final parts = <String>[];

    if (address['street'] != null && address['street'].toString().isNotEmpty) {
      parts.add(address['street']);
    }

    if (address['rt'] != null &&
        address['rt'].toString().isNotEmpty &&
        address['rw'] != null &&
        address['rw'].toString().isNotEmpty) {
      parts.add('RT ${address['rt']}/RW ${address['rw']}');
    }

    if (address['village'] != null &&
        address['village'].toString().isNotEmpty) {
      parts.add('Kelurahan ${address['village']}');
    }

    if (address['district'] != null &&
        address['district'].toString().isNotEmpty) {
      parts.add('Kecamatan ${address['district']}');
    }

    if (address['city'] != null && address['city'].toString().isNotEmpty) {
      parts.add(address['city']);
    }

    if (address['province'] != null &&
        address['province'].toString().isNotEmpty) {
      parts.add(address['province']);
    }

    if (address['postal_code'] != null &&
        address['postal_code'].toString().isNotEmpty) {
      parts.add(address['postal_code']);
    }

    return parts.join('\n');
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: CustomFilledButton(
          title: 'Pilih Alamat',
          onPressed: () {
            // Handle pilih alamat
            final selectedAddress = _addresses[selectedIndex];

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Alamat "${selectedAddress['label'] ?? 'Alamat'}" berhasil dipilih',
                  style: whiteTextStyle.copyWith(fontWeight: medium),
                ),
                backgroundColor: greenColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );

            // Return to previous page with selected address
            Navigator.pop(context, selectedAddress);
          },
        ),
      ),
    );
  }

  void _showAddressOptions(BuildContext context, Map<String, dynamic> address) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: greyColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Options
            ListTile(
              leading: Icon(Icons.edit, color: blackColor),
              title: Text(
                'Edit Alamat',
                style: blackTextStyle.copyWith(fontWeight: medium),
              ),
              onTap: () {
                Navigator.pop(context);
                // Navigate to edit address page
                // TODO: Implement edit address functionality
              },
            ),
            if (address['is_default'] != 1 && address['is_default'] != true)
              ListTile(
                leading: Icon(Icons.star, color: greenColor),
                title: Text(
                  'Jadikan Utama',
                  style: blackTextStyle.copyWith(fontWeight: medium),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _setDefaultAddress(address['id']);
                },
              ),
            ListTile(
              leading: Icon(Icons.delete, color: redcolor),
              title: Text(
                'Hapus Alamat',
                style: blackTextStyle.copyWith(fontWeight: medium),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, address);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Map<String, dynamic> address,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Hapus Alamat',
          style: blackTextStyle.copyWith(fontWeight: semiBold, fontSize: 18),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus alamat "${address['label'] ?? 'Alamat'}"?',
          style: blackTextStyle.copyWith(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: greyTextStyle.copyWith(fontWeight: medium),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAddress(address['id']);
            },
            child: Text(
              'Hapus',
              style: TextStyle(color: redcolor, fontWeight: medium),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'add_address_page.dart';

class SelectAddressPage extends StatefulWidget {
  const SelectAddressPage({super.key});

  @override
  State<SelectAddressPage> createState() => _SelectAddressPageState();
}

class _SelectAddressPageState extends State<SelectAddressPage> {
  int selectedIndex = 0;

  // Data alamat dummy - hanya rumah
  final List<Map<String, dynamic>> addresses = [
    {
      'id': 1,
      'title': 'Rumah',
      'name': 'John Doe',
      'phone': '+62 812-3456-7890',
      'address':
          'Jl. Merdeka No. 123, RT 01/RW 02\nKelurahan Kemerdekaan, Kecamatan Central\nJakarta Pusat, DKI Jakarta 10110',
      'isDefault': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: uicolor,
      appBar: CustomAppBar(
        title: 'Tambah Jadwal',
        rightImageAsset: 'assets/ic_plus.png',
        onRightImagePressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddAddressPage()),
          );
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Address List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
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
                                      address['title'],
                                      style: blackTextStyle.copyWith(
                                        fontWeight: semiBold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (address['isDefault']) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: greenColor,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
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
                                  '${address['name']} | ${address['phone']}',
                                  style: greyTextStyle.copyWith(
                                    fontSize: 12,
                                    fontWeight: medium,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Address
                                Text(
                                  address['address'],
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
      ),
      bottomNavigationBar: Container(
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
            title: 'Tambah Jadwal',
            onPressed: () {
              // Handle pilih alamat
              final selectedAddress = addresses[selectedIndex];

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Alamat "${selectedAddress['title']}" berhasil dipilih',
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
              },
            ),
            ListTile(
              leading: Icon(Icons.star, color: greenColor),
              title: Text(
                'Jadikan Utama',
                style: blackTextStyle.copyWith(fontWeight: medium),
              ),
              onTap: () {
                Navigator.pop(context);
                // Set as default address
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
          'Apakah Anda yakin ingin menghapus alamat "${address['title']}"?',
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
              // Handle delete address
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

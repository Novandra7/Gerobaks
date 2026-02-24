import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';
import 'package:flutter/material.dart';

class MyLocationPage extends StatefulWidget {
  const MyLocationPage({super.key});

  @override
  State<MyLocationPage> createState() => _MyLocationPageState();
}

class _MyLocationPageState extends State<MyLocationPage> {
  // Index alamat yang menjadi utama
  int _utamaIndex = 0;

  final List<Map<String, dynamic>> _locations = [
    {
      'label': 'Rumah',
      'address': 'Jl. Sudirman No. 10, Kel. Kebon Jeruk',
      'city': 'Jakarta Barat, 11530',
      'icon': Icons.home,
      'subscriptionPlan': 'Premium',
      'subscriptionStatus': 'Aktif',
    },
    {
      'label': 'Kantor',
      'address': 'Jl. Thamrin No. 5, Kel. Gondangdia',
      'city': 'Jakarta Pusat, 10350',
      'icon': Icons.business,
      'subscriptionPlan': 'Basic',
      'subscriptionStatus': 'Kadaluarsa',
    },
    {
      'label': 'Gudang',
      'address': 'Jl. Raya Bekasi No. 88, Kel. Cakung',
      'city': 'Jakarta Timur, 13910',
      'icon': Icons.warehouse,
      'subscriptionPlan': '-',
      'subscriptionStatus': 'Tidak Aktif',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: uicolor,
      appBar: const CustomAppNotif(title: 'Alamat Saya', showBackButton: true),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          itemCount: _locations.length,
          itemBuilder: (context, index) =>
              _buildLocationCard(index, _locations[index]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/wilayah');
        },
        foregroundColor: yellowColor,
        backgroundColor: Color(0xFF4CAF50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Image.asset('assets/ic_map_pin_add_line.png', width: 24),
      ),
    );
  }

  Widget _buildLocationCard(int index, Map<String, dynamic> loc) {
    final bool isUtama = index == _utamaIndex;
    final String subscriptionStatus = loc['subscriptionStatus'] as String;
    final String subscriptionPlan = loc['subscriptionPlan'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUtama ? greenColor : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: blackColor.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: icon + label + alamat
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: greenColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        loc['icon'] as IconData,
                        color: greenColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc['label'] as String,
                            style: blackTextStyle.copyWith(
                              fontSize: 18,
                              fontWeight: bold,
                            ),
                          ),
                          Text(
                            loc['address'] as String,
                            style: greyTextStyle.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Kota
                Row(
                  children: [
                    Icon(Icons.location_city, color: greenColor, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      loc['city'] as String,
                      style: greyTextStyle.copyWith(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Badge subscription
                Row(
                  children: [
                    _buildSubscriptionBadge(
                      subscriptionPlan,
                      subscriptionStatus,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Tombol Hapus & Gunakan
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () =>
                              _showDeleteConfirmation(context, index),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: redcolor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Hapus',
                            style: blackTextStyle.copyWith(
                              fontSize: 13,
                              fontWeight: semiBold,
                              color: redcolor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: isUtama
                              ? null
                              : () {
                                  setState(() => _utamaIndex = index);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isUtama
                                ? greenColor
                                : Colors.grey[600],
                            disabledBackgroundColor: greenColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isUtama ? 'Alamat Utama' : 'Gunakan',
                            style: whiteTextStyle.copyWith(
                              fontSize: 13,
                              fontWeight: semiBold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Badge UTAMA di pojok kanan atas
          if (isUtama)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: greenColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Text(
                  'UTAMA',
                  style: whiteTextStyle.copyWith(
                    fontSize: 10,
                    fontWeight: bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int index) {
    final loc = _locations[index];
    final bool isUtama = index == _utamaIndex;
    final String subscriptionStatus = loc['subscriptionStatus'] as String;
    final bool hasActiveSubscription = subscriptionStatus == 'Aktif';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: redcolor, size: 24),
            const SizedBox(width: 8),
            Text(
              'Hapus Alamat',
              style: blackTextStyle.copyWith(fontSize: 16, fontWeight: bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah kamu yakin ingin menghapus alamat "${loc['label']}"?',
              style: blackTextStyle.copyWith(fontSize: 13),
            ),
            if (hasActiveSubscription) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: redcolor.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: redcolor.withAlpha(80)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: redcolor, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Alamat ini memiliki langganan aktif. Menghapus alamat akan membatalkan langganan terkait.',
                        style: blackTextStyle.copyWith(
                          fontSize: 11,
                          color: redcolor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (isUtama) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withAlpha(80)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ini adalah alamat utama kamu.',
                        style: blackTextStyle.copyWith(
                          fontSize: 11,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: blackTextStyle.copyWith(
                fontSize: 13,
                fontWeight: semiBold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _locations.removeAt(index);
                if (_utamaIndex >= _locations.length) {
                  _utamaIndex = _locations.isEmpty ? 0 : _locations.length - 1;
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: redcolor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Hapus',
              style: whiteTextStyle.copyWith(
                fontSize: 13,
                fontWeight: semiBold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionBadge(String plan, String status) {
    final Color statusColor;
    final IconData statusIcon;

    switch (status) {
      case 'Aktif':
        statusColor = greenColor;
        statusIcon = Icons.check_circle;
        break;
      case 'Kadaluarsa':
        statusColor = redcolor;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.remove_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: statusColor),
          const SizedBox(width: 5),
          Text(
            plan != '-' ? '$plan · $status' : 'Belum Berlangganan',
            style: blackTextStyle.copyWith(
              fontSize: 11,
              fontWeight: semiBold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

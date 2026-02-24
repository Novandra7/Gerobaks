import 'package:bank_sha/blocs/blocs.dart';
import 'package:bank_sha/models/address_model.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class MyLocationPage extends StatefulWidget {
  const MyLocationPage({super.key});

  @override
  State<MyLocationPage> createState() => _MyLocationPageState();
}

class _MyLocationPageState extends State<MyLocationPage> {
  @override
  void initState() {
    super.initState();
    context.read<AddressBloc>().add(const FetchAddresses());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: uicolor,
      appBar: const CustomAppNotif(title: 'Alamat Saya', showBackButton: true),
      body: SafeArea(
        child: BlocConsumer<AddressBloc, AddressState>(
          listener: (context, state) {
            if (state.status == AddressStatus.error &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: redcolor,
                ),
              );
            }
            if (state.status == AddressStatus.operationSuccess &&
                state.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.successMessage!),
                  backgroundColor: greenColor,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == AddressStatus.loading) {
              return _buildSkeletonList();
            }

            if (state.status == AddressStatus.error &&
                state.addresses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: redcolor, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage ?? 'Gagal memuat alamat',
                      style: greyTextStyle.copyWith(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<AddressBloc>().add(
                        const FetchAddresses(),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: greenColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Coba Lagi',
                        style: whiteTextStyle.copyWith(fontWeight: semiBold),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state.addresses.isEmpty) {
              return Center(
                child: Text(
                  'Belum ada alamat tersimpan.',
                  style: greyTextStyle.copyWith(fontSize: 14),
                ),
              );
            }

            final isOperating = state.status == AddressStatus.operating;

            return Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  itemCount: state.addresses.length,
                  itemBuilder: (context, index) =>
                      _buildLocationCard(state.addresses[index]),
                ),
                if (isOperating)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black26,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/wilayah');
        },
        foregroundColor: yellowColor,
        backgroundColor: const Color(0xFF4CAF50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Image.asset('assets/ic_map_pin_add_line.png', width: 24),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      itemCount: 3,
      itemBuilder: (_, __) => _buildSkeletonCard(),
    );
  }

  Widget _buildSkeletonCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Badge
            Container(
              height: 26,
              width: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 20),
            // Buttons row
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForLabel(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('rumah')) return Icons.home;
    if (lower.contains('kantor')) return Icons.business;
    if (lower.contains('gudang')) return Icons.warehouse;
    return Icons.location_on;
  }

  Widget _buildLocationCard(AddressModel loc) {
    final bool isUtama = loc.isDefault;
    final String plan = loc.subscriptionPlan ?? '-';
    final String status = loc.subscriptionStatus ?? '';

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
                        _iconForLabel(loc.label),
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
                            loc.label,
                            style: blackTextStyle.copyWith(
                              fontSize: 18,
                              fontWeight: bold,
                            ),
                          ),
                          Text(
                            loc.address,
                            style: greyTextStyle.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Badge subscription
                _buildSubscriptionBadge(plan, status),
                const SizedBox(height: 20),

                // Tombol Hapus & Gunakan
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () =>
                              _showDeleteConfirmation(context, loc),
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
                              : () => context.read<AddressBloc>().add(
                                  SetDefaultAddress(loc.id),
                                ),
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

  void _showDeleteConfirmation(BuildContext context, AddressModel loc) {
    final bool hasActiveSubscription =
        (loc.subscriptionStatus ?? '').toLowerCase() == 'active' ||
        loc.subscriptionStatus == 'Aktif';

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
              'Apakah kamu yakin ingin menghapus alamat "${loc.label}"?',
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
            if (loc.isDefault) ...[
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
              context.read<AddressBloc>().add(DeleteAddress(loc.id));
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

    switch (status.toLowerCase()) {
      case 'active':
      case 'aktif':
        statusColor = greenColor;
        statusIcon = Icons.check_circle;
        break;
      case 'expired':
      case 'kadaluarsa':
        statusColor = redcolor;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.remove_circle_outline;
    }

    final bool hasPlan = plan != '-' && plan.isNotEmpty;
    final String displayStatus = _localizeStatus(status);

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
            hasPlan ? '$plan · $displayStatus' : 'Belum Berlangganan',
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

  String _localizeStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Aktif';
      case 'expired':
        return 'Kadaluarsa';
      case 'inactive':
        return 'Tidak Aktif';
      default:
        return status;
    }
  }
}

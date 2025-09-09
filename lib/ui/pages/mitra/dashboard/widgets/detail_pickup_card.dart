import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/utils/responsive_helper.dart';

class DetailPickupCard extends StatelessWidget {
  final String customerName;
  final String phoneNumber;
  final String address;
  final String pickupTime;
  final String wasteType;
  final String estimatedWeight;
  final String status;
  final Color statusColor;
  final VoidCallback? onTap;

  const DetailPickupCard({
    Key? key,
    required this.customerName,
    required this.phoneNumber,
    required this.address,
    required this.pickupTime,
    required this.wasteType,
    required this.estimatedWeight,
    required this.status,
    this.statusColor = const Color(0xFFFFB74D),
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = ResponsiveHelper.isSmallScreen(context);
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getResponsiveSpacing(context, 20),
        vertical: ResponsiveHelper.getResponsiveSpacing(context, 8),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getResponsiveSpacing(context, 14), // Padding lebih kecil
                    vertical: ResponsiveHelper.getResponsiveSpacing(context, 10), // Padding lebih kecil
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded( // Tambahkan expanded untuk mencegah overflow
                        child: Text(
                          'Detail Pengambilan',
                          style: blackTextStyle.copyWith(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, isSmallScreen ? 15 : 16), // Ukuran font lebih kecil
                            fontWeight: semiBold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.getResponsiveSpacing(context, 10), // Padding lebih kecil
                          vertical: ResponsiveHelper.getResponsiveSpacing(context, 4), // Padding lebih kecil
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 12)),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 11), // Ukuran font lebih kecil
                            fontWeight: medium,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Detail items
                Padding(
                  padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 16)),
                  child: Column(
                    children: [
                      // Pelanggan
                      _buildDetailItem(
                        context,
                        icon: Icons.person_outline,
                        label: 'Pelanggan',
                        value: customerName,
                        iconColor: Colors.green,
                      ),
                      
                      // Telepon
                      _buildDetailItem(
                        context,
                        icon: Icons.phone_outlined,
                        label: 'Telepon',
                        value: phoneNumber,
                        iconColor: Colors.green,
                      ),
                      
                      // Alamat
                      _buildDetailItem(
                        context,
                        icon: Icons.location_on_outlined,
                        label: 'Alamat',
                        value: address,
                        iconColor: Colors.green,
                        maxLines: 3, // Tambahkan baris untuk alamat panjang
                      ),
                      
                      // Waktu Pengambilan
                      _buildDetailItem(
                        context,
                        icon: Icons.access_time_outlined,
                        label: 'Waktu Pengambilan',
                        value: pickupTime,
                        iconColor: Colors.green,
                      ),
                      
                      // Jenis Sampah
                      _buildDetailItem(
                        context,
                        icon: Icons.delete_outline,
                        label: 'Jenis Sampah',
                        value: wasteType,
                        iconColor: Colors.green,
                      ),
                      
                      // Perkiraan Berat
                      _buildDetailItem(
                        context,
                        icon: Icons.scale_outlined,
                        label: 'Perkiraan Berat',
                        value: estimatedWeight,
                        iconColor: Colors.green,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                
                // Bottom warning stripes
                Container(
                  height: ResponsiveHelper.getResponsiveHeight(context, 12),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/img_warning_stripes.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    int maxLines = 1,
    bool isLast = false,
  }) {
    final bool isSmallScreen = ResponsiveHelper.isSmallScreen(context);
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 0 : ResponsiveHelper.getResponsiveSpacing(context, 8), // Kurangi spacing lebih lanjut
      ),
      child: Row(
        crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            width: ResponsiveHelper.getResponsiveWidth(context, 26), // Ukuran ikon lebih kecil
            height: ResponsiveHelper.getResponsiveHeight(context, 26), // Ukuran ikon lebih kecil
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor,
                size: ResponsiveHelper.getResponsiveIconSize(context, 13), // Ukuran ikon lebih kecil
              ),
            ),
          ),
          SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 6)), // Kurangi spacing
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: greyTextStyle.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 10), // Ukuran font lebih kecil
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 1)), // Minimal spacing
                Text(
                  value,
                  style: blackTextStyle.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, isSmallScreen ? 12 : 13), // Ukuran font lebih kecil
                    fontWeight: medium,
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/utils/responsive_helper.dart';

class NavigationDemoPage extends StatelessWidget {
  const NavigationDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Demo Navigasi Baru',
          style: blackTextStyle.copyWith(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
            fontWeight: semiBold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, const Color(0xFFF6FBF7)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration
              Container(
                width: ResponsiveHelper.getResponsiveWidth(context, 240),
                height: ResponsiveHelper.getResponsiveHeight(context, 240),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.map,
                    size: ResponsiveHelper.getResponsiveIconSize(context, 120),
                    color: greenColor,
                  ),
                ),
              ),

              SizedBox(
                height: ResponsiveHelper.getResponsiveSpacing(context, 40),
              ),

              Text(
                'Navigasi Pengambilan Sampah',
                style: blackTextStyle.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 24),
                  fontWeight: semiBold,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(
                height: ResponsiveHelper.getResponsiveSpacing(context, 16),
              ),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsiveSpacing(
                    context,
                    24,
                  ),
                ),
                child: Text(
                  'Navigasi ke lokasi pelanggan dengan tampilan yang responsif dan informatif',
                  style: greyTextStyle.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      16,
                    ),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(
                height: ResponsiveHelper.getResponsiveSpacing(context, 48),
              ),

              // Launch Button
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsiveSpacing(
                    context,
                    24,
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: ResponsiveHelper.getResponsiveHeight(context, 56),
                  child: ElevatedButton(
                    onPressed: () {
                      // Sample data to pass to the navigation page
                      final Map<String, dynamic> demoScheduleData = {
                        'customer_name': 'Wahyu Indra',
                        'customer_address':
                            'JL. Muso Salim B, Kota Samarinda, Kalimantan Timur',
                        'time_slot': '09:00 - 11:00',
                        'waste_type': 'Organik',
                        'waste_weight': '2 Kg',
                        'lat': -0.4917,
                        'lng': 117.1422,
                        'phone': '+6281234567890',
                        'distance': 3.2,
                        'duration': 15,
                        'elevation': 10,
                      };

                      // Navigate to the improved navigation page
                      Navigator.pushNamed(
                        context,
                        '/navigation-improved',
                        arguments: demoScheduleData,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: greenColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getResponsiveRadius(context, 16),
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Coba Navigasi Baru',
                      style: whiteTextStyle.copyWith(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          18,
                        ),
                        fontWeight: semiBold,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: ResponsiveHelper.getResponsiveSpacing(context, 16),
              ),

              // Info text
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsiveSpacing(
                    context,
                    24,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Fitur Utama:',
                      style: blackTextStyle.copyWith(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          16,
                        ),
                        fontWeight: semiBold,
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveHelper.getResponsiveSpacing(context, 8),
                    ),
                    _buildFeatureItem(
                      context,
                      'Tarik kartu untuk melihat lebih banyak informasi',
                    ),
                    _buildFeatureItem(
                      context,
                      'Tekan ikon telepon untuk menghubungi pelanggan',
                    ),
                    _buildFeatureItem(
                      context,
                      'Tampilan responsif untuk semua ukuran layar',
                    ),
                    _buildFeatureItem(
                      context,
                      'Petunjuk rute visual ke lokasi pelanggan',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: ResponsiveHelper.getResponsiveSpacing(context, 8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: greenColor,
            size: ResponsiveHelper.getResponsiveIconSize(context, 18),
          ),
          SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 8)),
          Expanded(
            child: Text(
              text,
              style: greentextstyle2.copyWith(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                fontWeight: medium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

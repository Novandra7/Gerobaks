import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:bank_sha/utils/toast_helper.dart';
import 'package:bank_sha/ui/widgets/shared/dialog_helper.dart';
import 'package:flutter/material.dart';

class SignUpBatch5Page extends StatefulWidget {
  const SignUpBatch5Page({super.key});

  @override
  State<SignUpBatch5Page> createState() => _SignUpBatch5PageState();
}

class _SignUpBatch5PageState extends State<SignUpBatch5Page> {
  String _selectedPlan = 'monthly';
  
  final List<Map<String, dynamic>> _subscriptionPlans = [
    {
      'id': 'monthly',
      'title': 'Paket Bulanan',
      'price': 'Rp 99.000',
      'period': '/bulan',
      'originalPrice': 'Rp 149.000',
      'discount': '34% OFF',
      'features': [
        'Gratis ongkir unlimited',
        'Cashback hingga 10%',
        'Priority customer service',
        'Akses produk eksklusif',
      ],
      'popular': false,
    },
    {
      'id': 'yearly',
      'title': 'Paket Tahunan',
      'price': 'Rp 999.000',
      'period': '/tahun',
      'originalPrice': 'Rp 1.788.000',
      'discount': '44% OFF',
      'features': [
        'Semua benefit paket bulanan',
        'Gratis ongkir ke seluruh Indonesia',
        'Cashback hingga 15%',
        'Customer service 24/7',
        'Akses early bird produk baru',
        'Gratis 2 bulan subscription',
      ],
      'popular': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // Logo Section
                  // const SizedBox(height: 60),

                  // Back Button
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: blackColor,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),

                  // Logo GEROBAKS
                  Container(
                    width: 200,
                    height: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    child: Image.asset(
                      'assets/img_gerobakss.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.shopping_cart,
                              color: greenColor,
                              size: 32,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'GEROBAKS',
                              style: greeTextStyle.copyWith(
                                fontSize: 28,
                                fontWeight: bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Title
                  Text(
                    'Pilih Paket Langganan',
                    style: blackTextStyle.copyWith(
                      fontSize: 24,
                      fontWeight: bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Langkah 5 dari 5 - Selesaikan Pendaftaran',
                    style: greyTextStyle.copyWith(
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Dapatkan keuntungan maksimal dengan berlangganan GEROBAKS Premium',
                    textAlign: TextAlign.center,
                    style: greyTextStyle.copyWith(
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Progress Indicator (All completed)
                  Row(
                    children: List.generate(5, (index) {
                      return [
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: greenColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        if (index < 4) const SizedBox(width: 8),
                      ];
                    }).expand((element) => element).toList(),
                  ),

                  const SizedBox(height: 30),

                  // Subscription Plans
                  ...List.generate(_subscriptionPlans.length, (index) {
                    final plan = _subscriptionPlans[index];
                    final isSelected = _selectedPlan == plan['id'];
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedPlan = plan['id'];
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? greenColor : greyColor.withOpacity(0.3),
                              width: isSelected ? 2 : 1,
                            ),
                            color: isSelected ? greenColor.withOpacity(0.05) : whiteColor,
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Plan Header
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                plan['title'],
                                                style: blackTextStyle.copyWith(
                                                  fontSize: 18,
                                                  fontWeight: bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Text(
                                                    plan['price'],
                                                    style: greeTextStyle.copyWith(
                                                      fontSize: 24,
                                                      fontWeight: bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    plan['period'],
                                                    style: greyTextStyle.copyWith(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Text(
                                                    plan['originalPrice'],
                                                    style: greyTextStyle.copyWith(
                                                      fontSize: 12,
                                                      decoration: TextDecoration.lineThrough,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: redcolor,
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      plan['discount'],
                                                      style: whiteTextStyle.copyWith(
                                                        fontSize: 10,
                                                        fontWeight: bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Radio<String>(
                                          value: plan['id'],
                                          groupValue: _selectedPlan,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedPlan = value!;
                                            });
                                          },
                                          activeColor: greenColor,
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16),

                                    // Features
                                    ...List.generate(plan['features'].length, (featureIndex) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: greenColor,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                plan['features'][featureIndex],
                                                style: blackTextStyle.copyWith(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),

                              // Popular Badge
                              if (plan['popular'])
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
                                        topRight: Radius.circular(12),
                                        bottomLeft: Radius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'PALING POPULER',
                                      style: whiteTextStyle.copyWith(
                                        fontSize: 10,
                                        fontWeight: bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // Benefits Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          greenColor.withOpacity(0.1),
                          greenColor.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: greenColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.celebration,
                          color: greenColor,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Penawaran Terbatas!',
                          style: greeTextStyle.copyWith(
                            fontSize: 16,
                            fontWeight: bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dapatkan diskon hingga 44% untuk pengguna baru!\nBerlaku hingga akhir bulan ini.',
                          textAlign: TextAlign.center,
                          style: greyTextStyle.copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  const SizedBox(height: 30),

                  // Action Buttons
                  CustomFilledButton(
                    title: 'Langganan Sekarang',
                    onPressed: () {
                      // Show alpha version message
                      ToastHelper.showToast(
                        context: context,
                        message: 'Fitur langganan sedang dalam versi alpha dan belum tersedia.',
                        isSuccess: false,
                        duration: const Duration(seconds: 3),
                      );
                      
                      // Show dialog explaining alpha version using custom dialog
                      DialogHelper.showInfoDialog(
                        context: context,
                        title: 'Versi Alpha',
                        message: 'Fitur langganan masih dalam tahap pengembangan (versi alpha) dan belum tersedia saat ini. Anda dapat melanjutkan pendaftaran tanpa berlangganan.',
                        buttonText: 'Daftar Tanpa Langganan',
                        icon: Icons.info_outline,
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          _completeRegistration(); // Complete registration
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Skip Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                        // Show confirmation dialog using custom dialog
                        DialogHelper.showConfirmDialog(
                          context: context,
                          title: 'Yakin ingin melewati?',
                          message: 'Anda akan kehilangan kesempatan mendapatkan diskon spesial ini. Anda bisa berlangganan kapan saja di halaman profil.',
                          confirmText: 'Ya, Lewati',
                          cancelText: 'Batal',
                          icon: Icons.help_outline,
                        ).then((confirmed) {
                          if (confirmed) {
                            // Complete registration and go to home
                            _completeRegistration();
                          }
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: whiteColor,
                        foregroundColor: greyColor,
                        side: BorderSide(color: greyColor.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Nanti Saja Deh',
                        style: greyTextStyle.copyWith(
                          fontSize: 16,
                          fontWeight: semiBold,
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
      ),
    );
  }

  void _completeRegistration() async {
    try {
      // Get user data from arguments
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (args == null || !args.containsKey('email') || !args.containsKey('password')) {
        throw Exception('Data registrasi tidak lengkap');
      }

      // Navigate to sign-up success page with credentials
      Navigator.pushNamed(
        context,
        '/sign-up-success',
        arguments: {
          'fullName': args['fullName'],
          'email': args['email'],
          'password': args['password'],
          'phone': args['phone'],
        },
      );
    } catch (e) {
      // Show error dialog using custom dialog
      DialogHelper.showErrorDialog(
        context: context,
        title: 'Error',
        message: 'Terjadi kesalahan saat melanjutkan registrasi: ${e.toString()}',
      );
    }
  }
}
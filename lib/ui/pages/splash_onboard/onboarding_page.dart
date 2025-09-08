import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  final PageController _pageController = PageController();
  late final AnimationController _animationController;
  
  // Data untuk onboarding pages
  List<Map<String, dynamic>> onboardingData = [
    {
      'title': 'Pembersihan\nRamah Lingkungan',
      'subtitle': 'Bersihkan ruang Anda dengan\nmudah dan ramah lingkungan.',
      'image': 'assets/img_onboard1fix.png',
      'color': Color(0xFF8CD6A7), // Warna latar yang sedikit lebih terang
      'height': 420.0,
      'width': 350.0,
    },
    {
      'title': 'Lingkungan Lebih\nBaik',
      'subtitle': 'Buat lingkungan lebih segar bersama\ntim pembersih hijau kami',
      'image': 'assets/img_onboard2.png',
      'color': Color(0xFFA3E4CB), // Warna latar berbeda
      'height': 350.0,
      'width': 280.0,
    },
    {
      'title': 'Mulai Bersama',
      'subtitle': 'Bersih itu bijak, pilih yang eco-\nfriendly untuk masa depan lebih baik',
      'image': 'assets/img_onboard3.png',
      'color': Color(0xFFB1EDD8), // Warna latar untuk slide ketiga
      'height': 300.0,
      'width': 260.0,
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Scaffold(
      backgroundColor: uicolor,
      body: Stack(
        children: [
          // Background dengan warna dinamis berdasarkan slide
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  onboardingData[currentIndex]['color'].withOpacity(0.2),
                  uicolor,
                ],
              ),
            ),
          ),
          
          // Konten utama
          SafeArea(
            child: Column(
              children: [
                
                // Carousel untuk gambar
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: onboardingData.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentIndex = index;
                        _animationController.reset();
                        _animationController.forward();
                      });
                    },
                    itemBuilder: (context, index) {
                      return FadeTransition(
                        opacity: _animationController,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.2, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeOut,
                          )),
                          child: Center(
                            child: Image.asset(
                              onboardingData[index]['image'],
                              height: isTablet ? onboardingData[index]['height'] * 1.2 : onboardingData[index]['height'],
                              width: isTablet ? onboardingData[index]['width'] * 1.2 : onboardingData[index]['width'],
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Content box
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: isTablet ? 40 : 24,
                    vertical: isTablet ? 32 : 20,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 32 : 22, 
                    vertical: isTablet ? 32 : 24,
                  ),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Judul dengan animasi
                      FadeTransition(
                        opacity: _animationController,
                        child: Text(
                          onboardingData[currentIndex]['title'],
                          style: blackTextStyle.copyWith(
                            fontSize: isTablet ? 24 : 20,
                            fontWeight: semiBold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      SizedBox(height: isTablet ? 32 : 26),
                      
                      // Subtitle dengan animasi
                      FadeTransition(
                        opacity: _animationController,
                        child: Text(
                          onboardingData[currentIndex]['subtitle'],
                          style: greyTextStyle.copyWith(
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: regular,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      SizedBox(height: isTablet ? 36 : 30),
                      
                      // Dots indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          onboardingData.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: currentIndex == index ? 24 : 10,
                            height: 10,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: currentIndex == index
                                  ? greenColor
                                  : greyColor.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: isTablet ? 30 : 24),
                      
                      // Tombol navigasi dengan kondisi berbeda untuk slide terakhir
                      currentIndex == 2
                          ? Column(
                              children: [
                                // Tombol Mulai dengan Hero Animation
                                Hero(
                                  tag: 'next-button',
                                  child: CustomFilledButton(
                                    title: 'Mulai Sekarang',
                                    height: isTablet ? 56 : 50,
                                    onPressed: () {
                                      // Animasi fade out sebelum navigasi
                                      _animationController.reverse().then((_) {
                                        Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          '/sign-up',
                                          (route) => false,
                                        );
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(height: isTablet ? 24 : 20),
                                // Tombol Sign In
                                CustomTextButton(
                                  title: 'Sudah punya akun? Sign In',
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/sign-in');
                                  },
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                // Skip button untuk langsung ke slide terakhir
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      currentIndex = 2;
                                      _animationController.reset();
                                      _animationController.forward();
                                    });
                                    // Pindah ke halaman terakhir
                                    _pageController.animateToPage(
                                      2,
                                      duration: Duration(milliseconds: 500),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Text(
                                    'Skip',
                                    style: greyTextStyle.copyWith(
                                      fontSize: isTablet ? 16 : 14,
                                      fontWeight: medium,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                // Button Lanjut dengan animasi
                                Hero(
                                  tag: 'next-button',
                                  child: CustomFilledButton(
                                    title: 'Lanjut',
                                    width: isTablet ? 180 : 150,
                                    height: isTablet ? 50 : 45,
                                    onPressed: () {
                                      if (currentIndex < onboardingData.length - 1) {
                                        setState(() {
                                          currentIndex++;
                                          _animationController.reset();
                                          _animationController.forward();
                                        });
                                        _pageController.animateToPage(
                                          currentIndex,
                                          duration: Duration(milliseconds: 500),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

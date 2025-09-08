import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';
import 'package:bank_sha/ui/pages/end_user/address/select_address_page.dart';
import 'package:flutter/material.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarHome(),
      backgroundColor: uicolor,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          buildInfoCard(),
          buildQuickPicks(context),
          buildAboutUs(context),
        ],
      ),
    );
  }

  Widget buildInfoCard() {
    final PageController pageController = PageController(
      initialPage: 1000,
      viewportFraction: 0.85,
    );

    final List<Map<String, dynamic>> cardData = [
      {
        'image': 'assets/img_truksampah.png',
        'text': 'Jumlah Yang Membuat Jadwal Pengambilan Hari Ini ada ',
        'count': '17',
      },
      {
        'image': 'assets/img_truksampah.png',
        'text': 'Tempat Sampah Yang Telah\nDiambil Hari Ini ada ',
        'count': '17',
      },
      {
        'image': 'assets/img_card3.png',
        'text': 'Jumlah Yang Membuat Jadwal Pengambilan Hari Ini ada ',
        'count': '25',
      },
    ];

    return Container(
      margin: const EdgeInsets.only(top: 20),
      height: 200,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: PageView.builder(
          controller: pageController,
          itemBuilder: (context, index) {
            final data = cardData[index % cardData.length];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(data['image']!, fit: BoxFit.cover),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text.rich(
                          TextSpan(
                            style: blackTextStyle.copyWith(
                              fontSize: 18,
                              fontWeight: semiBold,
                              color: Colors.green,
                            ),
                            children: [
                              TextSpan(text: data['text']),
                              TextSpan(
                                text: data['count'],
                                style: blackTextStyle.copyWith(
                                  fontSize: 18,
                                  fontWeight: semiBold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildQuickPicks(BuildContext context) {
    List<Map<String, dynamic>> quickItems = [
      {
        'icon': Icons.note_add_outlined,
        'title': 'Jadwal Baru',
        'subtitle': 'Buat Jadwal Pengamb..',
        'route': '/tambah-jadwal',
      },
      {
        'icon': Icons.location_on_outlined,
        'title': 'Tracking Truk',
        'subtitle': 'Tracking truk sekitar',
        'route': '/tracking_full',
      },
      {
        'icon': Icons.assignment_outlined,
        'title': 'Keluhan',
        'subtitle': 'Keluhan Yang Kamu B..',
        'route': '/buatKeluhan',
      },
      {
        'icon': Icons.redeem,
        'title': 'Reward',
        'subtitle': 'Kumpulan Reward',
        'route': '/reward',
      },
    ];

    return Container(
      margin: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Advanced Point Balance Card - Made clickable and interactive
          InkWell(
            onTap: () {
              // Navigate to reward page when card is tapped
              Navigator.pushNamed(context, '/reward');
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: greenui,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: greenColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Upper part with points balance
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Left side with icon and title
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: whiteColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(
                                'assets/ic_stars.png',
                                width: 24,
                                height: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Point Balance',
                                  style: greentextstyle2.copyWith(
                                    fontSize: 14,
                                    fontWeight: medium,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '0 pts',
                                  style: greentextstyle2.copyWith(
                                    fontSize: 24,
                                    fontWeight: extraBold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Right side with action button
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: greenColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Tukarkan',
                                style: whiteTextStyle.copyWith(
                                  fontSize: 12,
                                  fontWeight: semiBold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: whiteColor,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Divider
                  Divider(
                    color: greenColor.withOpacity(0.2),
                    height: 1,
                  ),
                  // Bottom part with info text
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: greentext,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Kumpulkan poin dengan jadwal rutin',
                          style: greentextstyle2.copyWith(
                            fontSize: 12,
                            fontWeight: regular,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Coming Soon Section - Rearranged with image on top and text below
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: greenui, // Light green background as in design
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: greenColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // Top image section
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: SizedBox(
                    height: 170, // Increased height for better image display
                    width: double.infinity,
                    child: Image.asset(
                      'assets/img_pesut.jpeg',
                      fit: BoxFit.fill, // Fill mode to cover entire space
                    ),
                  ),
                ),
                // Text section below the image
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, Samarinda',
                        style: blackTextStyle.copyWith(
                          fontSize: 24,
                          fontWeight: bold,
                          color: Colors.green[800], // Darker green for title
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kami akan segera hadir di Kota Samarinda, Stay Tuned!',
                        style: blackTextStyle.copyWith(
                          fontSize: 14,
                          fontWeight: medium,
                          color: Colors.green[700],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Header for Menu Pilihan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pilihan',
                style: blackTextStyle.copyWith(fontSize: 16, fontWeight: semiBold),
              ),
              TextButton(
                onPressed: () {
                  // Can be implemented later to show all options
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Lihat Semua',
                  style: greentextstyle2.copyWith(
                    fontSize: 12,
                    fontWeight: medium,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // More Compact Menu Grid with just icons and names
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(quickItems.length, (index) {
              final item = quickItems[index];
              return InkWell(
                onTap: () {
                  // Handle special navigation for "Jadwal Baru"
                  if (item['title'] == 'Jadwal Baru') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SelectAddressPage(),
                      ),
                    );
                  } else {
                    Navigator.pushNamed(context, item['route']);
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: (MediaQuery.of(context).size.width - 48 - 24) / 4, // 4 items per row, minus padding
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon with circle background
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: greenColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            item['icon'],
                            color: greenColor,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Simple title text
                      Text(
                        item['title'],
                        style: blackTextStyle.copyWith(
                          fontSize: 12,
                          fontWeight: medium,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget buildAboutUs(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with title and see all button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tentang Kami',
                style: blackTextStyle.copyWith(fontWeight: semiBold, fontSize: 16),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/about-us');
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Selengkapnya',
                  style: greentextstyle2.copyWith(
                    fontSize: 12,
                    fontWeight: medium,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Improved about us card with better visuals
          Container(
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                children: [
                  // Top image banner with overlay text
                  Stack(
                    children: [
                      // Background image
                      Image.asset(
                        'assets/img_gerobaks_trust.png',
                        width: double.infinity,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                      // Gradient overlay
                      Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.1),
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      // Logo and title
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: whiteColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(
                                'assets/img_logo.png',
                                width: 40,
                                height: 40,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bersih Itu Sehat!',
                                    style: whiteTextStyle.copyWith(
                                      fontWeight: bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    'Platform layanan angkut sampah terpercaya',
                                    style: whiteTextStyle.copyWith(
                                      fontSize: 12,
                                      fontWeight: regular,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Content section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Description with icon
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: greenColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.emoji_nature, 
                                size: 20, 
                                color: greenColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Kami berkomitmen menciptakan lingkungan yang bersih melalui pengelolaan sampah yang modern, praktis, dan berkelanjutan.',
                                style: blackTextStyle.copyWith(
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Action button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/about-us');
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: whiteColor,
                              backgroundColor: greenColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Pelajari Lebih Lanjut',
                              style: whiteTextStyle.copyWith(
                                fontWeight: semiBold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

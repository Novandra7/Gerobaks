import 'package:bank_sha/ui/pages/end_user/wilayah/wilayah_full_screen.dart';
import 'package:bank_sha/ui/widgets/shared/chat_icon_with_badge.dart';
import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';

class CustomAppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? imageAssetPath;
  final IconData? iconData;
  final VoidCallback? onActionPressed;

  const CustomAppHeader({
    super.key,
    required this.title,
    this.imageAssetPath,
    this.iconData,
    this.onActionPressed,
  });

  @override
  /*************  ✨ Windsurf Command ⭐  *************/
  /// Builds the custom app header widget.
  ///
  /// This widget returns an [AppBar] with a title and an optional trailing widget.
  /// The trailing widget can be either an [Icon] or an [Image] based on the
  /// specified [iconData] or [imageAssetPath], respectively. The trailing widget
  /// is wrapped in a [GestureDetector] that triggers [onActionPressed] when tapped.
  ///
  /// The [AppBar] has a transparent background, no elevation, and does not
  /// automatically imply a leading widget. It is also wrapped in a [SafeArea]
  /// to ensure proper padding.
  /// *****  690d5f1c-594f-405a-a26b-64bc4536a92f  ******
  Widget build(BuildContext context) {
    Widget? trailingWidget;

    if (iconData != null) {
      trailingWidget = Icon(iconData, color: blackColor, size: 24);
    } else if (imageAssetPath != null) {
      trailingWidget = Image.asset(imageAssetPath!, width: 32, height: 32);
    }

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: uicolor,
      elevation: 0,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 5, 24, 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: blackTextStyle.copyWith(
                  fontWeight: semiBold,
                  fontSize: 20,
                ),
              ),
              if (trailingWidget != null)
                GestureDetector(onTap: onActionPressed, child: trailingWidget),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}

/// Custom AppBar untuk halaman notifikasi dengan title di tengah dan tombol back
class CustomAppNotif extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;

  const CustomAppNotif({
    super.key,
    required this.title,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: uicolor,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 5, 24, 15),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Title di tengah
              Center(
                child: Text(
                  title,
                  style: blackTextStyle.copyWith(
                    fontWeight: semiBold,
                    fontSize: 20,
                  ),
                ),
              ),

              // Tombol back di kiri
              if (showBackButton)
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}

class CustomAppBarHome extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBarHome({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: uicolor,
      elevation: 0,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 5, 24, 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo image pengganti teks "Gerobakku"
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/img_gerobakss.png',
                    height: 24, // ubah sesuai kebutuhan
                  ),
                ],
              ),

              // Actions Row - Notification and Chat icons
              Row(
                children: [
                  // Chat icon with badge
                  ChatIconWithBadge(
                    onTap: () {
                      Navigator.pushNamed(context, '/chat');
                    },
                  ),
                  const SizedBox(width: 12),
                  // Notification icon
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/notif');
                    },
                    child: Stack(
                      children: [
                        Image.asset(
                          'assets/ic_notification.png',
                          width: 32,
                          height: 32,
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: redcolor,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '3',
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}

class CutomAppTracking extends StatelessWidget implements PreferredSizeWidget {
  const CutomAppTracking({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: uicolor,
      elevation: 0,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 5, 24, 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Greeting
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   'Hallo!',
                  //   style: greyTextStyle.copyWith(
                  //     fontWeight: regular,
                  //     fontSize: 16,
                  //   ),
                  // ),
                  Text(
                    'Lokasi',
                    style: blackTextStyle.copyWith(
                      fontWeight: semiBold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),

              // Notification icon
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 400),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const WilayahFullScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            final curved = CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOut,
                            );

                            return FadeTransition(
                              opacity: curved,
                              child: ScaleTransition(
                                scale: Tween<double>(
                                  begin: 0.95,
                                  end: 1.0,
                                ).animate(curved),
                                child: child,
                              ),
                            );
                          },
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/ic_full_screen.png',
                      width: 32,
                      height: 32,
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

  @override
  Size get preferredSize => const Size.fromHeight(50);
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final String? rightImageAsset; // ← Tambahkan path gambar
  final VoidCallback? onRightImagePressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.rightImageAsset,
    this.onRightImagePressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: uicolor,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 5, 24, 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tombol Back (kiri)
              if (showBackButton)
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.arrow_back, color: Colors.black),
                )
              else
                const SizedBox(width: 24),

              // Title (tengah)
              Expanded(
                child: Center(
                  child: Text(
                    title,
                    style: blackTextStyle.copyWith(
                      fontWeight: semiBold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),

              // Gambar kanan (opsional)
              if (rightImageAsset != null)
                GestureDetector(
                  onTap: onRightImagePressed,
                  child: Image.asset(rightImageAsset!, height: 24, width: 24),
                )
              else
                const SizedBox(width: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}

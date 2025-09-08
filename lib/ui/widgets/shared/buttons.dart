import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';

class CustomFilledButton extends StatelessWidget {
  final String title;
  final double? width;
  final double? height;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool showIcon;
  final IconData? icon;

  const CustomFilledButton({
    super.key,
    required this.title,
    this.width = double.infinity,
    this.height = 50,
    this.onPressed,
    this.isLoading = false,
    this.showIcon = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoading ? greenColor.withOpacity(0.7) : greenColor,
          foregroundColor: whiteColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isLoading 
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: whiteColor,
                strokeWidth: 2,
              ),
            )
          : showIcon && icon != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: whiteColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: whiteTextStyle.copyWith(fontSize: 16, fontWeight: semiBold),
                    ),
                  ],
                )
              : Text(
                  title,
                  style: whiteTextStyle.copyWith(fontSize: 16, fontWeight: semiBold),
            ),
      ),
    );
  }
}

class CustomTextButton extends StatelessWidget {
  final String title;
  final double? width;
  final double? height;
  final VoidCallback? onPressed;

  const CustomTextButton({
    super.key,
    required this.title,
    this.width,
    this.height,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
        child: Text(title, style: greyTextStyle.copyWith(fontSize: 16)),
      ),
    );
  }
}

// Widget baru untuk Google Sign In Button dari Sign In Page
class CustomGoogleSignInButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;

  const CustomGoogleSignInButton({
    super.key,
    this.title = 'Log in dengan Google',
    this.onPressed,
    this.width = double.infinity,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: whiteColor,
          foregroundColor: blackColor,
          side: BorderSide(color: greyColor.withOpacity(0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image(
              image: const AssetImage(
                'assets/img_logo_google.png',
              ),
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: blackTextStyle.copyWith(
                fontSize: 16,
                fontWeight: medium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomGoogleButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final double? width;
  final String imagePath;

  const CustomGoogleButton({
    super.key,
    required this.title,
    this.onPressed,
    this.width,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(bottom: 15),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Colors.grey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 24, width: 24),
            const SizedBox(width: 5),
            Text(
              title,
              style: blackTextStyle.copyWith(fontSize: 16, fontWeight: medium),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomAppMenu extends StatelessWidget {
  final String iconURL;
  final String title;
  final Widget? page;
  final VoidCallback? onTap;

  const CustomAppMenu({
    super.key,
    required this.iconURL,
    required this.title,
    this.page,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page!),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Image.asset(iconURL, width: 30),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                title,
                style: blackTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: medium,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
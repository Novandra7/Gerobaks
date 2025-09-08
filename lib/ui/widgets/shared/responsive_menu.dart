import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';

class ResponsiveAppMenu extends StatelessWidget {
  final String iconURL;
  final String title;
  final Widget? page;
  final VoidCallback? onTap;
  final IconData? trailingIcon;
  final bool isHighlighted;

  const ResponsiveAppMenu({
    super.key,
    required this.iconURL,
    required this.title,
    this.page,
    this.onTap,
    this.trailingIcon = Icons.chevron_right,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return InkWell(
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
      borderRadius: BorderRadius.circular(12),
      splashColor: greenColor.withOpacity(0.1),
      highlightColor: greenColor.withOpacity(0.05),
      child: Ink(
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 18 : 16, // Padding vertikal lebih besar untuk tablet
          horizontal: isTablet ? 28 : 20, // Padding horizontal lebih besar untuk tablet
        ),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container with consistent size
            Container(
              width: isTablet ? 44 : 36,
              height: isTablet ? 44 : 36,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: greenColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                iconURL, 
                width: isTablet ? 28 : 24,
                height: isTablet ? 28 : 24,
                color: greenColor,
              ),
            ),
            SizedBox(width: isTablet ? 22 : 18),
            // Text expands to fill available space
            Expanded(
              child: Text(
                title,
                style: blackTextStyle.copyWith(
                  fontSize: isTablet ? 18 : 15,
                  fontWeight: medium,
                  color: blackColor,
                ),
              ),
            ),
            Icon(
              trailingIcon ?? Icons.chevron_right,
              color: Colors.grey,
              size: isTablet ? 26 : 22,
            ),
          ],
        ),
      ),
    );
  }
}

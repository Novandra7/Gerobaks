import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/utils/responsive_helper.dart';
import 'package:bank_sha/utils/golden_ratio_helper.dart';

class MinimalActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconBackgroundColor;
  final Color? iconColor;
  final bool hasNewContent;

  const MinimalActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconBackgroundColor,
    this.iconColor,
    this.hasNewContent = false,
  });

  @override
  Widget build(BuildContext context) {
    final double iconSize = ResponsiveHelper.getResponsiveIconSize(context, 20);
    final double baseSpacing = 6.0;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 12)),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 8)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 8)),
                  decoration: BoxDecoration(
                    color: iconBackgroundColor ?? greenui,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? greenColor,
                    size: iconSize,
                  ),
                ),
                if (hasNewContent)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: ResponsiveHelper.getResponsiveWidth(context, 8),
                      height: ResponsiveHelper.getResponsiveHeight(context, 8),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, baseSpacing)),
            Text(
              label,
              style: blackTextStyle.copyWith(
                fontSize: GoldenRatioHelper.goldenFontSize(context, level: -1, base: 12.0),
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
  }
}

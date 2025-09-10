import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/utils/responsive_helper.dart';
import 'package:bank_sha/utils/golden_ratio_helper.dart';

class GoldenProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final bool showDivider;
  final bool useGoldenRatio;

  const GoldenProfileSection({
    super.key,
    required this.title,
    required this.children,
    this.padding,
    this.showDivider = true,
    this.useGoldenRatio = true,
  });

  @override
  Widget build(BuildContext context) {
    // Base spacing that follows golden ratio
    final double baseSpacing = 16.0;
    final double titleSpacing = useGoldenRatio ? baseSpacing / GoldenRatioHelper.phi : baseSpacing / 2;
    final double contentPadding = useGoldenRatio ? baseSpacing * GoldenRatioHelper.phi : baseSpacing * 1.5;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getResponsiveSpacing(context, baseSpacing),
            vertical: ResponsiveHelper.getResponsiveSpacing(context, titleSpacing),
          ),
          child: Text(
            title,
            style: blackTextStyle.copyWith(
              fontSize: useGoldenRatio 
                  ? GoldenRatioHelper.goldenFontSize(context, level: 1, base: 14.0)
                  : ResponsiveHelper.getResponsiveFontSize(context, 16),
              fontWeight: semiBold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          margin: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getResponsiveSpacing(context, baseSpacing),
            vertical: ResponsiveHelper.getResponsiveSpacing(context, titleSpacing),
          ),
          padding: padding ?? EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, contentPadding)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildChildrenWithDividers(context),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildChildrenWithDividers(BuildContext context) {
    if (!showDivider || children.isEmpty) {
      return children;
    }

    final List<Widget> childrenWithDividers = [];
    final double dividerSpacing = GoldenRatioHelper.phi * 8;
    
    for (int i = 0; i < children.length; i++) {
      childrenWithDividers.add(children[i]);
      if (i < children.length - 1) {
        childrenWithDividers.add(
          Divider(
            color: lightBackgroundColor,
            thickness: 1,
            height: ResponsiveHelper.getResponsiveSpacing(context, dividerSpacing),
          ),
        );
      }
    }
    return childrenWithDividers;
  }
}

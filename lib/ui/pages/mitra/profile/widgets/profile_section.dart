import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/utils/responsive_helper.dart';

class ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final bool showDivider;

  const ProfileSection({
    super.key,
    required this.title,
    required this.children,
    this.padding,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getResponsiveSpacing(context, 16),
            vertical: ResponsiveHelper.getResponsiveSpacing(context, 8),
          ),
          child: Text(
            title,
            style: blackTextStyle.copyWith(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
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
            horizontal: ResponsiveHelper.getResponsiveSpacing(context, 16),
            vertical: ResponsiveHelper.getResponsiveSpacing(context, 8),
          ),
          padding: padding ?? EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 16)),
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
    for (int i = 0; i < children.length; i++) {
      childrenWithDividers.add(children[i]);
      if (i < children.length - 1) {
        childrenWithDividers.add(
          Divider(
            color: lightBackgroundColor,
            thickness: 1,
            height: ResponsiveHelper.getResponsiveSpacing(context, 24),
          ),
        );
      }
    }
    return childrenWithDividers;
  }
}

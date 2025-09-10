import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/utils/responsive_helper.dart';
import 'package:bank_sha/utils/golden_ratio_helper.dart';

class EnhancedProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? avatarUrl;
  final String? role;
  final String? id;
  final VoidCallback? onEditPressed;
  final bool useGoldenRatio;
  
  // Additional features
  final int notificationCount;
  final VoidCallback? onNotificationPressed;
  final String? statusText;
  final bool isVerified;

  const EnhancedProfileHeader({
    super.key,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.role,
    this.id,
    this.onEditPressed,
    this.useGoldenRatio = true,
    this.notificationCount = 0,
    this.onNotificationPressed,
    this.statusText,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    // Base spacing using golden ratio for better visual harmony
    final double baseSpacing = 20.0;
    final double verticalSpacing = useGoldenRatio ? baseSpacing / GoldenRatioHelper.phi : baseSpacing / 2;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [greenColor, const Color(0xFF0CAF60)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(ResponsiveHelper.getResponsiveRadius(context, 24)),
          bottomRight: Radius.circular(ResponsiveHelper.getResponsiveRadius(context, 24)),
        ),
        boxShadow: [
          BoxShadow(
            color: greenColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + ResponsiveHelper.getResponsiveSpacing(context, verticalSpacing),
        bottom: ResponsiveHelper.getResponsiveSpacing(context, baseSpacing),
        left: ResponsiveHelper.getResponsiveSpacing(context, baseSpacing),
        right: ResponsiveHelper.getResponsiveSpacing(context, baseSpacing),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              Image.asset(
                'assets/img_gerobakss.png', 
                height: ResponsiveHelper.getResponsiveHeight(context, 28),
                color: Colors.white,
              ),
              // Notification and edit buttons
              Row(
                children: [
                  if (onNotificationPressed != null) ...[
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          onPressed: onNotificationPressed,
                          icon: Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: ResponsiveHelper.getResponsiveIconSize(context, 24),
                          ),
                          tooltip: 'Notifikasi',
                        ),
                        if (notificationCount > 0)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveHelper.getResponsiveSpacing(context, 4),
                                vertical: ResponsiveHelper.getResponsiveSpacing(context, 2),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(
                                  ResponsiveHelper.getResponsiveRadius(context, 10)
                                ),
                              ),
                              child: Text(
                                notificationCount > 9 ? '9+' : notificationCount.toString(),
                                style: whiteTextStyle.copyWith(
                                  fontSize: GoldenRatioHelper.goldenFontSize(context, level: -2, base: 14.0),
                                  fontWeight: semiBold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 4)),
                  ],
                  if (onEditPressed != null)
                    IconButton(
                      onPressed: onEditPressed,
                      icon: Icon(
                        Icons.edit_outlined,
                        color: Colors.white,
                        size: ResponsiveHelper.getResponsiveIconSize(context, 24),
                      ),
                      tooltip: 'Edit Profil',
                    ),
                ],
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, verticalSpacing * 1.2)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture with verification badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildProfileAvatar(context),
                  if (isVerified)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 4)),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          Icons.verified_user,
                          color: Colors.white,
                          size: ResponsiveHelper.getResponsiveIconSize(context, 14),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, baseSpacing * 0.8)),
              // Profile Info with clean layout
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: whiteTextStyle.copyWith(
                              fontSize: GoldenRatioHelper.goldenFontSize(context, level: 1, base: 16.0),
                              fontWeight: extraBold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (statusText != null) ...[
                          Container(
                            margin: EdgeInsets.only(
                              left: ResponsiveHelper.getResponsiveSpacing(context, 8),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.getResponsiveSpacing(context, 8),
                              vertical: ResponsiveHelper.getResponsiveSpacing(context, 4),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(
                                ResponsiveHelper.getResponsiveRadius(context, 4)
                              ),
                            ),
                            child: Text(
                              statusText!,
                              style: whiteTextStyle.copyWith(
                                fontSize: GoldenRatioHelper.goldenFontSize(context, level: -1, base: 14.0),
                                fontWeight: semiBold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 4)),
                    Text(
                      email,
                      style: whiteTextStyle.copyWith(
                        fontSize: GoldenRatioHelper.goldenFontSize(context, level: 0, base: 14.0),
                        fontWeight: medium,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (id != null || role != null) ...[
                      SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 8)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.getResponsiveSpacing(context, 8),
                          vertical: ResponsiveHelper.getResponsiveSpacing(context, 4),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (role != null) ...[
                              Icon(
                                Icons.verified_rounded,
                                color: Colors.white,
                                size: ResponsiveHelper.getResponsiveIconSize(context, 14),
                              ),
                              SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 4)),
                              Text(
                                role!,
                                style: whiteTextStyle.copyWith(
                                  fontSize: GoldenRatioHelper.goldenFontSize(context, level: -1, base: 14.0),
                                  fontWeight: medium,
                                ),
                              ),
                              if (id != null)
                                SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 8)),
                            ],
                            if (id != null) ...[
                              Icon(
                                Icons.credit_card,
                                color: Colors.white,
                                size: ResponsiveHelper.getResponsiveIconSize(context, 14),
                              ),
                              SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 4)),
                              Text(
                                'ID: $id',
                                style: whiteTextStyle.copyWith(
                                  fontSize: GoldenRatioHelper.goldenFontSize(context, level: -1, base: 14.0),
                                  fontWeight: medium,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return Container(
        width: ResponsiveHelper.getResponsiveWidth(context, 64),
        height: ResponsiveHelper.getResponsiveHeight(context, 64),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          image: DecorationImage(
            image: NetworkImage(avatarUrl!),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      );
    } else {
      // Show initial if no avatar
      return Container(
        width: ResponsiveHelper.getResponsiveWidth(context, 64),
        height: ResponsiveHelper.getResponsiveHeight(context, 64),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'A',
            style: TextStyle(
              fontSize: GoldenRatioHelper.goldenFontSize(context, level: 1, base: 18.0),
              fontWeight: extraBold,
              color: greenColor,
            ),
          ),
        ),
      );
    }
  }
}

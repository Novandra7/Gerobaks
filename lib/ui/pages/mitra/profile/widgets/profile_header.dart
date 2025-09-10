import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/utils/responsive_helper.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? avatarUrl;
  final String? role;
  final String? id;
  final VoidCallback? onEditPressed;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.role,
    this.id,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
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
        top: MediaQuery.of(context).padding.top + ResponsiveHelper.getResponsiveSpacing(context, 16),
        bottom: ResponsiveHelper.getResponsiveSpacing(context, 24),
        left: ResponsiveHelper.getResponsiveSpacing(context, 20),
        right: ResponsiveHelper.getResponsiveSpacing(context, 20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/img_gerobakss.png', 
                height: ResponsiveHelper.getResponsiveHeight(context, 28),
                color: Colors.white,
              ),
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
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 20)),
          Row(
            children: [
              // Profile Picture
              _buildProfileAvatar(context),
              SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 16)),
              // Profile Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: whiteTextStyle.copyWith(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
                        fontWeight: extraBold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 4)),
                    Text(
                      email,
                      style: whiteTextStyle.copyWith(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                        fontWeight: medium,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (id != null) ...[
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
                                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                                  fontWeight: medium,
                                ),
                              ),
                              SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 8)),
                            ],
                            Icon(
                              Icons.credit_card,
                              color: Colors.white,
                              size: ResponsiveHelper.getResponsiveIconSize(context, 14),
                            ),
                            SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 4)),
                            Text(
                              'ID: $id',
                              style: whiteTextStyle.copyWith(
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                                fontWeight: medium,
                              ),
                            ),
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
        ),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'A',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 24),
              fontWeight: extraBold,
              color: greenColor,
            ),
          ),
        ),
      );
    }
  }
}

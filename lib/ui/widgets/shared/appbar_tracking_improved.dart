import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';

class CustomAppTrackingImproved extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData? iconData;
  final String? iconAsset;
  final VoidCallback? onActionPressed;
  final List<Widget>? actions;
  final bool showIconWithTitle;
  final String? titleIconAsset;

  const CustomAppTrackingImproved({
    super.key,
    this.title = 'Lokasi',
    this.iconData,
    this.iconAsset,
    this.onActionPressed,
    this.actions,
    this.showIconWithTitle = false,
    this.titleIconAsset,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> actionWidgets = [];
    
    // Add primary action if specified
    if ((iconData != null || iconAsset != null) && onActionPressed != null) {
      actionWidgets.add(
        GestureDetector(
          onTap: onActionPressed,
          child: iconData != null
              ? Icon(iconData, color: blackColor, size: 24)
              : Container(
                  padding: const EdgeInsets.all(4),
                  child: Image.asset(
                    iconAsset!,
                    width: 24,
                    height: 24,
                    color: greenColor, // Warna hijau untuk ikon
                    fit: BoxFit.contain,
                  ),
                ),
        ),
      );
    }
    
    // Add additional actions if any
    if (actions != null) {
      actionWidgets.addAll(actions!);
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
              // Title with optional icon
              Expanded(
                child: showIconWithTitle && titleIconAsset != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: blackTextStyle.copyWith(
                              fontWeight: semiBold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Image.asset(
                            titleIconAsset!,
                            width: 24,
                            height: 24,
                            color: greenColor, // Warna hijau untuk ikon
                          ),
                        ],
                      )
                    : Text(
                        title,
                        style: blackTextStyle.copyWith(
                          fontWeight: semiBold,
                          fontSize: 20,
                        ),
                      ),
              ),
              
              // Action buttons
              if (actionWidgets.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: actionWidgets.map((widget) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: widget,
                    );
                  }).toList(),
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

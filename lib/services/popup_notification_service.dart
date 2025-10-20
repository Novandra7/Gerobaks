import 'package:flutter/material.dart';
import 'package:bank_sha/services/waste_schedule_service.dart';
import 'package:bank_sha/shared/theme.dart';

class PopupNotificationService {
  static final PopupNotificationService _instance =
      PopupNotificationService._internal();
  factory PopupNotificationService() => _instance;
  PopupNotificationService._internal();

  static OverlayEntry? _currentOverlay;
  static bool _isShowing = false;
  static bool _hasShownTodayNotification = false;
  static String? _lastNotificationDate;

  /// Show notification popup from top of screen
  static void showWasteScheduleNotification(BuildContext context) {
    // Check if date has changed and reset flag if needed
    final currentDate = DateTime.now().toString().split(
      ' ',
    )[0]; // YYYY-MM-DD format
    if (_lastNotificationDate != currentDate) {
      _hasShownTodayNotification = false;
      _lastNotificationDate = currentDate;
    }

    if (_isShowing ||
        !WasteScheduleService.hasTodayPickup() ||
        _hasShownTodayNotification) {
      return;
    }

    final notification = WasteScheduleService.generateTodayNotification();
    if (notification.isEmpty) return;

    // Mark that we've shown today's notification
    _hasShownTodayNotification = true;

    _showNotificationPopup(
      context: context,
      title: notification['title'],
      message: notification['message'],
      icon: _getIconData(notification['icon']),
      color: greenColor,
      onTap: () => _handleNotificationTap(context, notification),
    );
  }

  /// Show custom notification popup
  static void showCustomNotification(
    BuildContext context, {
    required String title,
    required String message,
    IconData? icon,
    Color? color,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 4),
  }) {
    if (_isShowing) return;

    _showNotificationPopup(
      context: context,
      title: title,
      message: message,
      icon: icon ?? Icons.notifications,
      color: color ?? greenColor,
      onTap: onTap,
      duration: duration,
    );
  }

  static void _showNotificationPopup({
    required BuildContext context,
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 4),
  }) {
    if (_isShowing) return;

    _isShowing = true;
    final overlay = Overlay.of(context);

    _currentOverlay = OverlayEntry(
      builder: (context) => PopupNotificationWidget(
        title: title,
        message: message,
        icon: icon,
        color: color,
        onTap: onTap,
        onDismiss: _dismissNotification,
      ),
    );

    overlay.insert(_currentOverlay!);

    // Auto dismiss after duration
    Future.delayed(duration, () {
      _dismissNotification();
    });
  }

  static void _dismissNotification() {
    if (_currentOverlay != null && _isShowing) {
      _currentOverlay!.remove();
      _currentOverlay = null;
      _isShowing = false;
    }
  }

  static void _handleNotificationTap(
    BuildContext context,
    Map<String, dynamic> notification,
  ) {
    _dismissNotification();
    if (notification['isClickable'] == true && notification['route'] != null) {
      Navigator.pushNamed(context, notification['route']);
    }
  }

  /// Reset the notification flag (useful for new app sessions or testing)
  static void resetTodayNotificationFlag() {
    _hasShownTodayNotification = false;
    _lastNotificationDate = null;
  }

  /// Check if today's notification has been shown
  static bool get hasShownTodayNotification => _hasShownTodayNotification;

  /// Get the last notification date
  static String? get lastNotificationDate => _lastNotificationDate;

  static IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'eco':
        return Icons.eco;
      case 'recycling':
        return Icons.recycling;
      case 'warning':
        return Icons.warning;
      case 'delete':
        return Icons.delete_outline;
      case 'schedule':
        return Icons.schedule;
      default:
        return Icons.notifications;
    }
  }

  /// Force dismiss any active notification
  static void dismiss() {
    _dismissNotification();
  }
}

class PopupNotificationWidget extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;

  const PopupNotificationWidget({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    this.onTap,
    required this.onDismiss,
  });

  @override
  State<PopupNotificationWidget> createState() =>
      _PopupNotificationWidgetState();
}

class _PopupNotificationWidgetState extends State<PopupNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    _animationController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: widget.color.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: widget.color.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: widget.onTap,
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Icon
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: widget.color.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  widget.icon,
                                  color: widget.color,
                                  size: 24,
                                ),
                              ),

                              const SizedBox(width: 16),

                              // Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.title,
                                      style: blackTextStyle.copyWith(
                                        fontWeight: semiBold,
                                        fontSize: 15,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.message,
                                      style: greyTextStyle.copyWith(
                                        fontSize: 13,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Close button
                              GestureDetector(
                                onTap: _handleDismiss,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: greyColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: greyColor,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

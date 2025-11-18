import 'package:flutter/material.dart';

/// Pop-up notification untuk status change jadwal
/// Muncul di tengah layar dengan animasi
class ScheduleNotificationPopup {
  /// Show popup notification saat status berubah
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    required ScheduleNotificationPopupType type,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _ScheduleNotificationPopupDialog(
        title: title,
        message: message,
        subtitle: subtitle,
        type: type,
        onTap: onTap,
      ),
    );
  }
}

enum ScheduleNotificationPopupType {
  accepted, // Hijau - jadwal diterima
  onTheWay, // Biru - mitra on the way
  arrived, // Orange - mitra sudah tiba
  completed, // Hijau tua - selesai
}

class _ScheduleNotificationPopupDialog extends StatefulWidget {
  final String title;
  final String message;
  final String? subtitle;
  final ScheduleNotificationPopupType type;
  final VoidCallback? onTap;

  const _ScheduleNotificationPopupDialog({
    required this.title,
    required this.message,
    this.subtitle,
    required this.type,
    this.onTap,
  });

  @override
  State<_ScheduleNotificationPopupDialog> createState() =>
      _ScheduleNotificationPopupDialogState();
}

class _ScheduleNotificationPopupDialogState
    extends State<_ScheduleNotificationPopupDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    print('🎬 [PopupNotification] initState - Starting animation');

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
    print('▶️ [PopupNotification] Animation started');

    // Auto dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        print('⏱️ [PopupNotification] Auto-dismissing...');
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getColor() {
    switch (widget.type) {
      case ScheduleNotificationPopupType.accepted:
        return const Color(0xFF10B981); // Green
      case ScheduleNotificationPopupType.onTheWay:
        return const Color(0xFF3B82F6); // Blue
      case ScheduleNotificationPopupType.arrived:
        return const Color(0xFFF59E0B); // Orange
      case ScheduleNotificationPopupType.completed:
        return const Color(0xFF059669); // Dark Green
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case ScheduleNotificationPopupType.accepted:
        return Icons.check_circle_outline;
      case ScheduleNotificationPopupType.onTheWay:
        return Icons.local_shipping_outlined;
      case ScheduleNotificationPopupType.arrived:
        return Icons.location_on_outlined;
      case ScheduleNotificationPopupType.completed:
        return Icons.task_alt;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 [PopupNotification] build() called');

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AlertDialog(
          contentPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          content: GestureDetector(
            onTap: () {
              print('👆 [PopupNotification] Tapped, dismissing...');
              Navigator.of(context).pop();
              widget.onTap?.call();
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header dengan warna
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _getColor(),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIcon(),
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Title
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Message
                        Text(
                          widget.message,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF64748B),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        // Subtitle (jika ada)
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.subtitle!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Close button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              print('✅ [PopupNotification] Close button tapped');
                              Navigator.of(context).pop();
                              widget.onTap?.call();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getColor(),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'OK, Mengerti',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Auto dismiss info
                        Text(
                          'Akan tertutup otomatis dalam 5 detik',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Close icon (X)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

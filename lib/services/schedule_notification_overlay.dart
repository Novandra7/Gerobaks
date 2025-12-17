import 'package:flutter/material.dart';
import 'dart:async';

/// Alternative implementation using OverlayEntry
/// More reliable for showing notifications from background services
class ScheduleNotificationOverlay {
  static OverlayEntry? _currentOverlay;
  static Timer? _dismissTimer;

  /// Show notification using Overlay (more reliable than showDialog)
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    required ScheduleNotificationOverlayType type,
    String? subtitle,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 5),
  }) {
    print('');
    print('🚀 [ScheduleNotificationOverlay] show() called');
    print('   Title: $title');
    print('   Message: $message');
    print('   Type: $type');
    print('   Context: ${context.widget.runtimeType}');
    print('   Context mounted: ${context.mounted}');

    // Dismiss previous overlay if exists
    dismiss();

    if (!context.mounted) {
      print('⚠️ [ScheduleNotificationOverlay] Context not mounted');
      return;
    }

    // Get root overlay
    final overlay = Overlay.of(context, rootOverlay: true);
    print('✅ [ScheduleNotificationOverlay] Got overlay');

    // Create overlay entry
    _currentOverlay = OverlayEntry(
      builder: (context) {
        print('📦 [ScheduleNotificationOverlay] Building overlay widget');
        return _ScheduleNotificationOverlayWidget(
          title: title,
          message: message,
          subtitle: subtitle,
          type: type,
          onTap: () {
            onTap?.call();
            dismiss();
          },
          onDismiss: dismiss,
        );
      },
    );

    // Insert overlay
    overlay.insert(_currentOverlay!);
    print('✅ [ScheduleNotificationOverlay] Overlay inserted');

    // Auto dismiss
    _dismissTimer = Timer(duration, () {
      dismiss();
    });
  }

  /// Dismiss current overlay
  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;

    if (_currentOverlay != null) {
      _currentOverlay?.remove();
      _currentOverlay = null;
      print('🗑️ [ScheduleNotificationOverlay] Overlay dismissed');
    }
  }
}

enum ScheduleNotificationOverlayType {
  accepted, // Hijau - jadwal diterima
  onTheWay, // Biru - mitra on the way
  arrived, // Orange - mitra sudah tiba
  completed, // Hijau tua - selesai
}

class _ScheduleNotificationOverlayWidget extends StatefulWidget {
  final String title;
  final String message;
  final String? subtitle;
  final ScheduleNotificationOverlayType type;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _ScheduleNotificationOverlayWidget({
    required this.title,
    required this.message,
    this.subtitle,
    required this.type,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_ScheduleNotificationOverlayWidget> createState() =>
      __ScheduleNotificationOverlayWidgetState();
}

class __ScheduleNotificationOverlayWidgetState
    extends State<_ScheduleNotificationOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    print('🎬 [OverlayNotification] initState - Starting animation');

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
    print('▶️ [OverlayNotification] Animation started');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getColor() {
    switch (widget.type) {
      case ScheduleNotificationOverlayType.accepted:
        return const Color(0xFF10B981); // Green
      case ScheduleNotificationOverlayType.onTheWay:
        return const Color(0xFF3B82F6); // Blue
      case ScheduleNotificationOverlayType.arrived:
        return const Color(0xFFF59E0B); // Orange
      case ScheduleNotificationOverlayType.completed:
        return const Color(0xFF059669); // Dark Green
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case ScheduleNotificationOverlayType.accepted:
        return Icons.check_circle_outline;
      case ScheduleNotificationOverlayType.onTheWay:
        return Icons.local_shipping_outlined;
      case ScheduleNotificationOverlayType.arrived:
        return Icons.location_on_outlined;
      case ScheduleNotificationOverlayType.completed:
        return Icons.task_alt;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 [OverlayNotification] build() called');

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Background overlay with blur
          GestureDetector(
            onTap: widget.onDismiss,
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),

          // Centered dialog
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 24,
                  ),
                  child: GestureDetector(
                    onTap: widget.onTap,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400),
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
                                    onPressed: widget.onTap,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _getColor(),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

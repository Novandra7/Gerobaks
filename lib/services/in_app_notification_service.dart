import 'package:flutter/material.dart';

/// Service untuk menampilkan in-app notification banner
/// yang muncul dari atas layar dengan animasi slide
class InAppNotificationService {
  /// Menampilkan notification banner dari atas
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    InAppNotificationType type = InAppNotificationType.info,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
    String? subtitle,
  }) {
    try {
      print('🎨 [InAppNotificationService] show() called');
      print('   Title: $title');
      print('   Message: $message');
      print('   Type: $type');

      // Check if context is valid
      if (!context.mounted) {
        print('❌ [InAppNotificationService] Context is not mounted!');
        return;
      }

      print('✅ [InAppNotificationService] Getting overlay...');
      final overlay = Overlay.of(context);

      print('✅ [InAppNotificationService] Creating overlay entry...');
      late OverlayEntry overlayEntry;

      overlayEntry = OverlayEntry(
        builder: (context) {
          print('🏗️ [InAppNotificationService] Building banner widget...');
          return _InAppNotificationBanner(
            title: title,
            message: message,
            subtitle: subtitle,
            type: type,
            duration: duration,
            onTap: onTap ?? () => overlayEntry.remove(),
            onDismiss: () => overlayEntry.remove(),
          );
        },
      );

      overlay.insert(overlayEntry);
      print('✅ [InAppNotificationService] Overlay entry inserted!');
      print('🎉 [InAppNotificationService] Banner should be visible now!');
    } catch (e, stackTrace) {
      print('❌ [InAppNotificationService] ERROR: $e');
      print('Stack trace: $stackTrace');
    }
  }
}

enum InAppNotificationType {
  success, // Hijau - untuk jadwal diterima
  info, // Biru - untuk jadwal on the way
  warning, // Orange - untuk mitra sudah tiba
  completed, // Hijau tua - untuk pengambilan selesai
}

class _InAppNotificationBanner extends StatefulWidget {
  final String title;
  final String message;
  final String? subtitle;
  final InAppNotificationType type;
  final Duration duration;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _InAppNotificationBanner({
    required this.title,
    required this.message,
    this.subtitle,
    required this.type,
    required this.duration,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_InAppNotificationBanner> createState() =>
      _InAppNotificationBannerState();
}

class _InAppNotificationBannerState extends State<_InAppNotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    print('🎬 [Banner] initState - Starting animation');

    // Setup animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Slide dari atas ke bawah
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1), // Start from top (hidden above screen)
      end: Offset.zero, // End at normal position
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Fade in
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Start animation
    print('▶️ [Banner] Starting forward animation...');
    _controller.forward().then((_) {
      print('✅ [Banner] Animation completed!');
    });

    // Auto dismiss setelah duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        print('⏱️ [Banner] Duration expired, auto-dismissing...');
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case InAppNotificationType.success:
        return const Color(0xFF10B981); // Green-500
      case InAppNotificationType.info:
        return const Color(0xFF3B82F6); // Blue-500
      case InAppNotificationType.warning:
        return const Color(0xFFF59E0B); // Orange-500
      case InAppNotificationType.completed:
        return const Color(0xFF059669); // Green-600
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case InAppNotificationType.success:
        return Icons.check_circle;
      case InAppNotificationType.info:
        return Icons.info;
      case InAppNotificationType.warning:
        return Icons.warning_amber_rounded;
      case InAppNotificationType.completed:
        return Icons.task_alt;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 [Banner] build() called');

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    print('📐 [Banner] Screen width: $screenWidth, isTablet: $isTablet');

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: () {
              _dismiss();
              widget.onTap();
            },
            onVerticalDragEnd: (details) {
              // Swipe up to dismiss
              if (details.velocity.pixelsPerSecond.dy < -300) {
                _dismiss();
              }
            },
            child: SafeArea(
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: isTablet ? 32 : 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _getBackgroundColor(),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _dismiss();
                      widget.onTap();
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: EdgeInsets.all(isTablet ? 18 : 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getIcon(),
                              color: Colors.white,
                              size: isTablet ? 28 : 24,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isTablet ? 18 : 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.message,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.95),
                                    fontSize: isTablet ? 15 : 14,
                                  ),
                                ),
                                if (widget.subtitle != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.subtitle!,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: isTablet ? 14 : 13,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Close button
                          IconButton(
                            onPressed: _dismiss,
                            icon: const Icon(Icons.close, color: Colors.white),
                            iconSize: isTablet ? 22 : 20,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

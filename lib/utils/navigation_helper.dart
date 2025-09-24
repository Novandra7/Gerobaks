import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:bank_sha/ui/pages/mitra/pengambilan/navigation_page_redesigned.dart';

/// Fixes memory leaks and device restarts during navigation
/// by properly disposing of resources when navigation is closed.
class NavigationHelper {
  /// Keeps track of active MapController instances
  static final List<MapController> _controllers = [];

  /// Keeps track of active Timers
  static final List<Timer> _timers = [];

  /// Register a MapController to ensure it gets disposed properly
  static void registerController(MapController controller) {
    _controllers.add(controller);
  }

  /// Register a Timer to ensure it gets cancelled properly
  static void registerTimer(Timer timer) {
    _timers.add(timer);
  }

  /// Unregister a MapController when it's properly disposed
  static void unregisterController(MapController controller) {
    _controllers.remove(controller);
  }

  /// Unregister a Timer when it's properly cancelled
  static void unregisterTimer(Timer timer) {
    _timers.remove(timer);
  }

  /// Clean up all resources (call this when app is shutting down or when memory is low)
  static void cleanupResources() {
    // Cancel all timers
    for (var timer in _timers) {
      if (timer.isActive) {
        timer.cancel();
      }
    }
    _timers.clear();

    // Dispose all controllers
    for (var controller in _controllers) {
      try {
        controller.dispose();
      } catch (e) {
        // Ignore errors during cleanup
        print('Error disposing controller: $e');
      }
    }
    _controllers.clear();
  }
}

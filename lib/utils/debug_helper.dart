import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class DebugHelper {
  static void testDebugConsole() {
    // Using print statements
    print('Regular print statement test');

    // Using developer.log (more visible in debug console)
    developer.log('Developer log test', name: 'DEBUG_TEST');

    // Using debugPrint (throttles messages)
    debugPrint('Debug print test');
  }
}

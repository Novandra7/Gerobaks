import 'package:flutter/material.dart';

/// Global navigation service untuk handle navigasi dari anywhere
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  static GlobalKey<NavigatorState>? _navigatorKey;

  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  static GlobalKey<NavigatorState>? get navigatorKey => _navigatorKey;

  static BuildContext? get context => _navigatorKey?.currentContext;

  static Future<dynamic>? pushNamedAndRemoveUntil(
    String routeName, {
    bool Function(Route<dynamic>)? predicate,
  }) {
    if (_navigatorKey?.currentState == null) {
      print('❌ NavigationService: Navigator key is null');
      return null;
    }
    return _navigatorKey!.currentState!.pushNamedAndRemoveUntil(
      routeName,
      predicate ?? (route) => false,
    );
  }

  static void pop() {
    if (_navigatorKey?.currentState == null) {
      print('❌ NavigationService: Navigator key is null');
      return;
    }
    _navigatorKey!.currentState!.pop();
  }
}

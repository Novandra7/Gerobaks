import 'package:flutter/foundation.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

class TileProviderService {
  static TileProviderService? _instance;
  CachedTileProvider? _cachedTileProvider;

  // Private constructor
  TileProviderService._();

  // Factory constructor to return the singleton instance
  factory TileProviderService() {
    _instance ??= TileProviderService._();
    return _instance!;
  }

  // Initialize the cached tile provider
  Future<void> initialize() async {
    try {
      // Use memory cache for simplicity
      final store = MemCacheStore();

      _cachedTileProvider = CachedTileProvider(
        maxStale: const Duration(days: 30),
        store: store,
      );
      debugPrint('TileProviderService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing TileProviderService: $e');
      // Fallback to a non-cached provider if initialization fails
      _cachedTileProvider = null;
    }
  }

  // Get the cached tile provider, or null if not initialized
  CachedTileProvider? get cachedTileProvider => _cachedTileProvider;

  // Check if the service is initialized
  bool get isInitialized => _cachedTileProvider != null;
}

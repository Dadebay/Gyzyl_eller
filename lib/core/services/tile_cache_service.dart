import 'dart:developer' as dev;

import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// Tile cache service for flutter_map.
///
/// Call [TileCacheService.init] once on app start (in ApplicationInitialize).
/// Then use [TileCacheService.tileProvider] as the TileLayer's tileProvider.
///
/// Uses [CachedTileProvider] from flutter_map_cache, which combines request
/// cancellation (during pan/zoom) and disk caching in a single dio interceptor.
///
/// This fixes the "grey tiles until clear data" bug: when flutter_map cancels
/// an in-flight tile request, CachedTileProvider returns a transparent image
/// WITHOUT writing to cache, so cancelled tiles simply reload later.
class TileCacheService {
  static late final HiveCacheStore _store;
  static late final CachedTileProvider tileProvider;

  static Future<void> init() async {
    final dir = await getApplicationSupportDirectory();
    final cachePath = join(dir.path, 'map_tile_cache');

    _store = HiveCacheStore(cachePath, hiveBoxName: 'map_tile_cache');

    tileProvider = CachedTileProvider(
      store: _store,
      maxStale: const Duration(days: 30),
      cachePolicy: CachePolicy.forceCache,
      hitCacheOnErrorExcept: const [],
    );

    dev.log('[TileCache] initialized at $cachePath', name: 'TileCacheService');
  }

  static Future<void> clear() async {
    await _store.clean();
    dev.log('[TileCache] cache cleared', name: 'TileCacheService');
  }
}

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'schemas/cached_criminal_schema.dart';
import 'schemas/favorite_schema.dart';

part 'isar_service.g.dart';

@Riverpod(keepAlive: true)
Future<Isar> isarInstance(IsarInstanceRef ref) async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
    [FavoriteSchemaSchema, CachedCriminalSchemaSchema],
    directory: dir.path,
  );
}

class IsarService {
  IsarService(this._isar);

  final Isar _isar;

  // ─── Favorites ────────────────────────────────────────────────────────────

  Future<List<FavoriteSchema>> getAllFavorites() async {
    return _isar.favoriteSchemas.where().sortBySavedAtDesc().findAll();
  }

  Stream<List<FavoriteSchema>> watchFavorites() {
    return _isar.favoriteSchemas.where().sortBySavedAtDesc().watch(
          fireImmediately: true,
        );
  }

  Future<bool> isFavorite(String hash) async {
    return _isar.favoriteSchemas.where().hashEqualTo(hash).count().then(
          (c) => c > 0,
        );
  }

  Future<void> addFavorite(FavoriteSchema favorite) async {
    await _isar.writeTxn(() async {
      await _isar.favoriteSchemas.put(favorite);
    });
  }

  Future<void> removeFavorite(String hash) async {
    await _isar.writeTxn(() async {
      await _isar.favoriteSchemas.where().hashEqualTo(hash).deleteAll();
    });
  }

  // ─── Cache ────────────────────────────────────────────────────────────────

  Future<List<CachedCriminalSchema>> getCachedBySearchKey(
    String searchKey,
    int page,
    int pageSize,
  ) async {
    final offset = (page - 1) * pageSize;
    return _isar.cachedCriminalSchemas
        .filter()
        .searchKeyEqualTo(searchKey)
        .sortByCachedAtDesc()
        .offset(offset)
        .limit(pageSize)
        .findAll();
  }

  Future<void> cacheResults(
    List<CachedCriminalSchema> items,
    String searchKey,
  ) async {
    await _isar.writeTxn(() async {
      // Evict old entries for this search key
      await _isar.cachedCriminalSchemas
          .filter()
          .searchKeyEqualTo(searchKey)
          .deleteAll();
      await _isar.cachedCriminalSchemas.putAll(items);

      // Enforce global limit of 100
      final count = await _isar.cachedCriminalSchemas.count();
      if (count > 100) {
        final oldest = await _isar.cachedCriminalSchemas
            .where()
            .sortByCachedAt()
            .limit(count - 100)
            .findAll();
        final ids = oldest.map((e) => e.id).toList();
        await _isar.cachedCriminalSchemas.deleteAll(ids);
      }
    });
  }

  Future<bool> hasFreshCache(String searchKey) async {
    final item = await _isar.cachedCriminalSchemas
        .filter()
        .searchKeyEqualTo(searchKey)
        .findFirst();
    if (item == null) return false;
    final age = DateTime.now().difference(item.cachedAt);
    return age.inHours < 24;
  }
}

@Riverpod(keepAlive: true)
Future<IsarService> isarService(IsarServiceRef ref) async {
  final isar = await ref.watch(isarInstanceProvider.future);
  return IsarService(isar);
}

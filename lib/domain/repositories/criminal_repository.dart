import 'package:dartz/dartz.dart';

import '../../core/network/api_exception.dart';
import '../entities/criminal_summary.dart';
import '../entities/paginated_result.dart';
import '../entities/search_filters.dart';

abstract class CriminalRepository {
  Future<Either<ApiException, PaginatedResult<CriminalSummary>>> searchCriminals(
    SearchFilters filters,
  );

  Future<Either<ApiException, CriminalSummary>> getCriminalByHash(String hash);

  Future<List<CriminalSummary>> getFavorites();

  Stream<List<CriminalSummary>> watchFavorites();

  Future<bool> isFavorite(String hash);

  Future<void> addFavorite(CriminalSummary criminal);

  Future<void> removeFavorite(String hash);
}

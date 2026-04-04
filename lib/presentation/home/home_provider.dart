import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/criminal_summary.dart';
import '../../domain/entities/search_filters.dart';
import '../../domain/usecases/search_criminals_usecase.dart';

part 'home_provider.g.dart';

@riverpod
Future<List<CriminalSummary>> topWanted(TopWantedRef ref) async {
  final useCase = ref.watch(searchCriminalsUseCaseProvider);
  final result = await useCase(
    const SearchFilters(
      page: 1,
      size: 5,
      sortBy: 'montoRecompensa',
      direction: 'desc',
    ),
  );
  return result.fold(
    (_) => [],
    (paginated) => paginated.items,
  );
}

@riverpod
Future<HomeStats> homeStats(HomeStatsRef ref) async {
  final useCase = ref.watch(searchCriminalsUseCaseProvider);
  final result = await useCase(
    const SearchFilters(page: 1, size: 1),
  );
  return result.fold(
    (_) => const HomeStats(totalBuscados: 0, recompensaMaxima: 0),
    (paginated) => HomeStats(
      totalBuscados: paginated.totalElements,
      recompensaMaxima: paginated.items.isNotEmpty
          ? paginated.items
              .map((c) => c.montoRecompensa)
              .reduce((a, b) => a > b ? a : b)
          : 0,
    ),
  );
}

class HomeStats {
  const HomeStats({
    required this.totalBuscados,
    required this.recompensaMaxima,
  });

  final int totalBuscados;
  final double recompensaMaxima;
}

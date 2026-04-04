import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/criminal_summary.dart';
import '../../domain/entities/search_filters.dart';
import '../../domain/usecases/search_criminals_usecase.dart';

part 'map_provider.g.dart';

/// Agrupa criminales por departamento para el mapa de calor.
@riverpod
Future<Map<String, List<CriminalSummary>>> criminalsByDepartamento(
  CriminalsByDepartamentoRef ref, {
  String? idDelito,
}) async {
  final useCase = ref.watch(searchCriminalsUseCaseProvider);

  // Fetch up to 200 records for the map
  final result = await useCase(
    SearchFilters(
      page: 1,
      size: 200,
      sortBy: 'id',
      direction: 'desc',
      idDelito: idDelito,
    ),
  );

  return result.fold(
    (_) => {},
    (paginated) {
      final map = <String, List<CriminalSummary>>{};
      for (final c in paginated.items) {
        map.putIfAbsent(c.departamento, () => []).add(c);
      }
      return map;
    },
  );
}

@riverpod
class MapFilterNotifier extends _$MapFilterNotifier {
  @override
  String? build() => null;

  void setDelito(String? idDelito) => state = idDelito;
}
